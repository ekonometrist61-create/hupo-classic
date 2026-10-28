"""Customer-Lab L1 testleri (ağ yok, veritabanı yok).

Çalıştırma:  python -m unittest test_katalog -v
"""
import copy
import json
import unittest
from pathlib import Path

import katalog

ORNEK = json.loads((Path(__file__).parent.parent / "growth-ajan" / "ornek_veri.json").read_text(encoding="utf-8"))


class EsikKurali(unittest.TestCase):
    def test_esik_altindaki_hucre_persona_uretmez(self):
        veri = copy.deepcopy(ORNEK)
        veri["kohort"]["ozet"][0]["uygun_hane"] = 9  # D1 eşik altı
        kimlikler = [p["id"] for p in katalog.katalog_uret(veri)["personalar"]]
        self.assertNotIn("ilk_gun_geri_donen", kimlikler)

    def test_null_oran_persona_uretmez(self):
        veri = copy.deepcopy(ORNEK)
        veri["kohort"]["ozet"][1]["oran"] = None  # D7 gizli
        kimlikler = [p["id"] for p in katalog.katalog_uret(veri)["personalar"]]
        self.assertNotIn("hafta_ici_duzenli", kimlikler)

    def test_izin_gizli_deger_varsa_persona_yok(self):
        veri = copy.deepcopy(ORNEK)
        veri["veri_kalitesi"]["izin"][0]["kayit_yok"] = None
        kimlikler = [p["id"] for p in katalog.katalog_uret(veri)["personalar"]]
        self.assertNotIn("eposta_izinli", kimlikler)

    def test_esik_ustu_persona_uretilir(self):
        kimlikler = [p["id"] for p in katalog.katalog_uret(ORNEK)["personalar"]]
        self.assertIn("ilk_gun_geri_donen", kimlikler)
        self.assertIn("hafta_ici_duzenli", kimlikler)
        self.assertIn("eposta_izinli", kimlikler)


class HipotezEtiketi(unittest.TestCase):
    def test_cikti_hipotez_ve_uyari_tasir(self):
        sonuc = katalog.katalog_uret(ORNEK)
        self.assertEqual(sonuc["tur"], "hipotez_katalogu")
        self.assertIn("Gerçek kullanıcı ölçümü değildir", sonuc["uyari"])
        self.assertTrue(all("(hipotez)" in p["etiket"] for p in sonuc["personalar"]))

    def test_kanit_olarak_kullanim_uyarisi_var(self):
        self.assertIn("kanıt", katalog.UYARI)


class Gizlilik(unittest.TestCase):
    def test_cikti_kisi_alani_icermez(self):
        metin = json.dumps(katalog.katalog_uret(ORNEK), ensure_ascii=False)
        for yasak in ("email", "ogrenci_id", "household", "parent_name", "@", "anahtar-"):
            self.assertNotIn(yasak, metin)

    def test_n_degerleri_esik_ustunde(self):
        for p in katalog.katalog_uret(ORNEK)["personalar"]:
            self.assertGreaterEqual(p["n"], katalog.ESIK)


class Tekrarlanabilirlik(unittest.TestCase):
    def test_ayni_girdi_ayni_cikti(self):
        self.assertEqual(katalog.katalog_uret(ORNEK), katalog.katalog_uret(ORNEK))


if __name__ == "__main__":
    unittest.main()
