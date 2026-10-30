# Lead magnet ve kanıt-içerik fikirleri (2026-10-30)

Durum: FİKİR + ÖNCELİKLENDİRME. Kod, yayın, gönderim yok. Hepsi `ONAY BEKLİYOR`. Hedef: veli. Pilot sınıflar 3–7.
Güven etiketi: **K** = Kanıtlı (repo/paket), **V** = Varsayım, **H** = Hipotez (test edilecek).
Kaynaklar: `HUPOLINGO_Bilimsel_Kanitlar_Web_Pazarlama_2026.md` (kanıt paketi, "Kanıt"), `GROWTH_AND_MEASUREMENT`, `OLAY_TAKSONOMISI`, `ILETISIM_EKSIKLERI_PLANI_2026-10-27`, `ZIYARETCI_WIDGET_TASARIM`, `docs/marketing/19_DECISION_REGISTER`.

---

## 1. Mevcut durum (tekrar önerilmez, üstüne kurulur)

| Var olan | Not (K) |
|---|---|
| `/demo` 5 soruluk etkileşimli demo | Hesapsız, kayıt yok. Sorular "4. sınıf kazanımlarına göre" (4. sınıf = önceki program; etiket gözden geçirilmeli). Olay: `demo_tamamlandi` |
| Deneme sınavı ön kayıt (`/deneme-sinavi-kayit`, `DenemeKayitForm`) | Turnstile, sürümlü izin (`deneme-kayit-izin-2026-10-v1`), 3 ayrı kutu (e-posta/SMS/telefon). **Veli adı, çocuk adı, telefon zorunlu; sınıf listesi 3–8** (pilot 3–7 dışı 8 var). Olay: `deneme_on_kayit` |
| `/ticari-ileti-izni` | Sayfa var; şirket unvanı/e-posta/tarih yer tutucu, hukuk onayı yok |
| Erken erişim formu, `veli_adaylari` | Olaylar: `erken_erisim_gonderildi`, `veli_adayi_kaydi` |
| Ziyaretçi widget tasarımı | Tek soru, anonim, kimlik yok (tasarım; kodlanmış mı doğrulanmadı) |
| Growth CRM şeması | Çalıştıran katman eksik: `eposta-gonder` zamanlayıcısız, journey motoru yok, frekans/sessiz saat yok (E1–E4, P1–P4). **Dizi gönderimi için önkoşul** |
| Kilitli kararlar | K-5: "ücretsiz deneme" dili akış kartsız çalışana + hukuk onayına dek yok. K-6: iade/%100/iptal rozeti yok. K-0196: tek seferlik ödeme, otomatik yenileme yok. SMS/WhatsApp pazarlama: İYS + hukuk bekliyor (GÖR-018/019) |

---

## 2. Lead magnet kataloğu

Ortak kapı (öneri, V): **yalnız veli e-postası + sınıf (3–7) + ayrı pazarlama izni kutusu (işaretsiz)**. Çocuk adı, telefon, okul istenmez. İçeriği teslim etmek hizmet e-postası; devam serisi yalnız izinle (hukuk onayı bekler).
Maliyet: D/O/Y = düşük/orta/yüksek. Etki: ICE tabanlı kaba 1–5 (H).

