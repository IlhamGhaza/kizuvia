// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Members of the active family. Reloads after every successful sync.

@ProviderFor(familyMembers)
final familyMembersProvider = FamilyMembersFamily._();

/// Members of the active family. Reloads after every successful sync.

final class FamilyMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FamilyMember>>,
          List<FamilyMember>,
          FutureOr<List<FamilyMember>>
        >
    with
        $FutureModifier<List<FamilyMember>>,
        $FutureProvider<List<FamilyMember>> {
  /// Members of the active family. Reloads after every successful sync.
  FamilyMembersProvider._({
    required FamilyMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'familyMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$familyMembersHash();

  @override
  String toString() {
    return r'familyMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FamilyMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FamilyMember>> create(Ref ref) {
    final argument = this.argument as String;
    return familyMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FamilyMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$familyMembersHash() => r'6c8de12e5d5807a4804a9d9f4d388efddb83dd6b';

/// Members of the active family. Reloads after every successful sync.

final class FamilyMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FamilyMember>>, String> {
  FamilyMembersFamily._()
    : super(
        retry: null,
        name: r'familyMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Members of the active family. Reloads after every successful sync.

  FamilyMembersProvider call(String familyId) =>
      FamilyMembersProvider._(argument: familyId, from: this);

  @override
  String toString() => r'familyMembersProvider';
}
