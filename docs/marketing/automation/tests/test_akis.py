import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
import pazarlama_akis as A  # noqa: E402
import sosyal_lint as L  # noqa: E402

OLGULAR = json.loads((ROOT / "examples" / "olgular.json").read_text(encoding="utf-8"))
IYI = ("Günlük hedef 5 ile 20 soru arasında ayarlanır, varsayılan 10. Sınav garantisi vermiyoruz. "
       "Örnek soruları hesap açmadan deneyin.")


def taslak(metin=IYI):
    return {"kod": "P01", "kanal": "instagram", "metin": metin, "kanit": "olgu:gunluk_hedef", "durum": "taslak"}


class LintTests(unittest.TestCase):
    def test_temiz_metin_gecer(self):
        ok, b = L.lint(IYI, olgular=OLGULAR, kanit="olgu:gunluk_hedef")
        self.assertTrue(ok, b)

    def test_yasak_ifadeler_reddedilir(self):
        for metin in ["Ücretsiz deneme başlat.", "%100 güvenli ödeme", "Sınav garantisi veriyoruz", "KVKK uyumlu",
                      "Uygulamayı indir", "Otomatik yenilenir", "Son 3 gün kaçırmayın", "Çocuğunuz geri kalıyor",
                      "MEB onaylı içerik", "bilimsel olarak kanıtlandı"]:
            ok, b = L.lint(metin, olgular=OLGULAR, kanit="x")
            self.assertFalse(ok, metin)

    def test_olumsuz_dogru_kalip_izinli(self):
        ok, b = L.lint("Sınav garantisi vermiyoruz. Otomatik yenileme yok. Resmî sınav sorusu değildir.",
                       olgular=OLGULAR, kanit="x")
        self.assertTrue(ok, b)

    def test_uydurma_sayi_reddedilir(self):
        ok, b = L.lint("12.000 veli bize güveniyor", olgular=OLGULAR, kanit="x")
        self.assertFalse(ok)
        self.assertIn("uydurma_sayi", [x["kod"] for x in b])

    def test_kanit_bos_reddedilir(self):
        ok, _ = L.lint(IYI, olgular=OLGULAR, kanit="")
        self.assertFalse(ok)

    def test_utm(self):
        u = L.utm_uret("https://hupolingo.com/demo", "instagram", "sm-2026-12-h1", "p01")
        self.assertIn("utm_medium=organic_social", u)
        self.assertNotIn("utm_term", u)
        with self.assertRaises(ValueError):
            L.utm_uret("https://hupolingo.com/demo", "instagram", "ali veli@mail.com", "p01")
        with self.assertRaises(ValueError):
            L.utm_uret("https://hupolingo.com/demo", "tiktok", "k", "p01")


class AkisTests(unittest.TestCase):
    def test_tam_akis(self):
        g = taslak()
        g = A.gec(g, "marka-denetimi", olgular=OLGULAR)
        g = A.gec(g, "insan-onayi", olgular=OLGULAR, onaylayan="Proje Sahibi")
        g["planlanan_tarih"] = "Y+14"
        g = A.gec(g, "planlandi", olgular=OLGULAR)
        g = A.gec(g, "yayinlandi", kanit_url="https://www.instagram.com/p/ornek/")
        self.assertEqual(g["durum"], "yayinlandi")

    def test_atlama_imkansiz(self):
        with self.assertRaises(A.AkisHatasi):
            A.gec(taslak(), "yayinlandi", kanit_url="https://x")
        with self.assertRaises(A.AkisHatasi):
            A.gec(taslak(), "planlandi")

    def test_ajan_onaylayamaz(self):
        g = A.gec(taslak(), "marka-denetimi", olgular=OLGULAR)
        for ad in (None, "", "ajan", "MAR-OTO-AI", "bot"):
            with self.assertRaises(A.AkisHatasi):
                A.gec(g, "insan-onayi", olgular=OLGULAR, onaylayan=ad)

    def test_lint_basarisiz_ilerlemez(self):
        with self.assertRaises(A.AkisHatasi):
            A.gec(taslak("Ücretsiz deneme için tıklayın"), "marka-denetimi", olgular=OLGULAR)

    def test_onay_sonrasi_metin_degisirse_gecersiz(self):
        g = A.gec(taslak(), "marka-denetimi", olgular=OLGULAR)
        g = A.gec(g, "insan-onayi", olgular=OLGULAR, onaylayan="Proje Sahibi")
        g["metin"] = g["metin"] + " Yeni cümle."
        g["planlanan_tarih"] = "Y+14"
        with self.assertRaises(A.AkisHatasi):
            A.gec(g, "planlandi", olgular=OLGULAR)

    def test_yayin_kaniti_zorunlu(self):
        g = A.gec(taslak(), "marka-denetimi", olgular=OLGULAR)
        g = A.gec(g, "insan-onayi", olgular=OLGULAR, onaylayan="Proje Sahibi")
        g["planlanan_tarih"] = "Y+14"
        g = A.gec(g, "planlandi", olgular=OLGULAR)
        with self.assertRaises(A.AkisHatasi):
            A.gec(g, "yayinlandi")

    def test_ag_kodu_yok(self):
        kaynak = (ROOT / "scripts" / "pazarlama_akis.py").read_text(encoding="utf-8") + \
                 (ROOT / "scripts" / "sosyal_lint.py").read_text(encoding="utf-8")
        for yasak in ("import requests", "urllib.request", "import socket", "http.client", "smtplib"):
            self.assertNotIn(yasak, kaynak)

    def test_dry_run_varsayilan(self):
        import os
        os.environ.pop("DRY_RUN", None)
        self.assertTrue(A.dry_run())


if __name__ == "__main__":
    unittest.main(verbosity=2)
