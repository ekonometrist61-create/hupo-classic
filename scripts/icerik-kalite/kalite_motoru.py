"""Hupo hikâye kalite taraması (H-GIE Faz 1b).

Yalnız okur; hiçbir hikâye dosyasını veya durumunu değiştirmez.
Kontroller:
  * metadata:  zorunlu alanlar, fis_kodu/slug/dosya adı tutarlılığı, tekrar eden kimlikler
  * kodlama:   bozuk UTF-8 (çift kodlama) belirtileri
  * tekrar:    gövde metinleri arasında 3-kelime gömleği (shingle) Jaccard benzerliği
  * istatistik: kelime, cümle, ortalama cümle uzunluğu (uzman incelemesi için ham veri)

Sınır: Maarif/MEB kazanım uyumu ve seviye uygunluğu otomatik kesinleşmez.
Bu kontroller yalnız ön eleme içindir; her hikâye uzman incelemesinden geçmelidir.

Kullanım:  python kalite_motoru.py <hikaye_klasoru> <cikti_klasoru>
"""
import json
import re
import sys
from collections import defaultdict
from datetime import date
from itertools import combinations
from pathlib import Path

ZORUNLU = [
    "baslik", "slug", "fis_kodu", "tur", "sinif_alt", "sinif_ust",
    "okuma_bandi", "dunya_tipi", "yetiskin_uygun", "tanitim", "durum",
    "uretim_kaynak", "tarih", "etiketler",
]
BENZERLIK_ESIGI = 0.25  # 3-kelime gömleği Jaccard; üstü incelemeye alınır
BOZUK_KODLAMA = re.compile(r"Ã.|Ä.|Å.|Â.|Ã¼|Ã§|Ä±|Å.")
KELIME = re.compile(r"[a-zçğıöşü0-9]+")


def turkce_kucuk(metin: str) -> str:
    return metin.replace("İ", "i").replace("I", "ı").lower()


def on_bilgi_ve_govde(metin: str):
    satirlar = metin.splitlines()
    if not satirlar or satirlar[0].strip() != "---":
        return {}, metin
    try:
        son = satirlar.index("---", 1)
    except ValueError:
        return {}, metin
    on = {}
    anahtar = None
    for satir in satirlar[1:son]:
        if re.match(r"^[a-z_]+:", satir):
            anahtar, _, deger = satir.partition(":")
            on[anahtar] = deger.strip().strip(chr(34)).strip(chr(39))
        elif satir.startswith("  ") and anahtar:
            on[anahtar] += " " + satir.strip()
    return on, "\n".join(satirlar[son + 1 :])


def gomlek(kelimeler, n=3):
    return {" ".join(kelimeler[i : i + n]) for i in range(max(0, len(kelimeler) - n + 1))}


def istatistik(govde: str):
    kelimeler = KELIME.findall(turkce_kucuk(govde))
    cumleler = [c for c in re.split(r"[.!?…]+", govde) if KELIME.search(turkce_kucuk(c))]
    ort = round(len(kelimeler) / len(cumleler), 1) if cumleler else None
    return {"kelime": len(kelimeler), "cumle": len(cumleler), "ort_cumle_uzunlugu": ort}


def tara(klasor: Path):
    dosyalar = sorted(klasor.glob("*.hikaye.md"))
    kayitlar = []
    for yol in dosyalar:
        metin = yol.read_text(encoding="utf-8")
        on, govde = on_bilgi_ve_govde(metin)
        sorunlar = []
        eksik = [a for a in ZORUNLU if not on.get(a)]
        if eksik:
            sorunlar.append({"kod": "metadata_eksik", "alanlar": eksik})
        dosya_kodu = re.match(r"hr(\d+)", yol.name)
        fis = on.get("fis_kodu", "")
        if dosya_kodu and fis and fis.upper() != f"HR-{dosya_kodu.group(1)}":
            sorunlar.append({"kod": "fis_kodu_dosya_uyusmuyor", "fis_kodu": fis})
        if on.get("slug") and on.get("slug") != yol.name.replace(".hikaye.md", ""):
            sorunlar.append({"kod": "slug_dosya_uyusmuyor", "slug": on.get("slug")})
        bozuk = len(BOZUK_KODLAMA.findall(metin))
        if bozuk:
            sorunlar.append({"kod": "bozuk_kodlama", "adet": bozuk})
        kayitlar.append({
            "dosya": yol.name,
            "fis_kodu": fis,
            "baslik": on.get("baslik", ""),
            "durum": on.get("durum", ""),
            "istatistik": istatistik(govde),
            "gomlek": gomlek(KELIME.findall(turkce_kucuk(govde))),
            "sorunlar": sorunlar,
        })

    # Tekrar eden kimlikler
    kimlik = defaultdict(list)
    for k in kayitlar:
        if k["fis_kodu"]:
            kimlik[k["fis_kodu"].upper()].append(k["dosya"])
    for fis, liste in kimlik.items():
        if len(liste) > 1:
            for k in kayitlar:
                if k["fis_kodu"].upper() == fis:
                    k["sorunlar"].append({"kod": "fis_kodu_tekrar", "dosyalar": liste})

    # Gövde benzerliği
    ciftler = []
    for a, b in combinations(kayitlar, 2):
        ortak = len(a["gomlek"] & b["gomlek"])
        birlesim = len(a["gomlek"] | b["gomlek"])
        if birlesim == 0:
            continue
        j = ortak / birlesim
        if j >= BENZERLIK_ESIGI:
            ciftler.append({"a": a["dosya"], "b": b["dosya"], "jaccard": round(j, 3)})
    ciftler.sort(key=lambda c: -c["jaccard"])
    for c in ciftler:
        for k in kayitlar:
            if k["dosya"] in (c["a"], c["b"]):
                k["sorunlar"].append({"kod": "govde_benzer", "esik": BENZERLIK_ESIGI})

    for k in kayitlar:
        del k["gomlek"]
    return kayitlar, ciftler


