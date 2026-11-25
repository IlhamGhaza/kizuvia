import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/errors/app_failure.dart';
import 'package:kizuvia/core/errors/result.dart';
import 'package:kizuvia/core/sync/account_migrator.dart';
import 'package:kizuvia/core/utils/device_l10n.dart';
import 'package:kizuvia/features/auth/data/auth_repository.dart';
import 'package:kizuvia/features/family/data/family_repository.dart';
import 'package:kizuvia/features/family/domain/family.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'family_service.g.dart';

/// Create / join a family and attach the offline data to it (T2.2, T2.3).
class FamilyService {
  FamilyService({
    required this.repo,
    required this.migrator,
    required this.onAttached,
  });

  final FamilyRepository repo;
  final AccountMigrator migrator;

  /// Persists the active family (id, name) on the device.
  final Future<void> Function(String id, String name) onAttached;

  Future<Result<String, AppFailure>> create(
    String name, {
    String? displayName,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Result.err(ValidationFailure('name required'));
    }
    final r = await repo.createFamily(trimmed, displayName: displayName);
    return _attach(r, fallbackName: trimmed);
  }

  Future<Result<String, AppFailure>> join(
    String code, {
    String? displayName,
  }) async {
    final r = await repo.acceptInvite(code, displayName: displayName);
    return _attach(r);
  }

  /// Signed in on a new device: pick up the family the account already has.
  /// Returns the family id, or null if the account has no family yet.
  Future<Result<String?, AppFailure>> restoreExisting() async {
    final r = await repo.myFamilies();
    if (r is Err<List<FamilySummary>, AppFailure>) {
      return Result.err(r.failure);
    }
    final list = r.valueOrNull ?? const <FamilySummary>[];
    if (list.isEmpty) return const Result.ok(null);
    final f = list.first;
    await migrator.attachToFamily(f.id);
    await onAttached(f.id, f.name);
    return Result.ok(f.id);
  }

  Future<Result<String, AppFailure>> _attach(
    Result<String, AppFailure> created, {
    String? fallbackName,
  }) async {
    switch (created) {
      case Err<String, AppFailure>(:final failure):
        return Result.err(failure);
      case Ok<String, AppFailure>(:final value):
        var name = fallbackName;
        if (name == null) {
          final list = (await repo.myFamilies()).valueOrNull ?? const [];
          for (final f in list) {
            if (f.id == value) name = f.name;
          }
        }
        await migrator.attachToFamily(value);
        await onAttached(value, name ?? '');
        return Result.ok(value);
    }
  }
}

@Riverpod(keepAlive: true)
FamilyService familyService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return FamilyService(
    repo: ref.watch(familyRepositoryProvider),
    migrator: AccountMigrator(db, ref.watch(clockProvider)),
    onAttached: (id, name) =>
        ref.read(settingsControllerProvider.notifier).setFamily(id, name),
  );
}

/// Signed in without a family on this device: pick up the account's existing
/// family; if it has none but the phone holds data, create a personal family
/// so that data is backed up to the server. With no local data nothing is
/// created, so the user can still join someone else's family by code.
final autoFamilyProvider = Provider<void>((ref) {
  var running = false;
  Future<void> run() async {
    if (running) return;
    final user = ref.read(authUserProvider).value;
    if (user == null || ref.read(settingsControllerProvider).familyId != null) {
      return;
    }
    running = true;
    try {
      final service = ref.read(familyServiceProvider);
      final restored = await service.restoreExisting();
      if (restored is! Ok<String?, AppFailure> || restored.value != null) {
        return;
      }
      final hasData = await ref
          .read(accountMigratorProvider)
          .localPatientCount();
      if (hasData > 0) {
        await service.create(deviceL10n().familyDefaultName);
      }
    } on Object {
      // Offline or server error: stays local, retried on next sign-in/launch.
    } finally {
      running = false;
    }
  }

  ref.listen(authUserProvider, (_, _) => run(), fireImmediately: true);
});

@Riverpod(keepAlive: true)
AccountMigrator accountMigrator(Ref ref) =>
    AccountMigrator(ref.watch(appDatabaseProvider), ref.watch(clockProvider));
