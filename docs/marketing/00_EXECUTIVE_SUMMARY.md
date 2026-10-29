# 00 Yönetici Özeti ve "CMO olsam ilk 10 karar"

Durum: Taslak (onay bekliyor) · Tarih: 2026-10-29 · Rol: CMO/CGO · Bağımlı: tüm dosyalar · Karar kilidi: 19

Etiketler: **Kanıtlı** (repo/kaynak) · **Varsayım** · **Hipotez**. Hupo'nun gerçek kullanıcı/dönüşüm/maliyet verisi yok; hiçbir sayı sonuç vaadi değildir.

## 15. bölümdeki 12 soru
1. **Bugünkü gerçek durum (Kanıtlı):** Geliştirilmiş, geniş ama yayınsız bir ürün. Landing + hesapsız 5 soruluk demo + veli paneli canlı; mobil mağazada yok; fiyat ve ödeme canlıya alınmadı, hukuk metinleri onaysız; sosyal kanıt sıfır; arama indeksinde yok (robots). Rakip çıtası: MEBİ ücretsiz ve veli erişimli.
2. **En güçlü 3 avantaj:** (a) veliye okunur, "az veriyle yüzde göstermeyen" rapor (mevcut, kanıtlanacak); (b) tek seferlik ödeme, otomatik yenileme yok (kodla doğrulandı, yayınsız); (c) reklamsız/konumsuz çocuk alanı + veli onaylı veri (mevcut). Karakter/oyunlaştırma tek başına yetmez.
3. **En önemli 3 zayıflık:** (a) hazır olmama (mağaza/ödeme/hukuk/indeks); (b) kanıt ve sosyal kanıt yok, içerik hacmi/kalitesi doğrulanamadı; (c) odak dağınıklığı (çok modül, çoğu pilot) ve küçük ekip.
4. **Başlangıç segmenti:** Büyükşehir (ilk Ankara) 4. sınıf velisi, 4→5 geçişi; ikincil 3 ve 5–6. sınıf.
5. **Tek cümle konumlandırma:** "Günlük soru çalışmasını küçük adımlara bölen, veliye ilerlemeyi gösteren uygulama."
6. **Sosyal kanal önceliği:** Instagram (birincil) + YouTube/Shorts (yeniden kullanım) + LinkedIn ayda 2; TikTok/Facebook/X ertelendi; ücretli yok.
7. **Web'de ilk 5 değişiklik:** (1) mağaza rozetleri (Y1); (2) fiyat güven rozetleri ve kanıtsız kapsam listesi (Y2); (3) robots/sitemap/OG/JSON-LD (Y3); (4) "MEBİ ücretsiz" itirazına nötr SSS + gerçek ekran kaydı/hero testi (06 E1, E4, H2); (5) ücretsiz metni ve karakter/slogan bölümlerini veli diline çekmek (Y5, E3, E7).
8. **İlk 30 gün:** Kod/ölçüm değil önce karar ve zemin: onay paketi, hukuk takvimi, Y1/Y2/Y5 iş kaydı, hesap adı kontrolü, 8 veli görüşmesi, ekran kaydı çekimi, `olgular.json`+lint, UTM canlı doğrulama, ilk 10 gönderi onayı. Trafik yok.
9. **İlk 90 gün başarı ölçütleri:** Y1–Y5 kapalı, hukuk metinleri onaylı/takvimli, ≥8 görüşme kodlandı, UTM→PostHog çalışıyor, 4 hafta kesintisiz onaylı yayın, ≥10 pilot hane ilk oturum, bir kanal kararı ve hero kararı. Sayısal dönüşüm hedefi yok (baseline yok).
10. **Güvenle otomatikleştirilebilenler:** taslak üretimi, kural linter'ı, UTM üretimi, metrik CSV özeti, haftalık rapor taslağı, takvim→brief. **Otomatikleştirilmeyen:** onay, yayın, mesaj gönderimi, harcama, hesap bağlama, DM. Yerel MVP test edildi (14/14).
11. **Bir yıllık büyüme motorları (Hipotez):** (a) organik SEO/rehber içerikleri; (b) Instagram/Shorts veli rehberi; (c) pilot haneler → geri bildirim → kanıt; (d) dönem sonu yeniden satın alma ve mevsimsel kampanyalar (Eylül, tatiller); (e) onaylı veli/öğretmen topluluk tanıtımları. Ücretli reklam bu varsayımlarla ekonomik değil (15).
12. **Gerçek veri/deney gerekenler:** hero mesajı; "pilot" notunun etkisi; aktif→ücretli oranı ve fiyat; ücretli tık maliyeti; kanal CAC; demo→kayıt oranı; yeniden satın alma; "yüzde göstermeme"nin güven etkisi; mağaza dönüşümü; yayın saati/kanca biçimi. Hepsi baseline ve MDE gerektirir (14).

