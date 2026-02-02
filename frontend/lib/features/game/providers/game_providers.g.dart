// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Set of cells belonging to the currently selected word.
/// Optimized: only depends on selection, direction, and blackCells structure.

@ProviderFor(selectedWordCells)
final selectedWordCellsProvider = SelectedWordCellsProvider._();

/// Set of cells belonging to the currently selected word.
/// Optimized: only depends on selection, direction, and blackCells structure.

final class SelectedWordCellsProvider
    extends $FunctionalProvider<Set<CellKey>, Set<CellKey>, Set<CellKey>>
    with $Provider<Set<CellKey>> {
  /// Set of cells belonging to the currently selected word.
  /// Optimized: only depends on selection, direction, and blackCells structure.
  SelectedWordCellsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedWordCellsProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[
          selectedCellProvider,
          wordDirectionProvider,
          gameBoardProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>{
          SelectedWordCellsProvider.$allTransitiveDependencies0,
          SelectedWordCellsProvider.$allTransitiveDependencies1,
          SelectedWordCellsProvider.$allTransitiveDependencies2,
          SelectedWordCellsProvider.$allTransitiveDependencies3,
          SelectedWordCellsProvider.$allTransitiveDependencies4,
          SelectedWordCellsProvider.$allTransitiveDependencies5,
          SelectedWordCellsProvider.$allTransitiveDependencies6,
          SelectedWordCellsProvider.$allTransitiveDependencies7,
          SelectedWordCellsProvider.$allTransitiveDependencies8,
          SelectedWordCellsProvider.$allTransitiveDependencies9,
          SelectedWordCellsProvider.$allTransitiveDependencies10,
          SelectedWordCellsProvider.$allTransitiveDependencies11,
          SelectedWordCellsProvider.$allTransitiveDependencies12,
          SelectedWordCellsProvider.$allTransitiveDependencies13,
          SelectedWordCellsProvider.$allTransitiveDependencies14,
          SelectedWordCellsProvider.$allTransitiveDependencies15,
          SelectedWordCellsProvider.$allTransitiveDependencies16,
          SelectedWordCellsProvider.$allTransitiveDependencies17,
          SelectedWordCellsProvider.$allTransitiveDependencies18,
          SelectedWordCellsProvider.$allTransitiveDependencies19,
          SelectedWordCellsProvider.$allTransitiveDependencies20,
          SelectedWordCellsProvider.$allTransitiveDependencies21,
          SelectedWordCellsProvider.$allTransitiveDependencies22,
          SelectedWordCellsProvider.$allTransitiveDependencies23,
          SelectedWordCellsProvider.$allTransitiveDependencies24,
          SelectedWordCellsProvider.$allTransitiveDependencies25,
          SelectedWordCellsProvider.$allTransitiveDependencies26,
        },
      );

  static final $allTransitiveDependencies0 = selectedCellProvider;
  static final $allTransitiveDependencies1 = wordDirectionProvider;
  static final $allTransitiveDependencies2 = gameBoardProvider;
  static final $allTransitiveDependencies3 =
      GameBoardNotifierProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies4 =
      GameBoardNotifierProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies5 =
      GameBoardNotifierProvider.$allTransitiveDependencies2;
  static final $allTransitiveDependencies6 =
      GameBoardNotifierProvider.$allTransitiveDependencies3;
  static final $allTransitiveDependencies7 =
      GameBoardNotifierProvider.$allTransitiveDependencies4;
  static final $allTransitiveDependencies8 =
      GameBoardNotifierProvider.$allTransitiveDependencies5;
  static final $allTransitiveDependencies9 =
      GameBoardNotifierProvider.$allTransitiveDependencies6;
  static final $allTransitiveDependencies10 =
      GameBoardNotifierProvider.$allTransitiveDependencies7;
  static final $allTransitiveDependencies11 =
      GameBoardNotifierProvider.$allTransitiveDependencies8;
  static final $allTransitiveDependencies12 =
      GameBoardNotifierProvider.$allTransitiveDependencies9;
  static final $allTransitiveDependencies13 =
      GameBoardNotifierProvider.$allTransitiveDependencies10;
  static final $allTransitiveDependencies14 =
      GameBoardNotifierProvider.$allTransitiveDependencies11;
  static final $allTransitiveDependencies15 =
      GameBoardNotifierProvider.$allTransitiveDependencies12;
  static final $allTransitiveDependencies16 =
      GameBoardNotifierProvider.$allTransitiveDependencies13;
  static final $allTransitiveDependencies17 =
      GameBoardNotifierProvider.$allTransitiveDependencies14;
  static final $allTransitiveDependencies18 =
      GameBoardNotifierProvider.$allTransitiveDependencies16;
  static final $allTransitiveDependencies19 =
      GameBoardNotifierProvider.$allTransitiveDependencies17;
  static final $allTransitiveDependencies20 =
      GameBoardNotifierProvider.$allTransitiveDependencies18;
  static final $allTransitiveDependencies21 =
      GameBoardNotifierProvider.$allTransitiveDependencies19;
  static final $allTransitiveDependencies22 =
      GameBoardNotifierProvider.$allTransitiveDependencies20;
  static final $allTransitiveDependencies23 =
      GameBoardNotifierProvider.$allTransitiveDependencies21;
  static final $allTransitiveDependencies24 =
      GameBoardNotifierProvider.$allTransitiveDependencies22;
  static final $allTransitiveDependencies25 =
      GameBoardNotifierProvider.$allTransitiveDependencies23;
  static final $allTransitiveDependencies26 =
      GameBoardNotifierProvider.$allTransitiveDependencies24;

  @override
  String debugGetCreateSourceHash() => _$selectedWordCellsHash();

  @$internal
  @override
  $ProviderElement<Set<CellKey>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<CellKey> create(Ref ref) {
    return selectedWordCells(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<CellKey> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<CellKey>>(value),
    );
  }
}

