// Kullanim: node uret.js  (sharp gerekir). Ikonlari assets/hupo/ayakta.png'den uretir.
const sharp = require('sharp');
const path = require('path');
const fs = require('fs');
const root = path.resolve(__dirname, '..', '..');
const BG = { r: 0x6c, g: 0x4d, b: 0xf6, alpha: 1 }; // AppColors.primary
const src = path.join(root, 'assets/hupo/ayakta.png');
const res = path.join(root, 'android/app/src/main/res');
const icons = path.join(root, 'ios/Runner/Assets.xcassets/AppIcon.appiconset');
const launch = path.join(root, 'ios/Runner/Assets.xcassets/LaunchImage.imageset');

async function hupoOn(size, frac, bg) {
  const target = Math.round(size * frac);
  const img = await sharp(src).trim().resize(target, target, { fit: 'inside' }).toBuffer();
  const base = sharp({ create: { width: size, height: size, channels: 4, background: bg || { r: 0, g: 0, b: 0, alpha: 0 } } });
  return base.composite([{ input: img, gravity: 'center' }]).png();
}
(async () => {
  const fg = { mdpi: 108, hdpi: 162, xhdpi: 216, xxhdpi: 324, xxxhdpi: 432 };
  const legacy = { mdpi: 48, hdpi: 72, xhdpi: 96, xxhdpi: 144, xxxhdpi: 192 };
  for (const d of Object.keys(fg)) {
    const dir = path.join(res, `mipmap-${d}`);
    await (await hupoOn(fg[d], 0.60)).toFile(path.join(dir, 'ic_launcher_foreground.png'));
    const s = legacy[d];
    const sq = await (await hupoOn(s, 0.82, BG)).toBuffer();
    const mask = Buffer.from(`<svg width="${s}" height="${s}"><rect width="${s}" height="${s}" rx="${s * 0.22}"/></svg>`);
    await sharp(sq).composite([{ input: mask, blend: 'dest-in' }]).png().toFile(path.join(dir, 'ic_launcher.png'));
  }
  const out = __dirname;
  await (await hupoOn(432, 0.60)).toFile(path.join(out, 'android-on-plan-432.png'));
  await (await hupoOn(512, 0.82, BG)).flatten({ background: BG }).removeAlpha().png().toFile(path.join(out, 'play-store-ikon-512.png'));
  await (await hupoOn(1024, 0.82, BG)).flatten({ background: BG }).removeAlpha().png().toFile(path.join(out, 'ios-ikon-1024.png'));
  const contents = JSON.parse(fs.readFileSync(path.join(icons, 'Contents.json'), 'utf8'));
  for (const im of contents.images) {
    const px = Math.round(parseFloat(im.size.split('x')[0]) * parseFloat(im.scale));
    await (await hupoOn(px, 0.82, BG)).flatten({ background: BG }).removeAlpha().png().toFile(path.join(icons, im.filename));
  }
  for (const [n, sc] of [['LaunchImage.png', 1], ['LaunchImage@2x.png', 2], ['LaunchImage@3x.png', 3]]) {
    await sharp(src).trim().resize(168 * sc, 185 * sc, { fit: 'inside' }).png().toFile(path.join(launch, n));
  }
  const hero = await sharp(src).trim().resize(400, 400, { fit: 'inside' }).toBuffer();
  await sharp({ create: { width: 1024, height: 500, channels: 4, background: BG } })
    .composite([{ input: hero, gravity: 'center' }]).png().toFile(path.join(out, 'play-store-one-cikan-1024x500.png'));
  console.log('tamam');
})();
