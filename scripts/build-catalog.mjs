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

// Sticker frame (STYLE.md §8): tiles are silhouette die-cut stickers — the art is
// TRANSPARENT around the subject so the app's themed `cellBackground` shows through.
// The build only guarantees a uniform TRANSPARENT safe-area margin so the white
// outline never touches the cell edge; corner rounding + background color are the
// app's job, never baked into the WebP.
const MARGIN_RATIO = config.stickerMarginRatio ?? 0.08;
// Guard against a misconfigured ratio: <0 or >=0.5 makes the inner box zero/negative
// and Sharp throws a cryptic resize error further down. Fail early and clearly.
if (typeof MARGIN_RATIO !== 'number' || !(MARGIN_RATIO >= 0 && MARGIN_RATIO < 0.5)) {
  throw new Error(
    `catalog.config.json "stickerMarginRatio" must be a number in [0, 0.5); got ${JSON.stringify(MARGIN_RATIO)}`,
  );
}
const TRANSPARENT = { r: 0, g: 0, b: 0, alpha: 0 };

// Chroma key (STYLE.md §9/§10): AI models can't reliably emit real alpha, and the
// sticker's white outline can't be separated from a white background — so raster
// masters are authored on a solid CHROMA background (default magenta) that the build
// keys out to transparency here. The white outline survives because it's white, not
// the key colour. Vector (SVG) masters are already transparent and skip this.
const CHROMA = hexToRgb(config.chromaKey ?? '#FF00FF');
const KEY_IN = 70; // colour distance <= this => fully keyed (transparent)
const KEY_OUT = 150; // >= this => fully opaque; between => feathered edge + despill
const SPILL_CAP = 40; // how far a key-dominant channel may exceed the base near edges

function hexToRgb(hex) {
  const n = parseInt(String(hex).replace('#', ''), 16);
  return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
}

// Key the CHROMA colour out of a raw RGBA buffer in place: distance-based alpha with
// a feathered edge, plus a despill that pulls the key's dominant channels back toward
// the pixel's non-dominant channels so no coloured fringe rings the white outline.
function keyChroma(data, ch, [kr, kg, kb]) {
  const dom = [kr > 128, kg > 128, kb > 128]; // which channels are "high" in the key
  for (let i = 0; i < data.length; i += ch) {
    const r = data[i], g = data[i + 1], b = data[i + 2];
    const d = Math.hypot(r - kr, g - kg, b - kb);
    if (d <= KEY_IN) {
      data[i + 3] = 0;
    } else if (d < KEY_OUT) {
      const a = Math.round((255 * (d - KEY_IN)) / (KEY_OUT - KEY_IN));
      if (a < data[i + 3]) data[i + 3] = a;
      // despill: base = min of the pixel's channels that the key does NOT emphasize
      const nonDom = [!dom[0] ? r : Infinity, !dom[1] ? g : Infinity, !dom[2] ? b : Infinity];
      const base = Math.min(nonDom[0], nonDom[1], nonDom[2]);
      if (Number.isFinite(base)) {
        if (dom[0]) data[i] = Math.min(r, base + SPILL_CAP);
        if (dom[1]) data[i + 1] = Math.min(g, base + SPILL_CAP);
        if (dom[2]) data[i + 2] = Math.min(b, base + SPILL_CAP);
      }
    }
  }
}

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

  // Contain the whole master into the inner box, then extend a uniform TRANSPARENT
  // margin out to the full canvas. Alpha is preserved (no flatten) so the themed
  // cell background shows around the die-cut subject.
  const margin = Math.round(px * MARGIN_RATIO);
  const inner = px - margin * 2;
  const extend = { top: margin, bottom: margin, left: margin, right: margin, background: TRANSPARENT };
  const isVector = masterName.toLowerCase().endsWith('.svg');

  let webp;
  if (isVector) {
    // Already transparent — frame directly (byte-identical to the pre-chroma build).
    webp = await sharp(masterBuf, { density: 384 })
      .resize(inner, inner, { fit: 'contain', background: TRANSPARENT })
      .extend(extend)
      .webp({ quality: 90, effort: 5, alphaQuality: 100 })
      .toBuffer();
  } else {
    // Raster (AI) master: contain, then key the chroma background out to alpha
    // before framing.
    const { data, info } = await sharp(masterBuf)
      .resize(inner, inner, { fit: 'contain', background: TRANSPARENT })
      .ensureAlpha()
      .raw()
      .toBuffer({ resolveWithObject: true });
    keyChroma(data, info.channels, CHROMA);
    webp = await sharp(data, { raw: { width: info.width, height: info.height, channels: info.channels } })
      .extend(extend)
      .webp({ quality: 90, effort: 5, alphaQuality: 100 })
      .toBuffer();
  }

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
