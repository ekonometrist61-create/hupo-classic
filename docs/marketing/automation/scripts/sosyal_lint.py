"""Hupolingo sosyal/pazarlama metni kural linter'ı (yalnız yerel, ağ yok).

Kurallar docs/marketing/17_RISK_COMPLIANCE.md ve AGENTS kırmızı çizgilerinden gelir.
Çıktı: (gecti: bool, bulgular: list[dict]). Hiçbir şey yayınlamaz/göndermez.
"""
import json
import re
import unicodedata
from pathlib import Path

# İzin verilen olumsuz/dürüst kalıplar: eşleşmeden önce metinden silinir.
IZINLI_KALIPLAR = [
    r"garanti vermiyoruz", r"garantisi vermiyoruz", r"garanti yok", r"garanti vermeyiz",
    r"otomatik yenileme yok", r"otomatik yenilenmez",
    r"resm[iî] (okul )?s[ıi]nav sorusu de[gğ]ildir", r"resm[iî] s[ıi]nav sorusu olarak sunulmaz",
    r"ücretsiz değil",  # nadir; yine de inceleme
]

# (kod, regex, açıklama, ciddiyet)
YASAK = [
    ("ucretsiz", r"\bücretsiz\b|\bbedava\b", "'ücretsiz/bedava' (akış kartsız self-serve çalışana kadar yasak)", "HATA"),
    ("garanti", r"\bgaranti", "garanti dili", "HATA"),
    ("yuzde_yuz", r"%\s*100\b|yüzde yüz", "'%100' mutlak ifade", "HATA"),
    ("yenileme", r"otomatik yenil", "'otomatik yenilenir' (K-0196)", "HATA"),
    ("kvkk_uyumlu", r"kvkk\s*uyumlu|kvkk\s*ile\s*uyumlu", "'KVKK uyumlu' doğrulanmamış iddia", "HATA"),
    ("resmi", r"\bresm[iî]\b|meb\s*onayl|meb\s*iş\s*birli|meb\s*ortağ", "resmî/MEB onay-ortaklık izlenimi", "HATA"),
    ("indir", r"\bindir\b|app store|google play|mağazadan", "mağaza 'indir' CTA'sı (mağaza yayını yok)", "HATA"),
    ("bilimsel", r"bilimsel olarak|bilim.*kan[ıi]tlad|araştırmalar gösteriyor|uzmanlar onaylad", "doğrulanmamış bilimsel iddia", "HATA"),
    ("numara1", r"\b1\s*numara|bir numara|en iyi|lider\b", "üstünlük iddiası", "HATA"),
    ("aciliyet", r"son\s+\d+\s+gün|sınırlı süre|sınırlı kontenjan|kaçırmay|stok|hemen al|sayaç", "sahte aciliyet/kıtlık", "HATA"),
    ("korku", r"geri kal(ıyor|mas)|geride kal|kaybet|yetişemey|sınav korkusu|kaygı", "korku/kayıp çerçevesi", "HATA"),
    ("kiyas", r"diğer çocuklar|akranlar[ıi]n[ıi]|sınıf birincisi", "veli/çocuk kıyası", "HATA"),
    ("ai_vaat", r"yapay zek|özel ders|özel öğretmen", "AI/özel ders vaadi (çocuk yüzeyinde LLM yok)", "UYARI"),
    ("sosyal_kanit", r"en çok tercih|binlerce|yüzlerce|seviyor|kullanıcı sayımız|yorum", "doğrulanmamış sosyal kanıt", "UYARI"),
    ("kazanim_kodu", r"\b[A-ZÇĞİÖŞÜ]{1,4}\.\d{1,2}\.\d{1,2}(\.\d{1,2})?\b", "MEB kazanım kodu (kaynak görülmeden yazılmaz)", "UYARI"),
    ("okul_adi", r"\b\w+\s+(anadolu lisesi|proje okulu|koleji)\b", "okul/kurum adı", "UYARI"),
    ("yaris_ai", r"hikâye yarışması|hikaye yarışması", "MEB hikâye yarışması ilişkisi", "HATA"),
]

