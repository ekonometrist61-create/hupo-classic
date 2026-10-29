"""A/B A2 testleri: z-testi, SRM, ara bakış yasağı, guardrail ve SAHTE VERİ ile hata oranları.

Çalıştırma:  python -m unittest test_analiz -v
"""
import random
import unittest
from datetime import date, timedelta

import analiz as a

BITIS = date(2026, 11, 30)
DENEY = {"kol_basi_ornek": 500, "bitis": BITIS, "alfa": 0.05}


def sayilar(kn, kx, dn, dx, guard=None):
    s = {"kontrol": {"n": kn, "x": kx}, "deney": {"n": dn, "x": dx}}
    if guard:
        s["guardrail"] = guard
    return s


class ZTesti(unittest.TestCase):
    def test_esit_oranlar_p_bir(self):
        _, z, p = a.iki_oranli_z(50, 100, 50, 100)
        self.assertAlmostEqual(z, 0.0)
        self.assertAlmostEqual(p, 1.0)

    def test_fark_isareti_ve_simetri(self):
        f1, z1, p1 = a.iki_oranli_z(40, 100, 60, 100)
        f2, z2, p2 = a.iki_oranli_z(60, 100, 40, 100)
        self.assertGreater(f1, 0)
        self.assertAlmostEqual(z1, -z2)
        self.assertAlmostEqual(p1, p2)

    def test_bilinen_deger(self):
        # 0.50 -> 0.60, kol başına 385 (%80 güç tasarımı): beklenen z = z_(alfa/2) + z_guc = 1.96 + 0.84 = 2.80
        _, z, p = a.iki_oranli_z(192, 385, 231, 385)
        self.assertAlmostEqual(z, 2.80, delta=0.05)
        self.assertLess(p, 0.01)

    def test_sifir_kol_reddedilir(self):
        with self.assertRaises(ValueError):
            a.iki_oranli_z(1, 0, 1, 10)


class Srm(unittest.TestCase):
    def test_dengeli_ornek_gecer(self):
        self.assertGreater(a.srm_p(500, 500), 0.5)

    def test_bozuk_ornek_yakalanir(self):
        self.assertLess(a.srm_p(600, 400), a.SRM_ESIK)


class AraBakis(unittest.TestCase):
    def test_bitis_oncesi_karar_verilmez(self):
        s = a.analiz(DENEY, sayilar(1000, 100, 1000, 200), BITIS - timedelta(days=1))
        self.assertEqual(s["durum"], "ara_izleme")
        self.assertIsNone(s["birincil"])


class Kapilar(unittest.TestCase):
    def test_srm_gecersiz_sonuc_raporlanmaz(self):
        s = a.analiz(DENEY, sayilar(600, 60, 400, 60), BITIS)
        self.assertEqual(s["durum"], "srm_gecersiz")
        self.assertIsNone(s["birincil"])

    def test_yetersiz_ornek(self):
        s = a.analiz(DENEY, sayilar(100, 10, 100, 20), BITIS)
        self.assertEqual(s["durum"], "yetersiz_ornek")

    def test_guardrail_ihlali_birincili_iptal_eder(self):
        guard = {"iade_orani": {"kontrol": {"n": 1000, "x": 20}, "deney": {"n": 1000, "x": 80}}}
        s = a.analiz(DENEY, sayilar(1000, 100, 1000, 200, guard), BITIS)
        self.assertEqual(s["durum"], "guardrail_ihlali")
        self.assertTrue(s["guardrail"][0]["kotu"])

    def test_temiz_karar_hazir(self):
        guard = {"iade_orani": {"kontrol": {"n": 1000, "x": 20}, "deney": {"n": 1000, "x": 21}}}
        s = a.analiz(DENEY, sayilar(1000, 100, 1000, 200, guard), BITIS)
        self.assertEqual(s["durum"], "karar_hazir")
        self.assertTrue(s["birincil"]["anlamli"])


class BonferroniVeGuvenAraligi(unittest.TestCase):
    def test_coklu_metrikte_alfa_bolunur(self):
        guard = {"a": {"kontrol": {"n": 1000, "x": 20}, "deney": {"n": 1000, "x": 20}},
                 "b": {"kontrol": {"n": 1000, "x": 20}, "deney": {"n": 1000, "x": 20}}}
        s = a.analiz(DENEY, sayilar(1000, 100, 1000, 100, guard), BITIS)
        self.assertEqual(len(s["guardrail"]), 2)

    def test_guven_araligi_fark_icerir(self):
        lo, hi = a.guven_araligi(100, 1000, 200, 1000)
        self.assertLess(lo, 0.10)
        self.assertGreater(hi, 0.10)


# ---------------------------------------------------------------------
# SAHTE VERİ: sıfır etkili deneylerde hata oranları (spec §9)
# ---------------------------------------------------------------------
def _binom(rng, n, p):
    return sum(1 for _ in range(n) if rng.random() < p)


class SahteVeriHataOrani(unittest.TestCase):
    """Gerçek etki yokken birincil testin yanlış pozitif oranı alfa'ya yakın kalmalı."""

    def test_sifir_etkide_yanlis_pozitif_alfa_civarinda(self):
        rng = random.Random(20261028)
        n = 800
        sims = 1500
        p = 0.20
        yanlis = 0
        for _ in range(sims):
            x1 = _binom(rng, n, p)
            x2 = _binom(rng, n, p)
            _, _, pv = a.iki_oranli_z(x1, n, x2, n)
            if pv < 0.05:
                yanlis += 1
        oran = yanlis / sims
        # Beklenen 0.05; 1500 simülasyonda 2 sigma ~ ±0.011
        self.assertGreater(oran, 0.03, f"yanlış pozitif oranı çok düşük: {oran:.3f}")
        self.assertLess(oran, 0.07, f"yanlış pozitif oranı çok yüksek: {oran:.3f}")

    def test_sifir_etkide_srm_yanlis_alarm_dusuk(self):
        rng = random.Random(7)
        sims = 1500
        alarm = 0
        for _ in range(sims):
            kn = _binom(rng, 2000, 0.5)
            dn = 2000 - kn
            if a.srm_p(2000 - dn, dn) < a.SRM_ESIK:
                alarm += 1
        # Beklenen SRM alarm oranı ~0.001; 1500 simülasyonda birkaçı olabilir, çok olmamalı
        self.assertLess(alarm / sims, 0.01, f"SRM yanlış alarmı fazla: {alarm}")

    def test_gercek_etkide_guc_yaklasik_seksen(self):
        rng = random.Random(42)
        n = 1100  # 0.20 -> 0.25 için yaklaşık %80 güç
        sims = 600
        anlamli = 0
        for _ in range(sims):
            x1 = _binom(rng, n, 0.20)
            x2 = _binom(rng, n, 0.25)
            _, _, pv = a.iki_oranli_z(x1, n, x2, n)
            if pv < 0.05:
                anlamli += 1
        guc = anlamli / sims
        self.assertGreater(guc, 0.72, f"güç düşük: {guc:.3f}")
        self.assertLess(guc, 0.90, f"güç beklenenden yüksek: {guc:.3f}")


if __name__ == "__main__":
    unittest.main()
