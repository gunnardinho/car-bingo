/// The concrete result of running the generator on a [BoardSpec]: which item
/// sits in each cell. For any board that has progress this is PERSISTED and
/// treated as authoritative (§4), so a later catalog change can never silently
/// remap a user's checked cells onto different items.
class BoardLayout {
  final int size;

  /// Length `size*size`, row-major. `null` marks the free centre cell.
  final List<String?> cellItemIds;

  final int? freeIndex;

  const BoardLayout({
    required this.size,
    required this.cellItemIds,
    required this.freeIndex,
  });

  /// The placed item ids in cell order (excludes the free centre).
  List<String> get itemIds => [
        for (final id in cellItemIds) ?id,
      ];

  String? itemIdAt(int index) => cellItemIds[index];
}
