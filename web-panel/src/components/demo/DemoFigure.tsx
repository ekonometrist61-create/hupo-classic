import type { DemoSekil } from "./demoQuestions";

// Örnek soru şekilleri: koddan çizilen küçük satır içi SVG'ler (görsel dosya yok).
// Renk tek bilgi taşıyıcısı değildir: taralı parçalar çizgili desenle de ayrılır, noktalar harfle adlandırılır.
// Ekran okuyucu için `alt` metni şekildeki veriyi söyler, cevabı söylemez.

const STROKE = "stroke-navy dark:stroke-gray-200";
const TEXT = "fill-navy dark:fill-gray-100";
const SOFT_STROKE = "stroke-navy/25 dark:stroke-gray-500";
const FONT = { fontFamily: "inherit" } as const;

function Frame({ alt, children, viewBox = "0 0 320 190" }: { alt: string; children: React.ReactNode; viewBox?: string }) {
  return (
    <svg
      role="img"
      aria-label={alt}
      viewBox={viewBox}
      className="mx-auto h-auto w-full max-w-md"
      xmlns="http://www.w3.org/2000/svg"
    >
      {children}
    </svg>
  );
}

function Fraction({ parca, boyali, alt }: { parca: number; boyali: number; alt: string }) {
  const w = 288;
  const cell = w / parca;
  return (
    <Frame alt={alt} viewBox="0 0 320 110">
      <defs>
        <pattern id="demo-tarali" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
          <rect width="6" height="6" className="fill-brand-300" />
          <line x1="0" y1="0" x2="0" y2="6" strokeWidth="2" className="stroke-brand-600" />
        </pattern>
      </defs>
      {Array.from({ length: parca }, (_, i) => (
        <rect
          key={i}
          x={16 + i * cell}
          y={25}
          width={cell}
          height={60}
          fill={i < boyali ? "url(#demo-tarali)" : "transparent"}
          strokeWidth={2}
          className={STROKE}
        />
      ))}
    </Frame>
  );
}

function Bars({
  baslik,
  veri,
  max,
  adim,
  alt,
}: {
  baslik: string;
  veri: { ad: string; deger: number }[];
  max: number;
  adim: number;
  alt: string;
}) {
  const left = 44;
  const right = 308;
  const top = 34;
  const bottom = 152;
  const h = bottom - top;
  const slot = (right - left) / veri.length;
  const bw = Math.min(46, slot - 18);
  const ticks: number[] = [];
  for (let v = 0; v <= max; v += adim) ticks.push(v);
  const y = (v: number) => bottom - (v / max) * h;
  return (
    <Frame alt={alt}>
      <text x={left} y={16} fontSize={12} fontWeight={800} className={TEXT} style={FONT}>
        {baslik}
      </text>
      {ticks.map((t) => (
        <g key={t}>
          <line x1={left} x2={right} y1={y(t)} y2={y(t)} strokeWidth={1} className={SOFT_STROKE} />
          <text x={left - 6} y={y(t) + 4} fontSize={11} textAnchor="end" className={TEXT} style={FONT}>
            {t}
          </text>
        </g>
      ))}
      {veri.map((d, i) => {
        const x = left + i * slot + (slot - bw) / 2;
        return (
          <g key={d.ad}>
            <rect x={x} y={y(d.deger)} width={bw} height={bottom - y(d.deger)} rx={3} className="fill-brand-500" />
            <text x={x + bw / 2} y={y(d.deger) - 5} fontSize={12} fontWeight={800} textAnchor="middle" className={TEXT} style={FONT}>
              {d.deger}
            </text>
            <text x={x + bw / 2} y={bottom + 16} fontSize={12} fontWeight={700} textAnchor="middle" className={TEXT} style={FONT}>
              {d.ad}
            </text>
          </g>
        );
      })}
      <line x1={left} x2={right} y1={bottom} y2={bottom} strokeWidth={2} className={STROKE} />
    </Frame>
  );
}

function Rect({ en, boy, birim, alt }: { en: number; boy: number; birim: string; alt: string }) {
  const k = 200 / Math.max(en, boy);
  const w = en * k;
  const h = boy * k;
  const x = (320 - w) / 2 + 10;
  const y = 40;
  return (
    <Frame alt={alt} viewBox="0 0 320 150">
      <rect x={x} y={y} width={w} height={h} strokeWidth={3} className={`${STROKE} fill-cream-dark dark:fill-gray-700`} />
      <text x={x + w / 2} y={y - 10} fontSize={14} fontWeight={800} textAnchor="middle" className={TEXT} style={FONT}>
        {en} {birim}
      </text>
      <text x={x - 10} y={y + h / 2 + 5} fontSize={14} fontWeight={800} textAnchor="end" className={TEXT} style={FONT}>
        {boy} {birim}
      </text>
    </Frame>
  );
}

