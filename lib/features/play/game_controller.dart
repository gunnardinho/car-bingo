import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/providers.dart';
import '../../domain/board/board_layout.dart';
import '../../domain/board/board_spec.dart';
import '../../domain/board/generator/board_generator.dart';
import '../../domain/board/win_rules.dart';

/// One active solo game: the immutable [BoardSpec] + regenerated [BoardLayout]
/// plus the mutable set of marked cell indices. Progress is in-memory for the
/// walking skeleton; Drift persistence + the Firestore outbox arrive next (§4).
class GameState {
  final BoardSpec spec;
  final BoardLayout layout;
  final Set<int> marks; // user-marked cell indices (excludes the free centre)

  const GameState({required this.spec, required this.layout, required this.marks});

  bool get won => hasWon(spec, marks);

  int get totalCells => spec.cellCount;

  /// Marked count including the auto-marked free centre.
  int get markedCount => marks.length + (spec.freeIndex != null ? 1 : 0);

  GameState copyWith({Set<int>? marks}) =>
      GameState(spec: spec, layout: layout, marks: marks ?? this.marks);
}

class GameController extends Notifier<GameState?> {
  final Random _random;

  GameController([Random? random]) : _random = random ?? Random();

  @override
  GameState? build() => null;

  /// Start a new solo board of [size] (3/4/5) from a fresh random seed. The
  /// seed is the only nondeterministic input; generation from it is pure.
  void newGame(int size, {List<WinMode> winModes = const [WinMode.fullBoard]}) {
    final catalog = ref.read(catalogProvider).requireValue;
    final spec = BoardSpec(
      seed: _randomSeed(),
      size: size,
      catalogVersion: catalog.catalogVersion,
      algoVersion: catalog.algoVersion,
      configHash: catalog.configHash,
      winModes: winModes,
    );
    final layout = generateBoard(spec, catalog);
    state = GameState(spec: spec, layout: layout, marks: <int>{});
  }

  void toggle(int index) {
    final s = state;
    if (s == null || index == s.spec.freeIndex) return;
    final marks = Set<int>.of(s.marks);
    if (!marks.remove(index)) marks.add(index);
    state = s.copyWith(marks: marks);
  }

  void clear() => state = null;

  String _randomSeed() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no ambiguous 0/O/1/I
    final code = List.generate(4, (_) => chars[_random.nextInt(chars.length)]).join();
    return 'ROADTRIP-$code';
  }
}

final gameControllerProvider =
    NotifierProvider<GameController, GameState?>(GameController.new);

/// The cell whose detail is shown in the master–detail pane / sheet.
class SelectedCell extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? index) => state = index;
}

final selectedCellProvider = NotifierProvider<SelectedCell, int?>(SelectedCell.new);
