import sys, glob, os, re, json, csv, datetime, collections, statistics, openpyxl, xlrd

BASE = sys.argv[1]          # scratchpad (x/ = plan xlsx, sinav/ = dagilim xlsx)
OUT = sys.argv[2]           # docs/mufredat
os.makedirs(OUT, exist_ok=True)

AY = {'ocak':1,'january':1,'januar':1,'şubat':2,'subat':2,'february':2,'februar':2,'mart':3,'march':3,'märz':3,'marz':3,
      'nisan':4,'april':4,'mayıs':5,'mayis':5,'may':5,'mai':5,'haziran':6,'june':6,'juni':6,'temmuz':7,'july':7,'juli':7,
      'ağustos':8,'agustos':8,'august':8,'eylül':9,'eylul':9,'september':9,'ekim':10,'october':10,'oktober':10,
      'kasım':11,'kasim':11,'november':11,'aralık':12,'aralik':12,'december':12,'dezember':12}
LET = 'A-ZÇĞİÖŞÜ'
CODE = re.compile(r'(?<![\w.])((?:[%s][%sa-zçğıöşü]{0,4}|[A-Z]\d)\.\s?(?:[A-Z%s0-9]{1,5}\.){1,4}[A-Z0-9]{1,5})(?=\.|\s|$|[–—-])' % (LET, LET, LET))
WK = re.compile(r'(\d+)\s*\.*\s*(?:Hafta|Week|Woche)|(?:Hafta|Week|Woche)\s*(\d+)', re.I)


def cl(v):
    if v is None: return ''
    if isinstance(v, float) and v == int(v): v = int(v)
    s = str(v).replace('\r', '').strip()
    s = re.sub(r'[ \t]+', ' ', s)
    s = re.sub(r'\s*\n\s*', ' / ', s)
    return s.strip(' /')


def sheets(f):
    if f.endswith('.xls'):
        wb = xlrd.open_workbook(f)
        for s in wb.sheets():
            yield s.name, [[s.cell_value(r, c) for c in range(s.ncols)] for r in range(s.nrows)]
    else:
        wb = openpyxl.load_workbook(f, data_only=True)
        for s in wb.worksheets:
            yield s.title, [list(r) for r in s.iter_rows(values_only=True)]


def norm(s):
    return (s.upper().replace('İ', 'I').replace('Ş', 'S').replace('Ğ', 'G').replace('Ü', 'U').replace('Ö', 'O').replace('Ç', 'C'))


def split_codes(t):
    t = re.sub(r'\b(DKAB|SB)\s+(\d)', r'\1.\2', t)
    ms = [m for m in CODE.finditer(t) if re.search(r'\d', m.group(1))]
    out = []
    for i, m in enumerate(ms):
        end = ms[i + 1].start() if i + 1 < len(ms) else len(t)
        metin = re.sub(r'\s*/\s*$', '', t[m.end():end].strip(' ./:-–—'))[:400]
        out.append({'kod': re.sub(r'\s', '', m.group(1)).rstrip('.'), 'metin': metin})
    return out


def dates(s):
    s = s.replace('–', '-').replace('—', '-')
    s = re.sub(r'(\d)\.(?=\s|-|$)', r'\1', s)
    toks = re.findall(r'(\d{1,2})\s*([^\W\d_]{3,})?', s)
    if len(toks) < 2: return None, None
    (d1, a1), (d2, a2) = toks[0], toks[1]
    a2n = AY.get(a2.lower()); a1n = AY.get(a1.lower()) if a1 else a2n
    if not (a1n and a2n): return None, None
    y = lambda a: 2026 if a >= 8 else 2027
    try:
        return datetime.date(y(a1n), a1n, int(d1)).isoformat(), datetime.date(y(a2n), a2n, int(d2)).isoformat()
    except Exception:
        return None, None


