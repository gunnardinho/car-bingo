import 'dart:convert';

import '../../domain/board/board_layout.dart';
import '../../domain/board/board_spec.dart';
import '../local/drift/database.dart';

/// Pure mapping between Drift rows and domain board types, shared by every
/// data-layer reader so the (de)serialization rules live in exactly one place.

String encodeWinModes(List<WinMode> modes) => modes.map((m) => m.name).join(',');

/// Tolerant on purpose: trim entries and drop unknown/renamed ones rather than
/// throw, so a spec written by a future schema can't make a load fail and block
/// startup. A spec always resolves to >= 1 win mode.
List<WinMode> decodeWinModes(String csv) {
  final byName = {for (final m in WinMode.values) m.name: m};
  final modes = <WinMode>[
    for (final raw in csv.split(',')) ?byName[raw.trim()],
  ];
  return modes.isEmpty ? const [WinMode.fullBoard] : modes;
}

BoardSpec boardSpecFromRow(StoredBoardSpec r) => BoardSpec(
      seed: r.seed,
      size: r.size,
      freeSpace: r.freeSpace,
      catalogVersion: r.catalogVersion,
      algoVersion: r.algoVersion,
      configHash: r.configHash,
      winModes: decodeWinModes(r.winModes),
      mode: r.mode,
    );

BoardLayout boardLayoutFromRow(StoredBoardLayout r) {
  final ids = [
    for (final e in jsonDecode(r.cellItemIds) as List) e as String?,
  ];
  final free = ids.indexOf(null); // -1 on even boards (no free centre)
  return BoardLayout(
    size: r.size,
    cellItemIds: ids,
    freeIndex: free == -1 ? null : free,
  );
}
