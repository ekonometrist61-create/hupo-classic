import React from 'react';
import {AbsoluteFill, Easing, Img, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {loadFont} from '@remotion/google-fonts/Nunito';

const {fontFamily} = loadFont('normal', {weights: ['700', '800', '900'], subsets: ['latin', 'latin-ext']});

// HUPO SIGNATURE ENTRANCE: 1600 ms + 400 ms bekleme, 60 fps, 1080x2340 (Galaxy S23 FE orani)
export const IMZA_TOPLAM = 120;
const FPS = 60;
const DP = 1080 / 412; // 2,62 px/dp

// AppColors (mobile-app/lib/theme/app_theme.dart)
const PRIMARY = '#147D8A';
const PRIMARY_LIGHT = '#4FB3BF';
const PRIMARY_DARK = '#0D5762';
const SUN = '#F5C842';
const SUN_DARK = '#D9A91E';
const CREAM = '#FFF9ED';
const INK = '#17324D';
const MUTED = '#4A6A85';
const CORAL = '#D96A28';
const LINE = '#F0E6CF';

// Hupo katman seti (845x900 tuvali) - hupo_katmanlar_v2.json
const RW = 845;
const RH = 900;
const SAG = {x: 530, y: 90, piv: [560, 440] as const};
const SOL = {x: 0, y: 420, piv: [292, 450] as const};
const GOZ = {x: 165, y: 121};
const TIP = [806, 100] as const; // sag kanat ucu

const clamp = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'} as const;
const ms = (f: number) => (f * 1000) / FPS;
const ease = Easing.bezier(0.22, 0.9, 0.2, 1); // yumusak cikis
const easeIO = Easing.bezier(0.45, 0, 0.2, 1);

type P = [number, number];
const bez3 = (a: P, b: P, c: P, d: P, u: number): P => {
  const m = 1 - u;
  const f = (i: number) => m * m * m * a[i] + 3 * m * m * u * b[i] + 3 * m * u * u * c[i] + u * u * u * d[i];
  return [f(0), f(1)];
};

// --- Hupo yerlesimleri (px) ---
const STAGE: P = [540, 0.42 * 2340];
const HOME: P = [(20 + 52) * DP, (28 + 8 + 48 + 52) * DP]; // HeroHeader: 104 dp Hupo, sol 20 dp
const K_NATIVE = (144 * DP) / RH; // sistem splash'indeki Hupo boyu (144 dp)
const K_STAGE = (200 * DP) / RH;
const K_HOME = (104 * DP) / RH;

const Rig: React.FC<{cx: number; cy: number; k: number; tilt: number; kanat: number; gozKapali: boolean}> = ({cx, cy, k, tilt, kanat, gozKapali}) => (
  <div style={{position: 'absolute', left: cx - RW / 2, top: cy - RH / 2, width: RW, height: RH, transform: `rotate(${tilt}deg) scale(${k})`, transformOrigin: '50% 50%'}}>
    <Img src={staticFile('hupo_govde_kanatsiz.webp')} style={{position: 'absolute', left: 0, top: 0, width: RW, height: RH}} />
    {gozKapali ? <Img src={staticFile('hupo_goz_kapali.webp')} style={{position: 'absolute', left: GOZ.x, top: GOZ.y}} /> : null}
    <Img src={staticFile('hupo_kanat_sol.webp')} style={{position: 'absolute', left: SOL.x, top: SOL.y}} />
    <Img src={staticFile('hupo_kanat_sag.webp')} style={{position: 'absolute', left: SAG.x, top: SAG.y, transformOrigin: `${SAG.piv[0] - SAG.x}px ${SAG.piv[1] - SAG.y}px`, transform: `rotate(${kanat}deg)`}} />
  </div>
);

const Yildiz: React.FC<{x: number; y: number; boyut: number; opak: number; don: number; renk: string}> = ({x, y, boyut, opak, don, renk}) => (
  <svg width={boyut} height={boyut} viewBox="-10 -10 20 20" style={{position: 'absolute', left: x - boyut / 2, top: y - boyut / 2, opacity: opak, transform: `rotate(${don}deg)`}}>
    <path d="M0 -9 C1 -2 2 -1 9 0 C2 1 1 2 0 9 C-1 2 -2 1 -9 0 C-2 -1 -1 -2 0 -9 Z" fill={renk} />
  </svg>
);

// Ana sayfa ogesi: kademeli belirme (yalniz opaklik + kucuk kayma)
const Giris: React.FC<{t: number; bas: number; children: React.ReactNode; style?: React.CSSProperties; kayma?: number}> = ({t, bas, children, style, kayma = 22}) => {
  const p = interpolate(t, [bas, bas + 360], [0, 1], {...clamp, easing: ease});
  return <div style={{...style, opacity: p, transform: `translateY(${(1 - p) * kayma * DP / 2.62}px)`}}>{children}</div>;
};

// yildiz (seviye), simsek (XP), alev (seri): ikon fontuna bagli olmayan basit yollar
const IKON: Record<string, string> = {
  yildiz: 'M12 5 L13.9 9.6 L18.9 10 L15.1 13.3 L16.3 18.2 L12 15.6 L7.7 18.2 L8.9 13.3 L5.1 10 L10.1 9.6 Z',
  simsek: 'M13.2 4.5 L7.5 12.6 H11.2 L10.4 19.5 L16.5 11 H12.6 Z',
  alev: 'M12.2 4.3 C12.7 7.2 9.1 8.6 9.1 12.8 A3.1 3.1 0 0 0 15.3 12.8 C15.3 11.1 14.4 10.3 14 8.9 C13.6 7.5 13.5 5.8 12.2 4.3 Z',
};

const StatPill: React.FC<{ikon: string; renk: string; deger: string; etiket: string}> = ({ikon, renk, deger, etiket}) => (
  <div style={{width: 300, height: 150, borderRadius: 52, background: 'rgba(255,255,255,0.96)', display: 'flex', alignItems: 'center', gap: 22, padding: '0 28px', boxSizing: 'border-box'}}>
    <svg width={74} height={74} viewBox="0 0 24 24" style={{flexShrink: 0}}>
      <circle cx="12" cy="12" r="12" fill={renk} />
      <path d={IKON[ikon]} fill="#fff" />
    </svg>
    <div>
      <div style={{fontSize: 54, fontWeight: 900, color: INK, lineHeight: 1}}>{deger}</div>
      <div style={{fontSize: 27, fontWeight: 700, color: MUTED, marginTop: 6}}>{etiket}</div>
    </div>
  </div>
);

const Kart: React.FC<{y: number; h: number; baslik: string; alt: string; renk: string; ilerleme?: number}> = ({y, h, baslik, alt, renk, ilerleme}) => (
  <div style={{position: 'absolute', left: 52, right: 52, top: y, height: h, borderRadius: 52, background: '#fff', border: `3px solid ${LINE}`, display: 'flex', alignItems: 'center', gap: 34, padding: '0 36px', boxSizing: 'border-box'}}>
    <div style={{width: 110, height: 110, borderRadius: 34, background: renk, flexShrink: 0}} />
    <div style={{flex: 1}}>
      <div style={{fontSize: 46, fontWeight: 900, color: INK}}>{baslik}</div>
      <div style={{fontSize: 30, fontWeight: 700, color: MUTED, marginTop: 6}}>{alt}</div>
      {ilerleme !== undefined ? (
        <div style={{marginTop: 18, height: 18, borderRadius: 9, background: LINE}}>
          <div style={{width: `${ilerleme * 100}%`, height: '100%', borderRadius: 9, background: SUN}} />
        </div>
      ) : null}
    </div>
  </div>
);

export const HupoImza: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const t = ms(frame);

  // ================= HUPO =================
  // Sahne 1-2: sistem boyundan sahne boyuna yumusak buyume + hafif yukselme
  const buyu = interpolate(t, [300, 740], [0, 1], {...clamp, easing: ease});
  const kStage = K_NATIVE + (K_STAGE - K_NATIVE) * buyu;
  const stageY = STAGE[1] - 26 * buyu + 5 * Math.sin((t / 1000) * Math.PI * 2 * 0.9) * interpolate(t, [300, 700], [0, 1], clamp);
  // Sahne 3-4: Hupo, izin ucunda ana sayfa konumuna suzulur
  // 800-1300 ms: yumusak varis + cok hafif asim; 1300'de tam yerinde (spring cok uzun soniyordu)
  const gp = interpolate(t, [800, 1300], [0, 1], {...clamp, easing: Easing.bezier(0.22, 0.85, 0.25, 1.1)});
  const ctrl: P = [820, 640];
  const bx = (1 - gp) * (1 - gp) * STAGE[0] + 2 * (1 - gp) * gp * ctrl[0] + gp * gp * HOME[0];
  const by = (1 - gp) * (1 - gp) * stageY + 2 * (1 - gp) * gp * ctrl[1] + gp * gp * HOME[1];
  const k = t < 800 ? kStage : kStage + (K_HOME - kStage) * gp;
  const cx = t < 800 ? STAGE[0] : bx;
  const cy = t < 800 ? stageY : by;

  // goz: 0-400 uykuda, 400'de acilir, 600-660 dogal kirpma
  const gozKapali = t < 400 || (t >= 600 && t < 670);
  // kanat: katlanmis(+24) -> acilis (-7 asim) -> 0
  const kanat = t < 440 ? 24 : t < 640 ? interpolate(t, [440, 600, 640], [24, -7, -7], {...clamp, easing: Easing.bezier(0.3, 1.2, 0.4, 1)}) : interpolate(t, [640, 760], [-7, 0], {...clamp, easing: ease});
  // kucuk bas/govde egimi
  const tilt = interpolate(t, [440, 560, 700], [0, 2.4, 0], clamp);

  // kanat ucu (ekran) - kivilcim cikisi
  const ang = (kanat * Math.PI) / 180;
  const dx = TIP[0] - SAG.piv[0];
  const dy = TIP[1] - SAG.piv[1];
  const tx = SAG.piv[0] + dx * Math.cos(ang) - dy * Math.sin(ang);
  const ty = SAG.piv[1] + dx * Math.sin(ang) + dy * Math.cos(ang);
  const tipX = STAGE[0] + kStage * (tx - RW / 2);
  const tipY = STAGE[1] - 26 * buyu + kStage * (ty - RH / 2);

  // ================= SAHNE 3: ALTIN IZ =================
  const iz0: P = [tipX, tipY];
  const IZ_A: P = [1190, 520];
  const IZ_B: P = [760, 40];
  const IZ_C: P = [HOME[0] + 70, HOME[1] - 20];
  const baslik = interpolate(t, [750, 1180], [0, 1], {...clamp, easing: easeIO});
  const sonuk = interpolate(t, [1100, 1320], [1, 0], clamp);
  const izSegmentleri: React.ReactNode[] = [];
  if (t >= 750 && sonuk > 0) {
    const N = 56;
    const uzun = 0.5;
    for (let i = 0; i < N; i++) {
      const f0 = i / N;
      const f1 = (i + 1) / N;
      const u0 = baslik - uzun * (1 - f0);
      const u1 = baslik - uzun * (1 - f1);
      if (u1 <= 0) continue;
      const a = bez3(iz0, IZ_A, IZ_B, IZ_C, Math.max(0, u0));
      const b = bez3(iz0, IZ_A, IZ_B, IZ_C, Math.max(0, Math.min(1, u1)));
      const w = (1.2 + 7.5 * Math.pow(f1, 1.4)) * 1; // ince, uca dogru kalinlasir
      const al = Math.pow(f1, 1.6) * 0.95 * sonuk;
      izSegmentleri.push(<line key={`g${i}`} x1={a[0]} y1={a[1]} x2={b[0]} y2={b[1]} stroke={SUN} strokeOpacity={al * 0.28} strokeWidth={w * 3.4} strokeLinecap="round" />);
      izSegmentleri.push(<line key={`c${i}`} x1={a[0]} y1={a[1]} x2={b[0]} y2={b[1]} stroke={SUN} strokeOpacity={al} strokeWidth={w} strokeLinecap="round" />);
      izSegmentleri.push(<line key={`b${i}`} x1={a[0]} y1={a[1]} x2={b[0]} y2={b[1]} stroke="#fff" strokeOpacity={al * 0.8} strokeWidth={Math.max(1, w * 0.28)} strokeLinecap="round" />);
    }
  }
  const basKonum = bez3(iz0, IZ_A, IZ_B, IZ_C, Math.min(1, baslik));

  // ================= BASLIK MORFU: tam ekran turkuaz -> ana sayfa basligi =================
  const HEADER_H = 900;
  const morf = interpolate(t, [720, 1300], [0, 1], {...clamp, easing: easeIO});
  const baslikYuk = 2340 + (HEADER_H - 2340) * morf;
  const gradT = interpolate(t, [600, 1200], [0, 1], clamp);

  // ================= SAHNE 2 KIVILCIMLAR =================
  const kiv = [0, 1, 2].map((i) => {
    const bas = 520 + i * 55;
    const p = interpolate(t, [bas, bas + 300], [0, 1], {...clamp, easing: ease});
    const a = -0.9 - i * 0.55;
    const mesafe = (70 + i * 38) * p * DP / 2;
    return {x: tipX + Math.cos(a) * mesafe, y: tipY + Math.sin(a) * mesafe - p * 20, o: Math.sin(p * Math.PI) * 0.95, s: (34 + i * 10) * (0.5 + p * 0.6), d: p * 50 + i * 20, r: i === 1 ? '#fff' : SUN};
  });

  // ================= ANA SAYFA ICERIGI =================
  const progress = interpolate(t, [1300, 1650], [0, 0.62], {...clamp, easing: ease});
  const pillBas = [1210, 1270, 1330];

  return (
    <AbsoluteFill style={{background: CREAM, fontFamily, overflow: 'hidden'}}>
      {/* krem ana sayfa zemini ve kartlar (baslik daraldikca gorunur) */}
      <Giris t={t} bas={1290} style={{position: 'absolute', left: 0, top: 0, width: 1080, height: 2340}}>
        <div style={{position: 'absolute', left: 52, top: 960, fontSize: 56, fontWeight: 900, color: INK}}>Bugün</div>
      </Giris>
      <Giris t={t} bas={1330} style={{position: 'absolute', left: 0, top: 0, width: 1080, height: 2340}}>
        <Kart y={1070} h={200} baslik="Günlük hedef" alt="3 sorudan 2'si tamam" renk={SUN} ilerleme={0.66} />
      </Giris>
      <Giris t={t} bas={1380} style={{position: 'absolute', left: 0, top: 0, width: 1080, height: 2340}}>
        <Kart y={1300} h={170} baslik="Günlük görevler" alt="2 görev seni bekliyor" renk={CORAL} />
      </Giris>
      <Giris t={t} bas={1430} style={{position: 'absolute', left: 0, top: 0, width: 1080, height: 2340}}>
        <Kart y={1500} h={170} baslik="Matematik" alt="Kesirler · 4. sınıf" renk={PRIMARY} />
      </Giris>
      <Giris t={t} bas={1480} style={{position: 'absolute', left: 0, top: 0, width: 1080, height: 2340}}>
        <Kart y={1700} h={170} baslik="Türkçe" alt="Paragraf · 4. sınıf" renk={PRIMARY_LIGHT} />
      </Giris>

      {/* baslik: ilk karede duz turkuaz (sistem splash'iyle ayni), sonra HeroHeader gradyani */}
      <div style={{position: 'absolute', left: 0, top: 0, width: 1080, height: baslikYuk, background: PRIMARY, borderRadius: `0 0 ${94 * morf}px ${94 * morf}px`, overflow: 'hidden'}}>
        <div style={{position: 'absolute', inset: 0, opacity: gradT, background: `linear-gradient(135deg, ${PRIMARY_LIGHT} 0%, ${PRIMARY} 55%, ${PRIMARY_DARK} 100%)`}} />
        <div style={{position: 'absolute', right: -80, top: -105, width: 393, height: 393, borderRadius: '50%', background: '#fff', opacity: 0.1 * morf}} />
        <div style={{position: 'absolute', left: -130, top: baslikYuk > 900 ? 700 : 530, width: 315, height: 315, borderRadius: '50%', background: '#fff', opacity: 0.07 * morf}} />
        {/* sahne atmosferi (yalniz sahne suresince): ince parcaciklar */}
        {[[0.78, 0.1, 14], [0.9, 0.18, 9], [0.7, 0.24, 8], [0.93, 0.3, 11], [0.62, 0.08, 7]].map((p, i) => (
          <div key={i} style={{position: 'absolute', left: p[0] * 1080, top: p[1] * 2340, width: p[2], height: p[2], borderRadius: '50%', background: '#fff', opacity: interpolate(t, [100, 500, 1000, 1200], [0, 0.45, 0.45, 0], clamp)}} />
        ))}
      </div>

      {/* ust cubuk (karakter chip, zil, profil, cikis) */}
      <Giris t={t} bas={1150} style={{position: 'absolute', left: 0, top: 0, width: 1080, height: 300}} kayma={10}>
        <div style={{position: 'absolute', left: 52, top: 110, height: 98, width: 360, borderRadius: 49, background: 'rgba(255,255,255,0.22)'}} />
        {[0, 1, 2].map((i) => <div key={i} style={{position: 'absolute', right: 52 + i * 120, top: 118, width: 82, height: 82, borderRadius: 41, background: 'rgba(255,255,255,0.28)'}} />)}
      </Giris>

      {/* selamlama */}
      <Giris t={t} bas={1180} style={{position: 'absolute', left: 20 * DP + 104 * DP + 12 * DP, top: 290, width: 1080 - (20 * DP + 104 * DP + 12 * DP) - 52, color: '#fff', fontSize: 26 * DP, fontWeight: 900, lineHeight: 1.15}}>
        Merhaba şampiyon!
      </Giris>

      {/* StatPill x3 */}
      <div style={{position: 'absolute', left: 52, top: 560, display: 'flex', justifyContent: 'space-between', width: 1080 - 104}}>
        <Giris t={t} bas={pillBas[0]}><StatPill ikon="yildiz" renk={SUN_DARK} deger="7" etiket="Seviye" /></Giris>
        <Giris t={t} bas={pillBas[1]}><StatPill ikon="simsek" renk={PRIMARY} deger="1.240" etiket="Toplam XP" /></Giris>
        <Giris t={t} bas={pillBas[2]}><StatPill ikon="alev" renk={CORAL} deger="5" etiket="Seri (gün)" /></Giris>
      </div>

      {/* seviye cubugu */}
      <Giris t={t} bas={1300} style={{position: 'absolute', left: 52, top: 760, width: 1080 - 104}}>
        <div style={{height: 37, borderRadius: 19, background: 'rgba(255,255,255,0.25)', overflow: 'hidden'}}>
          <div style={{width: `${progress * 100}%`, height: '100%', background: SUN, borderRadius: 19}} />
        </div>
        <div style={{marginTop: 14, fontSize: 34, fontWeight: 700, color: 'rgba(255,255,255,0.9)'}}>Sonraki seviyeye sadece 160 XP kaldı!</div>
      </Giris>

      {/* altin iz */}
      <svg width={1080} height={2340} style={{position: 'absolute', left: 0, top: 0}}>{izSegmentleri}</svg>
      {t >= 750 && sonuk > 0 ? <div style={{position: 'absolute', left: basKonum[0] - 22, top: basKonum[1] - 22, width: 44, height: 44, borderRadius: '50%', background: 'radial-gradient(circle, rgba(255,255,255,0.95) 0%, rgba(245,200,66,0.55) 45%, rgba(245,200,66,0) 72%)', opacity: sonuk}} /> : null}

      {/* Hupo */}
      <Rig cx={cx} cy={cy} k={k} tilt={tilt} kanat={kanat} gozKapali={gozKapali} />

      {/* sahne 2 kivilcimlari */}
      {kiv.map((c, i) => <Yildiz key={i} x={c.x} y={c.y} boyut={c.s} opak={c.o} don={c.d} renk={c.r} />)}
    </AbsoluteFill>
  );
};
