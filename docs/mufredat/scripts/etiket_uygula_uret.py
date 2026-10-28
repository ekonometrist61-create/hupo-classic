"""İki bağımsız okumanın (birinci: etiket_onerileri_*.csv, ikinci kör: ikinci_inceleme_*.csv) uyuştuğu
etiketlerden doğrulamalı SQL üretir. Birinci okumada güveni `dusuk` olanlar çıkarılır.

Çıktı: etiket_onerileri/uygulanacak_etiketler_2026-10-24.csv ve uygula_etiketler_2026-10-24.sql
SQL: kod, sorunun sınıfı + eşlenmiş dersi için mufredat_hafta (2026-2027)'de yoksa satır atlanır (admin_set_question_kazanim ile aynı doğrulama);
yalnız onaylı ve kazanımsız sorulara dokunur; her değişiklik question_revisions'a düşer.
Çalıştırma: python -X utf8 etiket_uygula_uret.py <docs/mufredat/etiket_onerileri>
"""
import csv
import sys
import os

D = sys.argv[1]
rd = lambda f: list(csv.DictReader(open(os.path.join(D, f), encoding='utf-8-sig')))
a = {r['soru_id']: r for r in rd('etiket_onerileri_2026-10-24.csv')}
b = {r['soru_id']: r for r in rd('ikinci_inceleme_2026-10-24.csv')}

secilen = []
for k, x in a.items():
    y = b.get(k)
    if not y or x['durum'] != 'oneri' or x['guven'] == 'dusuk':
        continue
    if x['onerilen_kod'] == y['kod']:
        secilen.append((k, x['ders'], x['sinif'], x['onerilen_kod'], x['guven'], y['guven']))

with open(os.path.join(D, 'uygulanacak_etiketler_2026-10-24.csv'), 'w', encoding='utf-8-sig', newline='') as f:
    w = csv.writer(f)
    w.writerow(['soru_id', 'ders', 'sinif', 'kod', 'guven_1', 'guven_2'])
    w.writerows(secilen)

vals = ',\n'.join("  ('%s','%s')" % (s[0], s[3].replace("'", "''")) for s in secilen)
sql = f"""-- Kazanım etiketleri: iki bağımsız okuyucunun aynı kodda uyuştuğu {len(secilen)} soru.
-- Kaynak: docs/mufredat/etiket_onerileri/ (birinci okuma + kör ikinci okuma). İnsan onayı: örnek incelemesi önerilir.
-- Doğrulama: kod, sorunun sınıfı + eşlenmiş dersi için mufredat_hafta (2026-2027)'de bulunmalı; yalnız onaylı ve kazanımsız sorulara dokunur.
-- Her değişiklik question_revisions'a yazılır. Gereken önkoşul: 20261085 uygulanmış olmalı ("Din Kültürü" soruları için 20261088).
with t(soru_id, kod) as (values
{vals}
), gecerli as (
  select q.id, t.kod, min(h.kazanim_metni) as metin
    from t
    join public.questions q on q.id = t.soru_id::uuid
    join public.mufredat_ders_eslesme e on e.soru_ders = q.ders
    join public.mufredat_hafta h
      on h.ders = e.mufredat_ders and h.sinif = q.sinif
     and h.kaynak_yili = '2026-2027' and h.kazanim_kodu = t.kod
   where q.onay_durumu = 'onaylandi'
     and (q.kazanim_kodu is null or q.kazanim_kodu = '')
   group by q.id, t.kod
), rev as (
  insert into public.question_revisions (question_id, revised_by, old_data, degisen_alanlar)
  select q.id, null, to_jsonb(q), array['kazanim_kodu', 'kazanim_metni']
    from gecerli g join public.questions q on q.id = g.id
  returning question_id
)
update public.questions q
   set kazanim_kodu = g.kod, kazanim_metni = g.metin
  from gecerli g
 where q.id = g.id;
"""
open(os.path.join(D, 'uygula_etiketler_2026-10-24.sql'), 'w', encoding='utf-8', newline='\n').write(sql)
print('secilen', len(secilen))
