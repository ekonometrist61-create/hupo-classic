"""Customer-Lab L1: persona parametre kataloğu.

Girdi: toplulaştırılmış rapor verisi (kohort özeti, izin özeti). Kişi verisi yoktur.
Çıktı: HİPOTEZ katalog. Gerçek kullanıcı ölçümü değildir; kanıt olarak kullanılamaz.

Kurallar (spec §3, §6):
  * Her persona en az ESIK (10) hane/öğrenci ile türetilir; altında persona üretilmez.
  * Null (gizli) veya eksik değerden parametre türetilmez.
  * Her çıktı "hipotez": true ve bir uyarı metni taşır.
  * Aynı girdi aynı çıktıyı verir (tohum ve sıralama sabit).
"""
import json
import sys
from pathlib import Path

ESIK = 10
UYARI = "Hipotez kataloğu. Gerçek kullanıcı ölçümü değildir; A/B testi olmadan karar kanıtı sayılmaz."


def _gun(ozet, gun):
    for s in ozet:
        if s.get("gun") == gun:
            return s
    return None


def katalog_uret(veri: dict, esik: int = ESIK) -> dict:
    personalar = []

    ozet = veri.get("kohort", {}).get("ozet", [])
    d1 = _gun(ozet, 1)
    d7 = _gun(ozet, 7)

    if d1 and d1.get("uygun_hane") is not None and d1["uygun_hane"] >= esik and d1.get("oran") is not None:
        personalar.append({
            "id": "ilk_gun_geri_donen",
            "etiket": "İlk gün geri dönen veli (hipotez)",
            "n": d1["uygun_hane"],
            "parametreler": {"d1_oran_yuzde": d1["oran"]},
            "kaynak": "kohort.ozet[gun=1]",
        })

    if d7 and d7.get("uygun_hane") is not None and d7["uygun_hane"] >= esik and d7.get("oran") is not None:
        personalar.append({
            "id": "hafta_ici_duzenli",
            "etiket": "Bir hafta içinde geri dönen veli (hipotez)",
            "n": d7["uygun_hane"],
            "parametreler": {"d7_oran_yuzde": d7["oran"]},
            "kaynak": "kohort.ozet[gun=7]",
        })

    eposta = next((i for i in veri.get("veri_kalitesi", {}).get("izin", []) if i.get("kanal") == "eposta"), None)
    if eposta:
        acik = eposta.get("acik")
        kapali = eposta.get("kapali")
        kayit_yok = eposta.get("kayit_yok")
        if None not in (acik, kapali, kayit_yok):
            toplam = acik + kapali + kayit_yok
            if toplam >= esik:
                personalar.append({
                    "id": "eposta_izinli",
                    "etiket": "E-posta izni açık veli (hipotez)",
                    "n": toplam,
                    "parametreler": {"eposta_acik_yuzde": round(100.0 * acik / toplam, 1)},
                    "kaynak": "veri_kalitesi.izin[eposta]",
                })

    personalar.sort(key=lambda p: p["id"])
    return {"tur": "hipotez_katalogu", "esik": esik, "uyari": UYARI, "personalar": personalar}


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Kullanım: python katalog.py <rapor_verisi.json> <cikti.json>")
        sys.exit(2)
    veri = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    sonuc = katalog_uret(veri)
    Path(sys.argv[2]).write_text(json.dumps(sonuc, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"persona={len(sonuc['personalar'])}")
