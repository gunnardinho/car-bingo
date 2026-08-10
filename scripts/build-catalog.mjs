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
const WHITE = { r: 255, g: 255, b: 255, alpha: 1 };

// Die-cut synthesis (STYLE.md §8/§10): AI masters are authored as a coloured subject
// on a SOLID WHITE background, with NO border. The build removes that background and
// draws the white outline itself, so every tile's border is byte-for-byte identical
// regardless of the source art. Vector (SVG) masters are already transparent + already
// carry their outline, so they skip this.
const OUTLINE_RATIO = config.stickerOutlineRatio ?? 0.035; // outline width, fraction of px
if (typeof OUTLINE_RATIO !== 'number' || !(OUTLINE_RATIO >= 0 && OUTLINE_RATIO < 0.2)) {
  throw new Error(
    `catalog.config.json "stickerOutlineRatio" must be a number in [0, 0.2); got ${JSON.stringify(OUTLINE_RATIO)}`,
  );
}
const WHITE_CUT = 225; // every channel >= this => a removable-background pixel

// Flood-fill the solid white background to transparency starting from the canvas
// edges (a "magic wand" from the border), so white INSIDE the subject is preserved —
// only white that is edge-connected through other white pixels is removed. In place
// on a raw RGBA buffer.
function removeWhiteBackground(data, W, H, ch) {
  const white = (p) => data[p * ch] >= WHITE_CUT && data[p * ch + 1] >= WHITE_CUT && data[p * ch + 2] >= WHITE_CUT;
  const seen = new Uint8Array(W * H);
  const stack = [];
  const visit = (x, y) => {
    if (x < 0 || x >= W || y < 0 || y >= H) return;
    const p = y * W + x;
    if (!seen[p] && white(p)) { seen[p] = 1; stack.push(p); }
  };
  for (let x = 0; x < W; x++) { visit(x, 0); visit(x, H - 1); }
  for (let y = 0; y < H; y++) { visit(0, y); visit(W - 1, y); }
  while (stack.length) {
    const p = stack.pop();
    data[p * ch + 3] = 0;
    const x = p % W, y = (p / W) | 0;
    visit(x + 1, y); visit(x - 1, y); visit(x, y + 1); visit(x, y - 1);
  }
}

// Draw a uniform white die-cut outline of `width` px around the opaque subject: a
// two-pass chamfer distance transform from the subject, then paint white where a
// transparent pixel lies within `width` of it (1 px feathered rim). In place on RGBA.
function addWhiteOutline(data, W, H, ch, width) {
  const N = W * H, INF = 1e9, D1 = 1, D2 = Math.SQRT2;
  const dist = new Float32Array(N);
  for (let p = 0; p < N; p++) dist[p] = data[p * ch + 3] >= 128 ? 0 : INF;
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) {
    const p = y * W + x; let d = dist[p];
    if (x > 0) d = Math.min(d, dist[p - 1] + D1);
    if (y > 0) d = Math.min(d, dist[p - W] + D1);
    if (x > 0 && y > 0) d = Math.min(d, dist[p - W - 1] + D2);
    if (x < W - 1 && y > 0) d = Math.min(d, dist[p - W + 1] + D2);
    dist[p] = d;
  }
  for (let y = H - 1; y >= 0; y--) for (let x = W - 1; x >= 0; x--) {
    const p = y * W + x; let d = dist[p];
    if (x < W - 1) d = Math.min(d, dist[p + 1] + D1);
    if (y < H - 1) d = Math.min(d, dist[p + W] + D1);
    if (x < W - 1 && y < H - 1) d = Math.min(d, dist[p + W + 1] + D2);
    if (x > 0 && y < H - 1) d = Math.min(d, dist[p + W - 1] + D2);
    dist[p] = d;
  }
  for (let p = 0; p < N; p++) {
    if (data[p * ch + 3] >= 128) continue; // subject stays
    const d = dist[p];
    if (d > 0 && d <= width) {
      const o = p * ch;
      data[o] = 255; data[o + 1] = 255; data[o + 2] = 255;
      data[o + 3] = d > width - 1 ? Math.round(255 * (width - d)) : 255; // feathered rim
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
    // Raster (AI) master = coloured subject on solid white, no border. Inset it by
    // the outline width, remove the white background to alpha, then draw the uniform
    // white die-cut outline ourselves before framing.
    const outline = Math.max(1, Math.round(px * OUTLINE_RATIO));
    const subjectBox = inner - 2 * outline;
    const { data, info } = await sharp(masterBuf)
      .resize(subjectBox, subjectBox, { fit: 'contain', background: WHITE })
      .extend({ top: outline, bottom: outline, left: outline, right: outline, background: WHITE })
      .ensureAlpha()
      .raw()
      .toBuffer({ resolveWithObject: true });
    removeWhiteBackground(data, info.width, info.height, info.channels);
    addWhiteOutline(data, info.width, info.height, info.channels, outline);
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
