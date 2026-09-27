// Toplu soru ekleme için SAF mantık: CSV ayrıştırma, başlık eşleme, satır dönüştürme,
// doğrulama (sunucudaki public._soru_hatasi ile aynı kurallar), parçalama, CSV üretimi.
// Yalnızca göreli import ve papaparse kullanır (proje takma adı yok).
import Papa from "papaparse";

import type {
  ImportError,
  ImportResult,
  QuestionInput,
  QuestionStatus,
} from "../types";

export const BOM = String.fromCharCode(0xfeff);
const BOM_RE = new RegExp("^" + BOM);
export const CHUNK_SIZE = 500;
export const OPTION_KEYS = ["A", "B", "C", "D", "E"] as const;
export const STATUSES: QuestionStatus[] = ["beklemede", "onaylandi", "reddedildi"];

export type FieldName =
  | "okul"
  | "ders"
  | "konu"
  | "alt_konu"
  | "zorluk"
  | "soru_metni"
  | "sik_a"
  | "sik_b"
  | "sik_c"
  | "sik_d"
  | "sik_e"
  | "dogru_sik"
  | "cozum_adimlari"
  | "onay_durumu";

export const TEMPLATE_HEADER: FieldName[] = [
  "okul",
  "ders",
  "konu",
  "alt_konu",
  "zorluk",
  "soru_metni",
  "sik_a",
  "sik_b",
  "sik_c",
  "sik_d",
  "sik_e",
  "dogru_sik",
  "cozum_adimlari",
  "onay_durumu",
];

export const REQUIRED_FIELDS: FieldName[] = [
  "okul",
  "ders",
  "konu",
  "zorluk",
  "soru_metni",
  "sik_a",
  "sik_b",
  "dogru_sik",
];

// ---------------------------------------------------------------------
// Başlık normalleştirme ve eşleme
// ---------------------------------------------------------------------

const TR_MAP: Record<string, string> = {
  ç: "c",
  ğ: "g",
  ı: "i",
  ö: "o",
  ş: "s",
  ü: "u",
  â: "a",
  î: "i",
  û: "u",
};

/** Küçük harf, Türkçe aksan duyarsız, yalnızca harf/rakam kalır (boşluk, _, - atılır). */
export function normalizeKey(input: string): string {
  return input
    .replace(BOM_RE, "")
    .replace(/İ/g, "i")
    .replace(/I/g, "i")
    .toLowerCase()
    .replace(/[çğıöşüâîû]/g, (c) => TR_MAP[c] ?? c)
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]/g, "");
}

const ALIASES: Record<FieldName, string[]> = {
  okul: ["okul", "okuladi", "okulturu", "school"],
  ders: ["ders", "dersadi", "subject"],
  konu: ["konu", "konuadi", "topic"],
  alt_konu: ["altkonu", "altkonuadi", "subtopic"],
  zorluk: ["zorluk", "zorlukderecesi", "zorlukseviyesi", "seviye", "difficulty"],
  soru_metni: ["sorumetni", "soru", "sorumetin", "sorukoku", "metin", "question"],
  sik_a: ["sika", "a", "seceneka"],
  sik_b: ["sikb", "b", "secenekb"],
  sik_c: ["sikc", "c", "secenekc"],
  sik_d: ["sikd", "d", "secenekd"],
  sik_e: ["sike", "e", "seceneke"],
  dogru_sik: ["dogrusik", "dogru", "cevap", "dogrucevap", "dogrusecenek", "answer"],
  cozum_adimlari: ["cozumadimlari", "cozum", "cozumler", "cozumadimi", "solution"],
  onay_durumu: ["onaydurumu", "onay", "durum", "status"],
};

const ALIAS_LOOKUP: Map<string, FieldName> = (() => {
  const m = new Map<string, FieldName>();
  for (const [field, list] of Object.entries(ALIASES) as [FieldName, string[]][]) {
    for (const a of list) if (!m.has(a)) m.set(a, field);
  }
  return m;
})();

export interface HeaderMapping {
  /** Her sütun için eşleşen alan (yoksa null). */
  columns: (FieldName | null)[];
  /** Tanınmayan (yok sayılacak) başlıklar, orijinal yazımıyla. */
  unknown: string[];
  /** Aynı alana ikinci kez eşleşen sütunlar (yok sayılır). */
  duplicates: string[];
  /** Eksik zorunlu alanlar. */
  missing: FieldName[];
}

export function mapHeader(headerCells: string[]): HeaderMapping {
  const seen = new Set<FieldName>();
  const columns: (FieldName | null)[] = [];
  const unknown: string[] = [];
  const duplicates: string[] = [];

  for (const raw of headerCells) {
    const label = raw.trim();
    const field = ALIAS_LOOKUP.get(normalizeKey(label)) ?? null;
    if (field === null) {
      columns.push(null);
      if (label !== "") unknown.push(label);
    } else if (seen.has(field)) {
      columns.push(null);
      duplicates.push(label);
    } else {
      seen.add(field);
      columns.push(field);
    }
  }

  return {
    columns,
    unknown,
    duplicates,
    missing: REQUIRED_FIELDS.filter((f) => !seen.has(f)),
  };
}

