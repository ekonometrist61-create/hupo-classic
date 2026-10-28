"""A/B aday ve örneklem testleri.

Çalıştırma:  python -m unittest test_ab_aday -v
"""
import unittest

import ab_aday as ab


class OrnekBoyutu(unittest.TestCase):
    def test_bilinen_deger_p_0_5_ile_0_6(self):
        # Klasik sonuç: %50 -> %60, alfa 0.05, güç 0.8 => kol başına ~385
        self.assertEqual(ab.ornek_boyutu(0.5, 0.6), 385)

    def test_fark_kuculunce_ornek_buyur(self):
        self.assertGreater(ab.ornek_boyutu(0.10, 0.11), ab.ornek_boyutu(0.10, 0.15))

    def test_alfa_kuculunce_ornek_buyur(self):
        self.assertGreater(ab.ornek_boyutu(0.2, 0.3, alfa=0.01), ab.ornek_boyutu(0.2, 0.3, alfa=0.05))

    def test_gecersiz_girdiler_reddedilir(self):
        with self.assertRaises(ValueError):
            ab.ornek_boyutu(0.5, 0.5)
        with self.assertRaises(ValueError):
            ab.ornek_boyutu(0.0, 0.3)
        with self.assertRaises(ValueError):
            ab.ornek_boyutu(0.2, 0.3, alfa=1.5)


SENARYOLAR = [
    {"senaryo": "fiyat_9900", "beklenen_alt": 0.08, "beklenen_ust": 0.12},
    {"senaryo": "fiyat_14900", "beklenen_alt": 0.05, "beklenen_ust": 0.09},
    {"senaryo": "fiyat_19900", "beklenen_alt": 0.04, "beklenen_ust": 0.06},
]


class AdayListesi(unittest.TestCase):
    def test_bonferroni_alfa_aday_sayisina_bolunur(self):
        cikti = ab.aday_listesi(SENARYOLAR, referans_oran=0.10)
        self.assertAlmostEqual(cikti["adaylar"][0]["alfa_duzeltilmis"], 0.05 / 3, places=6)

    def test_duzeltilmis_alfa_ile_orneklem_daha_buyuk(self):
        duz = ab.aday_listesi(SENARYOLAR, referans_oran=0.07)
        tek = ab.aday_listesi(SENARYOLAR[:1], referans_oran=0.07)
        n_duz = next(a["kol_basi_ornek"] for a in duz["adaylar"] if a["senaryo"] == "fiyat_9900")
        n_tek = tek["adaylar"][0]["kol_basi_ornek"]
        self.assertGreater(n_duz, n_tek)

    def test_her_aday_hipotez_ve_uyari_tasir(self):
        cikti = ab.aday_listesi(SENARYOLAR, referans_oran=0.10)
        self.assertEqual(cikti["etiket"], "hipotez_aday")
        self.assertTrue(all(a["etiket"] == "hipotez_aday" for a in cikti["adaylar"]))
        self.assertIn("Gerçek A/B", cikti["uyari"])

    def test_referansa_esit_aday_atlanir(self):
        cikti = ab.aday_listesi([{"senaryo": "x", "beklenen_alt": 0.09, "beklenen_ust": 0.11}], referans_oran=0.10)
        self.assertEqual(cikti["aday_sayisi"], 0)

    def test_siralama_kucuk_orneklem_once(self):
        cikti = ab.aday_listesi(SENARYOLAR, referans_oran=0.10)
        ornekler = [a["kol_basi_ornek"] for a in cikti["adaylar"]]
        self.assertEqual(ornekler, sorted(ornekler))

    def test_bos_aday_ve_gecersiz_referans_reddedilir(self):
        with self.assertRaises(ValueError):
            ab.aday_listesi([], referans_oran=0.1)
        with self.assertRaises(ValueError):
            ab.aday_listesi(SENARYOLAR, referans_oran=1.0)


if __name__ == "__main__":
    unittest.main()