function Circuit({ anahtarAcik, alt }: { anahtarAcik: boolean; alt: string }) {
  return (
    <Frame alt={alt} viewBox="0 0 320 180">
      <g fill="none" strokeWidth={3} strokeLinecap="round" className={STROKE}>
        {/* Üst tel ve ampul */}
        <path d="M60 50 H134" />
        <path d="M186 50 H260 V140" />
        {/* Alt tel ve anahtar */}
        <path d="M260 140 H210" />
        <path d="M130 140 H60" />
        {anahtarAcik ? <path d="M130 140 L196 108" /> : <path d="M130 140 H210" />}
        {/* Sol tel ve pil */}
        <path d="M60 50 V84" />
        <path d="M60 106 V140" />
        <path d="M44 84 H76" />
        <path d="M51 96 H69" strokeWidth={6} />
        {/* Ampul */}
        <circle cx={160} cy={50} r={26} className="fill-gold-400/40" />
        <path d="M145 35 L175 65 M175 35 L145 65" strokeWidth={2} />
      </g>
      <circle cx={130} cy={140} r={4} className="fill-navy dark:fill-gray-100" />
      <circle cx={210} cy={140} r={4} className="fill-navy dark:fill-gray-100" />
      <g fontSize={13} fontWeight={800} className={TEXT} style={FONT}>
        <text x={160} y={96} textAnchor="middle">Ampul</text>
        <text x={170} y={166} textAnchor="middle">Anahtar</text>
        <text x={90} y={100}>Pil</text>
      </g>
    </Frame>
  );
}

function NumberLine({
  min,
  max,
  adim,
  etiketAdim,
  noktalar,
  alt,
}: {
  min: number;
  max: number;
  adim: number;
  etiketAdim: number;
  noktalar: { ad: string; deger: number }[];
  alt: string;
}) {
  const left = 30;
  const right = 290;
  const yLine = 100;
  const n = Math.round((max - min) / adim);
  const x = (v: number) => left + ((v - min) / (max - min)) * (right - left);
  const fmt = (v: number) => String(v).replace(".", ",").replace("-", "−");
  return (
    <Frame alt={alt} viewBox="0 0 320 150">
      <line x1={left - 10} x2={right + 10} y1={yLine} y2={yLine} strokeWidth={3} className={STROKE} />
      {Array.from({ length: n + 1 }, (_, i) => {
        const v = Math.round((min + i * adim) * 1000) / 1000;
        const labeled = i % etiketAdim === 0;
        return (
          <g key={i}>
            <line x1={x(v)} x2={x(v)} y1={yLine - (labeled ? 9 : 6)} y2={yLine + (labeled ? 9 : 6)} strokeWidth={2} className={STROKE} />
            {labeled && (
              <text x={x(v)} y={yLine + 28} fontSize={13} fontWeight={700} textAnchor="middle" className={TEXT} style={FONT}>
                {fmt(v)}
              </text>
            )}
          </g>
        );
      })}
      {noktalar.map((p) => (
        <g key={p.ad}>
          <circle cx={x(p.deger)} cy={yLine} r={7} className="fill-gold-500 stroke-navy dark:stroke-gray-100" strokeWidth={2} />
          <text x={x(p.deger)} y={yLine - 20} fontSize={16} fontWeight={800} textAnchor="middle" className={TEXT} style={FONT}>
            {p.ad}
          </text>
        </g>
      ))}
    </Frame>
  );
}

function Groups({ a, b, alt }: { a: { ad: string; sayi: number }; b: { ad: string; sayi: number }; alt: string }) {
  return (
    <Frame alt={alt} viewBox="0 0 320 140">
      <text x={16} y={22} fontSize={13} fontWeight={800} className={TEXT} style={FONT}>
        {a.ad}
      </text>
      {Array.from({ length: a.sayi }, (_, i) => (
        <circle key={i} cx={24 + i * 24} cy={42} r={8} className="fill-brand-500" />
      ))}
      <text x={16} y={86} fontSize={13} fontWeight={800} className={TEXT} style={FONT}>
        {b.ad}
      </text>
      {Array.from({ length: b.sayi }, (_, i) => (
        <rect key={i} x={17 + i * 16.5} y={96} width={13} height={13} rx={2} className="fill-gold-500 stroke-navy dark:stroke-gray-100" strokeWidth={1.5} />
      ))}
    </Frame>
  );
}

