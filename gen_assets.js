// Generates all Assets.xcassets color sets with correct UTF-8 JSON (no BOM)
const fs = require('fs');
const path = require('path');

const base = 'MHDPruvodce/Resources/Assets.xcassets';

const colors = {
  AppPrimary:      '0A84FF',
  AppSuccess:      '30D158',
  AppWarning:      'FF9F0A',
  AppDanger:       'FF453A',
  BusBadge:        '0A84FF',
  TramBadge:       'FF9F0A',
  MetroBadge:      '30D158',
  TrainBadge:      'FF453A',
  TrolleybusBadge: 'BF5AF2',
};

function hexToFloat(h) {
  return (parseInt(h, 16) / 255).toFixed(3);
}

// Root Contents.json
fs.mkdirSync(base, { recursive: true });
fs.writeFileSync(
  path.join(base, 'Contents.json'),
  JSON.stringify({ info: { author: 'xcode', version: 1 } }, null, 2) + '\n',
  { encoding: 'utf8' }
);

// Each color set
for (const [name, hex] of Object.entries(colors)) {
  const dir = path.join(base, name + '.colorset');
  fs.mkdirSync(dir, { recursive: true });
  const r = hexToFloat(hex.slice(0, 2));
  const g = hexToFloat(hex.slice(2, 4));
  const b = hexToFloat(hex.slice(4, 6));
  const contents = {
    colors: [
      {
        color: {
          'color-space': 'srgb',
          components: { red: r, green: g, blue: b, alpha: '1.000' },
        },
        idiom: 'universal',
      },
    ],
    info: { author: 'xcode', version: 1 },
  };
  fs.writeFileSync(
    path.join(dir, 'Contents.json'),
    JSON.stringify(contents, null, 2) + '\n',
    { encoding: 'utf8' }
  );
  console.log('  ' + name + ' #' + hex);
}

// AppIcon — needs at minimum a valid Contents.json
const iconDir = path.join(base, 'AppIcon.appiconset');
fs.mkdirSync(iconDir, { recursive: true });
fs.writeFileSync(
  path.join(iconDir, 'Contents.json'),
  JSON.stringify({
    images: [{ idiom: 'universal', platform: 'ios', size: '1024x1024' }],
    info: { author: 'xcode', version: 1 },
  }, null, 2) + '\n',
  { encoding: 'utf8' }
);

console.log('Done — all assets written as UTF-8 without BOM');