SAYI = re.compile(r"(?<![0-9A-Za-zÇĞİÖŞÜçğıöşü])\d{1,3}(?:\.\d{3})+(?![0-9A-Za-zÇĞİÖŞÜçğıöşü])|(?<![0-9A-Za-zÇĞİÖŞÜçğıöşü])\d+(?:[.,]\d+)?(?![0-9A-Za-zÇĞİÖŞÜçğıöşü])")

def _deger(m):
    """"12.000" -> 12000 (Türkçe binlik ayracı); "3,5" -> 3.5."""
    if re.fullmatch(r"\d{1,3}(?:\.\d{3})+", m):
        return float(m.replace(".", ""))
    return float(m.replace(",", "."))



def _kucuk(s: str) -> str:
    # Türkçe I/İ doğru küçültme
    s = s.replace("İ", "i").replace("I", "ı")
    return unicodedata.normalize("NFC", s.lower())


def olgu_sayilari(olgular) -> set:
    """olgular.json içindeki tüm sayılar (string içindekiler dahil)."""
    bulunan = set()

    def gez(x):
        if isinstance(x, bool) or x is None:
            return
        if isinstance(x, (int, float)):
            bulunan.add(float(x))
        elif isinstance(x, str):
            for m in SAYI.findall(x):
                try:
                    bulunan.add(_deger(m))
                except ValueError:
                    pass
        elif isinstance(x, dict):
            for v in x.values():
                gez(v)
        elif isinstance(x, list):
            for v in x:
                gez(v)

    gez(olgular)
    return bulunan


def lint(metin: str, olgular=None, kanit=None):
    bulgular = []
    t = _kucuk(metin)
    for k in IZINLI_KALIPLAR:
        t = re.sub(k, " ", t)
    for kod, rx, aciklama, ciddiyet in YASAK:
        for m in re.finditer(rx, t, flags=re.IGNORECASE):
            bulgular.append({"kod": kod, "ciddiyet": ciddiyet, "metin": m.group(0), "aciklama": aciklama})
    # URL'leri sayı denetiminden çıkar
    t_sayi = re.sub(r"https?://\S+", " ", metin)
    if olgular is not None:
        izinli = olgu_sayilari(olgular)
        for m in SAYI.findall(t_sayi):
            try:
                v = _deger(m)
            except ValueError:
                continue
            if v not in izinli:
                bulgular.append({"kod": "uydurma_sayi", "ciddiyet": "HATA", "metin": m,
                                 "aciklama": "sayı olgular.json içinde yok (uydurma KPI/iddia)"})
    if kanit is not None and not str(kanit).strip():
        bulgular.append({"kod": "kanit_yok", "ciddiyet": "HATA", "metin": "", "aciklama": "kanit alanı boş"})
    gecti = not any(b["ciddiyet"] == "HATA" for b in bulgular)
    return gecti, bulgular


def utm_uret(taban: str, kaynak: str, kampanya: str, icerik: str) -> str:
    """Yalnız izinli UTM alanları; utm_term yok; değerler [A-Za-z0-9._~-]{1,100} (utm.ts kuralı)."""
    ok = re.compile(r"^[A-Za-z0-9._~-]{1,100}$")
    for ad, v in (("kaynak", kaynak), ("kampanya", kampanya), ("icerik", icerik)):
        if not ok.match(v):
            raise ValueError(f"geçersiz UTM değeri ({ad})")
    if kaynak not in ("instagram", "youtube", "linkedin", "email", "google", "meta"):
        raise ValueError("bilinmeyen utm_source")
    medium = {"instagram": "organic_social", "youtube": "organic_social", "linkedin": "organic_social",
              "email": "lifecycle", "google": "cpc", "meta": "paid_social"}[kaynak]
    ayrac = "&" if "?" in taban else "?"
    return f"{taban}{ayrac}utm_source={kaynak}&utm_medium={medium}&utm_campaign={kampanya}&utm_content={icerik}"


def olgular_yukle(yol):
    return json.loads(Path(yol).read_text(encoding="utf-8"))

