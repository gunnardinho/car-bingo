// Generates a flat-pictogram placeholder master.svg for every item that lacks
// one, so the board renders while you produce real art. Skips items that
// already have a master (yours or a real illustration). Placeholders follow the
// flat, category-colored language in STYLE.md; item NAMES are drawn by the app,
// never baked into the tile.
//
//   node scripts/make-placeholders.mjs

import { readFile, readdir, writeFile, access } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)));
const ITEMS_DIR = join(ROOT, 'content', 'items');
const CONFIG = join(ROOT, 'content', 'catalog.config.json');

const exists = (p) => access(p).then(() => true).catch(() => false);

// --- tiny deterministic color helpers (no deps) ---
function hexToHsl(hex) {
  const n = parseInt(hex.replace('#', ''), 16);
  let r = ((n >> 16) & 255) / 255, g = ((n >> 8) & 255) / 255, b = (n & 255) / 255;
  const max = Math.max(r, g, b), min = Math.min(r, g, b);
  let h = 0, s = 0; const l = (max + min) / 2;
  if (max !== min) {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    if (max === r) h = (g - b) / d + (g < b ? 6 : 0);
    else if (max === g) h = (b - r) / d + 2;
    else h = (r - g) / d + 4;
    h *= 60;
  }
  return [h, s * 100, l * 100];
}
function hslToHex(h, s, l) {
  h = ((h % 360) + 360) % 360; s = Math.max(0, Math.min(100, s)) / 100; l = Math.max(0, Math.min(100, l)) / 100;
  const c = (1 - Math.abs(2 * l - 1)) * s;
  const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
  const m = l - c / 2;
  let r = 0, g = 0, b = 0;
  if (h < 60) [r, g, b] = [c, x, 0];
  else if (h < 120) [r, g, b] = [x, c, 0];
  else if (h < 180) [r, g, b] = [0, c, x];
  else if (h < 240) [r, g, b] = [0, x, c];
  else if (h < 300) [r, g, b] = [x, 0, c];
  else [r, g, b] = [c, 0, x];
  const to = (v) => Math.round((v + m) * 255).toString(16).padStart(2, '0');
  return `#${to(r)}${to(g)}${to(b)}`;
}
function hash(str) { let h = 2166136261; for (let i = 0; i < str.length; i++) { h ^= str.charCodeAt(i); h = Math.imul(h, 16777619); } return h >>> 0; }

// --- category glyphs (white on category background), drawn centered on 512 canvas ---
const GLYPHS = {
  road_signs: `
    <path d="M256 120 L392 360 L120 360 Z" fill="none" stroke="#fff" stroke-width="26" stroke-linejoin="round"/>
    <rect x="242" y="210" width="28" height="86" rx="14" fill="#fff"/>
    <circle cx="256" cy="330" r="16" fill="#fff"/>`,
  vehicles: `
    <rect x="128" y="238" width="256" height="72" rx="26" fill="#fff"/>
    <rect x="182" y="188" width="148" height="66" rx="22" fill="#fff"/>
    <circle cx="188" cy="320" r="34" fill="#fff"/><circle cx="188" cy="320" r="14" fill="{bg}"/>
    <circle cx="324" cy="320" r="34" fill="#fff"/><circle cx="324" cy="320" r="14" fill="{bg}"/>`,
  animals: `
    <ellipse cx="256" cy="308" rx="74" ry="58" fill="#fff"/>
    <circle cx="176" cy="248" r="30" fill="#fff"/>
    <circle cx="228" cy="206" r="30" fill="#fff"/>
    <circle cx="284" cy="206" r="30" fill="#fff"/>
    <circle cx="336" cy="248" r="30" fill="#fff"/>`,
  nature: `
    <circle cx="344" cy="176" r="40" fill="#fff"/>
    <path d="M112 366 L212 206 L286 302 L340 232 L400 366 Z" fill="#fff"/>`,
  buildings: `
    <polygon points="150,254 256,158 362,254" fill="#fff"/>
    <rect x="180" y="252" width="152" height="130" fill="#fff"/>
    <rect x="238" y="312" width="36" height="70" rx="6" fill="{bg}"/>`,
};

const config = JSON.parse(await readFile(CONFIG, 'utf8'));
const colorByCat = Object.fromEntries(config.categories.map((c) => [c.id, c.color]));

const dirs = (await readdir(ITEMS_DIR, { withFileTypes: true })).filter((d) => d.isDirectory()).map((d) => d.name).sort();

let written = 0, skipped = 0;
for (const id of dirs) {
  const master = join(ITEMS_DIR, id, 'master.svg');
  if (await exists(master)) { skipped++; continue; }
  const item = JSON.parse(await readFile(join(ITEMS_DIR, id, 'item.json'), 'utf8'));
  const base = colorByCat[item.categoryId] ?? '#888888';
  // subtle deterministic per-item variation so neighbouring tiles differ
  const [h, s, l] = hexToHsl(base);
  const j = hash(id);
  const bg = hslToHex(h + ((j % 21) - 10), s, l + (((j >> 5) % 9) - 4));
  const glyph = (GLYPHS[item.categoryId] ?? GLYPHS.buildings).replaceAll('{bg}', bg);
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <rect x="0" y="0" width="512" height="512" rx="64" fill="${bg}"/>
  <g>${glyph}
  </g>
</svg>
`;
  await writeFile(master, svg, 'utf8');
  written++;
}

console.log(`make-placeholders: ${written} written, ${skipped} skipped (master already present).`);
