"""WP3 - Kazanimsiz onayli sorular icin kazanim aday listesi uretir.

Girdi:
  --girdi    Salt okunur DB sorgusunun ciktisi (supabase db query --linked, JSON).
             Kazanimsiz onayli sorular.
  --kodlu    (Opsiyonel) Kazanim kodu dolu sorularin (ders, sinif, kazanim_kodu) ciktisi.
  --mufredat docs/mufredat/haftalik_akis_2026_2027.csv

Cikti (--cikti-dir):
  girdi_kazanimsiz_sorular.json  Temiz soru listesi (PII yok; ogrenci verisi yok)
  adaylar.json                   soru_id -> adaylar[kod, metin, unite_tema, skor]
  kontrol_kodlu.json             Ders eslemesi ve kod-mufredat kontrolu

DB'ye yazmaz. Ders eslemesi tahmin etmez: yalnizca birebir ayni ad kabul edilir.
"""
import argparse
import csv
import json
import os
import re
from collections import defaultdict

# Birebir eslesme: DB adi -> mufredat adi. Tahmin yok; buradaki liste disinda
# kalan adlar ders_eslesmedi sayilir.
DERS_ESLEME = {
    "Türkçe": "Türkçe",
    "Matematik": "Matematik",
    "Fen Bilimleri": "Fen Bilimleri",
    "Hayat Bilgisi": "Hayat Bilgisi",
    "Sosyal Bilgiler": "Sosyal Bilgiler",
    "İngilizce": "İngilizce",
    "Din Kültürü ve Ahlak Bilgisi": "Din Kültürü ve Ahlak Bilgisi",
}

STOP = {
    "bir", "ve", "ile", "için", "olan", "olarak", "gibi", "bunu", "hangi", "hangisi",
    "aşağıdaki", "aşağıda", "soru", "doğru", "yanlış", "kadar", "daha", "çok", "her",
    "göre", "sonra", "önce", "içinde", "arasında", "üzerine", "bağlı", "verilen",
    "metin", "metne", "cümle", "cümlede", "örnek", "hangileri", "nedir", "neden",
}


def tr_lower(s):
    return s.replace("I", "ı").replace("İ", "i").lower()


def stems(text):
    out = set()
    for tok in re.findall(r"[a-zçğıöşü0-9]+", tr_lower(text or "")):
        if len(tok) < 4 or tok in STOP:
            continue
        out.add(tok[:5])  # kaba ek kirpma
    return out


def parse_json_out(path):
    t = open(path, encoding="utf-8").read()
    return json.loads(t[t.index("{"): t.rindex("}") + 1])