FIELDS = [('AY','ay'),('MONTH','ay'),('MONAT','ay'),('HAFTA','hafta'),('WEEK','hafta'),('WOCHE','hafta'),
          ('DERS','saat'),('CLASS HOUR','saat'),('/ CLASS HOUR','saat'),('UNTERRICHTSEINHEIT','saat'),
          ('UNIT/THEME','unite'),('UNITE','unite'),('TEMA','unite'),('THEME','unite'),('LEKTION','unite'),('THEMA','unite'),('OGRENME ALANI','unite'),
          ('KONU','konu'),('METIN','konu'),('CONTENT FRAME','konu'),('INHALTSRAHMEN','konu'),('ICERIK CERCEVESI','konu'),
          ('OGRENME CIKTILARI','cikti'),('KAZANIM','cikti'),('LEARNING','cikti'),('LERNERGEBNISSE','cikti'),('LERNZIELE','cikti'),('DINLEME','cikti'),
          ('OLCME','olcme'),('ASSESSMENT','olcme'),('BEWERTUNG','olcme'),('YONTEM','yontem'),
          ('BELIRLI GUN','gun'),('NATIONAL','gun'),('NATIONALE','gun')]


def plan_sheet(rows, INFER=False):
    hi = None
    for i, r in enumerate(rows[:12]):
        if any(norm(cl(v)) in ('HAFTA', 'WEEK', 'WOCHE') for v in r): hi = i; break
    if hi is None: return None
    cm = {}
    for j, v in enumerate(rows[hi]):
        n = norm(cl(v))
        if not n: continue
        for key, f in FIELDS:
            if n.startswith(key) or (key == 'ICERIK CERCEVESI' and key in n):
                if f not in cm: cm[f] = j
                break
    if 'cikti' not in cm: return None
    ends = [cm[k] for k in ('olcme', 'yontem', 'gun') if k in cm and cm[k] > cm['cikti']]
    c0 = cm['cikti']; c1 = min(ends) if ends else len(rows[hi])
    weeks = []; extra = []; cur = None
    for r in rows[hi + 1:]:
        g = lambda f: cl(r[cm[f]]) if f in cm and cm[f] < len(r) else ''
        h = g('hafta'); allt = ' | '.join(cl(v) for v in r if cl(v))
        outt = ' / '.join(cl(r[j]) for j in range(c0, min(c1, len(r))) if cl(r[j]))
        ms = list(WK.finditer(h))
        if ms:
            segs = [h[x.start():(ms[i + 1].start() if i + 1 < len(ms) else len(h))] for i, x in enumerate(ms)]
            grp = []
            for sg, x in zip(segs, ms):
                n = int(x.group(1) or x.group(2)); rest = WK.sub('', sg, 1); d1, d2 = dates(rest)
                cur = {'hafta': n, 'tarih_metin': re.sub(r'^[\s:/]+|[\s/]+$', '', rest), 'baslangic': d1, 'bitis': d2,
                       'ay': g('ay'), 'saat': g('saat'), 'unite_tema': [], 'konu': [], 'kazanimlar': [],
                       'olcme': g('olcme'), 'belirli_gun': g('gun'), 'not': 'birlesik_hucre' if len(ms) > 1 else ''}
                weeks.append(cur); grp.append(cur)
            cur['_grp'] = grp if len(grp) > 1 else None
        elif INFER and not h and g('saat') and cur and cur['kazanimlar'] and split_codes(outt):
            ds = dt = None
            if cur['baslangic']:
                a = datetime.date.fromisoformat(cur['baslangic']) + datetime.timedelta(days=7)
                ds = a.isoformat(); dt = (a + datetime.timedelta(days=4)).isoformat()
            cur = {'hafta': cur['hafta'] + 1, 'tarih_metin': '(etiket kayıp, çıkarım)', 'baslangic': ds, 'bitis': dt, 'ay': '',
                   'saat': g('saat'), 'unite_tema': [], 'konu': [], 'kazanimlar': [], 'olcme': g('olcme'),
                   'belirli_gun': g('gun'), 'not': 'hafta_etiketi_cikarim'}
            weeks.append(cur)
        elif not h:
            if allt and re.search(r'TATİL|TATIL|SINAV|OKUL TEMELLİ|HOLIDAY|FERIEN|EXAM|PRÜFUNG', allt, re.I) and not split_codes(outt):
                extra.append({'once_hafta': (cur['hafta'] if cur else 0), 'metin': allt[:200]}); continue
        if not allt or cur is None: continue
        for tgt in (cur.get('_grp') or [cur]):
            for f, lst in (('unite', 'unite_tema'), ('konu', 'konu')):
                v = g(f)
                if v and v not in tgt[lst] and len(v) < 250: tgt[lst].append(v)
            for c in split_codes(outt):
                if all(c['kod'] != k['kod'] for k in tgt['kazanimlar']): tgt['kazanimlar'].append(c)
            # kodsuz kazanim metni (yalniz kodu olmayan 2025-2026 DKAB dosyalari): kod uydurulmaz
            if ALLOW_TEXT and outt and not split_codes(outt) and all(outt[:80] != k['metin'][:80] for k in tgt['kazanimlar']):
                tgt['kazanimlar'].append({'kod': '', 'metin': outt[:400]})
            if not tgt['belirli_gun'] and g('gun'): tgt['belirli_gun'] = g('gun')
            if not tgt['olcme'] and g('olcme'): tgt['olcme'] = g('olcme')
    for w in weeks: w.pop('_grp', None)
    return weeks, extra