## "Ben CMO olsaydım ilk 10 stratejik kararım"
1. **Önce hazır ol, sonra büyüt.** Y1–Y5, hukuk onayı, ödeme E2E ve hesaplar kapanmadan trafik yok. (Kanıtlı: 03, 17)
2. **Rekabet ekseni içerik hacmi değil, veli güveni ve görünür rutin.** MEBİ'yle yarışma, tamamla. (02)
3. **Tek segment, tek mesaj, tek CTA:** 4. sınıf velisi, "günde 10 soruluk rutin", "Örnek soruları dene". (03, 04)
4. **"Yapay zekâ" ve "sınav garantisi" kategorisine girme.** Çocuk yüzeyinde LLM yok; MEBİ/Kunduz'da var. (02, 17)
5. **Ücretli reklamı ilk 6 ay kapat.** Senaryo modeli: başa baş için ≈%1,1 ziyaretçi→ücretli gerekir; varsayılan huni ≈%0,04–0,3. (15)
6. **Kanıtı kendimiz üret:** 8 veli görüşmesi, 20–30 pilot hane, gerçek ekran kaydı; sosyal kanıt yok olduğu sürece uydurma yok. (05, 10)
7. **Organik çekirdek:** Y3 indeks paketi + veli rehberleri + Instagram/Shorts + onaylı veli/öğretmen toplulukları. 20 taktikten ICE ≥36 olanlar. (20)
8. **Marka çatısı tek (Hupolingo);** Okuma, Kelime Evreni, Görselli soru, Deneme sınavı, HupoMentor pazarlamada anılmaz (pilot/planlı). (01, 03)
9. **Otomasyon = taslak + denetim + ölçüm; yayın insanda.** Mevcut growth-ajan/CRM üzerine EXTEND; yeni panel kurma. (12)
10. **Her kararı veri geldikçe güncelle:** baseline'ları 90. günde kilitle, hedefleri o zaman yaz, bütçe modelini gerçek girdilerle yeniden çalıştır; "belirsiz" geçerli sonuçtur. (13–15, 19)

## Belge haritası
01 ürün denetimi · 02 pazar/rakip · 03 makro strateji · 04 marka · 05 personalar · 06 web CRO/SEO · 07 sosyal · 08 yıllık plan · 09 içerik · 10 ilk 90 gün · 11_SAMPLE_CONTENT (instagram, reels_shorts, youtube, advertising, landing_pages, email_lifecycle, blog_content) · 12 otomasyon mimarisi · 13 KPI · 14 deney · 15 bütçe · 16 backlog · 17 risk · 18 kaynaklar · 19 karar kaydı · 20 taktik havuzu · calendar/ · automation/ (çalışan MVP + testler).

## Doğrulanamayanlar (özet)
Canlı site/mobil UX ve ekran görüntüsü; canlı DB içerik sayıları; rakip fiyat/yorum/sosyal/reklam (MEBİ, Kunduz dışı); anahtar kelime hacimleri; Meta/Google/YouTube politika ve API belgeleri; MEB okul bitiş/LGS/ortak yazılı tarihleri; Play ön kayıt 90 gün, iOS puan istemi 3/365, Instagram 7 gün özel yanıt; n8n iskeletlerinin içe aktarımı; görsel/video üretimi (hiç yapılmadı).
