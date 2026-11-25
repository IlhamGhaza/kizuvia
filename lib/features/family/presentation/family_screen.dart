import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/push/push_registrar.dart';
import 'package:kizuvia/core/supabase/supabase_config.dart';
import 'package:kizuvia/core/sync/sync_controller.dart';
import 'package:kizuvia/core/widgets/empty_state.dart';
import 'package:kizuvia/features/auth/data/auth_repository.dart';
import 'package:kizuvia/features/auth/domain/app_user.dart';
import 'package:kizuvia/features/family/data/family_repository.dart';
import 'package:kizuvia/features/family/data/family_service.dart';
import 'package:kizuvia/features/family/domain/family.dart';
import 'package:kizuvia/features/family/presentation/family_failure_text.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'family_screen.g.dart';

/// Members of the active family. Reloads after every successful sync.
@riverpod
Future<List<FamilyMember>> familyMembers(Ref ref, String familyId) async {
  ref.watch(syncControllerProvider.select((s) => s.lastSyncedAt));
  final r = await ref.watch(familyRepositoryProvider).members(familyId);
  return r.when(ok: (v) => v, err: (_) => throw StateError('members'));
}

/// Keluarga tab (T2.2, T2.3, T2.5): sign in, create/join, members, invites.
class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authUserProvider).value;
    final settings = ref.watch(settingsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.familyTitle)),
      body: user == null
          ? _SignedOut()
          : settings.familyId == null
          ? _NoFamily(user: user)
          : _FamilyDetail(user: user, familyId: settings.familyId!),
    );
  }
}

class _SignedOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: Icons.family_restroom_outlined,
      title: l10n.familyIntroTitle,
      body: SupabaseConfig.isReady
          ? l10n.familyIntroBody
          : '${l10n.accountUnavailable} (${SupabaseConfig.initError ?? (SupabaseConfig.isConfigured ? 'init' : 'config')})',
      actionLabel: SupabaseConfig.isReady ? l10n.signInAction : null,
      onAction: () => context.push('/login'),
    );
  }
}

class _NoFamily extends ConsumerStatefulWidget {
  const _NoFamily({required this.user});

  final AppUser user;

  @override
  ConsumerState<_NoFamily> createState() => _NoFamilyState();
}

class _NoFamilyState extends ConsumerState<_NoFamily> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  /// A new device of an existing account picks up its family automatically.
  Future<void> _restore() async {
    await ref.read(familyServiceProvider).restoreExisting();
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_checking) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(
          l10n.familyNoneTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.familyNoneBody),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: () => context.push('/family/create'),
          child: Text(l10n.createFamilyAction),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () => context.push('/family/join'),
          child: Text(l10n.joinFamilyAction),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextButton(
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          child: Text(l10n.signOutAction),
        ),
      ],
    );
  }
}

class _FamilyDetail extends ConsumerWidget {
  const _FamilyDetail({required this.user, required this.familyId});

