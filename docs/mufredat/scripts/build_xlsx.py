import json, csv, sys, collections, statistics, openpyxl
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

D = sys.argv[1]
P = json.load(open(D + '/yillik_plan_2026_2027.json', encoding='utf-8'))
tag = list(csv.DictReader(open(D + '/kazanim_etiket_tablosu_2026_2027.csv', encoding='utf-8-sig')))
ex = list(csv.DictReader(open(D + '/sinav_dagilim_donem1_2026_2027.csv', encoding='utf-8-sig')))
wk = list(csv.DictReader(open(D + '/okul_haftalari_2026_2027.csv', encoding='utf-8-sig')))
tak = list(csv.DictReader(open(D + '/takvim_notlari_2026_2027.csv', encoding='utf-8-sig')))

wb = openpyxl.Workbook()
HF = Font(bold=True, color='FFFFFF'); HB = PatternFill('solid', fgColor='2F5D50')


def sheet(name, header, rows, widths):
    ws = wb.create_sheet(name)
    ws.append(header)
    for c in ws[1]:
        c.font = HF; c.fill = HB; c.alignment = Alignment(wrap_text=True, vertical='center')
    for r in rows: ws.append(r)
    for i, w in enumerate(widths, 1): ws.column_dimensions[get_column_letter(i)].width = w
    ws.freeze_panes = 'A2'; ws.auto_filter.ref = ws.dimensions
    return ws


ws = wb.active; ws.title = 'Rehber'
for line in [
    'Hupo — 2026-2027 Haftalık Müfredat Akışı ve Ortak Yazılı Konu-Soru Dağılımı (Referans Tablosu)',
    '',
    'Kaynak 1: MEB TYMM Taslak Çerçeve Yıllık Planlar (Temel Eğitim) — tymm.meb.gov.tr/taslak-cerceve-planlari/temel-egitim',
    'Kaynak 2: MEB ODSGM 1. Dönem Konu Soru Dağılım Tabloları (2026-2027) — odsgm.meb.gov.tr/www/1donem-konu-soru-dagilim-tablolari-2026-2027/icerik/1724/tr',
    '',
    'Sayfalar:',
    '  Okul_Haftalari   : resmi hafta numarası ↔ tarih (tarihe göre ortak numaralama)',
    '  Haftalik_Akis    : ders × sınıf × hafta; ünite/tema, konu, kazanım kodları',
    '  Kazanim_Etiket   : soru etiketleme anahtarı — kazanım kodu → hafta(lar) + ortak yazılı soru sayısı (senaryo ortalaması/min/maks)',
    '  Sinav_Dagilim    : 1. Dönem 1. ve 2. Ortak Yazılı — kazanım başına senaryo bazlı soru sayıları (ham tablo, uzun biçim)',
    '  Tatil_Notlari    : planlarda geçen tatil/ara tatil satırları',
    '',
    'Uyarılar: planlar "taslak"tır, MEB güncelleyebilir. DKAB 5-7: 2026-27 planları (dogm.meb.gov.tr + kullanıcı dosyası); DKAB 4 ve 8: yalnız 2025-2026 dosyası, kazanım kodu yok.',
    'Ortak yazılı yalnız 5-8. sınıflar ve DKAB/Fen/Mat/Türkçe/Sosyal(İnkılap)/İngilizce için yayımlanmıştır.',
    '4. ve 8. sınıf (ve bazı derslerin 3/7. sınıfı) önceki program kodları kullanır; "program" sütununa bakın.',
    'Hafta numarası kaynak dosyada tekrar/kayma varsa tarihe göre düzeltilmiştir; ayrıntı: README.md',
]: ws.append([line])
ws.column_dimensions['A'].width = 140; ws['A1'].font = Font(bold=True, size=14)

sheet('Okul_Haftalari', ['hafta', 'baslangic', 'bitis'], [[int(r['hafta']), r['baslangic'], r['bitis']] for r in wk], [8, 14, 14])

rows = []
for p in P:
    for w in p['haftalar']:
        if w.get('dislandi'): continue
        rows.append([p['ders'], p['sinif'], p['varyant'], p['program'], w['hafta'], w['baslangic'], w['bitis'], w['saat'],
                     ' | '.join(w['unite_tema']), ' | '.join(w['konu']), ', '.join(k['kod'] for k in w['kazanimlar']),
                     w['belirli_gun'][:100], w['not'], p['kaynak_yili']])
sheet('Haftalik_Akis', ['ders', 'sinif', 'varyant', 'program', 'hafta', 'baslangic', 'bitis', 'ders_saati', 'unite_tema', 'konu', 'kazanim_kodlari', 'belirli_gun_hafta', 'kayit_notu', 'kaynak_yili'],
      rows, [28, 6, 18, 12, 7, 11, 11, 8, 40, 40, 50, 30, 20, 12])

cols = ['ders', 'sinif', 'varyant', 'program', 'kazanim_kodu', 'kazanim_metni', 'hafta_listesi', 'ilk_hafta', 'son_hafta', 'baslangic', 'bitis', 'unite_tema', 'konu',
        'ortak_yazili_1_senaryo_ort', 'ortak_yazili_1_min', 'ortak_yazili_1_max', 'ortak_yazili_2_senaryo_ort', 'ortak_yazili_2_min', 'ortak_yazili_2_max']
sheet('Kazanim_Etiket', cols, [[(int(r[c]) if c in ('sinif', 'ilk_hafta', 'son_hafta') else r[c]) for c in cols] for r in tag],
      [26, 6, 14, 12, 16, 60, 12, 8, 8, 11, 11, 30, 30, 10, 8, 8, 10, 8, 8])

# sinav: uzun biçim -> kazanım başına senaryo sayıları (geniş)
grp = collections.OrderedDict()
for e in ex:
    k = (e['ders'], e['sinif'], e['sinav'], e['unite'], e['konu'], e['kazanim_kodu'], e['kazanim_metni'])
    grp.setdefault(k, []).append(e['soru_sayisi'])
srows = []
for k, v in grp.items():
    nums = [int(x) for x in v]
    srows.append([k[0], int(k[1]), k[2], k[3], k[4], k[5], k[6], statistics.mean(nums), min(nums), max(nums), ' '.join(str(x) for x in nums)])
sheet('Sinav_Dagilim', ['ders', 'sinif', 'sinav', 'unite_alan', 'konu', 'kazanim_kodu', 'kazanim_metni', 'senaryo_ort', 'min', 'max', 'senaryolar_1_n'],
      srows, [26, 6, 28, 28, 28, 16, 50, 10, 6, 6, 24])
sheet('Tatil_Notlari', ['metin', 'gorulen_ders_sayisi'], [[r['metin'], int(r['gorulen_ders_sayisi'])] for r in tak], [90, 18])

wb.save(D + '/mufredat_referans_2026_2027.xlsx')
print('ok', len(rows), len(tag), len(srows))
