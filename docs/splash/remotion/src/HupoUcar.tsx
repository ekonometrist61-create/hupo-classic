import React from 'react';
import {AbsoluteFill, Easing, Img, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {loadFont} from '@remotion/google-fonts/Nunito';

const {fontFamily} = loadFont('normal', {weights: ['800', '900'], subsets: ['latin', 'latin-ext']});

export const UCAR_TOPLAM = 132; // 4,4 sn @30 fps

const PRIMARY = '#147D8A';
const PRIMARY_LIGHT = '#4FB3BF';
const SUN = '#F5C842';
const INK = '#17324D';

// Durus pozu (katmanli master) - hupo_katmanlar_v2.json, 845x900 tuvali
const W = 845;
const H = 900;
const SOL = {x: 0, y: 420, piv: [292, 450] as const};
const SAG = {x: 530, y: 90, piv: [560, 440] as const};
const GOZ = {x: 165, y: 121};
const GOZ_ORTA = [389, 277] as const; // master iki iris orta noktasi

// Ucus pozlari (1500x1500, goz orta noktasi (750,640))
const UC = 1500;
const UC_ANKRAJ = [750, 640] as const;
// poz basina govde oynamasi (px, ucus sprite olceginde): kanat asagi inerken govde yukselir
const POZ_DIKEY: Record<string, number> = {p1: 26, p2: 0, p3: -34, p4: 0};
const DONGU = ['p1', 'p1', 'p1', 'p2', 'p2', 'p2', 'p3', 'p3', 'p3', 'p2', 'p2', 'p2']; // 12 kare = 2,5 Hz

const clamp = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'} as const;
const lim = (v: number, a: number, b: number) => Math.min(b, Math.max(a, v));

const P0: [number, number] = [1380, -260];
const C1: [number, number] = [1120, 640];
const C2: [number, number] = [-60, 380];
const P3: [number, number] = [540, 880];
const bez = (u: number): [number, number] => {
  const m = 1 - u;
  const f = (a: number, b: number, c: number, d: number) => m * m * m * a + 3 * m * m * u * b + 3 * m * u * u * c + u * u * u * d;
  return [f(P0[0], C1[0], C2[0], P3[0]), f(P0[1], C1[1], C2[1], P3[1])];
};

const UCUS_SON = 54; // ucus biter, iniş frenlemesi baslar
const DEGME = 60; // yere degdigi kare

const DurusPozu: React.FC<{frame: number}> = ({frame}) => {
  let sag = 0;
  let sol = 0;
  if (frame >= 70 && frame < 112) {
    const t = (frame - 70) / 10;
    const g = interpolate(frame, [70, 76, 104, 112], [0, 1, 1, 0], clamp);
    sag = (-6 + 13 * Math.sin(t * Math.PI * 2)) * g;
    sol = 8 * Math.sin(t * Math.PI * 2 + 1.2) * g;
  }
  const kirp = frame >= 62 && frame < 65;
  const mutlu = frame >= 68 && frame < 124;
  return (
    <div style={{position: 'absolute', left: -GOZ_ORTA[0], top: -GOZ_ORTA[1], width: W, height: H}}>
      <Img src={staticFile('hupo_govde_kanatsiz.webp')} style={{position: 'absolute', left: 0, top: 0, width: W, height: H}} />
      {mutlu ? <Img src={staticFile('hupo_goz_mutlu.webp')} style={{position: 'absolute', left: GOZ.x, top: GOZ.y}} /> : null}
      {kirp && !mutlu ? <Img src={staticFile('hupo_goz_kapali.webp')} style={{position: 'absolute', left: GOZ.x, top: GOZ.y}} /> : null}
      <Img src={staticFile('hupo_kanat_sol.webp')} style={{position: 'absolute', left: SOL.x, top: SOL.y, transformOrigin: `${SOL.piv[0] - SOL.x}px ${SOL.piv[1] - SOL.y}px`, transform: `rotate(${lim(sol, -12, 45)}deg)`}} />
      <Img src={staticFile('hupo_kanat_sag.webp')} style={{position: 'absolute', left: SAG.x, top: SAG.y, transformOrigin: `${SAG.piv[0] - SAG.x}px ${SAG.piv[1] - SAG.y}px`, transform: `rotate(${lim(sag, -30, 25)}deg)`}} />
    </div>
  );
};

export const HupoUcar: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  // --- yol ---
  const u = interpolate(frame, [6, UCUS_SON], [0, 1], {...clamp, easing: Easing.out(Easing.cubic)});
  const [bx, by0] = bez(u);
  const inis = interpolate(frame, [UCUS_SON, DEGME], [0, 78], {...clamp, easing: Easing.in(Easing.quad)});
  const zip = frame >= 72 && frame < 96 ? -34 * Math.abs(Math.sin(((frame - 72) / 12) * Math.PI)) * interpolate(frame, [72, 96], [1, 0.6], clamp) : 0;

  // --- poz secimi ---
  const ucuyor = frame >= 6 && frame < DEGME;
  let poz = 'p2';
  if (frame >= UCUS_SON) poz = 'p4';
  else if (frame >= 6) poz = DONGU[(frame - 6) % 12];
  const bob = frame >= 6 && frame < UCUS_SON ? POZ_DIKEY[poz] : 0;

  // --- boyut ve donus ---
  const s = interpolate(u, [0, 1], [0.3, 0.8], {easing: Easing.in(Easing.quad)});
  const bank = interpolate(u, [0, 0.45, 1], [-16, 9, 0]) * (frame < UCUS_SON ? 1 : interpolate(frame, [UCUS_SON, DEGME], [1, 0], clamp)) + (frame >= 70 && frame < 112 ? 3 * Math.sin(((frame - 70) / 20) * Math.PI * 2) : 0);
  const sy = interpolate(frame, [DEGME, DEGME + 2, DEGME + 5, DEGME + 10], [1, 0.88, 1.05, 1], clamp);
  const sx = Math.min(1.12, 2 - sy);

  // goz orta noktasi (ekran): ucuyor: yol + govde oynamasi; duruyor: onceki yerlesim
  const ax = bx;
  const ay = by0 + inis + zip + bob * s;

  // --- zemin ---
  const zeminT = interpolate(frame, [0, 20], [0, 1], clamp);
  const golgeA = interpolate(frame, [38, 58], [0, 0.3], clamp);
  const golgeS = interpolate(frame, [30, 58], [0.5, 1], clamp);
  const kiv = frame >= 68 && frame < 100;
  const kt = interpolate(frame, [68, 100], [0, 1], clamp);
  const balon = spring({frame: frame - 72, fps, config: {damping: 12, stiffness: 150}});
  const yayT = interpolate(frame, [96, 114], [0, 1], {...clamp, easing: Easing.inOut(Easing.cubic)});
  const HARF = 'Hupolingo'.split('');

  return (
    <AbsoluteFill style={{background: `linear-gradient(180deg, ${PRIMARY} 0%, ${mix(PRIMARY, PRIMARY_LIGHT, zeminT * 0.35)} 45%, ${mix(PRIMARY, PRIMARY_LIGHT, zeminT)} 100%)`, fontFamily}}>
      {PARCACIK.map((p, i) => (
        <div key={i} style={{position: 'absolute', left: p[0] * 1080, top: p[1] * 1920 - frame * 0.7, width: p[2] * 1080, height: p[2] * 1080, borderRadius: '50%', background: 'rgba(255,255,255,0.5)', opacity: zeminT * p[3]}} />
      ))}

      {frame >= 8 && frame < 62 ? [1, 2, 3, 4, 5, 6].map((k) => {
        const uk = Math.max(0, u - k * 0.045);
        const [px, py] = bez(uk);
        return <div key={k} style={{position: 'absolute', left: px - 20 + k * 6, top: py + 120, width: 40 - k * 4, height: 40 - k * 4, borderRadius: '50%', background: '#fff', opacity: Math.max(0, 0.34 - k * 0.05) * interpolate(frame, [44, 60], [1, 0], clamp)}} />;
      }) : null}

      <div style={{position: 'absolute', left: 540 - 330 * golgeS, top: 1335 - 36 * golgeS, width: 660 * golgeS, height: 72 * golgeS, borderRadius: '50%', background: 'radial-gradient(ellipse at center, rgba(6,50,58,0.9) 0%, rgba(6,50,58,0) 70%)', opacity: golgeA}} />

      {/* Hupo: ankraj = iki gozun orta noktasi; govde merkezi etrafinda doner */}
      {frame >= 6 ? (
        <div style={{position: 'absolute', left: ax, top: ay, width: 0, height: 0, transform: `rotate(${bank}deg) scale(${s * sx}, ${s * sy})`, transformOrigin: '0px 300px'}}>
          {ucuyor ? (
            <Img src={staticFile(`ucus_${poz}.webp`)} style={{position: 'absolute', left: -UC_ANKRAJ[0], top: -UC_ANKRAJ[1], width: UC, height: UC}} />
          ) : (
            <DurusPozu frame={frame} />
          )}
        </div>
      ) : null}

      {kiv ? [0, 1, 2, 3, 4, 5, 6, 7].map((i) => {
        const a = (i / 8) * Math.PI * 2 + 0.3;
        const r = 330 + 230 * kt + (i % 2) * 40;
        const x = 540 + Math.cos(a) * r;
        const y = 900 - 20 + Math.sin(a) * r * 0.85;
        const o = Math.sin(kt * Math.PI) * 0.95;
        const sz = 46 + (i % 3) * 14;
        return (
          <svg key={i} width={sz} height={sz} viewBox="-10 -10 20 20" style={{position: 'absolute', left: x - sz / 2, top: y - sz / 2, opacity: o, transform: `rotate(${kt * 60 + i * 15}deg)`}}>
            <path d="M0 -9 C1 -2 2 -1 9 0 C2 1 1 2 0 9 C-1 2 -2 1 -9 0 C-2 -1 -1 -2 0 -9 Z" fill={i % 2 ? '#fff' : SUN} />
          </svg>
        );
      }) : null}

      <svg width={1080} height={1920} style={{position: 'absolute', left: 0, top: 0}}>
        <path d="M 905 880 C 1090 1250, 820 1730, 170 1810" fill="none" stroke={SUN} strokeWidth={14} strokeLinecap="round" pathLength={1} strokeDasharray={1} strokeDashoffset={1 - yayT} />
      </svg>

      <div style={{position: 'absolute', left: 0, right: 0, top: 1570, display: 'flex', justifyContent: 'center'}}>
        {HARF.map((h, i) => {
          const sp = spring({frame: frame - (102 + i * 1.6), fps, config: {damping: 13, stiffness: 150}});
          return <span key={i} style={{fontSize: 168, fontWeight: 900, color: '#fff', opacity: Math.min(1, sp * 1.4), transform: `translateY(${(1 - sp) * 70}px)`, display: 'inline-block', letterSpacing: -2}}>{h}</span>;
        })}
      </div>

      <div style={{position: 'absolute', left: 90, top: 420, transform: `scale(${Math.max(0, balon)})`, transformOrigin: 'bottom left', opacity: Math.min(1, balon * 2), background: '#fff', borderRadius: 52, padding: '36px 56px', fontSize: 76, fontWeight: 900, color: INK}}>
        Hoş geldin!
        <div style={{position: 'absolute', left: 150, bottom: -28, width: 0, height: 0, borderLeft: '24px solid transparent', borderRight: '24px solid transparent', borderTop: '32px solid #fff'}} />
      </div>
    </AbsoluteFill>
  );
};

const PARCACIK: number[][] = [
  [0.71, 0.03, 0.03, 0.5], [0.84, 0.06, 0.018, 0.4], [0.92, 0.02, 0.036, 0.3], [0.78, 0.14, 0.022, 0.5],
  [0.96, 0.11, 0.013, 0.4], [0.88, 0.21, 0.028, 0.25], [0.63, 0.07, 0.016, 0.35], [0.74, 0.26, 0.012, 0.3],
  [0.93, 0.27, 0.024, 0.25], [0.68, 0.17, 0.014, 0.45],
];

function mix(a: string, b: string, t: number): string {
  const p = (h: string) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));
  const [r1, g1, b1] = p(a);
  const [r2, g2, b2] = p(b);
  const c = (x: number, y: number) => Math.round(x + (y - x) * t);
  return `rgb(${c(r1, r2)}, ${c(g1, g2)}, ${c(b1, b2)})`;
}