  final AppUser user;
  final String familyId;

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    var role = FamilyRole.caregiver;
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.inviteRole),
          content: RadioGroup<String>(
            groupValue: role,
            onChanged: (v) => setState(() => role = v ?? role),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: FamilyRole.caregiver,
                  title: Text(l10n.roleCaregiver),
                ),
                RadioListTile<String>(
                  value: FamilyRole.patient,
                  title: Text(l10n.rolePatient),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, role),
              child: Text(l10n.inviteAction),
            ),
          ],
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    final r = await ref
        .read(familyRepositoryProvider)
        .createInvite(familyId, role: picked);
    if (!context.mounted) return;
    await r.when(
      ok: (code) => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.inviteCodeTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                code,
                style: Theme.of(ctx).textTheme.displaySmall
                    ?.copyWith(letterSpacing: 6),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.inviteCodeHint),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code));
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx)
                      .showSnackBar(SnackBar(content: Text(l10n.codeCopied)));
                }
              },
              child: Text(l10n.copyCode),
            ),
            FilledButton(
              onPressed: () => SharePlus.instance.share(
                ShareParams(text: l10n.inviteShareText(code)),
              ),
              child: Text(l10n.shareCode),
            ),
          ],
        ),
      ),
      err: (f) async => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(familyFailureText(l10n, f)))),
    );
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    required Future<void> Function() onYes,
  }) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    if (ok ?? false) await onYes();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final settings = ref.watch(settingsControllerProvider);
    final members = ref.watch(familyMembersProvider(familyId));
    final sync = ref.watch(syncControllerProvider);
    final repo = ref.read(familyRepositoryProvider);
    final me = members.value?.where((m) => m.userId == user.id).firstOrNull;
    final isOwner = me?.role == FamilyRole.owner;

    void refresh() => ref.invalidate(familyMembersProvider(familyId));
    void show(BuildContext c, String msg) =>
        ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));

    final syncLine = sync.offline
        ? l10n.syncStatusOffline
        : sync.pending > 0
        ? l10n.syncStatusPending(sync.pending)
        : l10n.syncStatusSynced;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(settings.familyName ?? '', style: text.headlineSmall),
        Text(
          l10n.signedInAs(user.email ?? ''),
          style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: ListTile(
            leading: Icon(
              sync.offline ? Icons.cloud_off : Icons.cloud_done_outlined,
            ),
            title: Text(syncLine),
            trailing: TextButton(
              onPressed: () =>
                  ref.read(syncControllerProvider.notifier).syncNow(),
              child: Text(l10n.syncNow),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(child: Text(l10n.membersTitle, style: text.titleMedium)),
            if (isOwner)
              FilledButton.icon(
                onPressed: () => _invite(context, ref),
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(l10n.inviteAction),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        members.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(l10n.loadError),
          ),
          data: (list) => Column(
            children: [
              for (final m in list)
                Card(
                  child: ListTile(
                    title: Text(
                      '${m.displayName ?? roleLabel(l10n, m.role)}'
                      '${m.userId == user.id ? ' ${l10n.youSuffix}' : ''}',
                    ),
                    subtitle: Text(roleLabel(l10n, m.role)),
                    trailing: isOwner && m.userId != user.id
                        ? PopupMenuButton<String>(
                            onSelected: (v) async {
                              final messenger = ScaffoldMessenger.of(context);
                              if (v == 'remove') {
                                await _confirm(
                                  context,
                                  title: l10n.removeMemberTitle,
                                  body: l10n.removeMemberBody,
                                  action: l10n.removeMember,
                                  onYes: () async {
                                    final r = await repo.removeMember(
                                      familyId,
                                      m.userId,
                                    );
                                    r.when(
                                      ok: (_) => refresh(),
                                      err: (f) => messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            familyFailureText(l10n, f),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                final r = await repo.setRole(
                                  familyId,
                                  m.userId,
                                  v,
                                );
                                r.when(
                                  ok: (_) => refresh(),
                                  err: (f) => messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(familyFailureText(l10n, f)),
                                    ),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              for (final role in [
                                FamilyRole.owner,
                                FamilyRole.caregiver,
                                FamilyRole.patient,
                              ])
                                if (role != m.role)
                                  PopupMenuItem(
                                    value: role,
                                    child: Text(
                                      '${l10n.changeRole}: '
                                      '${roleLabel(l10n, role)}',
                                    ),
                                  ),
                              PopupMenuItem(
                                value: 'remove',
                                child: Text(l10n.removeMember),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
        if (me != null)
          SwitchListTile(
            title: Text(l10n.notifyMissedLabel),
            value: me.notifyMissed,
            onChanged: (v) async {
              final r = await repo.setNotifyMissed(familyId, value: v);
              r.when(
                ok: (_) => refresh(),
                err: (f) => show(context, familyFailureText(l10n, f)),
              );
            },
          ),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton(
          onPressed: () => _confirm(
            context,
            title: l10n.leaveFamilyTitle,
            body: l10n.leaveFamilyBody,
            action: l10n.leaveFamily,
            onYes: () async {
              final messenger = ScaffoldMessenger.of(context);
              final r = await repo.removeMember(familyId, user.id);
              await r.when(
                ok: (_) =>
                    ref.read(settingsControllerProvider.notifier).clearFamily(),
                err: (f) async => messenger.showSnackBar(
                  SnackBar(content: Text(familyFailureText(l10n, f))),
                ),
              );
            },
          ),
          child: Text(l10n.leaveFamily),
        ),
        TextButton(
          onPressed: () async {
            await PushRegistrar.unregister();
            await ref.read(authRepositoryProvider).signOut();
            await ref.read(settingsControllerProvider.notifier).clearFamily();
          },
          child: Text(l10n.signOutAction),
        ),
      ],
    );
  }
}
