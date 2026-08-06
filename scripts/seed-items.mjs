// Seeds the initial ~30-item catalog as folder-per-item source files
// (content/items/<id>/item.json). One-time bootstrap: it SKIPS any item that
// already exists, so re-running never clobbers your edits. After this, the
// item.json files are the source of truth — edit them directly.
//
//   node scripts/seed-items.mjs
//
// Tier mapping (see difficulty_mix.dart / STYLE.md): 1-2=easy, 3=medium, 4-5=hard.

import { mkdir, writeFile, access } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)));
const ITEMS_DIR = join(ROOT, 'content', 'items');
const ACQUIRED = '2026-08-06';

// [id, category, subCategory, difficulty, weight, en name, nb name, en desc, nb desc]
const ITEMS = [
  // --- road_signs (10) ---
  ['speed_limit_80', 'road_signs', 'prohibition', 1, 3, 'Speed limit 80', 'Fartsgrense 80', 'A round white sign with a red border showing 80.', 'Rundt hvitt skilt med rød kant og tallet 80.'],
  ['stop_sign', 'road_signs', 'prohibition', 1, 2, 'Stop sign', 'Stoppskilt', 'A red octagon that says STOP.', 'Rød åttekant der det står STOPP.'],
  ['yield_sign', 'road_signs', 'priority', 2, 2, 'Yield sign', 'Vikeplikt', 'A downward-pointing white triangle with a red border.', 'Hvit trekant som peker ned, med rød kant.'],
  ['no_overtaking', 'road_signs', 'prohibition', 3, 1, 'No overtaking', 'Forbikjøring forbudt', 'Two cars side by side in a red-bordered circle.', 'To biler ved siden av hverandre i rød sirkel.'],
  ['moose_warning', 'road_signs', 'warning', 3, 1, 'Moose warning', 'Elg', 'A warning triangle with a moose silhouette.', 'Faretrekant med elg-silhuett.'],
  ['roundabout', 'road_signs', 'mandatory', 3, 1, 'Roundabout', 'Rundkjøring', 'Three blue arrows chasing each other in a circle.', 'Tre blå piler som følger hverandre i en sirkel.'],
  ['children_crossing', 'road_signs', 'warning', 3, 1, 'Children', 'Barn', 'A warning triangle with two children walking.', 'Faretrekant med to barn som går.'],
  ['tunnel_sign', 'road_signs', 'info', 3, 1, 'Tunnel', 'Tunnel', 'A road disappearing into a tunnel arch.', 'En vei som forsvinner inn i en tunnelåpning.'],
  ['falling_rocks', 'road_signs', 'warning', 4, 1, 'Falling rocks', 'Steinras', 'A warning triangle with rocks tumbling down a slope.', 'Faretrekant med stein som raser ned en skråning.'],
  ['slippery_road', 'road_signs', 'warning', 4, 1, 'Slippery road', 'Glatt kjørebane', 'A warning triangle with a car and skid marks.', 'Faretrekant med bil og skrensespor.'],

  // --- vehicles (5) ---
  ['red_car', 'vehicles', 'car', 1, 3, 'Red car', 'Rød bil', 'A small red passenger car.', 'En liten rød personbil.'],
  ['lorry', 'vehicles', 'truck', 1, 2, 'Lorry', 'Lastebil', 'A large truck hauling cargo.', 'En stor lastebil med last.'],
  ['bus', 'vehicles', 'bus', 2, 2, 'Bus', 'Buss', 'A long passenger bus.', 'En lang passasjerbuss.'],
  ['tractor', 'vehicles', 'farm', 3, 1, 'Tractor', 'Traktor', 'A farm tractor with big rear wheels.', 'En traktor med store bakhjul.'],
  ['motorhome', 'vehicles', 'recreational', 3, 1, 'Motorhome', 'Bobil', 'A boxy camper van / motorhome.', 'En firkantet bobil.'],

  // --- animals (5) ---
  ['cow', 'animals', 'livestock', 1, 2, 'Cow', 'Ku', 'A spotted cow in a field.', 'En flekkete ku på et jorde.'],
  ['sheep', 'animals', 'livestock', 2, 2, 'Sheep', 'Sau', 'A fluffy white sheep.', 'En lodden hvit sau.'],
  ['horse', 'animals', 'livestock', 3, 1, 'Horse', 'Hest', 'A standing horse.', 'En hest som står.'],
  ['deer', 'animals', 'wild', 4, 1, 'Deer', 'Rådyr', 'A roe deer at the roadside.', 'Et rådyr ved veikanten.'],
  ['fox', 'animals', 'wild', 5, 1, 'Fox', 'Rev', 'A red fox with a bushy tail.', 'En rødrev med busten hale.'],

  // --- nature (5) ---
  ['lake', 'nature', 'water', 1, 2, 'Lake', 'Innsjø', 'A calm blue lake.', 'En rolig blå innsjø.'],
  ['mountain', 'nature', 'terrain', 2, 2, 'Mountain', 'Fjell', 'A snow-capped mountain peak.', 'En snødekt fjelltopp.'],
  ['forest', 'nature', 'terrain', 3, 1, 'Forest', 'Skog', 'A stand of evergreen trees.', 'En samling grantrær.'],
  ['waterfall', 'nature', 'water', 4, 1, 'Waterfall', 'Foss', 'Water cascading down a cliff.', 'Vann som fosser ned et stup.'],
  ['rainbow', 'nature', 'sky', 5, 1, 'Rainbow', 'Regnbue', 'A colorful arc across the sky.', 'En fargerik bue over himmelen.'],

  // --- buildings (5) ---
  ['red_barn', 'buildings', 'rural_structures', 1, 2, 'Red barn', 'Rød låve', 'A classic red-painted barn.', 'En klassisk rødmalt låve.'],
  ['church', 'buildings', 'civic', 3, 1, 'Church', 'Kirke', 'A white church with a steeple.', 'En hvit kirke med spir.'],
  ['gas_station', 'buildings', 'roadside', 3, 1, 'Petrol station', 'Bensinstasjon', 'A fuel pump under a canopy.', 'En drivstoffpumpe under et tak.'],
  ['bridge', 'buildings', 'infrastructure', 3, 1, 'Bridge', 'Bru', 'A bridge spanning water.', 'En bru over vann.'],
  ['lighthouse', 'buildings', 'coastal', 4, 1, 'Lighthouse', 'Fyr', 'A striped coastal lighthouse.', 'Et stripete fyr ved kysten.'],
];

const exists = async (p) => access(p).then(() => true).catch(() => false);

let written = 0;
let skipped = 0;

for (const [id, categoryId, subCategoryId, difficulty, weight, en, nb, den, dnb] of ITEMS) {
  const dir = join(ITEMS_DIR, id);
  const file = join(dir, 'item.json');
  if (await exists(file)) {
    skipped++;
    continue;
  }
  const item = {
    id,
    schemaVersion: 1,
    categoryId,
    subCategoryId,
    difficulty,
    weight,
    regions: ['*'],
    enabled: true,
    name: { en, nb },
    description: { en: den, nb: dnb },
    image: { aspect: '1:1', format: 'webp', px: 512 },
    license: {
      source: 'placeholder',
      type: 'CC0-1.0',
      author: 'generated',
      attributionRequired: false,
      acquiredAt: ACQUIRED,
    },
  };
  await mkdir(dir, { recursive: true });
  await writeFile(file, JSON.stringify(item, null, 2) + '\n', 'utf8');
  written++;
}

console.log(`seed-items: ${written} written, ${skipped} skipped (already existed). Total defined: ${ITEMS.length}.`);