def ozet_yaz(kayitlar, ciftler, cikti: Path):
    cikti.mkdir(parents=True, exist_ok=True)
    bugun = date.today().isoformat()
    sayac = defaultdict(int)
    for k in kayitlar:
        for s in k["sorunlar"]:
            sayac[s["kod"]] += 1
    json_yol = cikti / f"kalite-raporu-{bugun}.json"
    json_yol.write_text(
        json.dumps({"tarih": bugun, "hikaye_sayisi": len(kayitlar), "sayac": sayac,
                    "benzer_ciftler": ciftler, "hikayeler": kayitlar},
                   ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    satirlar = [
        f"# Hikâye kalite taraması — {bugun}",
        "",
        "> Bu rapor yalnız ön eleme içindir. Maarif/MEB uyumu, seviye uygunluğu ve",
        "> yayın kararı uzman incelemesi ve insan onayı gerektirir. Hiçbir hikâye",
        "> bu rapor nedeniyle değiştirilmedi ya da yayınlanmadı.",
        "",
        f"Taranan hikâye: **{len(kayitlar)}**",
        "",
        "## Sayımlar",
        "",
        "| Kontrol | Adet |",
        "|---|---|",
    ]
    for kod, adet in sorted(sayac.items(), key=lambda x: -x[1]):
        satirlar.append(f"| {kod} | {adet} |")
    satirlar += ["", f"## Benzer gövde çiftleri (Jaccard ≥ {BENZERLIK_ESIGI})", ""]
    if ciftler:
        satirlar += ["| A | B | Jaccard |", "|---|---|---|"]
        satirlar += [f"| {c['a']} | {c['b']} | {c['jaccard']} |" for c in ciftler[:40]]
    else:
        satirlar.append("Eşik üstü benzer çift yok.")
    satirlar += ["", "## Metadata, kodlama ve tutarlılık sorunları", ""]
    sorunlu = [k for k in kayitlar if any(s["kod"] not in ("govde_benzer",) for s in k["sorunlar"])]
    if sorunlu:
        for k in sorunlu:
            detay = "; ".join(
                f"{s['kod']}{' ' + str(s.get('alanlar', s.get('adet', s.get('dosyalar', s.get('fis_kodu', s.get('slug', '')))))) if any(x in s for x in ('alanlar', 'adet', 'dosyalar', 'fis_kodu', 'slug')) else ''}"
                for s in k["sorunlar"] if s["kod"] != "govde_benzer"
            )
            satirlar.append(f"- {k['dosya']}: {detay}")
    else:
        satirlar.append("Metadata ve kodlama sorunu yok.")
    md_yol = cikti / f"kalite-ozeti-{bugun}.md"
    md_yol.write_text("\n".join(satirlar) + "\n", encoding="utf-8")
    return json_yol, md_yol


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Kullanım: python kalite_motoru.py <hikaye_klasoru> <cikti_klasoru>")
        sys.exit(2)
    kayitlar, ciftler = tara(Path(sys.argv[1]))
    j, m = ozet_yaz(kayitlar, ciftler, Path(sys.argv[2]))
    print(f"hikaye={len(kayitlar)} benzer_cift={len(ciftler)}")
    print(j)
    print(m)
