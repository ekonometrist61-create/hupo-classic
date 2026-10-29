// Ölçek üretim hattı (Faz 3). Alt komutlar:
//   node olcek-hat.mjs kontrol            olcek/sinif-N.json -> yapısal kontrol; geçenler olcek/gecerli-sinif-N.json, kör dosya olcek/kor-sinif-N.json
//   node olcek-hat.mjs gemini             gecerli-sinif-N.json'u Gemini ile kör çözer -> olcek/denetim-gemini-sinif-N.json
//   node olcek-hat.mjs sql                iki modelin de temiz bulduğu sorular için olcek/yukle-sinif-N.sql; elenenler olcek/elenen.json
// Claude denetimi olcek/denetim-claude-sinif-N.json ([{no,cevap,tek_dogru,sinif_uygun,sorun}]) dışarıda (alt ajan) üretilir.
// Hiçbir komut yayın yapmaz; SQL yalnız incelemede + iki 'pass' kaydı yazar.
import fs from 'node:fs';
const dir = new URL('./olcek/', import.meta.url);
const yol = (ad) => new URL(ad, dir);
const SINIFLAR = [1, 2, 3, 4, 5, 6, 7, 8];
const TURLER = new Set(['es_anlamli', 'zit_anlamli', 'es_sesli', 'deyim', 'atasozu', 'sozcuk_turu', 'baglamda_anlam']);
const STURU = new Set(['isim', 'sifat', 'fiil', 'zarf', 'baglac', 'zamir', 'edat', 'unlem', 'diger']);
const oku = (ad) => JSON.parse(fs.readFileSync(yol(ad), 'utf8'));
const yaz = (ad, v) => fs.writeFileSync(yol(ad), typeof v === 'string' ? v : JSON.stringify(v, null, 1), 'utf8');
const tr = (s) => s.replace(/İ/g, 'i').replace(/I/g, 'ı').toLowerCase();
const q = (s) => `'${String(s).replace(/'/g, "''")}'`;
const cmd = process.argv[2];

function kontrol() {
  const ozet = [];
  for (const n of SINIFLAR) {
    if (!fs.existsSync(yol(`sinif-${n}.json`))) continue;
    let liste;
    try { liste = oku(`sinif-${n}.json`); } catch (e) { ozet.push(`sinif ${n}: JSON hatası ${e.message}`); continue; }
    const gecerli = [], hatalar = [], kullanilan = new Set();
    liste.forEach((x, i) => {
      const h = [];
      if (!TURLER.has(x.t)) h.push('tur');
      if (x.s !== n) h.push('sinif');
      if (![1, 2, 3].includes(x.z)) h.push('zorluk');
      const hd = x.h || {};
      if (!hd.kelime || hd.kelime.length > 60 || !hd.anlam || hd.anlam.length < 2 || hd.anlam.length > 300) h.push('hedef');
      if (!['kelime', 'deyim', 'atasozu'].includes(hd.tur)) h.push('hedef_tur');
      if (hd.sozcuk_turu != null && !STURU.has(hd.sozcuk_turu)) h.push('sozcuk_turu');
      if (!Array.isArray(x.o) || x.o.length < 3 || x.o.length > 4 || (n >= 3 && x.o.length !== 4 && x.t !== 'sozcuk_turu')) h.push('sik_sayisi');
      else {
        if (!Number.isInteger(x.d) || x.d < 0 || x.d >= x.o.length) h.push('dogru_indeks');
        if (new Set(x.o.map((s) => tr(s.trim()))).size !== x.o.length) h.push('sik_tekrari');
        if (x.o.some((s) => typeof s !== 'string' || s.length < 1 || s.length > 120)) h.push('sik_uzunluk');
        if (x.o.some((s) => /hepsi|hiçbiri|^[a-d] ve [a-d]$/i.test(s))) h.push('hepsi_hicbiri');
        const L = x.o.map((s) => s.length), dg = Math.max(...L.filter((_, k) => k !== x.d));
        if (x.t !== 'sozcuk_turu' && L[x.d] > dg + 8) h.push('dogru_belirgin_uzun');
        if (['deyim', 'atasozu'].includes(x.t) && x.o.some((s) => tr(s).includes(tr(hd.kelime || '###')))) h.push('kok_sizinti');
      }
      if (typeof x.q !== 'string' || x.q.length < 5 || x.q.length > 400) h.push('kok');
      if (typeof x.a !== 'string' || x.a.length < 5 || x.a.length > 500) h.push('aciklama');
      if (x.ip != null && (typeof x.ip !== 'string' || x.ip.length > 200)) h.push('ipucu');
      const anahtar = `${x.t}|${tr(hd.kelime || '')}|${tr(hd.anlam || '')}`;
      if (kullanilan.has(anahtar)) h.push('tekrar_hedef');
      kullanilan.add(anahtar);
      if (h.length) hatalar.push(`#${i + 1} ${hd.kelime}: ${h.join(',')}`); else gecerli.push(x);
    });
    yaz(`gecerli-sinif-${n}.json`, gecerli);
    yaz(`kor-sinif-${n}.json`, gecerli.map((x, i) => ({ no: i + 1, sinif: x.s, soru: x.q, secenekler: x.o })));
    const dag = [0, 1, 2, 3].map((k) => gecerli.filter((x) => x.d === k).length).join('/');
    ozet.push(`sinif ${n}: ${liste.length} yazıldı, ${gecerli.length} geçerli, doğru şık dağılımı ${dag}${hatalar.length ? '\n   ' + hatalar.join('\n   ') : ''}`);
  }
  console.log(ozet.join('\n'));
}

