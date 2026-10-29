// Sözcük çekirdeği Faz 2: sinif-N.json -> kelime_anlamlari (ornek_cumle, sinif_alt/ust, zorluk) aktarım migration'ı.
// Kullanım: node docs/kelime-evreni/veritabani/uret-cekirdek-aktarim.mjs > supabase/migrations/20261096000000_sozcuk_cekirdegi_aktarim.sql
import fs from 'node:fs';
const dir = new URL('.', import.meta.url);
const tr = (s) => s.replace(/İ/g, 'i').replace(/I/g, 'ı').toLowerCase();
const harita = new Map(); // kelime|anlam -> {kelime, anlam, siniflar:Set, tur:Set, ornekler:[]}
for (let i = 1; i <= 8; i++) {
  const j = JSON.parse(fs.readFileSync(new URL(`sinif-${i}.json`, dir), 'utf8'));
  for (const r of j.iliskiler) {
    for (const k of ['a', 'b']) {
      const x = r[k];
      const anahtar = `${x.kelime}|${x.anlam}`;
      if (!harita.has(anahtar)) harita.set(anahtar, { kelime: x.kelime, anlam: x.anlam, siniflar: new Set(), turler: new Set(), ornekler: [] });
      const h = harita.get(anahtar);
      h.siniflar.add(i); h.turler.add(r.tur);
      const kok = tr(x.kelime).slice(0, Math.max(3, x.kelime.length - 2));
      if (r.ornek && tr(r.ornek).includes(kok)) h.ornekler.push(r.ornek);
    }
  }
}
const q = (s) => (s == null ? 'null' : `'${String(s).replace(/'/g, "''")}'`);
const satirlar = [];
for (const h of harita.values()) {
  const alt = Math.min(...h.siniflar), ust = Math.max(...h.siniflar);
  const taban = alt <= 3 ? 1 : alt <= 6 ? 2 : 3;
  const zorluk = Math.min(3, taban + (h.turler.has('es_sesli') ? 1 : 0));
  satirlar.push(`  (${q(h.kelime)}, ${q(h.anlam)}, ${q(h.ornekler[0] ?? null)}, ${alt}, ${ust}, ${zorluk})`);
}
console.log(`-- Üretici: docs/kelime-evreni/veritabani/uret-cekirdek-aktarim.mjs (${satirlar.length} anlam).
-- Zorluk kuralı (editoryal başlangıç): sınıf_alt 1-3 -> 1, 4-6 -> 2, 7-8 -> 3; eş sesli ilişkide +1 (en çok 3).
-- Örnek cümle yalnız hedef sözcüğü (ek almış hâliyle) içeriyorsa yazılır; yoksa boş kalır.
set client_encoding = 'UTF8';

update public.kelime_anlamlari k
   set ornek_cumle = coalesce(k.ornek_cumle, v.ornek),
       sinif_alt   = v.alt,
       sinif_ust   = v.ust,
       zorluk      = v.zorluk
  from (values
${satirlar.join(',\n')}
  ) as v(kelime, anlam, ornek, alt, ust, zorluk)
 where k.kelime = v.kelime and k.anlam = v.anlam;

-- Taslak soruların zorluğu sınıf vekilinden anlamın editoryal zorluğuna geçer (yayındakilere dokunulmaz).
update public.kelime_sorulari s
   set zorluk = a.zorluk
  from public.kelime_anlamlari a
 where a.id = s.anlam_id and a.zorluk is not null and s.durum = 'taslak';

-- Hikâye sözlüğü girdileri çekirdeğe anlam olarak girer (kelime en çok 60 karakter); aynı (kelime, anlam) tek satırdır.
insert into public.kelime_anlamlari (kelime, anlam, tur, sinif_alt, sinif_ust)
select g.yazim, g.anlam, g.tur, min(g.sinif_alt), max(g.sinif_ust)
  from public.okuma_sozluk_girdileri g
 where length(btrim(g.yazim)) between 1 and 60 and length(btrim(g.anlam)) between 2 and 300
 group by g.yazim, g.anlam, g.tur
on conflict (kelime, anlam) do nothing;

-- Aynı metinli eşleşme kesindir -> onayli. Çekirdekte aynı yazımlı başka anlam varsa öneri olarak eklenir (insan bakar).
insert into public.kelime_hikaye_baglari (anlam_id, sozluk_girdi_id, durum)
select a.id, g.id, 'onayli'
  from public.okuma_sozluk_girdileri g
  join public.kelime_anlamlari a on a.kelime = g.yazim and a.anlam = g.anlam
on conflict do nothing;

insert into public.kelime_hikaye_baglari (anlam_id, sozluk_girdi_id, durum)
select a.id, g.id, 'oneri'
  from public.okuma_sozluk_girdileri g
  join public.kelime_anlamlari a
    on lower(translate(a.kelime, 'İI', 'iı')) = lower(translate(g.yazim, 'İI', 'iı')) and a.anlam <> g.anlam
 where g.tur = 'kelime' and a.tur = 'kelime'
on conflict do nothing;

-- Aynı zaman damgasında çelişen kayıtlarda temkinli sıra: pass olmayan kayıt "son" sayılır.
create or replace function public._kelime_iki_model_gecti(p_tur text, p_id text, p_sonra timestamptz)
returns boolean
language sql
stable
set search_path = ''
as $fn$
  select coalesce(
           count(distinct t.denetci_aile) filter (where t.karar = 'pass') >= 2
           and bool_and(t.karar = 'pass'),
           false)
    from (
      select distinct on (k.denetci_model) k.denetci_model, k.denetci_aile, k.karar
        from public.kelime_denetim_kayitlari k
       where k.hedef_tur = p_tur and k.hedef_id = p_id
         and (p_sonra is null or k.created_at >= p_sonra)
       order by k.denetci_model, k.created_at desc, (k.karar = 'pass')
    ) t;
$fn$;`);