DIRS = [('dkab','Din Kültürü ve Ahlak Bilgisi'),('beden-egitimi-ve-oyun','Beden Eğitimi ve Oyun'),('beden-egitimi-ve-spor','Beden Eğitimi ve Spor'),
        ('bilisim','Bilişim Teknolojileri ve Yazılım'),('coklu-yabanci-dil-egitim-modeli-almanca','Almanca (ÇYDEM)'),
        ('coklu-yabanci-dil-egitim-modeli-ingilizce','İngilizce (ÇYDEM)'),('fen-bilimleri','Fen Bilimleri'),
        ('gorsel','Görsel Sanatlar'),('hayat','Hayat Bilgisi'),('ilkokul-matematik','Matematik'),('ortaokul-matematik','Matematik'),
        ('ilkokul-turkce','Türkçe'),('ortaokul-turkce','Türkçe'),('ingilizce-dersi','İngilizce'),
        ('insan-haklari','İnsan Hakları, Vatandaşlık ve Demokrasi'),('muzik','Müzik'),('ortaokul-teknoloji','Teknoloji ve Tasarım'),
        ('sosyal','Sosyal Bilgiler'),('tc-inkilap','T.C. İnkılap Tarihi ve Atatürkçülük')]


def ders_of(path):
    d = os.path.relpath(path, BASE + '/x').replace('\\', '/').split('/')[0]
    for k, v in DIRS:
        if d.startswith(k): return v
    return d


def varyant(fn, sn):
    if fn.lower().startswith('dkab'):
        return '2025-2026 dosyası (2026-27 yayımı yok)' if fn.lower() in ('dkab4.xlsx', 'dkab8.xlsx') else ''
    if 'ADA' in fn: return 'Ada Yayınları (2019 programı)'
    if 'Hecce' in fn: return 'Hecce Yayınları'
    u = sn.upper()
    if 'MEB' in u or 'TÜRKÇE 5' in u or 'SINIF ÇERÇEVE' in u or '2019 (MEB' in u.upper(): return 'MEB Yayınları'
    return ''


OLD = re.compile(r'^(M|F|G|Mü|Y|T|E\d)\.\d|^TT\.\d\.[A-Z]\.')


def prog(p):
    # DKAB: dogm.meb.gov.tr sayfasinda 4 ve 8 onceki program, 5-7 TYMM olarak isaretli
    if p['dosya'].lower().startswith('dkab'): return 'önceki program' if p['sinif'] in (4, 8) else 'TYMM'
    if 'TYMM' in p['sayfa'].upper(): return 'TYMM'
    cs = [k['kod'] for w in p['haftalar'] for k in w['kazanimlar']]
    if not cs: return 'belirsiz'
    old = sum(1 for c in cs if OLD.match(c) and not re.match(r'^T\.[DKOY]\.', c))
    return 'önceki program' if old / len(cs) > 0.5 else 'TYMM'


plans = []
for f in sorted(glob.glob(BASE + '/x/**/*.xls*', recursive=True)):
    fn = os.path.basename(f)
    for name, rows in sheets(f):
        ALLOW_TEXT = fn.lower() in ('dkab4.xlsx', 'dkab8.xlsx')
        r = plan_sheet(rows, INFER=name.upper().startswith('BTY'))
        if not r: continue
        w, e = r
        gm = re.search(r'dkab([4-8])', fn.lower()) if fn.lower().startswith('dkab') else re.search(r'[1-8]', name)
        if not gm: continue
        p = {'ders': ders_of(f), 'sinif': int(gm.group(1) if fn.lower().startswith('dkab') else gm.group()), 'varyant': varyant(fn, name), 'sayfa': name.strip(),
             'dosya': fn, 'haftalar': w, 'ekstra_satirlar': e}
        p['program'] = prog(p)
        p['kaynak_yili'] = '2025-2026' if fn.lower() in ('dkab4.xlsx', 'dkab8.xlsx') else '2026-2027'
        plans.append(p)