async function gemini() {
  const env = fs.readFileSync('C:/Dev/Soru-Cevap Hazırlama Programı/.env', 'utf8').split(/\r?\n/);
  const ev = (ad) => { const s = env.find((x) => x.startsWith(`${ad}=`)); return s ? s.slice(ad.length + 1).trim().replace(/^["']|["']$/g, '') : null; };
  const ANAHTAR = ev('GEMINI_API_KEY'), MODEL = ev('GEMINI_MODEL');
  if (!ANAHTAR || !MODEL) throw new Error('GEMINI_API_KEY / GEMINI_MODEL okunamadı');
  for (const n of SINIFLAR) {
    if (!fs.existsSync(yol(`kor-sinif-${n}.json`))) continue;
    const kor = oku(`kor-sinif-${n}.json`);
    const sonuc = [];
    for (let i = 0; i < kor.length; i += 20) {
      const parca = kor.slice(i, i + 20);
      const istem = `Sen bir Türkçe öğretmeni ve soru denetçisisin. Aşağıdaki çoktan seçmeli soruları KÖR çöz (cevap anahtarı sende yok).
Her soru için JSON dizisi döndür: [{"no":1,"cevap":0,"tek_dogru":true,"sinif_uygun":true,"sorun":""}]
- cevap: seçtiğin şıkkın 0 tabanlı indeksi. tek_dogru: yalnız tek şık doğruysa true. sinif_uygun: sınıf düzeyine uygunsa true.
- sorun: TDK/sözlük anlamına aykırılık, yanlış deyim/atasözü biçimi, eş sesli yerine çok anlamlı sözcük, ipucu sızması, şık dengesizliği varsa kısaca yaz; yoksa boş. Katı ol.
Sorular:\n${JSON.stringify(parca)}`;
      let yanit;
      for (let d = 1; d <= 3; d++) {
        yanit = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`, {
          method: 'POST', headers: { 'Content-Type': 'application/json', 'x-goog-api-key': ANAHTAR },
          body: JSON.stringify({ contents: [{ parts: [{ text: istem }] }], generationConfig: { responseMimeType: 'application/json', temperature: 0.1 } }),
        });
        if (yanit.ok) break;
        await new Promise((r) => setTimeout(r, 2000 * d));
      }
      if (!yanit.ok) throw new Error(`Gemini ${yanit.status}`);
      const m = (await yanit.json()).candidates?.[0]?.content?.parts?.[0]?.text ?? '[]';
      sonuc.push(...JSON.parse(m));
    }
    yaz(`denetim-gemini-sinif-${n}.json`, { model: MODEL, aile: 'gemini', sonuc });
    console.log(`sinif ${n}: ${sonuc.length}/${kor.length} cevaplandı`);
  }
}

function sql() {
  const elenen = [], ozet = [];
  for (const n of SINIFLAR) {
    if (!fs.existsSync(yol(`gecerli-sinif-${n}.json`))) continue;
    const g = oku(`gecerli-sinif-${n}.json`);
    const gm = fs.existsSync(yol(`denetim-gemini-sinif-${n}.json`)) ? oku(`denetim-gemini-sinif-${n}.json`) : null;
    const cl = fs.existsSync(yol(`denetim-claude-sinif-${n}.json`)) ? oku(`denetim-claude-sinif-${n}.json`) : null;
    if (!gm || !cl) { ozet.push(`sinif ${n}: denetim eksik (gemini:${!!gm}, claude:${!!cl}) — atlandı`); continue; }
    const cl_s = Array.isArray(cl) ? cl : cl.sonuc;
    const temiz = (r, x) => r && r.cevap === x.d && r.tek_dogru && r.sinif_uygun && !r.sorun;
    const kabul = [];
    g.forEach((x, i) => {
      const a = gm.sonuc.find((r) => r.no === i + 1), b = cl_s.find((r) => r.no === i + 1);
      if (temiz(a, x) && temiz(b, x)) kabul.push(x);
      else elenen.push({ sinif: n, kelime: x.h.kelime, tur: x.t, gemini: a ? { cevap: a.cevap, sorun: a.sorun, tek: a.tek_dogru } : null, claude: b ? { cevap: b.cevap, sorun: b.sorun, tek: b.tek_dogru } : null, anahtar: x.d });
    });
    const s = [`begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
do $olcek$
declare v_id uuid; v_anlam uuid;
begin`];
    for (const x of kabul) {
      const h = x.h;
      const alt = x.s, ust = x.s;
      s.push(`  insert into public.kelime_anlamlari (kelime, anlam, tur, sozcuk_turu, sinif_alt, sinif_ust, zorluk)
  values (${q(h.kelime)}, ${q(h.anlam)}, ${q(h.tur)}, ${h.sozcuk_turu ? q(h.sozcuk_turu) : 'null'}, ${alt}, ${ust}, ${x.z})
  on conflict (kelime, anlam) do update set
    sinif_alt = least(coalesce(public.kelime_anlamlari.sinif_alt, excluded.sinif_alt), excluded.sinif_alt),
    sinif_ust = greatest(coalesce(public.kelime_anlamlari.sinif_ust, excluded.sinif_ust), excluded.sinif_ust)
  returning id into v_anlam;
  v_id := public.kelime_soru_kaydet(null, v_anlam, ${q(x.t)}, ${x.s}, null, ${q(x.q)}, ${q(JSON.stringify(x.o))}::jsonb, ${x.d}, null, ${x.ip ? q(x.ip) : 'null'}, ${q(x.a)}, ${x.z});
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform public.kelime_denetim_kaydet('soru', v_id::text, ${q(gm.model)}, 'gemini', 'pass', null);
  perform public.kelime_denetim_kaydet('soru', v_id::text, ${q('claude-opus (bağımsız alt ajan, kör)')}, 'claude', 'pass', null);`);
    }
    s.push(`end
$olcek$;
commit;`);
    yaz(`yukle-sinif-${n}.sql`, s.join('\n'));
    ozet.push(`sinif ${n}: ${g.length} geçerli, ${kabul.length} kabul (iki model temiz), ${g.length - kabul.length} elendi`);
  }
  yaz('elenen.json', elenen);
  console.log(ozet.join('\n'));
}

if (cmd === 'kontrol') kontrol();
else if (cmd === 'gemini') await gemini();
else if (cmd === 'sql') sql();
else console.log('kullanım: kontrol | gemini | sql');
