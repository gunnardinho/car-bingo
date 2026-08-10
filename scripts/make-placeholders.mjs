// Generates a sticker placeholder master.svg for every item that lacks one, so
// the board renders while you produce real art. Skips items that already have a
// master (yours or a real illustration). Pass --force (or FORCE=1) to also
// REGENERATE existing masters, but ONLY for items whose license source is
// "placeholder" — real art (any other source) is never overwritten. Use this to
// refresh placeholders after a style change. Placeholders follow the v2 sticker
// language in STYLE.md: a vibrant accent glyph on a solid WHITE background (the
// app's cell clip supplies the rounded corners, and build-catalog.mjs adds the
// uniform white border margin). Item NAMES are drawn by the app, never baked in.
//
//   node scripts/make-placeholders.mjs [--force]

import { readFile, readdir, writeFile, access } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)));
const ITEMS_DIR = join(ROOT, 'content', 'items');
const CONFIG = join(ROOT, 'content', 'catalog.config.json');

const exists = (p) => access(p).then(() => true).catch(() => false);

function hash(str) { let h = 2166136261; for (let i = 0; i < str.length; i++) { h ^= str.charCodeAt(i); h = Math.imul(h, 16777619); } return h >>> 0; }

// Playful accent palette (STYLE.md §2), restricted to hues with strong contrast
// on white for a solid glyph fill (Sunshine is too light as a fill, so it's
// omitted here). Category color is intentionally NOT used for placeholder art in
// v2 — it stays in the data model only.
const PALETTE = ['#2E86AB', '#E4572E', '#6A994E', '#4C956C', '#C1666B', '#8E44AD', '#1B9AAA'];

// --- category glyphs ({fg} = accent fill/stroke, {bg} = white cut-outs), drawn
// centered on a 512 canvas ---
const GLYPHS = {
  road_signs: `
    <path d="M256 120 L392 360 L120 360 Z" fill="none" stroke="{fg}" stroke-width="26" stroke-linejoin="round"/>
    <rect x="242" y="210" width="28" height="86" rx="14" fill="{fg}"/>
    <circle cx="256" cy="330" r="16" fill="{fg}"/>`,
  vehicles: `
    <rect x="128" y="238" width="256" height="72" rx="26" fill="{fg}"/>
    <rect x="182" y="188" width="148" height="66" rx="22" fill="{fg}"/>
    <circle cx="188" cy="320" r="34" fill="{fg}"/><circle cx="188" cy="320" r="14" fill="{bg}"/>
    <circle cx="324" cy="320" r="34" fill="{fg}"/><circle cx="324" cy="320" r="14" fill="{bg}"/>`,
  animals: `
    <ellipse cx="256" cy="308" rx="74" ry="58" fill="{fg}"/>
    <circle cx="176" cy="248" r="30" fill="{fg}"/>
    <circle cx="228" cy="206" r="30" fill="{fg}"/>
    <circle cx="284" cy="206" r="30" fill="{fg}"/>
    <circle cx="336" cy="248" r="30" fill="{fg}"/>`,
  nature: `
    <circle cx="344" cy="176" r="40" fill="{fg}"/>
    <path d="M112 366 L212 206 L286 302 L340 232 L400 366 Z" fill="{fg}"/>`,
  buildings: `
    <polygon points="150,254 256,158 362,254" fill="{fg}"/>
    <rect x="180" y="252" width="152" height="130" fill="{fg}"/>
    <rect x="238" y="312" width="36" height="70" rx="6" fill="{bg}"/>`,
};

const FORCE = process.env.FORCE === '1' || process.argv.includes('--force');

const dirs = (await readdir(ITEMS_DIR, { withFileTypes: true })).filter((d) => d.isDirectory()).map((d) => d.name).sort();

let written = 0, skipped = 0;
for (const id of dirs) {
  const master = join(ITEMS_DIR, id, 'master.svg');
  const item = JSON.parse(await readFile(join(ITEMS_DIR, id, 'item.json'), 'utf8'));
  const isPlaceholder = (item.license?.source ?? 'placeholder') === 'placeholder';
  if (await exists(master)) {
    // Regenerate only in --force mode, and only for placeholder items — never
    // clobber real illustrations.
    if (!(FORCE && isPlaceholder)) { skipped++; continue; }
  }
  // Deterministic accent + a playful slight tilt per item, so neighbouring tiles
  // differ and fewer collapse to the same rendered tile (they dedupe by bytes).
  const j = hash(id);
  const fg = PALETTE[j % PALETTE.length];
  const tilt = [-8, -4, 0, 4, 8][(j >> 3) % 5];
  // {bg} holes are cut to transparent so the themed cell background shows through.
  const glyph = (GLYPHS[item.categoryId] ?? GLYPHS.buildings)
    .replaceAll('{fg}', fg)
    .replaceAll('{bg}', 'none');
  // Silhouette die-cut sticker (STYLE.md §8): TRANSPARENT background + a uniform
  // white outline that hugs the glyph. The outline is produced by dilating the
  // glyph's alpha and flooding it white, then painting the colored glyph on top.
  // Corners/background/margin are the app's + build's job — don't bake them here.
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <defs>
    <filter id="diecut" x="-25%" y="-25%" width="150%" height="150%">
      <feMorphology in="SourceAlpha" operator="dilate" radius="18" result="spread"/>
      <feFlood flood-color="#ffffff" result="white"/>
      <feComposite in="white" in2="spread" operator="in" result="outline"/>
      <feMerge>
        <feMergeNode in="outline"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  <g filter="url(#diecut)" transform="rotate(${tilt} 256 256)">${glyph}
  </g>
</svg>
`;
  await writeFile(master, svg, 'utf8');
  written++;
}

console.log(`make-placeholders: ${written} written, ${skipped} skipped (master already present).`);
