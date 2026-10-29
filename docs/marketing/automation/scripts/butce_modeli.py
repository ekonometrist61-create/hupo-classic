"""Hupolingo 12 aylık bütçe/CAC/LTV SENARYO modeli.

TÜM GİRDİLER VARSAYIMDIR (gerçek Hupo verisi yok). Çıktı tahmin değil, duyarlılık aralığıdır.
Gerçek veri geldikçe GIRDILER içindeki değerleri değiştirin (kaynak: Büyüme Özeti, growth_harcama, plans).
Kullanım: python butce_modeli.py [cikti.csv]
"""
import csv
import sys

AYLAR = ["2026-11", "2026-12", "2027-01", "2027-02", "2027-03", "2027-04",
         "2027-05", "2027-06", "2027-07", "2027-08", "2027-09", "2027-10"]

# Fiyat: PLAN KAYDI YOK. Üç varsayımsal tek seferlik dönem fiyatı (TL, KDV dahil varsayım).
FIYAT = {"dusuk": 400.0, "orta": 700.0, "yuksek": 1000.0}
NET_ORAN = 0.75          # KDV + ödeme komisyonu sonrası net gelir oranı (varsayım)
TEKRAR_ALIM = {"dusuk": 0.10, "orta": 0.25, "yuksek": 0.40}   # dönem sonu yeniden satın alma (varsayım)

# Huni oranları: (kötü, baz, iyi). Hepsi varsayım; baseline ölçülünce değişecek.
HUNI = {
    "ziyaret_demo":   (0.08, 0.15, 0.25),   # ziyaretçi -> demo tamamlama (çerez onaylı alt küme dışı etki yok sayıldı)
    "demo_kayit":     (0.05, 0.12, 0.20),   # demo -> veli kaydı
    "kayit_aktif":    (0.25, 0.40, 0.55),   # kayıt -> çocuk ilk tamamlanmış oturum
    "aktif_ucretli":  (0.02, 0.06, 0.12),   # aktif -> ücretli (K-0193 referans ölçümü sonrası gerçek)
}

# Mevsimsellik çarpanı (ara tatil, yarıyıl, yaz, okul açılışı). Hipotez.
MEVSIM = [1.0, 1.0, 1.2, 1.0, 1.1, 1.0, 1.0, 0.8, 0.9, 1.1, 1.4, 1.3]

SENARYO = {
    # organik ziyaretçi/ay (başlangıç, aylık büyüme), aylık ücretli bütçe TL, TBM (TL/tık), sabit araç+üretim TL/ay
    "A_minimum":  {"org0": 300,  "buyume": 0.12, "reklam": 0,      "tbm": 6.0, "sabit": 500},
    "B_dengeli":  {"org0": 300,  "buyume": 0.15, "reklam": 7500,   "tbm": 6.0, "sabit": 2500},
    "C_agresif":  {"org0": 300,  "buyume": 0.18, "reklam": 30000,  "tbm": 6.0, "sabit": 8000},
}
# Ücretli reklam yalnız Faz 3'ten sonra (2027-05 itibaren); öncesi 0 (kapı kuralı).
REKLAM_BASLANGIC = 6


def calistir(sen, huni_idx, fiyat_ad):
    p = SENARYO[sen]
    org = p["org0"]
    toplam_satis = 0.0
    harcama = 0.0
    satirlar = []
    for i, ay in enumerate(AYLAR):
        if i > 0:
            org *= 1 + p["buyume"]
        reklam = p["reklam"] if i >= REKLAM_BASLANGIC else 0
        ucretli_ziyaret = reklam / p["tbm"] if reklam else 0
        ziyaret = (org + ucretli_ziyaret) * MEVSIM[i]
        demo = ziyaret * HUNI["ziyaret_demo"][huni_idx]
        kayit = demo * HUNI["demo_kayit"][huni_idx]
        aktif = kayit * HUNI["kayit_aktif"][huni_idx]
        satis = aktif * HUNI["aktif_ucretli"][huni_idx]
        gider = reklam + p["sabit"]
        toplam_satis += satis
        harcama += gider
        satirlar.append((ay, round(ziyaret), round(demo, 1), round(kayit, 1), round(aktif, 1), round(satis, 2), gider))
    fiyat = FIYAT[fiyat_ad]
    net_birim = fiyat * NET_ORAN
    ltv = net_birim * (1 + TEKRAR_ALIM[fiyat_ad])
    cac = harcama / toplam_satis if toplam_satis else None
    return {
        "satirlar": satirlar,
        "toplam_harcama": harcama,
        "ucretli_hane": toplam_satis,
        "cac": cac,
        "ltv": ltv,
        "net_birim": net_birim,
        "ltv_cac": (ltv / cac) if cac else None,
        # Tek seferlik satışta geri ödeme = ilk satışta net gelir CAC'yi karşılıyor mu
        "ilk_satis_karsiliyor": (net_birim >= cac) if cac else None,
        "net_gelir": toplam_satis * ltv,
    }


def main(cikti=None):
    etiketler = ["kotu", "baz", "iyi"]
    sonuc = []
    for sen in SENARYO:
        for hi, hl in enumerate(etiketler):
            for fa in FIYAT:
                r = calistir(sen, hi, fa)
                sonuc.append({
                    "senaryo": sen, "huni": hl, "fiyat_varsayim": fa,
                    "toplam_harcama_TL": round(r["toplam_harcama"]),
                    "ucretli_hane": round(r["ucretli_hane"], 1),
                    "CAC_TL": None if r["cac"] is None else round(r["cac"]),
                    "net_birim_TL": round(r["net_birim"]),
                    "LTV_TL": round(r["ltv"]),
                    "LTV_CAC": None if r["ltv_cac"] is None else round(r["ltv_cac"], 2),
                    "ilk_satis_CAC_karsiliyor": r["ilk_satis_karsiliyor"],
                    "tahmini_net_gelir_TL": round(r["net_gelir"]),
                    "etiket": "SENARYO-VARSAYIM",
                })
    cols = list(sonuc[0].keys())
    if cikti:
        with open(cikti, "w", newline="", encoding="utf-8-sig") as f:
            w = csv.DictWriter(f, fieldnames=cols)
            w.writeheader()
            w.writerows(sonuc)
    return sonuc


if __name__ == "__main__":
    out = main(sys.argv[1] if len(sys.argv) > 1 else None)
    for r in out:
        if r["fiyat_varsayim"] == "orta":
            print(r["senaryo"], r["huni"], "harcama", r["toplam_harcama_TL"], "satis", r["ucretli_hane"],
                  "CAC", r["CAC_TL"], "LTV/CAC", r["LTV_CAC"])
