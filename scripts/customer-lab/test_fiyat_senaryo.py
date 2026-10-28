"""Fiyat senaryo koşucusu testleri (ağ ve veritabanı yok).

Çalıştırma:  python -m unittest test_fiyat_senaryo -v
"""
import unittest

import fiyat_senaryo as fs

PERSONA = {"id": "ilk_gun_geri_donen", "parametreler": {"d1_oran_yuzde": 70.0}}
FIYATLAR = [9900, 14900, 19900]


class Monotonluk(unittest.TestCase):
    def test_fiyat_artinca_beklenen_donusum_duser(self):
        s = fs.senaryo_uret(PERSONA, FIYATLAR)["sonuclar"]
        ortalama = [(x["beklenen_alt"] + x["beklenen_ust"]) / 2 for x in s]
        self.assertTrue(all(a > b for a, b in zip(ortalama, ortalama[1:])), ortalama)


class AralikKurallari(unittest.TestCase):
    def test_alt_ust_sirali_ve_0_1_arasinda(self):
        for x in fs.senaryo_uret(PERSONA, FIYATLAR)["sonuclar"]:
            self.assertLessEqual(x["beklenen_alt"], x["beklenen_ust"])
            self.assertGreaterEqual(x["beklenen_alt"], 0.0)
            self.assertLessEqual(x["beklenen_ust"], 1.0)

    def test_veritabani_kisitlarina_uyar(self):
        # sentetik_sonuc: beklenen_alt <= beklenen_ust, 0..1, etiket = 'hipotez'
        for x in fs.senaryo_uret(PERSONA, FIYATLAR)["sonuclar"]:
            self.assertEqual(x["etiket"], "hipotez")


class VarsayimSeffafligi(unittest.TestCase):
    def test_tum_varsayimlar_ciktida(self):
        cikti = fs.senaryo_uret(PERSONA, FIYATLAR)
        for anahtar in fs.VARSAYILAN:
            self.assertIn(anahtar, cikti["varsayimlar"])

    def test_hipotez_etiketi_ve_uyari(self):
        cikti = fs.senaryo_uret(PERSONA, FIYATLAR)
        self.assertEqual(cikti["etiket"], "hipotez")
        self.assertIn("A/B", cikti["uyari"])

    def test_varsayim_degistirilince_cikti_degisir_ve_kaydolur(self):
        a = fs.senaryo_uret(PERSONA, FIYATLAR)
        b = fs.senaryo_uret(PERSONA, FIYATLAR, varsayim={"baz_donusum_carpani": 0.4})
        self.assertNotEqual(a["sonuclar"], b["sonuclar"])
        self.assertEqual(b["varsayimlar"]["baz_donusum_carpani"], 0.4)


class Reddetme(unittest.TestCase):
    def test_gizli_d1_senaryo_uretmez(self):
        with self.assertRaises(ValueError):
            fs.senaryo_uret({"id": "x", "parametreler": {"d1_oran_yuzde": None}}, FIYATLAR)

    def test_pozitif_esneklik_reddedilir(self):
        with self.assertRaises(ValueError):
            fs.senaryo_uret(PERSONA, FIYATLAR, varsayim={"fiyat_esnekligi": 0.3})

    def test_bos_fiyat_listesi_reddedilir(self):
        with self.assertRaises(ValueError):
            fs.senaryo_uret(PERSONA, [])

    def test_band_araligi_disi_reddedilir(self):
        with self.assertRaises(ValueError):
            fs.senaryo_uret(PERSONA, FIYATLAR, varsayim={"belirsizlik_bandi": 1.5})

    def test_negatif_fiyat_reddedilir(self):
        with self.assertRaises(ValueError):
            fs.senaryo_uret(PERSONA, [-100])


class Tekrarlanabilirlik(unittest.TestCase):
    def test_ayni_girdi_ayni_cikti(self):
        self.assertEqual(fs.senaryo_uret(PERSONA, FIYATLAR, tohum=7), fs.senaryo_uret(PERSONA, FIYATLAR, tohum=7))

    def test_tohum_kaydedilir(self):
        self.assertEqual(fs.senaryo_uret(PERSONA, FIYATLAR, tohum=7)["tohum"], 7)


class Gizlilik(unittest.TestCase):
    def test_cikti_kisi_alani_icermez(self):
        metin = str(fs.senaryo_uret(PERSONA, FIYATLAR))
        for yasak in ("email", "ogrenci_id", "household", "@"):
            self.assertNotIn(yasak, metin)


if __name__ == "__main__":
    unittest.main()
