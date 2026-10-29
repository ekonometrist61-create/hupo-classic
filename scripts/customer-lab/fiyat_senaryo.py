"""Customer-Lab L2: fiyat duyarlılığı senaryo koşucusu.

Girdi : persona (katalog.py çıktısından; d1 oranı) + fiyat noktaları + AÇIK varsayımlar.
Çıktı : HİPOTEZ aralıkları. Gerçek dönüşüm ölçümü değildir; A/B testi yerine geçmez.

Model (bilinçli olarak basit):
    baz      = (d1_oran / 100) * baz_donusum_carpani          # varsayım: ücretli dönüşüm payı
    beklenen = baz * (fiyat / referans_fiyat) ** fiyat_esnekligi # esneklik < 0: fiyat artınca düşer
    aralik   = beklenen * (1 ± belirsizlik_bandi), [0, 1] içine kırpılır

Tüm varsayımlar çıktıya yazılır. Tohum kaydedilir (ileride Monte Carlo için); bu sürümde rastgelelik yoktur.
"""
import json
import sys
from pathlib import Path

VARSAYILAN = {
    "baz_donusum_carpani": 0.2,     # VARSAYIM: ilk gün tutulan velilerin ücretli dönüşüme oranı
    "fiyat_esnekligi": -0.5,        # VARSAYIM: fiyat %1 artınca talep yaklaşık %0.5 düşer
    "referans_fiyat_kurus": 9900,   # VARSAYIM: karşılaştırma fiyatı
    "belirsizlik_bandi": 0.3,       # VARSAYIM: ±%30 aralık
}


def senaryo_uret(persona: dict, fiyatlar_kurus: list, tohum: int = 0, varsayim: dict | None = None) -> dict:
    v = {**VARSAYILAN, **(varsayim or {})}

    d1 = persona.get("parametreler", {}).get("d1_oran_yuzde")
    if d1 is None:
        raise ValueError("Persona d1_oran_yuzde içermiyor; senaryo üretilmez (gizli veya eksik değer)")
    if not fiyatlar_kurus:
        raise ValueError("En az bir fiyat noktası gerekir")
    if v["fiyat_esnekligi"] >= 0:
        raise ValueError("fiyat_esnekligi negatif olmalı (fiyat artınca talep düşer)")
    if not 0 <= v["belirsizlik_bandi"] <= 1:
        raise ValueError("belirsizlik_bandi 0 ile 1 arasında olmalı")
    if not 0 < v["baz_donusum_carpani"] <= 1:
        raise ValueError("baz_donusum_carpani 0 ile 1 arasında olmalı")

    baz = (float(d1) / 100.0) * v["baz_donusum_carpani"]
    sonuclar = []
    for fiyat in sorted(set(int(f) for f in fiyatlar_kurus)):
        if fiyat <= 0:
            raise ValueError("Fiyat pozitif olmalı")
        beklenen = baz * (fiyat / v["referans_fiyat_kurus"]) ** v["fiyat_esnekligi"]
        alt = max(0.0, beklenen * (1 - v["belirsizlik_bandi"]))
        ust = min(1.0, beklenen * (1 + v["belirsizlik_bandi"]))
        sonuclar.append({
            "senaryo": f"fiyat_{fiyat}",
            "fiyat_kurus": fiyat,
            "beklenen_alt": round(alt, 4),
            "beklenen_ust": round(ust, 4),
            "etiket": "hipotez",
        })

    return {
        "tur": "fiyat_senaryosu",
        "etiket": "hipotez",
        "uyari": "Varsayıma dayalı hipotez. Gerçek dönüşüm ölçümü değildir; A/B testiyle doğrulanmadan karar kanıtı sayılmaz.",
        "tohum": tohum,
        "varsayimlar": v,
        "persona": {"id": persona.get("id"), "d1_oran_yuzde": d1},
        "sonuclar": sonuclar,
    }


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Kullanım: python fiyat_senaryo.py <persona.json> <fiyatlar_kurus,virgullu> <cikti.json>")
        sys.exit(2)
    persona = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    fiyatlar = [int(x) for x in sys.argv[2].split(",")]
    sonuc = senaryo_uret(persona, fiyatlar, tohum=42)
    Path(sys.argv[3]).write_text(json.dumps(sonuc, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"senaryo={len(sonuc['sonuclar'])} (hipotez)")