plans.sort(key=lambda p: (p['sinif'], p['ders'], p['varyant']))

# hafta numarasi: tarihe gore ortak (cogunluk) numaralama; kaynak hatalari (tekrar eden/kaymis numara) duzeltilir
dn = collections.defaultdict(collections.Counter)
for p in plans:
    for w in p['haftalar']:
        if w['baslangic'] and w['not'] != 'hafta_etiketi_cikarim': dn[w['baslangic']][w['hafta']] += 1
canon = {d: c.most_common(1)[0][0] for d, c in dn.items()}
for p in plans:
    for w in p['haftalar']:
        c = canon.get(w['baslangic'])
        if c and c != w['hafta']:
            w['hafta_kaynak'] = w['hafta']; w['hafta'] = c
            w['not'] = (w['not'] + ';' if w['not'] else '') + f"numara_duzeltildi(kaynak={w['hafta_kaynak']})"
nd = collections.defaultdict(collections.Counter)
for d, c in canon.items(): nd[c][d] += dn[d][c]
for p in plans:
    seen = collections.defaultdict(list)
    for w in p['haftalar']: seen[w['hafta']].append(w)
    for n, ws in seen.items():
        if len(ws) < 2: continue
        best = nd[n].most_common(1)[0][0] if nd.get(n) else None
        keep = next((w for w in ws if w['baslangic'] == best), ws[0])
        for w in ws:
            if w is not keep:
                w['dislandi'] = True
                w['not'] = (w['not'] + ';' if w['not'] else '') + 'supheli_tekrar_satir_dislandi'
cw_rows = sorted({(c, d) for d, c in canon.items()})
with open(OUT + '/okul_haftalari_2026_2027.csv', 'w', encoding='utf-8-sig', newline='') as fo:
    cw = csv.writer(fo); cw.writerow(['hafta', 'baslangic', 'bitis'])
    for c, d in cw_rows:
        cw.writerow([c, d, (datetime.date.fromisoformat(d) + datetime.timedelta(days=4)).isoformat()])
