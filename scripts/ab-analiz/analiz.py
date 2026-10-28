"""A/B motoru A2: toplulaştırılmış analiz (yerel, veritabanı yok).

Girdi: kol başına toplam (n) ve başarı (x) sayıları; guardrail sayıları; deney tanımı.
Çıktı: karar durumu. Kişi verisi yoktur.

Kurallar (AB_MOTORU_SPEC §5, §6):
  * Bitiş tarihinden önce karar verilmez ('ara_izleme'): ara bakış yasak.
  * SRM (örneklem oranı uyumsuzluğu) p < 0.001 ise deney geçersiz ('srm_gecersiz'); sonuç raporlanmaz.
  * Örneklem kol başına kol_basi_ornek'in altındaysa 'yetersiz_ornek'.
  * Birincil metrik: iki kuyruklu iki oranlı z-testi; çoklu karşılaştırmada alfa Bonferroni ile bölünür.
  * Guardrail: deney kolunda oran kontrolden anlamlı (tek kuyruklu, alfa) yüksekse 'guardrail_ihlali'.
"""
import math
from datetime import date
from statistics import NormalDist

N01 = NormalDist()
SRM_ESIK = 0.001


def iki_oranli_z(x1: int, n1: int, x2: int, n2: int):
    """(fark = p2 - p1, z, p_iki_kuyruk). p1 kontrol, p2 deney."""
    if n1 <= 0 or n2 <= 0:
        raise ValueError("Kol boyutu sıfırdan büyük olmalı")
    p1, p2 = x1 / n1, x2 / n2
    p_havuz = (x1 + x2) / (n1 + n2)
    se = math.sqrt(p_havuz * (1 - p_havuz) * (1 / n1 + 1 / n2))
    if se == 0:
        return p2 - p1, 0.0, 1.0
    z = (p2 - p1) / se
    p = 2 * (1 - N01.cdf(abs(z)))
    return p2 - p1, z, p


def guven_araligi(x1, n1, x2, n2, guven=0.95):
    p1, p2 = x1 / n1, x2 / n2
    se = math.sqrt(p1 * (1 - p1) / n1 + p2 * (1 - p2) / n2)
    k = N01.inv_cdf(1 - (1 - guven) / 2)
    fark = p2 - p1
    return fark - k * se, fark + k * se


def srm_p(n_kontrol: int, n_deney: int, beklenen_deney_orani: float = 0.5) -> float:
    """Tek kuyruk ki-kare (1 serbestlik derecesi) SRM p-değeri."""
    toplam = n_kontrol + n_deney
    e_deney = toplam * beklenen_deney_orani
    e_kontrol = toplam * (1 - beklenen_deney_orani)
    chi2 = (n_deney - e_deney) ** 2 / e_deney + (n_kontrol - e_kontrol) ** 2 / e_kontrol
    return 2 * (1 - N01.cdf(math.sqrt(chi2)))


def analiz(deney: dict, sayilar: dict, bugun: date) -> dict:
    """deney: {'kol_basi_ornek', 'bitis', 'alfa', 'guardrail_adlari', 'birincil_metrik'}
    sayilar: {'kontrol': {'n', 'x'}, 'deney': {'n', 'x'},
              'guardrail': {ad: {'kontrol': {'n','x'}, 'deney': {'n','x'}}}}
    """
    k_metrik = 1 + len(sayilar.get("guardrail", {}))
    alfa = deney["alfa"] / k_metrik  # Bonferroni: birincil + guardrail'lar
    kon, dey = sayilar["kontrol"], sayilar["deney"]
    sonuc = {"durum": None, "neden": None, "srm_p": None, "birincil": None, "guardrail": []}

    if bugun < deney["bitis"]:
        sonuc["durum"] = "ara_izleme"
        sonuc["neden"] = "Bitiş tarihinden önce karar verilmez (ara bakış yasak)."
        return sonuc

    sonuc["srm_p"] = srm_p(kon["n"], dey["n"])
    if sonuc["srm_p"] < SRM_ESIK:
        sonuc["durum"] = "srm_gecersiz"
        sonuc["neden"] = "Örneklem oranı uyumsuz (SRM); sonuç raporlanmaz."
        return sonuc

    if min(kon["n"], dey["n"]) < deney["kol_basi_ornek"]:
        sonuc["durum"] = "yetersiz_ornek"
        sonuc["neden"] = f"Kol başına en az {deney['kol_basi_ornek']} gerekir."
        return sonuc

    fark, z, p = iki_oranli_z(kon["x"], kon["n"], dey["x"], dey["n"])
    ci = guven_araligi(kon["x"], kon["n"], dey["x"], dey["n"], guven=1 - alfa)
    sonuc["birincil"] = {
        "kontrol_orani": round(kon["x"] / kon["n"], 4),
        "deney_orani": round(dey["x"] / dey["n"], 4),
        "fark": round(fark, 4),
        "ci": [round(ci[0], 4), round(ci[1], 4)],
        "p": round(p, 6),
        "anlamli": p < alfa,
    }

    ihlal = False
    for ad, g in sayilar.get("guardrail", {}).items():
        _, gz, gp = iki_oranli_z(g["kontrol"]["x"], g["kontrol"]["n"], g["deney"]["x"], g["deney"]["n"])
        gp_tek = gp / 2 if gz > 0 else 1 - gp / 2  # tek kuyruk: deney daha kötü mü
        kotu = gz > 0 and gp_tek < alfa
        ihlal = ihlal or kotu
        sonuc["guardrail"].append({"ad": ad, "p_tek_kuyruk": round(gp_tek, 6), "kotu": kotu})

    if ihlal:
        sonuc["durum"] = "guardrail_ihlali"
        sonuc["neden"] = "Guardrail metriği deney kolunda anlamlı biçimde kötü; birincil sonuç yok sayılır."
    else:
        sonuc["durum"] = "karar_hazir"
        sonuc["neden"] = "Birincil sonuç ön kayıtlı analizle hesaplandı."
    return sonuc


if __name__ == "__main__":
    import json
    import sys
    from pathlib import Path

    if len(sys.argv) != 3:
        print("Kullanım: python analiz.py <girdi.json> <bugun YYYY-MM-DD>")
        sys.exit(2)
    g = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    d = g["deney"]
    deney = {
        "kol_basi_ornek": d["kol_basi_ornek"],
        "bitis": date.fromisoformat(d["bitis"]),
        "alfa": d.get("alfa", 0.05),
    }
    print(json.dumps(analiz(deney, g["sayilar"], date.fromisoformat(sys.argv[2])), ensure_ascii=False, indent=2))
