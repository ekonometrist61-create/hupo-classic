import React, {useEffect, useRef, useState} from 'react';
import {Audio, AbsoluteFill, continueRender, delayRender, Easing, Img, interpolate, interpolateColors, random, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {getLength, getPointAtLength, evolvePath} from '@remotion/paths';
import {loadFont} from '@remotion/google-fonts/Nunito';
import veri from '../data/hupo_noktalar.json';

const {fontFamily, waitUntilDone} = loadFont('normal', {weights: ['600', '700', '900'], subsets: ['latin', 'latin-ext']});

// HUPO GIRIS FILMI: "Kelime Evreni". 5,0 sn; mobil (1080x2340) ve web (1920x1080) ayni zaman cizelgesi, farkli yerlesim.
export const GIRIS_SURE = 5.0;

// AppColors (mobile-app/lib/theme/app_theme.dart)
const PRIMARY = '#147D8A';
const SUN = '#F5C842';
const SUN_DARK = '#D9A91E';

// Gece/safak renkleri (marka turkuazindan turetildi; ilk ve son kare marka turkuazi)
const TURK: [string, string, string] = ['#0F6C78', '#147D8A', '#1B8A97']; // ust, orta, alt
const GECE: [string, string, string] = ['#021419', '#06303A', '#0A4651'];

// Hupo katman seti (845x900 tuvali) - hupo_katmanlar_v2.json
const RW = 845;
const RH = 900;
const SAG = {x: 530, y: 90, piv: [560, 440] as const};
const SOL = {x: 0, y: 420};
const GOZ = {x: 165, y: 121};
const TIP = [806, 100] as const; // sag kanat ucu

const clamp = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'} as const;
const easeOut = Easing.bezier(0.16, 1, 0.3, 1);
const easeInOut = Easing.bezier(0.65, 0, 0.35, 1);
const easePop = Easing.bezier(0.34, 1.4, 0.64, 1);

type P = [number, number];

type Xf = {cx: number; cy: number; k: number; tilt: number; sx: number; sy: number};
const toScreen = (xf: Xf, px: number, py: number): P => {
  const x = (px - RW / 2) * xf.k * xf.sx;
  const y = (py - RH / 2) * xf.k * xf.sy;
  const a = (xf.tilt * Math.PI) / 180;
  return [xf.cx + x * Math.cos(a) - y * Math.sin(a), xf.cy + x * Math.sin(a) + y * Math.cos(a)];
};

const Rig: React.FC<{xf: Xf; kanat: number; gozKapali: boolean; opacity: number}> = ({xf, kanat, gozKapali, opacity}) => (
  <div style={{position: 'absolute', left: xf.cx - RW / 2, top: xf.cy - RH / 2, width: RW, height: RH, opacity, transform: `rotate(${xf.tilt}deg) scale(${xf.k * xf.sx}, ${xf.k * xf.sy})`, transformOrigin: '50% 50%'}}>
    <Img src={staticFile('hupo_govde_kanatsiz.webp')} style={{position: 'absolute', left: 0, top: 0, width: RW, height: RH}} />
    {gozKapali ? <Img src={staticFile('hupo_goz_kapali.webp')} style={{position: 'absolute', left: GOZ.x, top: GOZ.y}} /> : null}
    <Img src={staticFile('hupo_kanat_sol.webp')} style={{position: 'absolute', left: SOL.x, top: SOL.y}} />
    <Img src={staticFile('hupo_kanat_sag.webp')} style={{position: 'absolute', left: SAG.x, top: SAG.y, transformOrigin: `${SAG.piv[0] - SAG.x}px ${SAG.piv[1] - SAG.y}px`, transform: `rotate(${kanat}deg)`}} />
  </div>
);

const STAR_PATH = 'M0 -9 C1 -2 2 -1 9 0 C2 1 1 2 0 9 C-1 2 -2 1 -9 0 C-2 -1 -1 -2 0 -9 Z';

// Wordmark olcumu: yazi tipi yuklendikten sonra kutu bir kez olculur (arc ve alt cizgi buna gore cizilir)
const useRect = () => {
  const ref = useRef<HTMLDivElement>(null);
  const [rect, setRect] = useState<{l: number; t: number; w: number; h: number} | null>(null);
  const [handle] = useState(() => delayRender('wordmark-olcum'));
  useEffect(() => {
    waitUntilDone().then(() => {
      const r = ref.current!.getBoundingClientRect();
      setRect({l: r.left, t: r.top, w: r.width, h: r.height});
      continueRender(handle);
    });
  }, [handle]);
  return {ref, rect};
};

const GLIF = ['ğ', 'ş', 'ı', 'ç', 'ö', 'ü', 'Ğ', 'Ş', 'İ', 'Ç', 'Ö', 'Ü', 'k', 'e', 'l', 'a'];
const KELIME = 'Hupolingo';

export const HupoGiris: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps, width: W, height: H} = useVideoConfig();
  const t = frame / fps;
  const portrait = H > W;
  const U = Math.min(W, H) / 1080;
  const {ref: wordRef, rect} = useRect();

  // ---------- yerlesim ----------
  const base = portrait ? {cx: W / 2, cy: H * 0.41, k: 0.86} : {cx: W * 0.21, cy: H * 0.5, k: 0.74};

  // ---------- zaman ----------
  const faz = interpolate(t, [0, 0.55, 1.9, 3.2], [0, 1, 1, 2], {...clamp, easing: easeInOut}); // 0 turkuaz, 1 gece, 2 safak
  const gece = interpolate(faz, [0, 1, 2], [0, 1, 0]); // yildizlarin gorunurlugu
  const camS = interpolate(t, [0.3, 2.6, 4.1], [1.0, 1.07, 1.0], {...clamp, easing: easeInOut});
  const camC: P = [W / 2, H / 2];

  // ---------- Hupo hareketi ----------
  const havada = interpolate(t, [0.9, 1.7], [0, 1], clamp);
  const hover = Math.sin((t - 0.9) * Math.PI * 2 * 0.55) * 9 * U * havada;
  const hopT = t - 2.48;
  // ucus: hazirlik (sikisma) -> sicrama -> inis -> oturma
  const sy = interpolate(hopT, [-0.1, 0.0, 0.18, 0.42, 0.52, 0.66], [1, 0.93, 1.05, 1.0, 0.95, 1.0], {...clamp, easing: easeInOut});
  const sx = 1 + (1 - sy) * 0.55;
  const hopY = interpolate(hopT, [0, 0.2, 0.42], [0, -46 * U, 0], {...clamp, easing: easeInOut});
  const nefes = 1 + 0.010 * Math.sin((t - 3.3) * Math.PI * 2 * 0.7) * interpolate(t, [3.2, 3.6], [0, 1], clamp);
  const tilt = 1.6 * Math.sin((t - 0.9) * Math.PI * 2 * 0.37) * havada + interpolate(hopT, [0, 0.2, 0.5], [0, -2.2, 0], {...clamp, easing: easeInOut});
  const xf: Xf = {cx: base.cx, cy: base.cy + hover + hopY, k: base.k * nefes, tilt, sx, sy};

  const gozKapali = t < 2.52 || (t >= 3.08 && t < 3.2);
  const dal = hopT - 0.1; // kanat selami: sonumlenen salinim
  const kanat = hopT > 0.1 ? -9 * Math.sin(dal * Math.PI * 2 * 2.3) * Math.exp(-dal * 2.4) : 0;
  const hupoOpak = interpolate(t, [1.95, 2.45], [0, 1], {...clamp, easing: easeOut});
  const noktaOpak = interpolate(t, [2.0, 2.55], [1, 0], clamp);

  // kanat ucu (ekran): ark baslangici
  const ang = (kanat * Math.PI) / 180;
  const dx = TIP[0] - SAG.piv[0];
  const dy = TIP[1] - SAG.piv[1];
  const tipW = toScreen(xf, SAG.piv[0] + dx * Math.cos(ang) - dy * Math.sin(ang), SAG.piv[1] + dx * Math.sin(ang) + dy * Math.cos(ang));
  const tip: P = [camC[0] + (tipW[0] - camC[0]) * camS, camC[1] + (tipW[1] - camC[1]) * camS];

  // ---------- gokyuzu ----------
  // ilk kare native splash ile ayni DUZ #147D8A; son kare hafif gradyanli turkuaz
  const bg = [0, 1, 2].map((i) => interpolateColors(faz, [0, 1, 2], [PRIMARY, GECE[i], TURK[i]]));
  const ufuk = interpolate(t, [2.1, 3.3], [0, 1], {...clamp, easing: easeOut});

  const yildizlar = Array.from({length: 150}, (_, i) => {
    const z = 0.35 + 0.65 * random(`z${i}`);
    return {x: random(`x${i}`) * W, y: random(`y${i}`) * H, r: (0.9 + 2.2 * random(`r${i}`)) * z * U * 1.4, z, ph: random(`p${i}`) * 6.28};
  });
  const glifler = GLIF.map((g, i) => {
    const z = 0.4 + 0.6 * random(`gz${i}`);
    return {g, x: random(`gx${i}`) * W, y: random(`gy${i}`) * H, s: (110 + 190 * z) * U, z, rot: (random(`gr${i}`) - 0.5) * 50, blur: z < 0.6 ? 4 * U : 0};
  });

  // ---------- parcaciklar ----------
  const goz = veri.goz as [number, number][];
  const gozOrta: P = [(goz[0][0] + goz[1][0]) / 2, (goz[0][1] + goz[1][1]) / 2];
  const maxD = 620;
  const noktalar = (veri.n as number[][]).map((n, i) => {
    const hedefW = toScreen(xf, n[0], n[1]);
    const hedef: P = [camC[0] + (hedefW[0] - camC[0]) * camS, camC[1] + (hedefW[1] - camC[1]) * camS];
    const baslangic: P = [random(`sx${i}`) * W, random(`sy${i}`) * H];
    const d = Math.hypot(n[0] - gozOrta[0], n[1] - gozOrta[1]);
    const gecik = 0.85 + 0.5 * Math.min(1, d / maxD) + 0.1 * random(`d${i}`);
    const sure = 0.62;
    const u = interpolate(t, [gecik, gecik + sure], [0, 1], clamp);
    const e = easeOut(u);
    const dir = random(`w${i}`) > 0.5 ? 1 : -1;
    const mx = (baslangic[0] + hedef[0]) / 2;
    const my = (baslangic[1] + hedef[1]) / 2;
    const vx = hedef[0] - baslangic[0];
    const vy = hedef[1] - baslangic[1];
    const ctrl: P = [mx - vy * 0.35 * dir, my + vx * 0.35 * dir];
    const q = (s: number): P => {
      const m = 1 - s;
      return [m * m * baslangic[0] + 2 * m * s * ctrl[0] + s * s * hedef[0], m * m * baslangic[1] + 2 * m * s * ctrl[1] + s * s * hedef[1]];
    };
    const p = q(e);
    const pEski = q(Math.max(0, e - 0.05)); // iz: yol uzayinda sabit kisa kuyruk (eased u degil)
    return {i, n, p, pEski, u, e};
  });

  // ---------- gozler: iki yildiz ----------
  const gozXf = goz.map((g) => {
    const w = toScreen(xf, g[0], g[1]);
    return [camC[0] + (w[0] - camC[0]) * camS, camC[1] + (w[1] - camC[1]) * camS] as P;
  });
  const gozYildizOpak = interpolate(t, [0.45, 0.95], [0, 1], {...clamp, easing: easeOut}) * interpolate(t, [2.38, 2.52], [1, 0], clamp);
  const nabiz = 1 + 0.12 * Math.sin((t - 0.45) * Math.PI * 2 * 1.4);
  const gozBoyut = 112 * U * interpolate(t, [0.45, 0.95], [0.2, 1], {...clamp, easing: easePop}) * nabiz;
  const patla = t - 2.5;

  // ---------- altin ark ----------
  const arkIlerleme = interpolate(t, [3.12, 3.95], [0, 1], {...clamp, easing: easeInOut});
  let arkPath = '';
  let arkUzunluk = 0;
  let yildizNokta: P = [0, 0];
  if (rect) {
    const xL = rect.l + rect.w * 0.02;
    const xR = rect.l + rect.w * 0.98;
    const yU = rect.t + rect.h + 10 * U;
    const X1 = Math.min(W - 70 * U, xR + 70 * U);
    // tek akici "S": kanat ucundan acilir, yazinin sag ucunu sarip alt cizgiye iner
    arkPath = portrait
      ? `M ${tip[0]} ${tip[1]} C ${tip[0] + 190 * U} ${tip[1] + 30 * U} ${X1 + 40 * U} ${rect.t - 380 * U} ${X1} ${rect.t - 70 * U} ` +
        `C ${X1 - 10 * U} ${rect.t + rect.h * 0.55} ${xR + 20 * U} ${yU + 38 * U} ${xR - 70 * U} ${yU + 30 * U} ` +
        `C ${rect.l + rect.w * 0.62} ${yU + 46 * U} ${rect.l + rect.w * 0.28} ${yU + 40 * U} ${xL} ${yU - 6 * U}`
      : `M ${tip[0]} ${tip[1]} C ${tip[0] + 230 * U} ${tip[1] - 40 * U} ${X1 + 60 * U} ${rect.t - 150 * U} ${X1} ${rect.t + rect.h * 0.15} ` +
        `C ${X1 - 8 * U} ${rect.t + rect.h * 0.7} ${xR + 20 * U} ${yU + 38 * U} ${xR - 70 * U} ${yU + 30 * U} ` +
        `C ${rect.l + rect.w * 0.62} ${yU + 46 * U} ${rect.l + rect.w * 0.28} ${yU + 40 * U} ${xL} ${yU - 6 * U}`;
    arkUzunluk = getLength(arkPath);
    yildizNokta = (() => {
      const pt = getPointAtLength(arkPath, arkUzunluk * arkIlerleme);
      return [pt.x, pt.y] as P;
    })();
  }
  const ark = arkPath ? evolvePath(arkIlerleme, arkPath) : null;

  // ---------- kelime isareti ----------
  const harfBas = 3.0;
  const wordSize = (portrait ? 150 : 176) * U;
  const tagOpak = interpolate(t, [4.1, 4.55], [0, 1], {...clamp, easing: easeOut});
  const wordTop = portrait ? H * 0.645 : H * 0.4;
  const wordLeft = portrait ? 0 : W * 0.40;
  const wordCss: React.CSSProperties = portrait
    ? {position: 'absolute', left: 0, width: W, top: wordTop, display: 'flex', justifyContent: 'center'}
    : {position: 'absolute', left: wordLeft, top: wordTop, display: 'flex'};

  return (
    <AbsoluteFill style={{background: `linear-gradient(180deg, ${bg[0]} 0%, ${bg[1]} 55%, ${bg[2]} 100%)`, fontFamily, overflow: 'hidden'}}>
      {/* safak ufku: ince sicak isik (yalniz dekor; altin yalniz imzada tam renk) */}
      <AbsoluteFill style={{opacity: ufuk, background: `radial-gradient(ellipse 85% 42% at 50% ${portrait ? 40 : 50}%, rgba(150,225,232,0.20) 0%, rgba(150,225,232,0) 70%)`}} />

      {/* dunya: yildizlar, harfler, parcaciklar, Hupo (kamera itmesi) */}
      <AbsoluteFill style={{transform: `scale(${camS})`, transformOrigin: `${camC[0]}px ${camC[1]}px`}}>
        {/* harf bulutu */}
        {glifler.map((g, i) => {
          const o = gece * (1 - ufuk * 0.9) * (0.05 + 0.1 * g.z);
          const dy2 = -t * 14 * g.z * U;
          return (
            <div key={i} style={{position: 'absolute', left: g.x, top: g.y + dy2, fontSize: g.s, fontWeight: 900, color: '#bfeaf0', opacity: o, transform: `rotate(${g.rot + t * 2 * g.z}deg)`, filter: g.blur ? `blur(${g.blur}px)` : undefined, lineHeight: 1}}>
              {g.g}
            </div>
          );
        })}

        <svg width={W} height={H} style={{position: 'absolute', left: 0, top: 0}}>
          <defs>
            <radialGradient id="ig">
              <stop offset="0%" stopColor="#fff" stopOpacity="1" />
              <stop offset="35%" stopColor="#fff6cf" stopOpacity="0.55" />
              <stop offset="100%" stopColor="#fff6cf" stopOpacity="0" />
            </radialGradient>
          </defs>
          {/* alan yildizlari */}
          {yildizlar.map((s, i) => {
            const tw = 0.55 + 0.45 * Math.sin(t * 2.2 + s.ph);
            const o = gece * (1 - ufuk * 0.75) * tw * (0.35 + 0.65 * s.z);
            const yy = (((s.y - t * 10 * s.z * U) % H) + H) % H;
            return <circle key={i} cx={s.x} cy={yy} r={s.r} fill="#e8fbff" opacity={o} />;
          })}
          {/* parcaciklar: yildizlar toplanip Hupo olur */}
          {noktaOpak > 0.01 &&
            noktalar.map(({i, n, p, pEski, u}) => {
              const gorunur = interpolate(t, [0.55 + 0.4 * random(`v${i}`), 1.0 + 0.3 * random(`v${i}`)], [0, 1], clamp);
              const yolda = u > 0 && u < 1;
              const rHedef = (n[5] ? 5.2 : 6.4) * base.k * camS * 1.0;
              const r = interpolate(u, [0, 0.85, 1], [1.4 * U, rHedef * 0.9, rHedef], clamp);
              const renk = `rgb(${n[2]},${n[3]},${n[4]})`;
              const kar = u < 1 ? 0.55 + 0.45 * u : 1;
              const o = gorunur * noktaOpak * kar;
              return (
                <g key={i} opacity={o}>
                  {yolda ? <line x1={pEski[0]} y1={pEski[1]} x2={p[0]} y2={p[1]} stroke="#dff7fb" strokeWidth={r * 0.9} strokeLinecap="round" opacity={0.3 * (1 - u)} /> : null}
                  {yolda && random(`g${i}`) > 0.55 ? <circle cx={p[0]} cy={p[1]} r={r * 3} fill="url(#ig)" opacity={0.6 * (1 - u)} /> : null}
                  <circle cx={p[0]} cy={p[1]} r={r} fill={u < 1 ? '#eafcff' : renk} />
                </g>
              );
            })}
          {/* iki goz yildizi */}
          {gozXf.map((g, i) => (
            <g key={`gz${i}`} opacity={gozYildizOpak} transform={`translate(${g[0]} ${g[1]})`}>
              <circle r={gozBoyut * 0.95} fill="url(#ig)" opacity={0.7} />
              <g transform={`scale(${gozBoyut / 18}) rotate(${i ? 8 : -6})`}>
                <path d={STAR_PATH} fill="#ffffff" />
              </g>
            </g>
          ))}
          {/* goz acilisi: kivilcim serpintisi */}
          {patla > 0 && patla < 0.7
            ? gozXf.map((g, gi) =>
                Array.from({length: 7}, (_, k) => {
                  const a = (k / 7) * Math.PI * 2 + gi * 0.6 + random(`k${gi}${k}`) * 0.5;
                  const pr = easeOut(patla / 0.7);
                  const dist = (70 + 70 * random(`kd${gi}${k}`)) * U * pr;
                  const sz = (14 + 14 * random(`ks${gi}${k}`)) * U * (1 - pr);
                  return (
                    <g key={`k${gi}${k}`} transform={`translate(${g[0] + Math.cos(a) * dist} ${g[1] + Math.sin(a) * dist}) scale(${sz / 18})`} opacity={1 - pr * 0.6}>
                      <path d={STAR_PATH} fill={k % 2 ? SUN : '#ffffff'} />
                    </g>
                  );
                }),
              )
            : null}
        </svg>

        {/* Hupo'nun arkasinda yumusak isik (patlama degil, ince hale) */}
        <div style={{position: 'absolute', left: xf.cx - 520 * U, top: xf.cy - 520 * U, width: 1040 * U, height: 1040 * U, borderRadius: '50%', opacity: interpolate(t, [1.7, 2.3, 3.4], [0, 0.55, 0.22], {...clamp, easing: easeInOut}), background: 'radial-gradient(circle, rgba(255,243,200,0.55) 0%, rgba(255,243,200,0) 62%)'}} />
        <Rig xf={xf} kanat={kanat} gozKapali={gozKapali} opacity={hupoOpak} />
      </AbsoluteFill>

      {/* marka katmani (kamera disi: olcum ve ark buna gore) */}
      <div style={wordCss}>
        <div ref={wordRef} style={{position: 'relative', display: 'flex', fontSize: wordSize, lineHeight: 1.15, fontWeight: 900, color: '#fff', letterSpacing: -2 * U}}>
          {KELIME.split('').map((c, i) => {
            const s = harfBas + i * 0.055;
            const p = interpolate(t, [s, s + 0.45], [0, 1], {...clamp, easing: easeOut});
            // isik suprintisi: harf harf, soldan saga kisa bir parlama (hizalama bozulmaz)
            const g = Math.exp(-Math.pow((t - (3.95 + i * 0.06)) / 0.11, 2));
            const renk = interpolateColors(g, [0, 1], ['#ffffff', '#FFE9A0']);
            return (
              <span key={i} style={{display: 'inline-block', color: renk, opacity: p, transform: `translateY(${(1 - p) * 54 * U - g * 4 * U}px)`, filter: p < 1 ? `blur(${(1 - p) * 8 * U}px)` : undefined, textShadow: `0 6px 26px rgba(3,40,48,0.32), 0 0 ${28 * g * U}px rgba(255,226,140,${0.8 * g})`}}>
                {c}
              </span>
            );
          })}
        </div>
      </div>

      {/* slogan */}
      {rect ? (
        <div style={{position: 'absolute', left: portrait ? 0 : rect.l, width: portrait ? W : undefined, textAlign: portrait ? 'center' : 'left', top: rect.t + rect.h + 84 * U, fontSize: (portrait ? 56 : 54) * U, fontWeight: 700, color: 'rgba(255,255,255,0.96)', letterSpacing: 1.5 * U, textShadow: '0 2px 14px rgba(3,40,48,0.35)', opacity: tagOpak, transform: `translateY(${(1 - tagOpak) * 16 * U}px)`}}>
          Birlikte öğrenelim
        </div>
      ) : null}

      {/* altin kanat izi */}
      {/* ses: tum isaretler giris_ses.wav icinde zamanlanmistir (tools/giris_ses_uret.py) */}
      <Audio src={staticFile('giris_ses.wav')} />

      {ark && rect ? (
        <svg width={W} height={H} style={{position: 'absolute', left: 0, top: 0}}>
          <defs>
            <linearGradient id="altin" gradientUnits="userSpaceOnUse" x1={rect.l + rect.w} y1={rect.t} x2={rect.l} y2={rect.t + rect.h}>
              <stop offset="0%" stopColor="#FFE08A" />
              <stop offset="55%" stopColor={SUN} />
              <stop offset="100%" stopColor={SUN_DARK} />
            </linearGradient>
            <radialGradient id="ig2">
              <stop offset="0%" stopColor="#fff" />
              <stop offset="40%" stopColor="#ffe9a0" stopOpacity="0.6" />
              <stop offset="100%" stopColor="#ffe9a0" stopOpacity="0" />
            </radialGradient>
          </defs>
          <path d={arkPath} fill="none" stroke={SUN} strokeWidth={26 * U} strokeLinecap="round" opacity={0.16} strokeDasharray={ark.strokeDasharray} strokeDashoffset={ark.strokeDashoffset} />
          <path d={arkPath} fill="none" stroke="url(#altin)" strokeWidth={10 * U} strokeLinecap="round" strokeDasharray={ark.strokeDasharray} strokeDashoffset={ark.strokeDashoffset} />
          {arkIlerleme > 0 && arkIlerleme < 1 ? (
            <g transform={`translate(${yildizNokta[0]} ${yildizNokta[1]})`}>
              <circle r={46 * U} fill="url(#ig2)" />
              <g transform={`scale(${(30 * U) / 18})`}>
                <path d={STAR_PATH} fill="#fffbe6" />
              </g>
            </g>
          ) : null}
        </svg>
      ) : null}
    </AbsoluteFill>
  );
};
