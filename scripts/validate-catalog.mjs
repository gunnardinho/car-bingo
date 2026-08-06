// Validates every item.json against the JSON Schema AND asserts the catalog is
// rich enough to fill each board size WITHOUT relaxation (ARCHITECTURE.md §8).
// Prints a (tier x category) coverage report and FAILS (exit 1) if a size can't
// be filled or the per-category cap makes a tier infeasible. This is the gate
// that turns "grow the catalog" into a failing test instead of guesswork.
//
//   node scripts/validate-catalog.mjs

import { readFile, readdir, access } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import Ajv2020 from 'ajv/dist/2020.js';

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)));
const ITEMS_DIR = join(ROOT, 'content', 'items');
const CONFIG = join(ROOT, 'content', 'catalog.config.json');
const SCHEMA = join(ROOT, 'content', 'schema', 'item.schema.json');

// Mirror of lib/domain/board/difficulty_mix.dart — keep in sync (a Dart test
// also asserts the quotas sum to the pick count).
const MIX = {
  3: { easy: 5, medium: 3, hard: 0 },
  4: { easy: 7, medium: 6, hard: 3 },
  5: { easy: 8, medium: 10, hard: 6 },
};
const tierOf = (d) => (d <= 2 ? 'easy' : d === 3 ? 'medium' : 'hard');
const exists = (p) => access(p).then(() => true).catch(() => false);

// Max-flow feasibility: can we pick quota[t] items from each tier such that no
// category supplies more than `capPerCat` items ACROSS THE WHOLE BOARD? The
// generator's per-category cap is cumulative across tiers (one catCount map for
// the whole board), so a per-tier check is unsound — it would pass catalogs the
// generator can only fill by firing its relaxation ladder and flooding one
// category. Source -> tier (cap quota[t]) -> category (cap counts[t][cat]) ->
// sink (cap capPerCat); feasible iff max-flow saturates all picks.
function fillableWithinCap(counts, cats, tiers, quota, capPerCat) {
  const picks = tiers.reduce((s, t) => s + (quota[t] || 0), 0);
  const nT = tiers.length;
  const nC = cats.length;
  const N = 2 + nT + nC;
  const S = 0;
  const T = N - 1;
  const tierNode = (i) => 1 + i;
  const catNode = (j) => 1 + nT + j;
  const cap = Array.from({ length: N }, () => new Array(N).fill(0));
  for (let i = 0; i < nT; i++) cap[S][tierNode(i)] = quota[tiers[i]] || 0;
  for (let i = 0; i < nT; i++)
    for (let j = 0; j < nC; j++) cap[tierNode(i)][catNode(j)] = counts[tiers[i]][cats[j]] || 0;
  for (let j = 0; j < nC; j++) cap[catNode(j)][T] = capPerCat;

  let flow = 0;
  for (;;) {
    const parent = new Array(N).fill(-1);
    parent[S] = S;
    const queue = [S];
    while (queue.length) {
      const u = queue.shift();
      for (let v = 0; v < N; v++) {
        if (parent[v] === -1 && cap[u][v] > 0) {
          parent[v] = u;
          queue.push(v);
        }
      }
    }
    if (parent[T] === -1) break;
    let bottleneck = Infinity;
    for (let v = T; v !== S; v = parent[v]) bottleneck = Math.min(bottleneck, cap[parent[v]][v]);
    for (let v = T; v !== S; v = parent[v]) {
      cap[parent[v]][v] -= bottleneck;
      cap[v][parent[v]] += bottleneck;
    }
    flow += bottleneck;
  }
  return flow >= picks;
}

const errors = [];

const config = JSON.parse(await readFile(CONFIG, 'utf8'));
const schema = JSON.parse(await readFile(SCHEMA, 'utf8'));
const catIds = new Set(config.categories.map((c) => c.id));

const ajv = new Ajv2020({ allErrors: true, strict: true, allowMatchingProperties: true });
const validate = ajv.compile(schema);

const dirs = (await readdir(ITEMS_DIR, { withFileTypes: true }))
  .filter((d) => d.isDirectory())
  .map((d) => d.name)
  .sort();

const items = [];
const seenIds = new Set();
for (const dir of dirs) {
  const file = join(ITEMS_DIR, dir, 'item.json');
  let item;
  try {
    item = JSON.parse(await readFile(file, 'utf8'));
  } catch (e) {
    errors.push(`${dir}/item.json: not readable/parseable (${e.message})`);
    continue;
  }
  if (!validate(item)) {
    for (const err of validate.errors) errors.push(`${dir}/item.json ${err.instancePath || '/'} ${err.message}`);
    continue;
  }
  if (item.id !== dir) errors.push(`${dir}/item.json: id "${item.id}" must equal folder name "${dir}"`);
  if (seenIds.has(item.id)) errors.push(`duplicate id: ${item.id}`);
  seenIds.add(item.id);
  if (!catIds.has(item.categoryId)) errors.push(`${item.id}: unknown categoryId "${item.categoryId}"`);
  const master = item.image?.master ?? 'master.svg';
  if (!(await exists(join(ITEMS_DIR, dir, master)))) {
    errors.push(`${item.id}: missing master image "${master}" (run: npm run placeholders)`);
  }
  items.push(item);
}

// --- coverage: enabled items per (tier x category) ---
const enabled = items.filter((i) => i.enabled);
const cats = config.categories.map((c) => c.id);
const tiers = ['easy', 'medium', 'hard'];
const counts = {}; // counts[tier][cat] = n
for (const t of tiers) counts[t] = Object.fromEntries(cats.map((c) => [c, 0]));
for (const i of enabled) counts[tierOf(i.difficulty)][i.categoryId]++;
const tierTotal = Object.fromEntries(tiers.map((t) => [t, cats.reduce((s, c) => s + counts[t][c], 0)]));

console.log(`\nCatalog coverage — ${enabled.length} enabled items across ${cats.length} categories`);
console.log('tier'.padEnd(8) + cats.map((c) => c.slice(0, 10).padStart(11)).join('') + '   total');
for (const t of tiers) {
  console.log(t.padEnd(8) + cats.map((c) => String(counts[t][c]).padStart(11)).join('') + String(tierTotal[t]).padStart(8));
}

// --- feasibility per board size ---
// cap denominator = distinct categories actually present among enabled items
// (matches the generator's nCats), so an empty configured category can't cause
// a false failure.
const nCats = new Set(enabled.map((i) => i.categoryId)).size || 1;
for (const size of [3, 4, 5]) {
  const quota = MIX[size];
  const picks = quota.easy + quota.medium + quota.hard;
  const cap = Math.ceil(picks / nCats) + 1; // cumulative per-category cap on a board
  for (const t of tiers) {
    if (quota[t] > 0 && tierTotal[t] < quota[t]) {
      errors.push(`${size}x${size}: needs ${quota[t]} ${t} items, only ${tierTotal[t]} enabled (short ${quota[t] - tierTotal[t]})`);
    }
  }
  if (!fillableWithinCap(counts, cats, tiers, quota, cap)) {
    errors.push(
      `${size}x${size}: cannot fill without exceeding the per-category cap of ${cap} — some category would flood the board / force the generator's relaxation ladder (spread items across more categories)`,
    );
  }
}

if (errors.length) {
  console.error(`\n✗ validate-catalog: ${errors.length} problem(s):`);
  for (const e of errors) console.error('  - ' + e);
  process.exit(1);
}
console.log(`\n✓ validate-catalog: ${items.length} items valid; all board sizes fillable without relaxation.`);
