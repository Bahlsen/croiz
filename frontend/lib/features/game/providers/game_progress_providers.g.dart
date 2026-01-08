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
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
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
    r'4a453130f542ef57a53037dd4a7aafedfbf5bb42';

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
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
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
    r'bbcd53004e70bfe6e5f32fc87cd708e138ff16b7';

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

  static final $allTransitiveDependencies0 = flashingCellsProvider;

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

String _$cellFlashingHash() => r'10b60d6887789d35c2b4907f2402efc4f63e3c06';

/// Provider family for whether a specific cell is currently flashing.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

final class CellFlashingFamily extends $Family
    with $FunctionalFamilyOverride<bool, CellKey> {
  CellFlashingFamily._()
    : super(
        retry: null,
        name: r'cellFlashingProvider',
        dependencies: <ProviderOrFamily>[flashingCellsProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          CellFlashingProvider.$allTransitiveDependencies0,
        ],
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
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
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
    r'22e3eea6e160c33eb91b4776f444a9c00a1b7100';

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

  static final $allTransitiveDependencies0 = flashingClearedCellsProvider;

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
    r'9adfb7abace2c0786f61d0a0e7a65c835a418fd2';

/// Provider family for whether a specific cell is in the "cleared flash" set.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

final class CellClearedFlashingFamily extends $Family
    with $FunctionalFamilyOverride<bool, CellKey> {
  CellClearedFlashingFamily._()
    : super(
        retry: null,
        name: r'cellClearedFlashingProvider',
        dependencies: <ProviderOrFamily>[flashingClearedCellsProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          CellClearedFlashingProvider.$allTransitiveDependencies0,
        ],
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
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
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
    r'b94132fee6fc40a82e62a48b9bf3d2968877c6bf';

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

/// Holds cells that should flash for REVEAL animation.

@ProviderFor(FlashingRevealedCellsNotifier)
final flashingRevealedCellsProvider = FlashingRevealedCellsNotifierProvider._();

/// Holds cells that should flash for REVEAL animation.
final class FlashingRevealedCellsNotifierProvider
    extends $NotifierProvider<FlashingRevealedCellsNotifier, Set<CellKey>> {
  /// Holds cells that should flash for REVEAL animation.
  FlashingRevealedCellsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flashingRevealedCellsProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
      );

  @override
  String debugGetCreateSourceHash() => _$flashingRevealedCellsNotifierHash();

  @$internal
  @override
  FlashingRevealedCellsNotifier create() => FlashingRevealedCellsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<CellKey> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<CellKey>>(value),
    );
  }
}

String _$flashingRevealedCellsNotifierHash() =>
    r'af4dbbf913775ad872170e9f54ce604d8d92036f';

/// Holds cells that should flash for REVEAL animation.

abstract class _$FlashingRevealedCellsNotifier extends $Notifier<Set<CellKey>> {
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

/// Provider family for whether a specific cell is currently flashing for reveal.

@ProviderFor(cellRevealedFlashing)
final cellRevealedFlashingProvider = CellRevealedFlashingFamily._();

/// Provider family for whether a specific cell is currently flashing for reveal.

final class CellRevealedFlashingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider family for whether a specific cell is currently flashing for reveal.
  CellRevealedFlashingProvider._({
    required CellRevealedFlashingFamily super.from,
    required CellKey super.argument,
  }) : super(
         retry: null,
         name: r'cellRevealedFlashingProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = flashingRevealedCellsProvider;

  @override
  String debugGetCreateSourceHash() => _$cellRevealedFlashingHash();

  @override
  String toString() {
    return r'cellRevealedFlashingProvider'
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
    return cellRevealedFlashing(ref, argument);
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
    return other is CellRevealedFlashingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cellRevealedFlashingHash() =>
    r'ed3e2983448e30dcbb1f24960ceef052e8974ccd';

/// Provider family for whether a specific cell is currently flashing for reveal.

final class CellRevealedFlashingFamily extends $Family
    with $FunctionalFamilyOverride<bool, CellKey> {
  CellRevealedFlashingFamily._()
    : super(
        retry: null,
        name: r'cellRevealedFlashingProvider',
        dependencies: <ProviderOrFamily>[flashingRevealedCellsProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          CellRevealedFlashingProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: false,
      );

  /// Provider family for whether a specific cell is currently flashing for reveal.

  CellRevealedFlashingProvider call(CellKey key) =>
      CellRevealedFlashingProvider._(argument: key, from: this);

  @override
  String toString() => r'cellRevealedFlashingProvider';
}