json.dump(plans, open(OUT + '/yillik_plan_2026_2027.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)

with open(OUT + '/haftalik_akis_2026_2027.csv', 'w', encoding='utf-8-sig', newline='') as fo:
    cw = csv.writer(fo)
    cw.writerow(['ders','sinif','varyant','program','hafta','baslangic','bitis','ay','ders_saati','unite_tema','konu','kazanim_kodu','kazanim_metni','belirli_gun_hafta','kayit_notu','kaynak_yili'])
    for p in plans:
        for w in p['haftalar']:
            if w.get('dislandi'): continue
            b = [p['ders'], p['sinif'], p['varyant'], p['program'], w['hafta'], w['baslangic'], w['bitis'], w['ay'], w['saat'],
                 ' | '.join(w['unite_tema']), ' | '.join(w['konu'])]
            for k in (w['kazanimlar'] or [{'kod': '', 'metin': ''}]):
                cw.writerow(b + [k['kod'], k['metin'], w['belirli_gun'][:120], w['not'], p['kaynak_yili']])

# takvim (tatil/sinav satirlari)
tak = collections.OrderedDict()
for p in plans:
    for e in p['ekstra_satirlar']:
        if re.search(r'TATİL|TATIL|HOLIDAY|FERIEN', e['metin'], re.I):
            tak.setdefault(re.sub(r'\s+', ' ', e['metin']), set()).add(p['ders'])
with open(OUT + '/takvim_notlari_2026_2027.csv', 'w', encoding='utf-8-sig', newline='') as fo:
    cw = csv.writer(fo); cw.writerow(['metin', 'gorulen_ders_sayisi'])
    for k, v in tak.items(): cw.writerow([k, len(v)])

# ---------------- sinav dagilim ----------------
SDERS = {'ank1': 'Din Kültürü ve Ahlak Bilgisi', 'ank2': 'Fen Bilimleri', 'ank3': 'Matematik', 'ank4': 'Türkçe',
         'ank5': 'Sosyal Bilgiler', 'ank6': 'İngilizce'}
exam = []; warn = []
for f in sorted(glob.glob(BASE + '/sinav/*.xlsx')):
    key = os.path.basename(f)[:4]
    for name, rows in sheets(f):
        gm = re.search(r'[5-8]', name)
        if not gm: continue
        sinif = int(gm.group())
        ders = SDERS[key]
        if key == 'ank5' and sinif == 8: ders = 'T.C. İnkılap Tarihi ve Atatürkçülük'
        hdr = None
        for i, r in enumerate(rows[:10]):
            if any('ortak yazılı' in cl(v).lower() for v in r): hdr = i; break
        if hdr is None: warn.append(f'{key} {name}: baslik yok'); continue
        starts = [(j, cl(v)) for j, v in enumerate(rows[hdr]) if 'ortak yazılı' in cl(v).lower()]
        ncol = max(len(r) for r in rows)
        rng = []
        for i, (j, nm) in enumerate(starts):
            e = starts[i + 1][0] if i + 1 < len(starts) else ncol
            rng.append((j, e, nm))
        sen = rows[hdr + 1]
        if not any('senaryo' in cl(v).lower() for v in sen): sen = rows[hdr + 2]; start_data = hdr + 3
        else: start_data = hdr + 2
        # kolonlar
        cmap = {}
        for j, v in enumerate(rows[hdr]):
            n = norm(cl(v))
            if n.startswith('UNITE') or n.startswith('ALAN BEC'): cmap['unite'] = j
            elif n.startswith('KONU'): cmap['konu'] = j
            elif n.startswith('OGRENME CIKTI') or n.startswith('KAZANIM'): cmap['cikti'] = j
        cu = ku = ''
        totals = {}
        for r in rows[start_data:]:
            cells = [cl(v) for v in r] + [''] * (ncol - len(r))
            if 'unite' in cmap and cells[cmap['unite']]: cu = cells[cmap['unite']]
            if 'konu' in cmap and cells[cmap['konu']]: ku = cells[cmap['konu']]
            first = ' '.join(cells[:3]).upper()
            vals = {}
            for (a, b, nm) in rng:
                for j in range(a, b):
                    v = r[j] if j < len(r) else None
                    if isinstance(v, (int, float)) and v != 0: vals[j] = int(v)
                    elif isinstance(v, str) and v.strip().isdigit() and int(v) != 0: vals[j] = int(v)
            if any(re.fullmatch(r'TOPLAM(\s+SORU)?(\s+SAYISI)?', c.strip().upper()) for c in cells[:3]):
                totals = vals; continue
            cod = split_codes(cells[cmap['cikti']]) if 'cikti' in cmap else []
            if not cod:
                if vals and any(cells): warn.append(f'{key} {name}: kodsuz satir sayili: {first[:60]}')
                continue
            c = cod[0]
            for (a, b, nm) in rng:
                for j in range(a, b):
                    sn = cl(sen[j]) if j < len(sen) else ''
                    n_ = vals.get(j, 0)
                    exam.append({'ders': ders, 'sinif': sinif, 'sinav': re.sub(r'\s+', ' ', nm), 'senaryo': sn,
                                 'unite': cu, 'konu': ku if 'konu' in cmap else '', 'kazanim_kodu': c['kod'],
                                 'kazanim_metni': c['metin'][:300], 'soru_sayisi': n_})
        # dogrulama: toplam
        if totals:
            for (a, b, nm) in rng:
                for j in range(a, b):
                    s = sum(e['soru_sayisi'] for e in exam if e['ders'] == ders and e['sinif'] == sinif and e['sinav'] == re.sub(r'\s+', ' ', nm) and e['senaryo'] == (cl(sen[j]) if j < len(sen) else ''))
                    if totals.get(j) and totals[j] != s:
                        warn.append(f'{ders} {sinif} {nm} {cl(sen[j])}: tablo toplami {totals[j]} != satir toplami {s}')
with open(OUT + '/sinav_dagilim_donem1_2026_2027.csv', 'w', encoding='utf-8-sig', newline='') as fo:
    cw = csv.DictWriter(fo, fieldnames=list(exam[0].keys())); cw.writeheader(); cw.writerows(exam)
json.dump(exam, open(OUT + '/sinav_dagilim_donem1_2026_2027.json', 'w', encoding='utf-8'), ensure_ascii=False)

# ---------------- kazanim etiket tablosu ----------------
ex = collections.defaultdict(lambda: collections.defaultdict(list))
for e in exam:
    ex[(e['ders'], e['sinif'], e['kazanim_kodu'].upper())][e['sinav']].append(e['soru_sayisi'])
ex_meta = {}
for e in exam: ex_meta.setdefault((e['ders'], e['sinif'], e['kazanim_kodu'].upper()), e)
rows_out = []; used = set()
for p in plans:
    idx = collections.OrderedDict()
    for w in p['haftalar']:
        if w.get('dislandi'): continue
        for k in w['kazanimlar']:
            if not k['kod']: k = {'kod': '', 'metin': k['metin']}
            d = idx.setdefault(k['kod'], {'metin': k['metin'], 'haftalar': [], 'bas': w['baslangic'], 'bit': w['bitis'], 'unite': set(), 'konu': set()})
            d['haftalar'].append(w['hafta']); d['bit'] = w['bitis'] or d['bit']
            d['unite'].update(w['unite_tema']); d['konu'].update(w['konu'])
    for kod, d in idx.items():
        if not kod: continue  # kodsuz metin etiket anahtarina girmez
        key = (p['ders'], p['sinif'], kod.upper()); used.add(key)
        r = {'ders': p['ders'], 'sinif': p['sinif'], 'varyant': p['varyant'], 'program': p['program'], 'kazanim_kodu': kod,
             'kazanim_metni': d['metin'], 'hafta_listesi': ';'.join(str(h) for h in d['haftalar']), 'ilk_hafta': d['haftalar'][0],
             'son_hafta': d['haftalar'][-1], 'baslangic': d['bas'], 'bitis': d['bit'],
             'unite_tema': ' | '.join(sorted(d['unite']))[:200], 'konu': ' | '.join(sorted(d['konu']))[:200]}
        for sv in ('1. Dönem 1. Ortak Yazılı Sınav', '1. Dönem 2. Ortak Yazılı Sınav'):
            xs = ex.get(key, {}).get(sv)
            tag = sv[9]
            if xs is None: r[f'ortak_yazili_{tag}_senaryo_ort'] = ''; r[f'ortak_yazili_{tag}_min'] = ''; r[f'ortak_yazili_{tag}_max'] = ''
            else: r[f'ortak_yazili_{tag}_senaryo_ort'] = round(statistics.mean(xs), 2); r[f'ortak_yazili_{tag}_min'] = min(xs); r[f'ortak_yazili_{tag}_max'] = max(xs)
        rows_out.append(r)
with open(OUT + '/kazanim_etiket_tablosu_2026_2027.csv', 'w', encoding='utf-8-sig', newline='') as fo:
    cw = csv.DictWriter(fo, fieldnames=list(rows_out[0].keys())); cw.writeheader(); cw.writerows(rows_out)

# ---------------- ozet ----------------
print('PLAN sayfa:', len(plans), ' etiket satiri:', len(rows_out))
for p in plans:
    wn = [w['hafta'] for w in p['haftalar'] if not w.get('dislandi')]; c = collections.Counter(wn)
    miss = [i for i in range(1, max(wn) + 1) if i not in wn]; dup = [k for k, v in c.items() if v > 1]
    nk = sum(len(w['kazanimlar']) for w in p['haftalar'])
    notes = collections.Counter(w['not'] for w in p['haftalar'] if w['not'])
    flag = '' if (len(wn) == 37 and not dup and nk) else ' <<'
    print(f"{p['ders'][:22]:22}|{p['sinif']}|{p['varyant'][:8]:8}|{p['program'][:6]:6}|hf={len(wn):2} kaz={nk:3} eksik={miss} dup={dup} {dict(notes) if notes else ''}{flag}")
print('SINAV satir:', len(exam))
per = collections.defaultdict(set)
for e in exam: per[(e['ders'], e['sinif'])].add(e['kazanim_kodu'].upper())
plan_codes = collections.defaultdict(set)
for k in used: plan_codes[(k[0], k[1])].add(k[2])
for kk, s in sorted(per.items(), key=lambda x: (x[0][1], x[0][0])):
    print(f"  {kk[0][:22]:22}|{kk[1]}| sinav kodu={len(s):3} planla eslesen={len(s & plan_codes.get(kk, set())):3}")
print('UYARI:', len(warn))
for w in warn[:40]: print('  ', w)

