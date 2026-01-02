// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Index of entries by cell for fast lookups.
/// Maps a CellKey to the list of entries (across/down) that include it.

@ProviderFor(cellEntriesIndex)
final cellEntriesIndexProvider = CellEntriesIndexProvider._();

/// Index of entries by cell for fast lookups.
/// Maps a CellKey to the list of entries (across/down) that include it.

final class CellEntriesIndexProvider
    extends
        $FunctionalProvider<
          Map<CellKey, List<PuzzleEntryData>>,
          Map<CellKey, List<PuzzleEntryData>>,
          Map<CellKey, List<PuzzleEntryData>>
        >
    with $Provider<Map<CellKey, List<PuzzleEntryData>>> {
  /// Index of entries by cell for fast lookups.
  /// Maps a CellKey to the list of entries (across/down) that include it.
  CellEntriesIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cellEntriesIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cellEntriesIndexHash();

  @$internal
  @override
  $ProviderElement<Map<CellKey, List<PuzzleEntryData>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<CellKey, List<PuzzleEntryData>> create(Ref ref) {
    return cellEntriesIndex(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<CellKey, List<PuzzleEntryData>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<CellKey, List<PuzzleEntryData>>>(
        value,
      ),
    );
  }
}

String _$cellEntriesIndexHash() => r'40b56b56adfde8bdb2a2308a183c5cfe4a5d00b0';

/// Pre-sorted across entries for fast navigation.
/// Computed once when entries change, not on every keystroke.

@ProviderFor(sortedAcrossEntries)
final sortedAcrossEntriesProvider = SortedAcrossEntriesProvider._();

/// Pre-sorted across entries for fast navigation.
/// Computed once when entries change, not on every keystroke.

final class SortedAcrossEntriesProvider
    extends
        $FunctionalProvider<
          List<PuzzleEntryData>,
          List<PuzzleEntryData>,
          List<PuzzleEntryData>
        >
    with $Provider<List<PuzzleEntryData>> {
  /// Pre-sorted across entries for fast navigation.
  /// Computed once when entries change, not on every keystroke.
  SortedAcrossEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortedAcrossEntriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortedAcrossEntriesHash();

  @$internal
  @override
  $ProviderElement<List<PuzzleEntryData>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PuzzleEntryData> create(Ref ref) {
    return sortedAcrossEntries(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PuzzleEntryData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PuzzleEntryData>>(value),
    );
  }
}

String _$sortedAcrossEntriesHash() =>
    r'451eed20356b258b5805da97068d61295921ff43';

/// Pre-sorted down entries for fast navigation.
/// Computed once when entries change, not on every keystroke.

@ProviderFor(sortedDownEntries)
final sortedDownEntriesProvider = SortedDownEntriesProvider._();

/// Pre-sorted down entries for fast navigation.
/// Computed once when entries change, not on every keystroke.

final class SortedDownEntriesProvider
    extends
        $FunctionalProvider<
          List<PuzzleEntryData>,
          List<PuzzleEntryData>,
          List<PuzzleEntryData>
        >
    with $Provider<List<PuzzleEntryData>> {
  /// Pre-sorted down entries for fast navigation.
  /// Computed once when entries change, not on every keystroke.
  SortedDownEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortedDownEntriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortedDownEntriesHash();

  @$internal
  @override
  $ProviderElement<List<PuzzleEntryData>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PuzzleEntryData> create(Ref ref) {
    return sortedDownEntries(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PuzzleEntryData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PuzzleEntryData>>(value),
    );
  }
}

String _$sortedDownEntriesHash() => r'd0d2c24d7731753b75cbdf5375375248d605171a';

/// Precomputed clue numbers map for quick per-cell lookup.
/// Uses CellKey for efficient hashability.

@ProviderFor(clueNumbers)
final clueNumbersProvider = ClueNumbersProvider._();

/// Precomputed clue numbers map for quick per-cell lookup.
/// Uses CellKey for efficient hashability.

final class ClueNumbersProvider
    extends
        $FunctionalProvider<
          Map<CellKey, int>,
          Map<CellKey, int>,
          Map<CellKey, int>
        >
    with $Provider<Map<CellKey, int>> {
  /// Precomputed clue numbers map for quick per-cell lookup.
  /// Uses CellKey for efficient hashability.
  ClueNumbersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clueNumbersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clueNumbersHash();

  @$internal
  @override
  $ProviderElement<Map<CellKey, int>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<CellKey, int> create(Ref ref) {
    return clueNumbers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<CellKey, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<CellKey, int>>(value),
    );
  }
}

String _$clueNumbersHash() => r'593c87eb2087531291b0cafc928cd1486a279147';

/// Provider family exposing a single cell's value. Widgets should watch
/// `cellValueProvider(CellKey(r, c))` to rebuild only when that cell's letter
/// changes, avoiding large grid rebuilds.
/// Uses CellKey for efficient hashability (unlike `List<int>`).

@ProviderFor(cellValue)
final cellValueProvider = CellValueFamily._();

/// Provider family exposing a single cell's value. Widgets should watch
/// `cellValueProvider(CellKey(r, c))` to rebuild only when that cell's letter
/// changes, avoiding large grid rebuilds.
/// Uses CellKey for efficient hashability (unlike `List<int>`).

final class CellValueProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Provider family exposing a single cell's value. Widgets should watch
  /// `cellValueProvider(CellKey(r, c))` to rebuild only when that cell's letter
  /// changes, avoiding large grid rebuilds.
  /// Uses CellKey for efficient hashability (unlike `List<int>`).
  CellValueProvider._({
    required CellValueFamily super.from,
    required CellKey super.argument,
  }) : super(
         retry: null,
         name: r'cellValueProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cellValueHash();

  @override
  String toString() {
    return r'cellValueProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as CellKey;
    return cellValue(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CellValueProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cellValueHash() => r'61c02b26dd3af7478e03d657bf043b1134968b29';

/// Provider family exposing a single cell's value. Widgets should watch
/// `cellValueProvider(CellKey(r, c))` to rebuild only when that cell's letter
/// changes, avoiding large grid rebuilds.
/// Uses CellKey for efficient hashability (unlike `List<int>`).

final class CellValueFamily extends $Family
    with $FunctionalFamilyOverride<String?, CellKey> {
  CellValueFamily._()
    : super(
        retry: null,
        name: r'cellValueProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Provider family exposing a single cell's value. Widgets should watch
  /// `cellValueProvider(CellKey(r, c))` to rebuild only when that cell's letter
  /// changes, avoiding large grid rebuilds.
  /// Uses CellKey for efficient hashability (unlike `List<int>`).

  CellValueProvider call(CellKey key) =>
      CellValueProvider._(argument: key, from: this);

  @override
  String toString() => r'cellValueProvider';
}
