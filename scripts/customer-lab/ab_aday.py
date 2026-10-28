"""Customer-Lab L3: A/B aday listesi ve örneklem hesabı.

Girdi : sentetik senaryo çıktıları (fiyat_senaryo.py). Hipotez.
Çıktı : gerçek A/B testine ADAY listesi. Sentetik sonuç karar değildir; her aday
        gerçek kullanıcıda, guardrail ve örneklem kurallarıyla doğrulanmalıdır.

Örneklem (iki oranlı z-testi, iki kuyruklu):
    n_kol = ((z_alfa + z_guc)^2 * (p1(1-p1) + p2(1-p2))) / (p1 - p2)^2
Çoklu karşılaştırma: k aday için alfa, Bonferroni ile alfa/k'ya bölünür.
"""
import math
from statistics import NormalDist

Z = NormalDist()
GUC = 0.8  # VARSAYIM: %80 güç


def ornek_boyutu(p1: float, p2: float, alfa: float = 0.05, guc: float = GUC) -> int:
    """Her kol için gerekli örneklem (yukarı yuvarlanmış)."""
    if not (0 < p1 < 1 and 0 < p2 < 1):
        raise ValueError("Oranlar (0,1) aralığında olmalı")
    if p1 == p2:
        raise ValueError("Fark sıfır; örneklem hesaplanamaz")
    if not (0 < alfa < 1 and 0 < guc < 1):
        raise ValueError("alfa ve güç (0,1) aralığında olmalı")
    z_a = Z.inv_cdf(1 - alfa / 2)
    z_g = Z.inv_cdf(guc)
    n = ((z_a + z_g) ** 2 * (p1 * (1 - p1) + p2 * (1 - p2))) / (p1 - p2) ** 2
    return math.ceil(n)


def aday_listesi(senaryolar: list, referans_oran: float, k_alfa: float = 0.05) -> dict:
    """Her senaryo için referansa göre örneklem ve çoklu karşılaştırma düzeltmeli alfa.

    senaryolar: fiyat_senaryo.py çıktısının 'sonuclar' listesi (beklenen_alt/ust).
    referans_oran: mevcut durumun oranı (hipotez değeri).
    """
    if not senaryolar:
        raise ValueError("Aday yok")
    if not 0 < referans_oran < 1:
        raise ValueError("referans_oran (0,1) aralığında olmalı")

    k = len(senaryolar)
    alfa_duzeltilmis = k_alfa / k  # Bonferroni
    adaylar = []
    for s in senaryolar:
        orta = (s["beklenen_alt"] + s["beklenen_ust"]) / 2
        if orta == referans_oran:
            continue
        n = ornek_boyutu(referans_oran, orta, alfa=alfa_duzeltilmis)
        adaylar.append({
            "senaryo": s["senaryo"],
            "hipotez_orani": round(orta, 4),
            "referans_orani": referans_oran,
            "fark_yuzde_puan": round((orta - referans_oran) * 100, 2),
            "kol_basi_ornek": n,
            "alfa_duzeltilmis": round(alfa_duzeltilmis, 6),
            "etiket": "hipotez_aday",
        })
    # Büyük fark ve küçük örneklem önce gelir
    adaylar.sort(key=lambda a: (a["kol_basi_ornek"], -abs(a["fark_yuzde_puan"])))
    return {
        "tur": "ab_aday_listesi",
        "etiket": "hipotez_aday",
        "uyari": "Sentetik hipotez. Gerçek A/B testi (rastgele atama, guardrail, ön kayıt) olmadan karar verilmez.",
        "guc": GUC,
        "k_alfa": k_alfa,
        "aday_sayisi": len(adaylar),
        "adaylar": adaylar,
    }
