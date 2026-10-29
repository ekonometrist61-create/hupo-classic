"""DKAB 8 kazanim kodu eslestirmesi (kod uydurmadan, yalniz birebir normalize metin eslesmesi).

Girdi:
  docs/mufredat/haftalik_akis_2026_2027.csv   (DKAB, sinif 8 plan satirlari; kazanim_metni ' / ' ile bolunur)
  docs/mufredat/sinav_dagilim_donem1_2026_2027.csv (DKAB, sinif 8 sinav kodlari)
Cikti:
  docs/mufredat/dkab8_kod_eslesme.csv (kod, plan_metni, sinav_metni, durum)

Kural: plan kazanimi = kazanim_metni'nin ilk ' / ' parcasi; baştaki numara oneki (N.) atilir.
Normalizasyon: parantez icerigi atilir, Turkce I/İ duzeltilir, kucuk harf, noktalama atilir, bosluk sadelestirilir.
Yalniz normalize metin birebir esitse eslestirilir; coklu eslesme varsa eslestirilmez (belirsiz).
"""
import csv
import os
import re
import sys
from collections import defaultdict

DOC = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
PLAN = os.path.join(DOC, 'haftalik_akis_2026_2027.csv')
SINAV = os.path.join(DOC, 'sinav_dagilim_donem1_2026_2027.csv')
OUT = os.path.join(DOC, 'dkab8_kod_eslesme.csv')
DERS = 'Din Kültürü ve Ahlak Bilgisi'
SINIF = '8'


def norm(s):
    s = re.sub(r'\([^)]*\)', ' ', s)
    s = s.replace('İ', 'i').replace('I', 'ı').lower()
    s = re.sub(r'[^\w\s]', ' ', s)
    s = s.replace('_', ' ')
    return re.sub(r'\s+', ' ', s).strip()


def ilk_cumle(metin):
    parca = metin.split(' / ')[0].strip()
    return re.sub(r'^\s*\d+\s*\.\s*', '', parca).strip()


plan_rows = [r for r in csv.DictReader(open(PLAN, encoding='utf-8-sig'))
             if r['ders'] == DERS and r['sinif'] == SINIF]
# plan kazanimi (normalize) -> ham ilk cumleler
plan_map = defaultdict(set)
for r in plan_rows:
    ham = ilk_cumle(r['kazanim_metni'] or '')
    if ham:
        plan_map[norm(ham)].add(ham)

sinav_rows = [r for r in csv.DictReader(open(SINAV, encoding='utf-8-sig'))
              if r['ders'] == DERS and r['sinif'] == SINIF]
sinav_pairs = sorted(set((r['kazanim_kodu'], r['kazanim_metni']) for r in sinav_rows))
kod_map = defaultdict(set)  # kod -> normalize metin
kod_ham = {}
for kod, metin in sinav_pairs:
    kod_map[kod].add(norm(metin))
    kod_ham[kod] = metin

plan_norm_to_codes = defaultdict(set)
for kod, nset in kod_map.items():
    for n in nset:
        plan_norm_to_codes[n].add(kod)

out = []
eslesen_kodlar = set()
for kod in sorted(kod_map):
    nset = kod_map[kod]
    if len(nset) > 1:
        out.append([kod, '', kod_ham[kod], 'belirsiz_sinav_kodu_coklu_metin'])
        continue
    n = next(iter(nset))
    if n in plan_map:
        if len(plan_norm_to_codes[n]) > 1:
            out.append([kod, ' | '.join(sorted(plan_map[n])), kod_ham[kod], 'belirsiz_coklu_kod'])
        elif len(plan_map[n]) > 1:
            out.append([kod, ' | '.join(sorted(plan_map[n])), kod_ham[kod], 'belirsiz_plan_ham_varyant'])
        else:
            out.append([kod, next(iter(plan_map[n])), kod_ham[kod], 'eslesti'])
            eslesen_kodlar.add(kod)
    else:
        out.append([kod, '', kod_ham[kod], 'sinav_kodu_plan_eslesmedi'])

# Yalniz iki kod icin yazim normalizasyonu (koordinator karari): aksan, ' ve ’, tire ve bosluk silinir.
YAZIM_KODLAR = {'DKAB.8.1.6', 'DKAB.8.2.5'}


def norm_yazim(s):
    s = norm(s).translate(str.maketrans('âûîÂÛÎ', 'auiAUI'))
    return s.replace(' ', '').replace('-', '')


yazim_plan = defaultdict(set)
for n, hamlar in plan_map.items():
    for h in hamlar:
        yazim_plan[norm_yazim(h)].add(h)

for satir in out:
    if satir[0] in YAZIM_KODLAR and satir[3] == 'sinav_kodu_plan_eslesmedi':
        adaylar = yazim_plan.get(norm_yazim(kod_ham[satir[0]]), set())
        if len(adaylar) == 1:
            ham = next(iter(adaylar))
            # plan grubu baska bir sinav kodu tarafindan birebir eslestirilmis mi?
            if norm(ham) in plan_norm_to_codes:
                satir[1:4] = [ham, kod_ham[satir[0]], 'belirsiz_yazim_plan_baska_kodla_esli']
            else:
                satir[1:4] = [ham, kod_ham[satir[0]], 'eslesti_yazim']
        elif len(adaylar) > 1:
            satir[3] = 'belirsiz_yazim_coklu_plan'

for satir in out:
    if satir[3] == 'eslesti_yazim':
        eslesen_kodlar.add(satir[0])

for n, hamlar in sorted(plan_map.items()):
    if n not in plan_norm_to_codes and not any(s[1] in hamlar for s in out if s[3] == 'eslesti_yazim'):
        for h in sorted(hamlar):
            out.append(['', h, '', 'plan_kazanimi_sinav_eslesmedi'])

with open(OUT, 'w', encoding='utf-8', newline='') as f:
    w = csv.writer(f)
    w.writerow(['kod', 'plan_metni', 'sinav_metni', 'durum'])
    w.writerows(out)

sayac = defaultdict(int)
for row in out:
    sayac[row[3]] += 1
print('plan satiri', len(plan_rows), 'benzersiz plan kazanimi (normalize)', len(plan_map))
print('sinav satiri', len(sinav_rows), 'benzersiz (kod,metin)', len(sinav_pairs))
for k, v in sorted(sayac.items()):
    print(k, v)
print('yazildi', OUT)

