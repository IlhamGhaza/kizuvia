// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_scanner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(labelParser)
final labelParserProvider = LabelParserProvider._();

final class LabelParserProvider
    extends
        $FunctionalProvider<
          AsyncValue<LabelParser>,
          LabelParser,
          FutureOr<LabelParser>
        >
    with $FutureModifier<LabelParser>, $FutureProvider<LabelParser> {
  LabelParserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labelParserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labelParserHash();

  @$internal
  @override
  $FutureProviderElement<LabelParser> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LabelParser> create(Ref ref) {
    return labelParser(ref);
  }
}

String _$labelParserHash() => r'b8bc13241e5df7eb8e63e2d34ba5991a20a9a3f5';

@ProviderFor(labelScanner)
final labelScannerProvider = LabelScannerProvider._();

final class LabelScannerProvider
    extends
        $FunctionalProvider<
          AsyncValue<LabelScanner>,
          LabelScanner,
          FutureOr<LabelScanner>
        >
    with $FutureModifier<LabelScanner>, $FutureProvider<LabelScanner> {
  LabelScannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labelScannerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labelScannerHash();

  @$internal
  @override
  $FutureProviderElement<LabelScanner> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LabelScanner> create(Ref ref) {
    return labelScanner(ref);
  }
}

String _$labelScannerHash() => r'07fffe457be3571d78a4ce2d5cb2df6b51ed319b';
