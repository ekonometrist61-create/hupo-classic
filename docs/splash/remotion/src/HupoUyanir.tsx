import React from 'react';
import {AbsoluteFill, Img, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig, Easing} from 'remotion';
import {loadFont} from '@remotion/google-fonts/Nunito';

const {fontFamily} = loadFont('normal', {weights: ['800', '900'], subsets: ['latin', 'latin-ext']});

export const TOPLAM_KARE = 96; // 3,2 sn @30 fps

// Renkler: AppColors (mobile-app/lib/theme/app_theme.dart)
const PRIMARY = '#147D8A';
const PRIMARY_LIGHT = '#4FB3BF';
const SUN = '#F5C842';
const INK = '#17324D';

// hupo_katmanlar.json (845x900 tuvali)
const TUVAL_W = 845;
const TUVAL_H = 900;
const KANAT = {x: 530, y: 90, pivot: [560, 440] as const};
const GOZ = {x: 165, y: 121};

const clamp = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'} as const;

const Hupo: React.FC<{frame: number; fps: number; olcek: number}> = ({frame, fps, olcek}) => {
  // Gozler: 0-12 uykuda; 12'de acilir; 20-22 hizli kirpma
  const kapali = frame < 12 || (frame >= 20 && frame < 23);
  // Kanat selami: 24-52 arasi -4..+6 derece (guvenli aralik)
  const t = frame - 24;
  const sallanma = t < 0 || t > 30 ? 0 : Math.sin((t / 30) * Math.PI * 3) * Math.min(1, t / 4) * Math.min(1, (30 - t) / 6);
  const aci = 1 + 5 * sallanma;
  return (
    <div style={{position: 'relative', width: TUVAL_W, height: TUVAL_H, transform: `scale(${olcek})`, transformOrigin: 'center center'}}>
      <Img src={staticFile('hupo_govde.webp')} style={{position: 'absolute', left: 0, top: 0, width: TUVAL_W, height: TUVAL_H}} />
      {kapali ? (
        <Img src={staticFile('hupo_goz_kapali.webp')} style={{position: 'absolute', left: GOZ.x, top: GOZ.y}} />
      ) : null}
      <Img
        src={staticFile('hupo_kanat.webp')}
        style={{
          position: 'absolute', left: KANAT.x, top: KANAT.y,
          transformOrigin: `${KANAT.pivot[0] - KANAT.x}px ${KANAT.pivot[1] - KANAT.y}px`,
          transform: `rotate(${-aci}deg)`,
        }}
      />
    </div>
  );
};

