// Rasterizes each item's master art to a content-hashed WebP tile and assembles
// the bundled manifest the Flutter app reads (assets/catalog/items.json).
// The manifest + tiles are build OUTPUTS, regenerable from content/ at any time.
//
//   node scripts/build-catalog.mjs

import { readFile, readdir, writeFile, mkdir, rm } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import sharp from 'sharp';

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)));
const ITEMS_DIR = join(ROOT, 'content', 'items');
const CONFIG = join(ROOT, 'content', 'catalog.config.json');
const OUT_DIR = join(ROOT, 'assets', 'catalog');
const TILES_DIR = join(OUT_DIR, 'tiles');

const config = JSON.parse(await readFile(CONFIG, 'utf8'));

// fresh output so removed items never leave orphan tiles behind
await rm(OUT_DIR, { recursive: true, force: true });
await mkdir(TILES_DIR, { recursive: true });

const dirs = (await readdir(ITEMS_DIR, { withFileTypes: true }))
  .filter((d) => d.isDirectory())
  .map((d) => d.name)
  .sort(); // stable order in the manifest

const writtenHashes = new Set();
const manifestItems = [];

for (const id of dirs) {
  const item = JSON.parse(await readFile(join(ITEMS_DIR, id, 'item.json'), 'utf8'));
  const px = item.image?.px ?? 512;
  const masterName = item.image?.master ?? 'master.svg';
  const masterBuf = await readFile(join(ITEMS_DIR, id, masterName));

  const webp = await sharp(masterBuf, { density: 384 })
    .resize(px, px, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .webp({ quality: 90, effort: 5 })
    .toBuffer();

  const hash = createHash('sha256').update(webp).digest('hex').slice(0, 16);
  const file = `tiles/${hash}.webp`;
  if (!writtenHashes.has(hash)) {
    await writeFile(join(OUT_DIR, file), webp);
    writtenHashes.add(hash);
  }
  const meta = await sharp(webp).metadata();

  manifestItems.push({
    id: item.id,
    categoryId: item.categoryId,
    subCategoryId: item.subCategoryId ?? null,
    difficulty: item.difficulty,
    weight: item.weight,
    regions: item.regions ?? ['*'],
    enabled: item.enabled,
    name: item.name,
    description: item.description ?? {},
    image: { hash, file, format: 'webp', width: meta.width, height: meta.height },
  });
}

const manifest = {
  catalogVersion: config.catalogVersion,
  algoVersion: config.algoVersion,
  configHash: config.configHash,
  categories: config.categories.map((c) => ({
    id: c.id,
    sortOrder: c.sortOrder,
    color: c.color,
    name: c.name,
  })),
  items: manifestItems,
};

await writeFile(join(OUT_DIR, 'items.json'), JSON.stringify(manifest), 'utf8');

console.log(
  `✓ build-catalog: ${manifestItems.length} items -> ${writtenHashes.size} tiles in assets/catalog/ ` +
    `(catalogVersion ${config.catalogVersion}).`,
);