| # | Ad | Kitle | Format | Neden kayıt bırakır | Sonraki huni adımı | Maliyet | Risk / uyum |
|---|---|---|---|---|---|---|---|
| 1 | **Çarpım Tablosu Pif Noktaları** | 3. sınıf (4'te tekrar) | Web sayfası + yazdırılabilir PDF (e-posta ile erişim) | Hemen kullanılır: kural/örüntü (5'ler, 9'lar, 10-11, eşlik/değişme ile 100 çarpımı ~yarıya indirme, "zor 8 çarpım") + 5 günlük tekrar planı | 5 günlük mini kurs (#2) → `/demo` → veli hesabı | D | "X günde ezberler" yok. Soruları özgün üret, yayınevi çoğaltma yok. Etki iddiası: "araştırmalar aktif hatırlama ve aralıklı tekrarın öğrenmeyi destekleyebildiğini gösteriyor" (Ruitenburg 2026) |
| 2 | **5 günlük "günlük tek soru" e-posta kursu** (#1'in devamı; her sınıf için ayrı) | 3–7 | E-posta kursu | Veli her gün 1 soru + 1 ipucu + çocukla 3 dk | Gün 5'te örnek veli raporu + hesap | D–O | Yalnız izinli kanal; `eposta-gonder` hazır olmadan gönderilmez |
| 3 | **Ayın Denemesi** (ay ay, sınıf bazlı) | 3–7 (4 "önceki program" etiketli; 8 pilot dışı) | Mini-test 10–15 soru/20 dk, sonuç e-postayla | Çocuğun o ayki konularda nerede olduğu; konu bazlı "bu hafta tekrar et" listesi | Sonuç e-postası → veli raporu örneği → hesap | **Y** (soru üretimi + denetim), altyapı var | Puan yüzde (0–100), sıralama/yüzdelik dilim **yok** (n yetersiz). Yayın kapısı: 2 bağımsız denetçi + insan onayı, `published=false`. MEB/yayınevi sorusu çoğaltma yok, MEB ilişkisi ima edilmez. Blueprint: `hupo-deneme-uzmani` |
| 4 | **Seviye keşfi mini-testi (8 soru)** | 3–7 | Etkileşimli, hesapsız, sonuç e-posta ile | "Bu hafta nereden başlayalım?" | Konu önerisi + plan (#5) | O | Tanı değil, **keşif**: "öğrenme stili/yetenek" etiketi yok (paket §7, H-089/H-092). Az soru = "kesin yeterlilik" yok |
| 5 | **Haftalık ev çalışma planı üreticisi** | 3–7 | Etkileşimli araç: sınıf + haftada kaç gün + günlük dakika + ders → 4 haftalık plan, PDF/takvim (.ics) | Hazır, kişiselleşmiş plan; veli karar yükü azalır | Plan e-postası → haftalık görev kartı (#7) | O | Çocuk bilgisi girilmez. "Plan = başarı" vaadi yok. Gerçek konular kazanım kaynağı doğrulanmadan kod yazılmaz (`source_pending`) |
| 6 | **Ara tatil / yarıyıl / yaz tatili plan paketi** | 3–7, sınıf bazlı | PDF + günlük kart | Tatilde ekran + tekrar dengesi, kısa günlük görev | Tatil öncesi e-posta → hesap | O | Tatil tarihleri MEB takviminden **doğrulanmadan** yazılmaz (V). Mevsimsel; yılda 4 pencere |
| 7 | **"Bu hafta 10 dakikalık görev kartı"** (haftalık abonelik) | 3–7 | E-posta bülteni: 3 kart + 1 soru + 1 veli ipucu | Sürekli değer; rutin kurar | Kart → hesap → ilk soru | O (şablon bir kez, içerik haftalık) | Sıklık ≤1/hafta, tek tık çıkış. Çocuğa gitmez. "Seri bozulursa kayıp" dili yok |
| 8 | **4→5 geçişi ve okul kabulü takvimi** | 4–5. sınıf velisi | Etkileşimli takvim + PDF kontrol listesi | Tarih/başvuru karmaşası; "ne zaman ne yapılır" | Ankara proje ortaokulu hazırlık içerikleri → Ayın Denemesi | O | Sınav tarih/formatı **resmî kaynakla doğrulanır; bulunamazsa "bilinmiyor"**. Okul adı = iş birliği ima etmez. Kabul/puan garantisi yok |
| 9 | **LGS'ye 1 yıl kala yol haritası** | 7. sınıf velisi | PDF + takvim | Yıl planı + konu sırası | Deneme + plan | O | 8. sınıf program kapsamı pilot dışı; yalnız veli rehberi, soru içermez. Garanti yok |
| 10 | **"Çocuğum çalışmaya başlamıyor" 7 küçük başlangıç** | 3–7 velisi | PDF rehber (6 sayfa) | En sık veli sıkıntısı; somut cümleler | Haftalık kart (#7) | D | Tanı/terapi dili yok; ruh sağlığı iddiası yok, gerekirse "uzmana başvurun". Fogg tarzı teknikler içeride kalır, metinde bilim terimi yok |
| 11 | **Yanlış defteri şablonu** | 4–7 | Yazdırılabilir PDF + 3 dk kullanım videosu (sonra) | Aktif hatırlama için hazır araç | Hesapta "yanlışlarım listesi" demo ekranı | D | Etki: "destekleyebilir" (Ruitenburg). Ürün ekran görüntüsü gerçek olmalı |
| 12 | **Paragraf sorusu 5 adım yöntemi + 5 mini paragraf** | 5–7 Türkçe | PDF + mini-test | Türkçe/okuma sorunu için yöntem | Okuma demosu (`/okuma-demo`) → hesap | O | Metinler özgün üretilir; **2026 MEB hikâye yarışması içeriği AI ile üretilmez**; `meb-soru-sozcuk-uzmani` kapısı |
| 13 | **Sözcük/deyim mini kartları (haftalık 5)** | 3–7 | Kart PDF + e-posta | Pratik, paylaşılabilir | Haftalık kart (#7) | O | Sözlük onayı gerekli, kaynak yazılır |
| 14 | **Tekrar takvimi oluşturucu** (sınav tarihi gir → tekrar günleri) | 4–7 | Etkileşimli araç, .ics | Sınav öncesi "ne zaman tekrar" | Plan e-postası → deneme | D–O | "Unutma eğrisi" görseli kavramsal çizimdir, ölçüm değil. Mawson & Kang 2025: sınırlar belirtilir |
| 15 | **Örnek veli raporu + "raporu nasıl okurum"** | Karar aşamasındaki veli | İndirilebilir PDF / etkileşimli sayfa ("örnek veri" etiketli) | Ürünü görmeden satın almama itirazını giderir | Hesap, `/demo` | D (ekran var) | Mutlaka "Bu ekran örnek verilerle hazırlanmıştır". Gerçek çocuk/ad yok. Müşteri sonucu gibi sunulmaz |
| 16 | **Aile çalışma sözleşmesi (ekran/çalışma dengesi)** | 4–7 | Doldurulabilir PDF | Aile içi tartışmayı yapılandırır | Haftalık kart | D | Sağlık/ekran bağımlılığı iddiası yok; "tavsiye" yerine örnek taslak |
| 17 | **Kesirleri görselle anlama (5. sınıf) / Çarpma-bölme görsel sözlüğü** | 5 / 3–4 | PDF + 1 etkileşimli görsel | Konuya özel sık takılma | Konu bazlı deneme | O–Y | SVG motoru (`tools/gorsel-motoru`) gerekebilir; görsel sorular kapısı onaylı değil |
| 18 | **Evde 10 dakikalık fen deney kartları** | 3–6 | PDF kartlar | Evde yapılabilir, paylaşılır | Haftalık kart | O | Güvenlik (yetişkin gözetimi); MEB kazanım eşlemesi doğrulanmadan kod yok |

Yeni trafik kanalı olarak fikir değil, **giriş kapısı**: #1, #4, #5, #8 SEO'ya uygun (veli sorusu odaklı, çocuk verisi/soru içeriği public index'e girmez). Not: `robots.txt Disallow:/` ve sitemap/OG/canonical yoksa (PROJE_GUNLUGU bulgusu) organik trafik çalışmaz; güncel durum doğrulanmadı.

---

## 3. Öncelik matrisi ve pilot

Puan: Etki (1–5, H) | Maliyet (1 düşük–5 yüksek) | Uyum riski (1 düşük–5 yüksek) | Skor = Etki − (Maliyet + Risk)/2, kaba sıralama.

| # | Etki | Maliyet | Risk | Skor | Karar |
|---|---|---|---|---|---|
| 1 Çarpım pif noktaları | 4 | 1 | 1 | 3.0 | **Pilot 1** |
| 7 Haftalık görev kartı | 4 | 2 | 2 | 2.0 | **Pilot 3** |
| 3 Ayın Denemesi | 5 | 4 | 3 | 1.5 | **Pilot 2** (tek sınıf, tek ay) |
| 5 Ev çalışma planı | 4 | 3 | 1 | 2.0 | Pilot sonrası ilk aday |
| 15 Örnek veli raporu | 3 | 1 | 1 | 2.0 | Hemen (B bölümü ile ortak) |
| 6 Tatil planı | 3 | 2 | 2 | 1.0 | Tarih doğrulanınca |
| 4 Seviye keşfi | 4 | 3 | 3 | 1.0 | Soru kapısı sonrası |
| 8 / 9 Kabul/LGS | 3 | 2 | 3 | 0.5 | Kaynak doğrulama sonrası |
| Kalanlar | 2–3 | 2–4 | 1–3 | ≤1.0 | Havuz |

**İlk 3 pilot:** (1) Çarpım pif noktaları + 5 günlük kurs, (2) Ayın Denemesi (ilk ay: tek sınıf, önerim 3. sınıf matematik karma; mevcut ön kayıt altyapısı üstüne), (3) Haftalık 10 dakikalık görev kartı (1 ve 2'yi taşıyan bülten).
Ortak ölçüt: yeterli örneklem olmadan A/B yok; ilk 4 hafta yalnız **taban oranları ölç**.

**4 haftalık uygulama sırası (hiçbir adımda gönderim yok)**

| Hafta | İş | Sahip |
|---|---|---|
| 1 | #1 içerik + PDF taslağı, soru seti (özgün), 5 günlük kurs metni; hafif form tasarımı; olay planı (§4) | MAR-OTO-AI (bu doküman sahibi) |
| 2 | Hafif lead formu + sayfa (kod), double opt-in, `izin_surum` kaydı; E1–E4 (gönderim motoru) durumu; Ayın Denemesi blueprint | Ana oturum (kod), `hupo-deneme-uzmani` |
| 3 | İç test (kendi adresimize), hukuk/şirket bilgisi kapısı, iki denetçi + insan onayı: Ayın Denemesi soruları | Kullanıcı + hukuk |
| 4 | Onay varsa yumuşak yayın (yalnız form + teslim sayfası); taban ölçümü; yoksa bekle | Kullanıcı onayı |

---

## 4. Huni tasarımı (Hupo uyarlaması)

"Ücretsiz deneme" aşaması yerine **"İlk çalışma"** (aktivasyon): deneme dili kilitli (K-5). Ödeme tek seferlik (K-0196).

| Aşama | Tanım | Olay (mevcut / önerilen) | Okunacak yer | Oran |
|---|---|---|---|---|
| Ziyaret | Magnet sayfası benzersiz ziyaret | `$pageview` (çerez onaylı; eksik sayar) | PostHog + sunucu sayacı | BOŞ |
| Lead magnet | Form gönderimi (e-posta doğrulandı) | *Önerilen:* `lead_magnet_istendi`, `lead_magnet_dogrulandi` (parametre: `icerik`, `sinif`, `utm_*`) | DB (`veli_adaylari` + kaynak alanı), PostHog yardımcı | BOŞ |
| Hesap | Veli hesabı | `hesap_olusturuldu`, `ogrenci_baglandi` | DB | BOŞ |
| İlk çalışma | İlk soru çözüldü | `ilk_soru_cozuldu` (W2'de planlı, repoda yok) | DB | BOŞ |
| Ödedi | Başarılı ödeme | `odeme_basarili` | DB (`payments`) | BOŞ |
| Veli sorusu | Destek talebi / görüşme (isteğe bağlı) | *Önerilen:* `destek_talebi_acildi` | Destek tablosu | BOŞ |

Kurallar: Oranlar kaynaksız yazılmaz; ilk 4 haftada ölçülür. Atıf yaklaşık (UTM: kaynak/kanal/içerik). PostHog yalnız web, çerez onaylı, çocuk ve mobil dışı; ad/e-posta/serbest cevap analytics'e taşınmaz. Yeni olay adları `snake_case`, ASCII, Türkçe, geçmiş zaman; `OLAY_TAKSONOMISI.md` eklemesi ana oturumda. Her aşamada koruma metriği: e-posta çıkış (unsub) oranı ve şikâyet.

### Seri iskeleti (7 adım; her adım bir soruyla biter; e-posta birincil)
WhatsApp/SMS yalnız ayrı izin kutusu + İYS/hukuk onayı sonrası; o zamana dek hiç yok.

| Zaman | Mesaj | Bitiş sorusu (tek tık) |
|---|---|---|
| 0. dk | Doğrulama bağlantısı (hizmet) | "Çocuğunuz kaçıncı sınıfta?" (yalnız sınıf alınmadıysa) |
| 1. dk | Teslim: PDF/sayfa bağlantısı | "Bu rehberden hangisi daha çok işinize yarar? A / B" |
| Gün 1 | İlk pif noktası + 3 dakikalık çalışma | "Bugün 10 dakika ayırabildiniz mi? Evet / Hayır" |
| Gün 3 | "Nerede takıldınız?" 3 seçenek (yanıtla → ekibe ulaşır) | "Hangi adımda zorlandınız?" |
| Gün 5 | Kurs tamamlandı, örnek veli raporu ("örnek veri") | "Raporda en çok neyi görmek istersiniz?" |
| Gün 6 | `/demo` veya Ayın Denemesi daveti (sahte aciliyet yok) | "Hangi konuyu önce denemek istersiniz?" |
| Gün 7 | Veli hesabı + plan kaydındaki gerçek fiyat/kapsam; ön bilgilendirme bağlantısı | "Karar vermeniz için eksik olan nedir?" |

Çıkış: abonelikten çıkış, hesap açma (seri sonlanır, onboarding başlar), ödeme. Sıklık sınırı ≤2/hafta, sessiz saat 21:00–09:00 (V). "Canlı oturum daveti" yok (kaynağımız yok).

### İzin akışı
1. Form: e-posta, sınıf. İsteğe bağlı kutu: "Hupolingo'dan eğitim içerikleri ve duyurular e-posta ile gelsin" (işaretsiz, sürümlü metin, `izin_surum`, zaman).
2. Çift doğrulama bağlantısı; doğrulama anında teslim.
3. Aydınlatma + `/ticari-ileti-izni` bağlantısı; SMS ve telefon kutuları bu magnetlerde **yok**.
4. Her e-postada tek tık çıkış; iptal fonksiyonu mevcut (K).
5. **Blokaj:** şirket unvanı/MERSİS/adres/e-posta ve hukuk onayı eksik (GÖR-078); onaysız yayın yok.

---

## 5. İkna ve kanıt içerik kataloğu (B)

Kaynak numaraları kanıt paketi §2'dedir. Genel çerçeve: "Araştırmalar … destekleyebiliyor; Hupolingo bu yaklaşımları bir araya getiriyor." Hupolingo'ya ait etki sonucu **yoktur**.

| # | İçerik | Kaynak (DOI) | Güvenli ifade | Yasaklı ifade |
|---|---|---|---|---|
| 1 | **"Oyunlaştırma nasıl çalışır" etkileşimli demo** (küçük görev, geri bildirim, ilerleme; hangi öğe neyi destekler) | Zeng 2024: 10.1111/bjet.13471; Kurnaz & Koçtürk 2025: 10.1002/pits.70056; Yao 2026: 10.1002/berj.70144 | "İyi tasarlanmış oyunlaştırma motivasyonu destekleyebiliyor; etki yaşa, derse ve tasarıma göre değişiyor." | "%78 başarı artışı" (g=0,782 yüzde değildir); "tüm çocuklarda garanti" |
| 2 | **Aktif hatırlama 3 soruluk mini deney** (oku vs. kendini sına) | Ruitenburg 2026: 10.1007/s10648-026-10225-5 | "Okul sınıflarında yapılan 53 çalışma, aktif geri çağırmanın öğrenmeyi destekleyebildiğini gösteriyor." Sayfada: "Bu mini deney sizin sonucunuzu kanıtlamaz, yalnızca yöntemi gösterir." | "Bilimsel olarak kanıtlandı"; kullanıcı sonucunu kanıt gibi sunmak |
| 3 | **Unutma eğrisi / tekrar aralığı görselleştirmesi** (kavramsal çizim) | Mawson & Kang 2025: 10.3390/bs15060771; Ruitenburg 2026 | "Aralıklı çalışma öğrenmeyi destekleyebiliyor; uygulama biçimi önemli." Etiket: "Kavramsal çizim, ölçüm değildir." | Çizimdeki sayıları Hupolingo verisi gibi sunmak; etki büyüklüklerini toplamak |
| 4 | **Açıklamalı çözüm vitrini** (bir sorunun adım adım çözümü, yanlış cevap açıklaması) | Kendi içeriğimiz (K1). Geri bildirim etkisi paketin 12 kaynağında doğrudan yok → **kanıt boşluğu** | "Her cevabın ardından neden doğru/yanlış olduğunu görür." | "Açıklama başarıyı artırır" gibi etki iddiası |
| 5 | **Örnek veli raporu** ("örnek veri" etiketli, gerçek ekran) | Kendi ürünümüz | "Bu ekran örnek verilerle hazırlanmıştır." Doğru oran + tekrar önerisi + "bugün nasıl destek olabilirim" | Gerçek çocuk/yorum gibi gösterim; kesin yeterlilik sonucu |
| 6 | **Şeffaflık sayfası: "Bilmediklerimiz"** | Romero-Rodríguez 2024: 10.1016/j.ijer.2024.102481; Aulagnon 2025: 10.1016/j.econedurev.2025.102721 | "İlkokulda oyunlaştırmanın öğrenme sonuçlarına dair sağlam kanıt sınırlı; kendi etkimizi pilotla ölçeceğiz." | Karşıt kanıtı saklamak |
| 7 | **Pilot sonuç yayın sözü** (protokol: önceden yazılmış hipotez, yeni sorularla ölçüm, 2–4 hafta gecikmeli kalıcılık, olumsuz sonuç da yayınlanır) | Paket §6 (pilot tasarım) | "Sonuçlar ne çıkarsa çıksın yayınlayacağız." Yalnız yönetim kararıyla (V) | "Bağımsız çalışmayla doğrulandı" (henüz yok); sonuç vaadi |
| 8 | **Yöntem ve denetim süreci sayfası** (soru üretimi → iki bağımsız denetim → insan onayı → yayın) | Repo kuralı (`published=false` varsayılan, 2 denetçi + insan). Gerçekten uygulanıyorsa | "Her soru yayınlanmadan önce iki ayrı denetimden ve insan onayından geçer." | Uzman/öğretmen adı, sertifika, "MEB onaylı/iş birliği", "kalite garantisi" |
| 9 | **"Hatırlatma var, suçluluk yok"** (seri ve bildirim yaklaşımımız) | Aulagnon 2025 (kullanım artışı; teste katılım %2,3 → seçilim yanlılığı riski) | "Nazik hatırlatmalar platform kullanımını artırabiliyor; biz kayıp korkusu kullanmıyoruz." | "Seri bozulursa kaybedersin" tarzı; sınıf kıyası |
| 10 | **"Ekran süresi değil öğrenme emeği"** (XP/süre ≠ öğrenme; veli raporunda ne görünür) | Yao 2026 (duyuşsal etki anlamlı değil); ürün ilkesi | "Süre değil, çözülen soru ve tekrar gereken konu raporlanır." | "Daha çok süre = daha çok öğrenme" |
| 11 | **Bir oturumun anatomisi** (10 soru → açıklama → yarın tekrar → veli raporu) | Ruitenburg 2026; ürün akışı | "Küçük, tamamlanabilir oturum." **Doğrulama:** "oturum ≤10 soru" ve "yanlışlar ertesi gün tekrar listesinde" ürün gerçeğiyle eşleşmeli | Üründe olmayan davranışı gösterme |
| 12 | **Araştırma kütüphanesi** (12 kaynak; her kartta: ne ölçtü, ne ölçmedi, Hupolingo'ya anlamı) | Paket §2 tüm DOI | Kartta yıl, tür, sade sonuç, DOI, "Bu bulgu Hupolingo'ya ait değildir" | "10.000 öğrenciyle Hupolingo" kalıbı; 12 çalışmanın katılımcılarını toplamak (örtüşme) |
| 13 | **Matematikte oyunlaştırma: ne işe yarar, ne yaramaz** (blog) | Yao 2026; Ratinho 2026: 10.1007/s10648-025-10108-1; Mohammed 2024: 10.1177/10468781241237389 (küçük örneklem); Pan 2026: 10.1007/s10639-025-13866-1 (kontrolsüz) | "Bilişsel sonuçlarda fayda görülürken duyuşsal etkiler tutarsız." | Küçük örneklemli çalışmayı genel sonuç gibi anlatmak |
| 14 | **Hikâye/okuma katılımı** (HupoRead yarışma hipotezi) | Palikot 2026: 10.1007/s11129-026-09311-3 | "Başka bir uygulamadaki deneyde yarışma sırasında tamamlanan hikâye sayısı %45 daha fazlaydı; ölçülen öğrenme değil katılımdı." | "10.000 çocuk Hupolingo ile %45 daha çok öğrendi" |

Kapsam: #1, #2, #3, #11 hesapsız etkileşimli; #5, #6, #8, #12 statik sayfa. Hepsi lead magnet olarak da kullanılabilir (gate'siz önerilir; güven içeriği kapının arkasına konmaz).

---

## 6. Çelişki ve risk listesi

| # | Konu | Durum / öneri |
|---|---|---|
| 1 | **Fiyat/deneme/iade**: Kanıt paketi §4 "399 TL / 90 gün", "14 gün ücretsiz deneme", "14 gün iade garantisi", "ücretli plan hazırlık aşamasında" ifadelerinin sitede çeliştiğini söylüyor. Repo: K-5 (ücretsiz deneme dili kilitli), K-6 (iade/iptal rozeti yok), K-0196 (tek seferlik, otomatik yenileme yok). | Tek onaylı plan kaydı gelene dek hiçbir magnet CTA'sında fiyat/deneme/iade yok |
| 2 | Paketteki CTA "Hupo'yu ücretsiz deneyin" | K-5 ile çelişir. "5 soruyu dene" veya "Veli hesabı oluştur" kullan; veli hesabının ücretsiz olup olmadığı doğrulanmadan "ücretsiz" yok |
| 3 | Paket briefi madde (10): akademik bulguları ürün incelemesi gibi schema markup | **Uygulanmaz**; yanıltıcı yapılandırılmış veri riski |
| 4 | Paketteki "10.000 öğrenciyle gerçek deney" başlığı | Okuyucu Hupolingo sonucu sanabilir; "Başka bir uygulamada 10.000 öğrencilik deney" biçimine çevir (görünür dipnota ek olarak) |
| 5 | `DenemeKayitForm`: çocuk adı + telefon zorunlu; sınıf 3–8 | Veri minimizasyonuna aykırı eğilim, pilot dışı sınıf 8. Magnet için ayrı hafif form; mevcut form ayrıca gözden geçirilmeli |
| 6 | Demo soruları 4. sınıf (önceki program) | Etiketi/öğeleri doğrula; 3–7 pilot ile uyum |
| 7 | Gönderim altyapısı eksik (E1–E4), iki sağlayıcı (Brevo/Resend), `ticari-ileti-izni` yer tutucu, GÖR-078 | Gönderim sıfır; bunlar kapanmadan seri çalışmaz |
| 8 | WhatsApp/SMS | İYS + hukuk; planda yalnız taslak adım var |
| 9 | Fikir kutusu arşivindeki H-kayıtları (H-126, H-127, H-128, H-138 vb.) tek tek karşılaştırılmadı | Fikirler `FIKIR_KAYDI.md`'ye FK-001–FK-005 olarak işlendi; arşivle çelişki taraması yapılmadı |
| 10 | Ürün gerçeği doğrulanmadı: "oturum ≤10 soru", "yanlışlar ertesi gün", veli panelinde "doğru oran" | Bu iddialar yayından önce ürün/ekranla doğrulanmalı |
| 11 | `robots.txt Disallow:/`, sitemap/OG/canonical (PROJE_GUNLUGU bulgusu) | Güncel durumu doğrula; yoksa SEO tabanlı magnet işe yaramaz |
| 12 | Uyarı: pilot sonuç sözü (B#7) yönetim kararı ister; yalnız kabul edilirse yaz | Karar #6 |

### Kullanıcıdan gereken kararlar (en çok 6)
1. **Hafif lead formu**: yalnız e-posta + sınıf + işaretsiz pazarlama izni (çocuk adı/telefon yok) kabul mü?
2. **İlk 3 pilot** (Çarpım pif noktaları, Ayın Denemesi, Haftalık görev kartı) ve ilk Ayın Denemesi sınıfı/ayı onayı (öneri: 3. sınıf).
3. **Hukuk ve şirket bilgisi** (unvan, MERSİS, e-posta, onay) ne zaman tamamlanır? Yayın tarihi buna bağlı.
4. **Fiyat/deneme/iade tek politika** ve veli hesabı ücretsiz mi? (magnet CTA'larını belirler)
5. **E-posta sağlayıcı** tek seçim (Brevo mu Resend mi) ve gönderim motoru işleri (P1–P4) önceliği.
6. **Kanıt-içerik sözü**: "pilot sonuçları ne çıkarsa yayınlarız" ifadesini kullanıp kullanmayacağımız ve Ayın Denemesi içerik kapısında insan onayını kimin vereceği.