export const HupoUyanir: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  // Zemin: ilk karede duz turkuaz (sistem splash'iyle ayni), sonra gradyan
  const zeminT = interpolate(frame, [0, 12], [0, 1], {...clamp, easing: Easing.out(Easing.quad)});

  // Hupo: native boyutu (144 dp ~ 377 px) -> tam boy (~669 px); merkezden asagi yerlesir
  const boyBas = 377 / 669;
  const buyume = spring({frame: frame - 10, fps, config: {damping: 14, stiffness: 120, mass: 0.9}});
  const sicrama = frame >= 14 && frame < 26 ? -46 * Math.sin(((frame - 14) / 12) * Math.PI) : 0;
  const nefes = frame > 60 ? 1 + 0.008 * Math.sin(((frame - 60) / 30) * Math.PI * 2) : 1;
  const olcek = (0.743 * 669 / 669) * (boyBas + (1 - boyBas) * Math.min(buyume, 1.04)) * nefes * (669 / 669);
  const merkezY = interpolate(frame, [10, 34], [960, 905], {...clamp, easing: Easing.out(Easing.cubic)}) + sicrama;

  // Altin yay: kanat ucundan (sag ust) yazinin altina
  const yayT = interpolate(frame, [26, 46], [0, 1], {...clamp, easing: Easing.inOut(Easing.cubic)});
  const yayYok = interpolate(frame, [46, 52], [1, 1], clamp);

  // Marka adi: harf harf
  const HARFLER = 'Hupolingo'.split('');
  // Konusma balonu
  const balon = spring({frame: frame - 62, fps, config: {damping: 12, stiffness: 140}});

  return (
    <AbsoluteFill style={{background: `linear-gradient(180deg, ${PRIMARY} 0%, ${PRIMARY} ${0}%, ${mix(PRIMARY, PRIMARY_LIGHT, zeminT)} 100%)`, fontFamily}}>
      {/* parcaciklar: sag ust agirlikli, deterministik */}
      {PARCACIK.map((p, i) => (
        <div key={i} style={{position: 'absolute', left: p[0] * 1080, top: p[1] * 1920 - frame * 0.6, width: p[2] * 1080, height: p[2] * 1080, borderRadius: '50%', background: 'rgba(255,255,255,0.5)', opacity: zeminT * p[3]}} />
      ))}

      {/* Hupo */}
      <div style={{position: 'absolute', left: 540 - TUVAL_W / 2, top: merkezY - TUVAL_H / 2, width: TUVAL_W, height: TUVAL_H}}>
        <Hupo frame={frame} fps={fps} olcek={olcek} />
      </div>

      {/* altin kanat yayi */}
      <svg width={1080} height={1920} style={{position: 'absolute', left: 0, top: 0}}>
        <path d="M 905 760 C 1090 1190, 820 1720, 170 1800" fill="none" stroke={SUN} strokeWidth={14} strokeLinecap="round" pathLength={1} strokeDasharray={1} strokeDashoffset={1 - yayT} opacity={yayYok} />
      </svg>

      {/* marka adi */}
      <div style={{position: 'absolute', left: 0, right: 0, top: 1560, display: 'flex', justifyContent: 'center'}}>
        {HARFLER.map((h, i) => {
          const s = spring({frame: frame - (38 + i * 1.6), fps, config: {damping: 13, stiffness: 150}});
          return (
            <span key={i} style={{fontSize: 168, fontWeight: 900, color: '#fff', opacity: Math.min(1, s * 1.4), transform: `translateY(${(1 - s) * 70}px)`, display: 'inline-block', letterSpacing: -2}}>{h}</span>
          );
        })}
      </div>

      {/* konusma balonu */}
      <div style={{position: 'absolute', left: 60, top: 440, transform: `scale(${Math.max(0, balon)})`, transformOrigin: 'bottom left', opacity: Math.min(1, balon * 2),
        background: '#fff', borderRadius: 48, padding: '34px 48px', fontSize: 58, fontWeight: 800, color: INK}}>
        Merhaba, ben Hupo!
        <div style={{position: 'absolute', left: 120, bottom: -26, width: 0, height: 0, borderLeft: '22px solid transparent', borderRight: '22px solid transparent', borderTop: '30px solid #fff'}} />
      </div>
    </AbsoluteFill>
  );
};

const PARCACIK: number[][] = [
  [0.71, 0.03, 0.030, 0.5], [0.84, 0.06, 0.018, 0.4], [0.92, 0.02, 0.036, 0.3], [0.78, 0.14, 0.022, 0.5],
  [0.96, 0.11, 0.013, 0.4], [0.88, 0.21, 0.028, 0.25], [0.63, 0.07, 0.016, 0.35], [0.74, 0.26, 0.012, 0.3],
  [0.93, 0.27, 0.024, 0.25], [0.68, 0.17, 0.014, 0.45],
];

function mix(a: string, b: string, t: number): string {
  const p = (h: string) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));
  const [r1, g1, b1] = p(a); const [r2, g2, b2] = p(b);
  const c = (x: number, y: number) => Math.round(x + (y - x) * t);
  return `rgb(${c(r1, r2)}, ${c(g1, g2)}, ${c(b1, b2)})`;
}