// ---------------------------------------------------------------------
// Ayrıştırma
// ---------------------------------------------------------------------

export interface RawRecord {
  /** Dosyadaki kayıt numarası (başlık = 1; boş satırlar da sayılır). */
  line: number;
  cells: string[];
}

export interface ParsedCsv {
  delimiter: string;
  headerCells: string[];
  mapping: HeaderMapping;
  records: RawRecord[];
}

const DELIMITERS = [";", ",", "\t"];

function stripSepLine(text: string): string {
  // Excel'in "sep=;" ilk satırı
  return text.replace(/^sep=.\r?\n/i, "");
}

/** Başlık satırına bakarak (en çok tanınan sütun) ayırıcıyı seçer. */
export function detectDelimiter(text: string): string {
  let best = ",";
  let bestScore = -1;
  for (const d of DELIMITERS) {
    const res = Papa.parse<string[]>(text, { delimiter: d, preview: 1 });
    const head = res.data[0] ?? [];
    const known = mapHeader(head).columns.filter((c) => c !== null).length;
    // Beraberlikte daha çok sütun veren ayırıcı
    const score = known * 1000 + head.length;
    if (score > bestScore) {
      bestScore = score;
      best = d;
    }
  }
  return best;
}

export function parseCsv(input: string): ParsedCsv {
  const text = stripSepLine(input.replace(BOM_RE, ""));
  const delimiter = detectDelimiter(text);
  const res = Papa.parse<string[]>(text, { delimiter });
  const all = res.data;

  // Baştaki boş satırları atla (numaralandırmada saymaya devam eder)
  let headIdx = 0;
  while (headIdx < all.length && isBlank(all[headIdx])) headIdx++;
  const headerCells = (all[headIdx] ?? []).map((c) => c.trim());
  const mapping = mapHeader(headerCells);

  const records: RawRecord[] = [];
  for (let i = headIdx + 1; i < all.length; i++) {
    if (isBlank(all[i])) continue;
    records.push({ line: i + 1, cells: all[i] });
  }
  return { delimiter, headerCells, mapping, records };
}

function isBlank(cells: string[]): boolean {
  return cells.every((c) => c.trim() === "");
}

// ---------------------------------------------------------------------
// Dönüştürme ve doğrulama
// ---------------------------------------------------------------------

/** "a | b\nc" -> ["a","b","c"] */
export function splitSteps(value: string): string[] {
  return value
    .split(/\||\r?\n/)
    .map((s) => s.trim())
    .filter((s) => s !== "");
}

export function parseDifficulty(value: string): number {
  const v = normalizeKey(value);
  if (v === "kolay") return 1;
  if (v === "orta") return 2;
  if (v === "zor") return 3;
  const n = Number(value.trim());
  return Number.isInteger(n) ? n : Number.NaN;
}

export function parseStatus(value: string): QuestionStatus | undefined {
  const v = normalizeKey(value);
  if (v === "onaylandi" || v === "onayli") return "onaylandi";
  if (v === "beklemede" || v === "bekliyor") return "beklemede";
  if (v === "reddedildi" || v === "red") return "reddedildi";
  return undefined;
}

export function rowToQuestion(
  cells: string[],
  columns: (FieldName | null)[]
): QuestionInput {
  const get: Partial<Record<FieldName, string>> = {};
  columns.forEach((field, idx) => {
    if (field) get[field] = (cells[idx] ?? "").trim();
  });
  const v = (f: FieldName) => get[f] ?? "";

  const siklar: Record<string, string> = {};
  for (const k of OPTION_KEYS) {
    const text = v(`sik_${k.toLowerCase()}` as FieldName);
    if (text !== "") siklar[k] = text;
  }

  const q: QuestionInput = {
    okul: v("okul"),
    ders: v("ders"),
    konu: v("konu"),
    alt_konu: v("alt_konu"),
    zorluk: parseDifficulty(v("zorluk")),
    soru_metni: v("soru_metni"),
    siklar,
    dogru_sik: v("dogru_sik").toUpperCase(),
    cozum_adimlari: splitSteps(v("cozum_adimlari")),
  };
  const status = parseStatus(v("onay_durumu"));
  if (status) q.onay_durumu = status;
  return q;
}

const blank = (s: unknown) => typeof s !== "string" || s.trim() === "";

