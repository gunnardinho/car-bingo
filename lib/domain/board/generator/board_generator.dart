import '../../catalog/item.dart';
import '../board_layout.dart';
import '../board_spec.dart';
import '../difficulty_mix.dart';
import 'sfc32.dart';

/// A pure, deterministic, versioned board generator: `board = f(spec, catalog)`.
/// Any two devices reproduce an identical board offline — the prerequisite for
/// shared boards and free server-side anti-cheat (ARCHITECTURE.md §3, §8).
///
/// Dispatch is keyed on `algoVersion` so changing the algorithm never breaks an
/// already-shared board.
typedef GeneratorFn = BoardLayout Function(BoardSpec spec, Catalog catalog);

const List<Tier> _tierOrder = [Tier.easy, Tier.medium, Tier.hard];

final Map<int, GeneratorFn> _generators = {1: _generateV1};

BoardLayout generateBoard(BoardSpec spec, Catalog catalog) {
  assert(
    catalog.catalogVersion == spec.catalogVersion,
    'Catalog ${catalog.catalogVersion} does not match spec ${spec.catalogVersion}',
  );
  final gen = _generators[spec.algoVersion];
  if (gen == null) {
    throw ArgumentError('Unknown algoVersion ${spec.algoVersion}');
  }
  return gen(spec, catalog);
}

/// Single deterministic pass: stable-sort by id → per-tier weighted sampling
/// without replacement (capped per category) → seeded Fisher–Yates placement
/// with the centre reserved as a free square on odd sizes.
BoardLayout _generateV1(BoardSpec spec, Catalog catalog) {
  // 1. Eligible pool. Never trust file/Firestore/locale order — stable-sort by
  //    string id so the draw order is identical everywhere.
  final pool = catalog.items
      .where((i) => i.enabled && i.hasImage && _regionOk(i, spec))
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  if (pool.isEmpty) {
    throw StateError('No eligible catalog items for board generation.');
  }

  final rng = Sfc32.fromSeed(spec.seedMaterial);
  final picks = spec.pickCount;
  final nCats = pool.map((i) => i.categoryId).toSet().length;
  final baseCap = (picks / nCats).ceil() + 1; // no category floods the board
  final quota = quotaForSize(spec.size);

  // 2. Select per difficulty tier.
  final selected = <Item>[];
  final usedIds = <String>{};
  final catCount = <String, int>{};
  for (final tier in _tierOrder) {
    final need = quota[tier] ?? 0;
    var chosen = 0;
    while (chosen < need) {
      final item = _pickForTier(rng, pool, tier, usedIds, catCount, baseCap, picks);
      if (item == null) break; // exhausted even after relaxation
      selected.add(item);
      usedIds.add(item.id);
      catCount.update(item.categoryId, (v) => v + 1, ifAbsent: () => 1);
      chosen++;
    }
  }
  // Fill any remainder. The size-keyed quota assumes a free centre, so an odd
  // board with freeSpace disabled needs one extra pick beyond sum(quota).
  while (selected.length < picks) {
    final item = _pickAny(rng, pool, usedIds, catCount, baseCap, picks);
    if (item == null) break;
    selected.add(item);
    usedIds.add(item.id);
    catCount.update(item.categoryId, (v) => v + 1, ifAbsent: () => 1);
  }

  if (selected.length < picks) {
    throw StateError(
      'Catalog cannot fill a ${spec.size}x${spec.size} board '
      '(${selected.length}/$picks). Run `npm run validate`.',
    );
  }

  // 3. Place via seeded Fisher–Yates; centre stays null (free) on odd sizes.
  _shuffle(rng, selected);
  final cells = List<String?>.filled(spec.cellCount, null);
  final free = spec.freeIndex;
  var s = 0;
  for (var i = 0; i < cells.length; i++) {
    if (i == free) continue;
    cells[i] = selected[s++].id;
  }
  return BoardLayout(size: spec.size, cellItemIds: cells, freeIndex: free);
}

bool _regionOk(Item item, BoardSpec spec) =>
    item.regions.isEmpty || item.regions.contains('*'); // MVP: no region targeting

/// Weighted pick without replacement honoring the per-category cap, with the
/// deterministic relaxation ladder: raise the cap, then borrow any unused item.
/// A build-time validator guarantees the ladder isn't needed for a real catalog.
Item? _pickForTier(
  Sfc32 rng,
  List<Item> pool,
  Tier tier,
  Set<String> usedIds,
  Map<String, int> catCount,
  int baseCap,
  int picks,
) {
  var cap = baseCap;
  while (true) {
    final eligible = [
      for (final i in pool)
        if (i.tier == tier &&
            !usedIds.contains(i.id) &&
            (catCount[i.categoryId] ?? 0) < cap)
          i,
    ];
    if (eligible.isNotEmpty) return _weightedPick(rng, eligible);
    if (cap < picks) {
      cap++; // relax: raise the category cap
      continue;
    }
    final borrow = [
      for (final i in pool)
        if (!usedIds.contains(i.id)) i,
    ];
    if (borrow.isEmpty) return null;
    return _weightedPick(rng, borrow);
  }
}

/// Pick any unused item (tier-agnostic) honoring the per-category cap with the
/// same relaxation ladder. Used to top up the board past sum(quota).
Item? _pickAny(
  Sfc32 rng,
  List<Item> pool,
  Set<String> usedIds,
  Map<String, int> catCount,
  int baseCap,
  int picks,
) {
  var cap = baseCap;
  while (true) {
    final eligible = [
      for (final i in pool)
        if (!usedIds.contains(i.id) && (catCount[i.categoryId] ?? 0) < cap) i,
    ];
    if (eligible.isNotEmpty) return _weightedPick(rng, eligible);
    if (cap < picks) {
      cap++;
      continue;
    }
    final any = [
      for (final i in pool)
        if (!usedIds.contains(i.id)) i,
    ];
    return any.isEmpty ? null : _weightedPick(rng, any);
  }
}

/// Draw one item with probability proportional to integer weight. [items] must
/// already be in deterministic (id-sorted) order.
Item _weightedPick(Sfc32 rng, List<Item> items) {
  var total = 0;
  for (final i in items) {
    total += i.weight;
  }
  final r = rng.nextInt(total);
  var acc = 0;
  for (final i in items) {
    acc += i.weight;
    if (r < acc) return i;
  }
  return items.last; // unreachable when total > 0
}

void _shuffle(Sfc32 rng, List<Item> list) {
  for (var i = list.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }
}
