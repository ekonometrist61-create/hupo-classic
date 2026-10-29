// Pilot soru dosyasını (JSON) uzak DB'ye taslak -> incelemede olarak yükleyen SQL üretir. YAYIN YAPMAZ.
// Kullanım: node pilot-ice-aktar.mjs pilot-deyim-atasozu.json [denetim-gemini-pilot-deyim-atasozu.json denetim-claude-pilot-deyim-atasozu.json] > yukle.sql
// Denetim dosyaları verilirse her soru için iki model kaydı da yazılır (yalnız kör cevap anahtarla uyuşup sorunsuzsa "pass").
// SQL: supabase db query --linked -f yukle.sql
import fs from 'node:fs';
const [dosya, ...denetimler] = process.argv.slice(2);
const sorular = JSON.parse(fs.readFileSync(dosya, 'utf8'));
const q = (s) => `'${String(s).replace(/'/g, "''")}'`;
const kararlar = denetimler.map((d) => {
  const j = JSON.parse(fs.readFileSync(d, 'utf8'));
  return { model: j.model, aile: j.aile, sonuc: j.sonuc };
});
const out = [];
out.push(`begin;
select set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' order by id limit 1), 'role', 'authenticated')::text, true);
create temp table _pilot_sonuc (no int, soru_id uuid, durum text) on commit drop;
do $pilot$
declare v_id uuid; v_anlam uuid;
begin`);
sorular.forEach((x, i) => {
  out.push(`  select id into strict v_anlam from public.kelime_anlamlari where id::text like ${q(x.k + '%')};
  v_id := public.kelime_soru_kaydet(null, v_anlam, ${q(x.t)}, ${x.s}, null, ${q(x.q)}, ${q(JSON.stringify(x.o))}::jsonb, ${x.d}, null, null, ${q(x.a)}, ${x.z});
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');`);
  for (const k of kararlar) {
    const r = k.sonuc.find((s) => s.no === i + 1);
    const temiz = r && r.cevap === x.d && r.tek_dogru && r.sinif_uygun && !r.sorun;
    const not = r && r.sorun ? r.sorun : null;
    out.push(`  perform public.kelime_denetim_kaydet('soru', v_id::text, ${q(k.model)}, ${q(k.aile)}, ${q(temiz ? 'pass' : 'review_needed')}, ${not ? q(not) : 'null'});`);
  }
  out.push(`  insert into _pilot_sonuc values (${i + 1}, v_id, 'incelemede');`);
});
out.push(`end
$pilot$;
select count(*) as yuklenen from _pilot_sonuc;
commit;`);
console.log(out.join('\n'));
