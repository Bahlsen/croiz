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
        dependencies: <ProviderOrFamily>[gameBoardProvider],
        $allTransitiveDependencies: <ProviderOrFamily>{
          CellEntriesIndexProvider.$allTransitiveDependencies0,
          CellEntriesIndexProvider.$allTransitiveDependencies1,
          CellEntriesIndexProvider.$allTransitiveDependencies2,
          CellEntriesIndexProvider.$allTransitiveDependencies3,
          CellEntriesIndexProvider.$allTransitiveDependencies4,
          CellEntriesIndexProvider.$allTransitiveDependencies5,
          CellEntriesIndexProvider.$allTransitiveDependencies6,
          CellEntriesIndexProvider.$allTransitiveDependencies7,
        },
      );

  static final $allTransitiveDependencies0 = gameBoardProvider;
  static final $allTransitiveDependencies1 =
      GameBoardNotifierProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      GameBoardNotifierProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies3 =
      GameBoardNotifierProvider.$allTransitiveDependencies2;
  static final $allTransitiveDependencies4 =
      GameBoardNotifierProvider.$allTransitiveDependencies3;
  static final $allTransitiveDependencies5 =
      GameBoardNotifierProvider.$allTransitiveDependencies4;
  static final $allTransitiveDependencies6 =
      GameBoardNotifierProvider.$allTransitiveDependencies5;
  static final $allTransitiveDependencies7 =
      GameBoardNotifierProvider.$allTransitiveDependencies6;

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

String _$cellEntriesIndexHash() => r'f78136b8ba32db1aa1f4cb84e722222c9bbb4b48';

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
        dependencies: <ProviderOrFamily>[gameBoardProvider],
        $allTransitiveDependencies: <ProviderOrFamily>{
          SortedAcrossEntriesProvider.$allTransitiveDependencies0,
          SortedAcrossEntriesProvider.$allTransitiveDependencies1,
          SortedAcrossEntriesProvider.$allTransitiveDependencies2,
          SortedAcrossEntriesProvider.$allTransitiveDependencies3,
          SortedAcrossEntriesProvider.$allTransitiveDependencies4,
          SortedAcrossEntriesProvider.$allTransitiveDependencies5,
          SortedAcrossEntriesProvider.$allTransitiveDependencies6,
          SortedAcrossEntriesProvider.$allTransitiveDependencies7,
        },
      );

  static final $allTransitiveDependencies0 = gameBoardProvider;
  static final $allTransitiveDependencies1 =
      GameBoardNotifierProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      GameBoardNotifierProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies3 =
      GameBoardNotifierProvider.$allTransitiveDependencies2;
  static final $allTransitiveDependencies4 =
      GameBoardNotifierProvider.$allTransitiveDependencies3;
  static final $allTransitiveDependencies5 =
      GameBoardNotifierProvider.$allTransitiveDependencies4;
  static final $allTransitiveDependencies6 =
      GameBoardNotifierProvider.$allTransitiveDependencies5;
  static final $allTransitiveDependencies7 =
      GameBoardNotifierProvider.$allTransitiveDependencies6;

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
    r'a5bb38df35ac8fdac03674347c1c5d0141b0354d';

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
        dependencies: <ProviderOrFamily>[gameBoardProvider],
        $allTransitiveDependencies: <ProviderOrFamily>{
          SortedDownEntriesProvider.$allTransitiveDependencies0,
          SortedDownEntriesProvider.$allTransitiveDependencies1,
          SortedDownEntriesProvider.$allTransitiveDependencies2,
          SortedDownEntriesProvider.$allTransitiveDependencies3,
          SortedDownEntriesProvider.$allTransitiveDependencies4,
          SortedDownEntriesProvider.$allTransitiveDependencies5,
          SortedDownEntriesProvider.$allTransitiveDependencies6,
          SortedDownEntriesProvider.$allTransitiveDependencies7,
        },
      );

  static final $allTransitiveDependencies0 = gameBoardProvider;
  static final $allTransitiveDependencies1 =
      GameBoardNotifierProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      GameBoardNotifierProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies3 =
      GameBoardNotifierProvider.$allTransitiveDependencies2;
  static final $allTransitiveDependencies4 =
      GameBoardNotifierProvider.$allTransitiveDependencies3;
  static final $allTransitiveDependencies5 =
      GameBoardNotifierProvider.$allTransitiveDependencies4;
  static final $allTransitiveDependencies6 =
      GameBoardNotifierProvider.$allTransitiveDependencies5;
  static final $allTransitiveDependencies7 =
      GameBoardNotifierProvider.$allTransitiveDependencies6;

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

String _$sortedDownEntriesHash() => r'b8c4453ddc5841b70d6be4fc6a064535cecb2a66';

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
        dependencies: <ProviderOrFamily>[gameBoardProvider],
        $allTransitiveDependencies: <ProviderOrFamily>{
          ClueNumbersProvider.$allTransitiveDependencies0,
          ClueNumbersProvider.$allTransitiveDependencies1,
          ClueNumbersProvider.$allTransitiveDependencies2,
          ClueNumbersProvider.$allTransitiveDependencies3,
          ClueNumbersProvider.$allTransitiveDependencies4,
          ClueNumbersProvider.$allTransitiveDependencies5,
          ClueNumbersProvider.$allTransitiveDependencies6,
          ClueNumbersProvider.$allTransitiveDependencies7,
        },
      );

  static final $allTransitiveDependencies0 = gameBoardProvider;
  static final $allTransitiveDependencies1 =
      GameBoardNotifierProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      GameBoardNotifierProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies3 =
      GameBoardNotifierProvider.$allTransitiveDependencies2;
  static final $allTransitiveDependencies4 =
      GameBoardNotifierProvider.$allTransitiveDependencies3;
  static final $allTransitiveDependencies5 =
      GameBoardNotifierProvider.$allTransitiveDependencies4;
  static final $allTransitiveDependencies6 =
      GameBoardNotifierProvider.$allTransitiveDependencies5;
  static final $allTransitiveDependencies7 =
      GameBoardNotifierProvider.$allTransitiveDependencies6;

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

String _$clueNumbersHash() => r'd46a26a27189f1da26204c3a86ad7b4540dbd9bf';

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

  static final $allTransitiveDependencies0 = gameBoardProvider;
  static final $allTransitiveDependencies1 =
      GameBoardNotifierProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      GameBoardNotifierProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies3 =
      GameBoardNotifierProvider.$allTransitiveDependencies2;
  static final $allTransitiveDependencies4 =
      GameBoardNotifierProvider.$allTransitiveDependencies3;
  static final $allTransitiveDependencies5 =
      GameBoardNotifierProvider.$allTransitiveDependencies4;
  static final $allTransitiveDependencies6 =
      GameBoardNotifierProvider.$allTransitiveDependencies5;
  static final $allTransitiveDependencies7 =
      GameBoardNotifierProvider.$allTransitiveDependencies6;

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

String _$cellValueHash() => r'945f1c4e873e4cdf42be7b216478c24166253f55';

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
        dependencies: <ProviderOrFamily>[gameBoardProvider],
        $allTransitiveDependencies: <ProviderOrFamily>{
          CellValueProvider.$allTransitiveDependencies0,
          CellValueProvider.$allTransitiveDependencies1,
          CellValueProvider.$allTransitiveDependencies2,
          CellValueProvider.$allTransitiveDependencies3,
          CellValueProvider.$allTransitiveDependencies4,
          CellValueProvider.$allTransitiveDependencies5,
          CellValueProvider.$allTransitiveDependencies6,
          CellValueProvider.$allTransitiveDependencies7,
        },
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