String _$selectedWordCellsHash() => r'9358f18a781d35f6631e893c7996306ae1ebc8ce';

/// Provider family that answers whether a specific cell is part of the
/// currently selected word.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

@ProviderFor(cellInSelectedWord)
final cellInSelectedWordProvider = CellInSelectedWordFamily._();

/// Provider family that answers whether a specific cell is part of the
/// currently selected word.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

final class CellInSelectedWordProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider family that answers whether a specific cell is part of the
  /// currently selected word.
  /// Optimized: uses select() to only rebuild when this cell's membership changes.
  CellInSelectedWordProvider._({
    required CellInSelectedWordFamily super.from,
    required CellKey super.argument,
  }) : super(
         retry: null,
         name: r'cellInSelectedWordProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = selectedWordCellsProvider;
  static final $allTransitiveDependencies1 =
      SelectedWordCellsProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      SelectedWordCellsProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies3 =
      SelectedWordCellsProvider.$allTransitiveDependencies2;
  static final $allTransitiveDependencies4 =
      SelectedWordCellsProvider.$allTransitiveDependencies3;
  static final $allTransitiveDependencies5 =
      SelectedWordCellsProvider.$allTransitiveDependencies4;
  static final $allTransitiveDependencies6 =
      SelectedWordCellsProvider.$allTransitiveDependencies5;
  static final $allTransitiveDependencies7 =
      SelectedWordCellsProvider.$allTransitiveDependencies6;
  static final $allTransitiveDependencies8 =
      SelectedWordCellsProvider.$allTransitiveDependencies7;
  static final $allTransitiveDependencies9 =
      SelectedWordCellsProvider.$allTransitiveDependencies8;
  static final $allTransitiveDependencies10 =
      SelectedWordCellsProvider.$allTransitiveDependencies9;
  static final $allTransitiveDependencies11 =
      SelectedWordCellsProvider.$allTransitiveDependencies10;
  static final $allTransitiveDependencies12 =
      SelectedWordCellsProvider.$allTransitiveDependencies11;
  static final $allTransitiveDependencies13 =
      SelectedWordCellsProvider.$allTransitiveDependencies12;
  static final $allTransitiveDependencies14 =
      SelectedWordCellsProvider.$allTransitiveDependencies13;
  static final $allTransitiveDependencies15 =
      SelectedWordCellsProvider.$allTransitiveDependencies14;
  static final $allTransitiveDependencies16 =
      SelectedWordCellsProvider.$allTransitiveDependencies15;
  static final $allTransitiveDependencies17 =
      SelectedWordCellsProvider.$allTransitiveDependencies16;
  static final $allTransitiveDependencies18 =
      SelectedWordCellsProvider.$allTransitiveDependencies17;
  static final $allTransitiveDependencies19 =
      SelectedWordCellsProvider.$allTransitiveDependencies18;
  static final $allTransitiveDependencies20 =
      SelectedWordCellsProvider.$allTransitiveDependencies19;
  static final $allTransitiveDependencies21 =
      SelectedWordCellsProvider.$allTransitiveDependencies20;
  static final $allTransitiveDependencies22 =
      SelectedWordCellsProvider.$allTransitiveDependencies21;
  static final $allTransitiveDependencies23 =
      SelectedWordCellsProvider.$allTransitiveDependencies22;
  static final $allTransitiveDependencies24 =
      SelectedWordCellsProvider.$allTransitiveDependencies23;
  static final $allTransitiveDependencies25 =
      SelectedWordCellsProvider.$allTransitiveDependencies24;
  static final $allTransitiveDependencies26 =
      SelectedWordCellsProvider.$allTransitiveDependencies25;
  static final $allTransitiveDependencies27 =
      SelectedWordCellsProvider.$allTransitiveDependencies26;

  @override
  String debugGetCreateSourceHash() => _$cellInSelectedWordHash();

  @override
  String toString() {
    return r'cellInSelectedWordProvider'
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
    return cellInSelectedWord(ref, argument);
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
    return other is CellInSelectedWordProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cellInSelectedWordHash() =>
    r'd20a8c0275273537f79ec58e770794a91b08e814';

/// Provider family that answers whether a specific cell is part of the
/// currently selected word.
/// Optimized: uses select() to only rebuild when this cell's membership changes.

final class CellInSelectedWordFamily extends $Family
    with $FunctionalFamilyOverride<bool, CellKey> {
  CellInSelectedWordFamily._()
    : super(
        retry: null,
        name: r'cellInSelectedWordProvider',
        dependencies: <ProviderOrFamily>[selectedWordCellsProvider],
        $allTransitiveDependencies: <ProviderOrFamily>{
          CellInSelectedWordProvider.$allTransitiveDependencies0,
          CellInSelectedWordProvider.$allTransitiveDependencies1,
          CellInSelectedWordProvider.$allTransitiveDependencies2,
          CellInSelectedWordProvider.$allTransitiveDependencies3,
          CellInSelectedWordProvider.$allTransitiveDependencies4,
          CellInSelectedWordProvider.$allTransitiveDependencies5,
          CellInSelectedWordProvider.$allTransitiveDependencies6,
          CellInSelectedWordProvider.$allTransitiveDependencies7,
          CellInSelectedWordProvider.$allTransitiveDependencies8,
          CellInSelectedWordProvider.$allTransitiveDependencies9,
          CellInSelectedWordProvider.$allTransitiveDependencies10,
          CellInSelectedWordProvider.$allTransitiveDependencies11,
          CellInSelectedWordProvider.$allTransitiveDependencies12,
          CellInSelectedWordProvider.$allTransitiveDependencies13,
          CellInSelectedWordProvider.$allTransitiveDependencies14,
          CellInSelectedWordProvider.$allTransitiveDependencies15,
          CellInSelectedWordProvider.$allTransitiveDependencies16,
          CellInSelectedWordProvider.$allTransitiveDependencies17,
          CellInSelectedWordProvider.$allTransitiveDependencies18,
          CellInSelectedWordProvider.$allTransitiveDependencies19,
          CellInSelectedWordProvider.$allTransitiveDependencies20,
          CellInSelectedWordProvider.$allTransitiveDependencies21,
          CellInSelectedWordProvider.$allTransitiveDependencies22,
          CellInSelectedWordProvider.$allTransitiveDependencies23,
          CellInSelectedWordProvider.$allTransitiveDependencies24,
          CellInSelectedWordProvider.$allTransitiveDependencies25,
          CellInSelectedWordProvider.$allTransitiveDependencies26,
          CellInSelectedWordProvider.$allTransitiveDependencies27,
        },
        isAutoDispose: false,
      );

  /// Provider family that answers whether a specific cell is part of the
  /// currently selected word.
  /// Optimized: uses select() to only rebuild when this cell's membership changes.

  CellInSelectedWordProvider call(CellKey key) =>
      CellInSelectedWordProvider._(argument: key, from: this);

  @override
  String toString() => r'cellInSelectedWordProvider';
}
