// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the set of found word keys (format: "row,col,direction").

@ProviderFor(FoundWordsNotifier)
final foundWordsProvider = FoundWordsNotifierProvider._();

/// Holds the set of found word keys (format: "row,col,direction").
final class FoundWordsNotifierProvider
    extends $NotifierProvider<FoundWordsNotifier, Set<String>> {
  /// Holds the set of found word keys (format: "row,col,direction").
  FoundWordsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foundWordsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foundWordsNotifierHash();

  @$internal
  @override
  FoundWordsNotifier create() => FoundWordsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$foundWordsNotifierHash() =>
    r'0d6fb8fdc1028b0ae17d137383f55c4731b699c5';

/// Holds the set of found word keys (format: "row,col,direction").

abstract class _$FoundWordsNotifier extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Holds cells that should flash (for word completion animation).

@ProviderFor(FlashingCellsNotifier)
final flashingCellsProvider = FlashingCellsNotifierProvider._();

/// Holds cells that should flash (for word completion animation).
final class FlashingCellsNotifierProvider
    extends $NotifierProvider<FlashingCellsNotifier, Set<CellKey>> {
  /// Holds cells that should flash (for word completion animation).
  FlashingCellsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flashingCellsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flashingCellsNotifierHash();

  @$internal
  @override
  FlashingCellsNotifier create() => FlashingCellsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<CellKey> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<CellKey>>(value),
    );
  }
}

String _$flashingCellsNotifierHash() =>
    r'0bbfebe4bc52ccfc68e24a918e14706a63043f25';

/// Holds cells that should flash (for word completion animation).

abstract class _$FlashingCellsNotifier extends $Notifier<Set<CellKey>> {
  Set<CellKey> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<CellKey>, Set<CellKey>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<CellKey>, Set<CellKey>>,
              Set<CellKey>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider family for whether a specific cell is currently flashing.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

@ProviderFor(cellFlashing)
final cellFlashingProvider = CellFlashingFamily._();

/// Provider family for whether a specific cell is currently flashing.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

final class CellFlashingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider family for whether a specific cell is currently flashing.
  /// Optimized: uses select() to only rebuild when this cell's membership changes.
  CellFlashingProvider._({
    required CellFlashingFamily super.from,
    required CellKey super.argument,
  }) : super(
         retry: null,
         name: r'cellFlashingProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cellFlashingHash();

  @override
  String toString() {
    return r'cellFlashingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as CellKey;
    return cellFlashing(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CellFlashingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cellFlashingHash() => r'4d27e524df34031e89c30f738f37c6d24de8a70b';

/// Provider family for whether a specific cell is currently flashing.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

final class CellFlashingFamily extends $Family
    with $FunctionalFamilyOverride<bool, CellKey> {
  CellFlashingFamily._()
    : super(
        retry: null,
        name: r'cellFlashingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Provider family for whether a specific cell is currently flashing.
  /// Optimized: uses select() to only rebuild when this cell's membership changes.

  CellFlashingProvider call(CellKey key) =>
      CellFlashingProvider._(argument: key, from: this);

  @override
  String toString() => r'cellFlashingProvider';
}

/// Holds cells that should flash red because they were cleared by the cleaner.

@ProviderFor(FlashingClearedCellsNotifier)
final flashingClearedCellsProvider = FlashingClearedCellsNotifierProvider._();

/// Holds cells that should flash red because they were cleared by the cleaner.
final class FlashingClearedCellsNotifierProvider
    extends $NotifierProvider<FlashingClearedCellsNotifier, Set<CellKey>> {
  /// Holds cells that should flash red because they were cleared by the cleaner.
  FlashingClearedCellsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flashingClearedCellsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flashingClearedCellsNotifierHash();

  @$internal
  @override
  FlashingClearedCellsNotifier create() => FlashingClearedCellsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<CellKey> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<CellKey>>(value),
    );
  }
}

String _$flashingClearedCellsNotifierHash() =>
    r'ff3141a82b080ac6ccc08cd3398411ab633a569d';

/// Holds cells that should flash red because they were cleared by the cleaner.

abstract class _$FlashingClearedCellsNotifier extends $Notifier<Set<CellKey>> {
  Set<CellKey> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<CellKey>, Set<CellKey>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<CellKey>, Set<CellKey>>,
              Set<CellKey>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider family for whether a specific cell is in the "cleared flash" set.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

@ProviderFor(cellClearedFlashing)
final cellClearedFlashingProvider = CellClearedFlashingFamily._();

/// Provider family for whether a specific cell is in the "cleared flash" set.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

final class CellClearedFlashingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider family for whether a specific cell is in the "cleared flash" set.
  /// Optimized: uses select() to only rebuild when this cell's membership changes.
  CellClearedFlashingProvider._({
    required CellClearedFlashingFamily super.from,
    required CellKey super.argument,
  }) : super(
         retry: null,
         name: r'cellClearedFlashingProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cellClearedFlashingHash();

  @override
  String toString() {
    return r'cellClearedFlashingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as CellKey;
    return cellClearedFlashing(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CellClearedFlashingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cellClearedFlashingHash() =>
    r'948bc3990cd0f23b610987bf2b4037189505f9e8';

/// Provider family for whether a specific cell is in the "cleared flash" set.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

final class CellClearedFlashingFamily extends $Family
    with $FunctionalFamilyOverride<bool, CellKey> {
  CellClearedFlashingFamily._()
    : super(
        retry: null,
        name: r'cellClearedFlashingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Provider family for whether a specific cell is in the "cleared flash" set.
  /// Optimized: uses select() to only rebuild when this cell's membership changes.

  CellClearedFlashingProvider call(CellKey key) =>
      CellClearedFlashingProvider._(argument: key, from: this);

  @override
  String toString() => r'cellClearedFlashingProvider';
}

/// Holds cells that are locked (found words cannot be edited).

@ProviderFor(LockedCellsNotifier)
final lockedCellsProvider = LockedCellsNotifierProvider._();

/// Holds cells that are locked (found words cannot be edited).
final class LockedCellsNotifierProvider
    extends $NotifierProvider<LockedCellsNotifier, Set<CellKey>> {
  /// Holds cells that are locked (found words cannot be edited).
  LockedCellsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockedCellsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockedCellsNotifierHash();

  @$internal
  @override
  LockedCellsNotifier create() => LockedCellsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<CellKey> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<CellKey>>(value),
    );
  }
}

String _$lockedCellsNotifierHash() =>
    r'10f3129b5a333b67062c70ab36ba3222203f9b60';

/// Holds cells that are locked (found words cannot be edited).

abstract class _$LockedCellsNotifier extends $Notifier<Set<CellKey>> {
  Set<CellKey> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<CellKey>, Set<CellKey>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<CellKey>, Set<CellKey>>,
              Set<CellKey>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