def load_mufredat(path):
    rows = []
    with open(path, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f):
            if r.get("kaynak_yili") != "2026-2027":
                continue
            if not r.get("kazanim_kodu"):
                continue
            rows.append(r)
    kaz = {}  # (ders, sinif, kod) -> bilgi
    for r in rows:
        key = (r["ders"], int(r["sinif"]), r["kazanim_kodu"])
        if key not in kaz:
            kaz[key] = {
                "kod": r["kazanim_kodu"],
                "metin": r["kazanim_metni"],
                "unite_tema": r["unite_tema"],
                "konu": r["konu"],
                "ilk_hafta": int(r["hafta"]),
            }
        else:
            kaz[key]["ilk_hafta"] = min(kaz[key]["ilk_hafta"], int(r["hafta"]))
    return kaz


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--girdi", required=True)
    ap.add_argument("--kodlu")
    ap.add_argument("--mufredat", required=True)
    ap.add_argument("--cikti-dir", required=True)
    a = ap.parse_args()

    sorular = parse_json_out(a.girdi)["rows"]
    sorular.sort(key=lambda r: (r["sinif"], r["ders"], r["id"]))
    girdi_out = []
    for r in sorular:
        girdi_out.append({
            "id": r["id"], "ders": r["ders"], "sinif": r["sinif"],
            "konu": r["konu"], "alt_konu": r["alt_konu"],
            "soru_metni": r["soru_metni"], "siklar": r["siklar"],
            "dogru_sik": r["dogru_sik"], "kazanim_kodu": r["kazanim_kodu"],
        })
    os.makedirs(a.cikti_dir, exist_ok=True)
    with open(os.path.join(a.cikti_dir, "girdi_kazanimsiz_sorular.json"), "w", encoding="utf-8") as f:
        json.dump(girdi_out, f, ensure_ascii=False, indent=1)

    kaz = load_mufredat(a.mufredat)
    # (ders, sinif) -> kazanim listesi
    by_ds = defaultdict(list)
    for (ders, sinif, kod), v in kaz.items():
        by_ds[(ders, sinif)].append(v)

    adaylar = {}
    ders_eslesmedi = []
    eslesme_yok_sinif = []
    for q in girdi_out:
        ders_m = DERS_ESLEME.get(q["ders"])
        if ders_m is None:
            ders_eslesmedi.append(q["id"])
            adaylar[q["id"]] = {"ders_eslesmedi": True, "adaylar": []}
            continue
        pool = by_ds.get((ders_m, q["sinif"]), [])
        if not pool:
            eslesme_yok_sinif.append(q["id"])
        qk = stems(q["konu"]) | stems(q["alt_konu"])
        qs = stems(q["soru_metni"]) - qk
        scored = []
        for k in pool:
            ks = stems(k["metin"]) | stems(k["konu"]) | stems(k["unite_tema"])
            skor = 2 * len(qk & ks) + len(qs & ks)
            if skor > 0:
                scored.append((skor, k["ilk_hafta"], k["kod"], k))
        scored.sort(key=lambda x: (-x[0], x[1], x[2]))
        top = [{"kod": k["kod"], "metin": k["metin"], "unite_tema": k["unite_tema"],
                "konu": k["konu"], "ilk_hafta": k["ilk_hafta"], "skor": s}
               for s, _, _, k in scored[:8]]
        adaylar[q["id"]] = {"ders_eslesmedi": False, "mufredat_ders": ders_m,
                            "sinif": q["sinif"], "adaylar": top}

    with open(os.path.join(a.cikti_dir, "adaylar.json"), "w", encoding="utf-8") as f:
        json.dump(adaylar, f, ensure_ascii=False, indent=1)

    # Kod dolu sorular: kod mufredatta var mi?
    kontrol = {"ders_eslesmedi_kazanimsiz": ders_eslesmedi,
               "sinif_mufredatta_yok_kazanimsiz": eslesme_yok_sinif,
               "kod_mufredatta_yok": []}
    if a.kodlu:
        kodlu = parse_json_out(a.kodlu)["rows"]
        for r in kodlu:
            ders_m = DERS_ESLEME.get(r["ders"])
            ok = ders_m is not None and (ders_m, int(r["sinif"]), r["kazanim_kodu"]) in kaz
            if not ok:
                kontrol["kod_mufredatta_yok"].append(
                    {"ders": r["ders"], "sinif": r["sinif"], "kod": r["kazanim_kodu"]})
        kontrol["kodlu_tuple_sayisi"] = len(kodlu)
    with open(os.path.join(a.cikti_dir, "kontrol_kodlu.json"), "w", encoding="utf-8") as f:
        json.dump(kontrol, f, ensure_ascii=False, indent=1)

    bos = sum(1 for v in adaylar.values() if not v["ders_eslesmedi"] and not v["adaylar"])
    print(f"soru={len(girdi_out)} ders_eslesmedi={len(ders_eslesmedi)} "
          f"sinif_mufredatta_yok={len(eslesme_yok_sinif)} bos_aday={bos} "
          f"kod_mufredatta_yok={len(kontrol['kod_mufredatta_yok'])}")


if __name__ == "__main__":
    main()