/** public._soru_hatasi ile aynı kurallar ve mesajlar; hata yoksa null. */
export function validateQuestion(q: QuestionInput): string | null {
  if (blank(q.okul)) return "okul boş olamaz";
  if (blank(q.ders)) return "ders boş olamaz";
  if (blank(q.konu)) return "konu boş olamaz";
  if (blank(q.soru_metni)) return "soru metni boş olamaz";
  if (!(q.zorluk === 1 || q.zorluk === 2 || q.zorluk === 3)) {
    return "zorluk 1, 2 veya 3 olmalı";
  }
  const keys = Object.keys(q.siklar ?? {});
  if (keys.length < 2) return "en az 2 şık gerekli";
  for (const k of keys) {
    if (!/^[A-E]$/.test(k)) return `şık anahtarı A-E arasında olmalı (${k})`;
    if (blank(q.siklar[k])) return `${k} şıkkı boş olamaz`;
  }
  if (!keys.includes((q.dogru_sik ?? "").toUpperCase())) {
    return "doğru şık, dolu şıklardan biri olmalı";
  }
  if (q.cozum_adimlari !== undefined && !Array.isArray(q.cozum_adimlari)) {
    return "çözüm adımları liste olmalı";
  }
  if (q.onay_durumu !== undefined && !STATUSES.includes(q.onay_durumu)) {
    return "onay durumu beklemede, onaylandi veya reddedildi olmalı";
  }
  return null;
}

export interface ConvertedRow {
  line: number;
  cells: string[];
  question: QuestionInput;
  error: string | null;
}

export function convertRecords(
  records: RawRecord[],
  columns: (FieldName | null)[]
): ConvertedRow[] {
  return records.map((r) => {
    const question = rowToQuestion(r.cells, columns);
    return { line: r.line, cells: r.cells, question, error: validateQuestion(question) };
  });
}

// ---------------------------------------------------------------------
// Parçalama ve sonuç birleştirme
// ---------------------------------------------------------------------

export function chunk<T>(items: T[], size: number = CHUNK_SIZE): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < items.length; i += size) out.push(items.slice(i, i + size));
  return out;
}

/**
 * Sunucunun `satir` değeri (1'den, parça içi sıra) -> orijinal dosya satırı.
 * validLines: yalnızca geçerli (gönderilen) satırların dosya numaraları, sırayla.
 * offset: bu parçanın validLines içindeki başlangıç indeksi.
 */
export function mapChunkErrors(
  errors: ImportError[],
  validLines: number[],
  offset: number
): ImportError[] {
  return errors.map((e) => ({
    satir: validLines[offset + e.satir - 1] ?? offset + e.satir,
    hata: e.hata,
  }));
}

export function emptyResult(): ImportResult {
  return { eklenen: 0, tekrar: 0, hatali: 0, hatalar: [] };
}

export function mergeResults(a: ImportResult, b: ImportResult): ImportResult {
  return {
    eklenen: a.eklenen + b.eklenen,
    tekrar: a.tekrar + b.tekrar,
    hatali: a.hatali + b.hatali,
    hatalar: [...a.hatalar, ...b.hatalar],
  };
}

// ---------------------------------------------------------------------
// CSV üretimi
// ---------------------------------------------------------------------

function quoteCell(value: string, delimiter: string): string {
  return value.includes('"') ||
    value.includes(delimiter) ||
    value.includes("\n") ||
    value.includes("\r")
    ? `"${value.replace(/"/g, '""')}"`
    : value;
}

/** BOM'lu CSV metni (Excel Türkçe karakterleri doğru gösterir). */
export function toCsv(rows: string[][], delimiter = ","): string {
  return (
    BOM + rows.map((r) => r.map((c) => quoteCell(c, delimiter)).join(delimiter)).join("\r\n") + "\r\n"
  );
}

export function templateCsv(): string {
  return toCsv([
    TEMPLATE_HEADER,
    [
      "İlkokul",
      "Matematik",
      "Doğal Sayılar",
      "Toplama İşlemi",
      "1",
      "Ayşe'nin 12 çilek, Ömer'in 15 çileği var. Toplam kaç çilek vardır?",
      "25",
      "27",
      "29",
      "31",
      "",
      "B",
      "12 ile 15'i toplarız | 12 + 15 = 27 | Cevap 27'dir",
      "beklemede",
    ],
    [
      "Ortaokul",
      "Fen Bilimleri",
      "Kuvvet ve Enerji",
      "",
      "2",
      "Aşağıdakilerden hangisi, bir cismin hareket enerjisine (kinetik enerji), örnek olarak verilebilir?",
      "Masanın üzerindeki kitap",
      "Koşan çocuk",
      "Gerilmiş yay, ok",
      "Yüksekte duran taş",
      "Duran araba",
      "B",
      "Kinetik enerji hareketli cisimlerde bulunur | Koşan çocuk hareket halindedir | Doğru cevap B şıkkıdır",
      "",
    ],
  ]);
}

/** Hatalı satırlar için: özgün başlık + özgün hücreler + "hata" sütunu. */
export function errorsCsv(
  headerCells: string[],
  rows: { cells: string[]; error: string }[],
  delimiter = ","
): string {
  return toCsv(
    [
      [...headerCells, "hata"],
      ...rows.map((r) => [
        ...headerCells.map((_, i) => r.cells[i] ?? ""),
        r.error,
      ]),
    ],
    delimiter
  );
}
