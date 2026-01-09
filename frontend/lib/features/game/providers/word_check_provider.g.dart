// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_check_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for answer validation service.

@ProviderFor(wordCheckService)
final wordCheckServiceProvider = WordCheckServiceProvider._();

/// Provider for answer validation service.

final class WordCheckServiceProvider
    extends
        $FunctionalProvider<
          WordCheckService,
          WordCheckService,
          WordCheckService
        >
    with $Provider<WordCheckService> {
  /// Provider for answer validation service.
  WordCheckServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordCheckServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordCheckServiceHash();

  @$internal
  @override
  $ProviderElement<WordCheckService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WordCheckService create(Ref ref) {
    return wordCheckService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordCheckService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordCheckService>(value),
    );
  }
}

String _$wordCheckServiceHash() => r'7719e32e71f604e8a4bb4488feb056c12275e766';