function Triangle({ a, b, alt }: { a: number; b: number; alt: string }) {
  const A = { x: 70, y: 160 };
  const B = { x: 250, y: 160 };
  const ra = (a * Math.PI) / 180;
  const rb = (b * Math.PI) / 180;
  // Köşe: A'dan a derece, B'den (180 - b) derece yönünde ışınların kesişimi.
  const base = B.x - A.x;
  const t = (base * Math.sin(rb)) / Math.sin(ra + rb);
  const C = { x: A.x + t * Math.cos(ra), y: A.y - t * Math.sin(ra) };
  return (
    <Frame alt={alt} viewBox="0 0 320 190">
      <polygon
        points={`${A.x},${A.y} ${B.x},${B.y} ${C.x},${C.y}`}
        strokeWidth={3}
        strokeLinejoin="round"
        className={`${STROKE} fill-cream-dark dark:fill-gray-700`}
      />
      <g fontSize={15} fontWeight={800} className={TEXT} style={FONT}>
        <text x={A.x + 22} y={A.y - 8}>
          {a}°
        </text>
        <text x={B.x - 22} y={B.y - 8} textAnchor="end">
          {b}°
        </text>
        <text x={C.x} y={C.y + 38} textAnchor="middle" fontSize={22}>
          ?
        </text>
      </g>
    </Frame>
  );
}

function Graph({
  xEtiket,
  yEtiket,
  xMax,
  yMax,
  yAdim,
  noktalar,
  alt,
}: {
  xEtiket: string;
  yEtiket: string;
  xMax: number;
  yMax: number;
  yAdim: number;
  noktalar: [number, number][];
  alt: string;
}) {
  const left = 56;
  const right = 296;
  const top = 24;
  const bottom = 142;
  const x = (v: number) => left + (v / xMax) * (right - left);
  const y = (v: number) => bottom - (v / yMax) * (bottom - top);
  const yTicks: number[] = [];
  for (let v = 0; v <= yMax; v += yAdim) yTicks.push(v);
  return (
    <Frame alt={alt}>
      <text x={left - 40} y={14} fontSize={12} fontWeight={800} className={TEXT} style={FONT}>
        {yEtiket}
      </text>
      {yTicks.map((v) => (
        <g key={v}>
          <line x1={left} x2={right} y1={y(v)} y2={y(v)} strokeWidth={1} className={SOFT_STROKE} />
          <text x={left - 6} y={y(v) + 4} fontSize={11} textAnchor="end" className={TEXT} style={FONT}>
            {v}
          </text>
        </g>
      ))}
      {Array.from({ length: xMax + 1 }, (_, v) => (
        <g key={v}>
          <line x1={x(v)} x2={x(v)} y1={bottom} y2={bottom + 5} strokeWidth={2} className={STROKE} />
          <text x={x(v)} y={bottom + 19} fontSize={12} textAnchor="middle" className={TEXT} style={FONT}>
            {v}
          </text>
        </g>
      ))}
      <line x1={left} x2={left} y1={top} y2={bottom} strokeWidth={2} className={STROKE} />
      <line x1={left} x2={right} y1={bottom} y2={bottom} strokeWidth={2} className={STROKE} />
      <polyline
        fill="none"
        strokeWidth={3}
        points={noktalar.map(([px, py]) => `${x(px)},${y(py)}`).join(" ")}
        className="stroke-brand-500"
      />
      {noktalar.map(([px, py]) => (
        <circle key={`${px}-${py}`} cx={x(px)} cy={y(py)} r={4.5} className="fill-gold-500 stroke-navy dark:stroke-gray-100" strokeWidth={1.5} />
      ))}
      <text x={(left + right) / 2} y={182} fontSize={12} fontWeight={800} textAnchor="middle" className={TEXT} style={FONT}>
        {xEtiket}
      </text>
    </Frame>
  );
}

export default function DemoFigure({ sekil }: { sekil: DemoSekil }) {
  switch (sekil.tip) {
    case "kesir":
      return <Fraction parca={sekil.parca} boyali={sekil.boyali} alt={sekil.alt} />;
    case "sutun":
      return <Bars baslik={sekil.baslik} veri={sekil.veri} max={sekil.max} adim={sekil.adim} alt={sekil.alt} />;
    case "dikdortgen":
      return <Rect en={sekil.en} boy={sekil.boy} birim={sekil.birim} alt={sekil.alt} />;
    case "devre":
      return <Circuit anahtarAcik={sekil.anahtarAcik} alt={sekil.alt} />;
    case "sayidogrusu":
      return (
        <NumberLine
          min={sekil.min}
          max={sekil.max}
          adim={sekil.adim}
          etiketAdim={sekil.etiketAdim}
          noktalar={sekil.noktalar}
          alt={sekil.alt}
        />
      );
    case "gruplar":
      return <Groups a={sekil.a} b={sekil.b} alt={sekil.alt} />;
    case "ucgen":
      return <Triangle a={sekil.a} b={sekil.b} alt={sekil.alt} />;
    case "grafik":
      return (
        <Graph
          xEtiket={sekil.xEtiket}
          yEtiket={sekil.yEtiket}
          xMax={sekil.xMax}
          yMax={sekil.yMax}
          yAdim={sekil.yAdim}
          noktalar={sekil.noktalar}
          alt={sekil.alt}
        />
      );
  }
}
