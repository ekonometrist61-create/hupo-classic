# Ekran sözleşmesi: Landing hareket sistemi

## Kimlik
Ekran/route: `/` (`src/app/[locale]/(full-width-pages)/page.tsx`)
Yüzey: marketing (veli ve ziyaretçi)
Yaş-sınıf veya rol: veli (satın alma kararı) ve ziyaretçi
Kullanıcının görevi: Hupo'nun ne yaptığını anlayıp örnek soruları denemek veya veli hesabı açmak
Ürün faydası: Animasyon bilgiyi okutmak için değil, bölüm geçişlerini takip etmeyi kolaylaştırmak için
Birincil eylem ve gerçek sonucu: "Örnek soruları dene" (`/demo`); sonuç gerçek ürün demosu
İkincil eylemler: "Veli hesabı oluştur", menüden bölüm çapaları (`#how-it-works`, `#report`, `#characters`, `#pricing`, `#faq`)
Giriş ve sonraki ekran: Hero CTA veya menü → `/demo` ya da bölüm

## İçerik ve yerleşim
İlk bakışta görünen bilgi: Hero H1, alt metin, CTA, örnek rapor (etiketli "ÖRNEK RAPOR")
Başlık/alt metin: Değişmedi; metin kaynağı `messages/tr.json` ve `en.json`
Kanıt veya veri kaynağı: Örnek rapor sabit demo verisi, etiketli; karakter ve plan verileri Supabase'den (yoksa fallback)
Hupo yeri, boyutu ve state: Hero'da telefon yanında maskot (pop giriş, yalnız transform); Benefits, Demo, Nasıl çalışır, Veli raporu, Karakterler görselleri değişmedi
Kullanılan mevcut bileşen/tokenlar: `landing/buttons.ts` (`landingPrimaryBtn`), `motion/Reveal`, `motion/RevealGroup`, `motion/DrawLine`, `motion/SplitText`, `motion/LandingMotion`; tokenlar `--ease-hupo-out`, `--ease-hupo-inout`, `--ease-hupo-pop`, `--animate-hupo-*`
Ekran boyutu/klavye/uzun metin davranışı: 390 px ve 1440 px kontrol edildi; yatay taşma yok. Klavye: SSS düğmeleri odaklanır; kapalı panel `inert`

## Davranış ve durumlar
Loading: İçerik SSR ile hemen görünür; iskelet veya sahte yükleme yok
Empty / veri yetersiz: Hikâyeler bölümü veri yoksa hiç çizilmez; fiyat satırları veri yoksa gizlenir (mevcut davranış)
Success: Yok (bu ekranda form yok)
Validation / network error: Yok; Supabase hatası mevcut try/catch ile sessizce fallback
Disabled / yetki yok: Yok
Geri / vazgeç / yeniden dene: Mobil menü Escape ile kapanır; SSS tekrar tıklanınca kapanır
Çift gönderim / bağlantı kopması: Yok (salt okunur sayfa)
İlgili backend davranışı ve yetki: Yok değişti. Fiyat CTA hedefi bu işte değişmedi (başka bir oturumun değişikliği korundu)

## Kontrol
1. Bölümler aşağı kaydırınca bir kez belirir; yukarı-aşağı tekrar oynamaz (`once: true`).
2. `prefers-reduced-motion: reduce` altında GSAP izi yok, tüm içerik görünür (ölçüldü: 0 gizli öğe).
3. SSS aç/kapa: `aria-expanded` ve `inert` doğru değişir; yükseklik 0 ↔ 72 px (ölçüldü).
4. Çapalar (`#pricing`, `#how-it-works`, `#faq`, `#report`, `#characters`) üst kenarı 80 px (header 65 px'in altı, ölçüldü).
5. `/demo` geçişinde konsol hatası yok; `lenis` sınıfı temizlenir (ölçüldü).
6. 390 px'te yatay taşma yok (scrollWidth = clientWidth, ölçüldü).

Erişilebilirlik ve reduced-motion: Reduced motion'da içerik ve çapalar çalışır; Lenis `respectReducedMotion` ile yumuşatmayı kapatır. SSS panelleri `role=region`, `aria-labelledby` korunur.
Ölçüm eventleri ve metrik tanımı: Değişmedi (`TrackedLink` olayları aynı).
Gerçek kontrol komutları/sonuçları: `npx tsc --noEmit` çıkış 0; `npx eslint` landing ve sayfa 0 hata (2 mevcut uyarı dokunulmayan dosyalarda); Playwright MCP ile 1440/390 görüntüler; `npx playwright test` home+mobile: tek worker'da 9/10 geçti, 1 başarısız (aşağıda).
Ekran görüntüsü / cihaz / viewport: 1440×900 ve 390×844 tam sayfa görüntüleri (scratchpad).
Doğrulanmadı: LCP ölçümü, gerçek cihaz kare süresi, Lighthouse, gerçek ağ koşulları.
Kanıt, varsayım ve açık sorular:
- CTA renk/hover geçişi 200 ms'e çekildi (renk/hover kuralı); reveal ve SSS yapısal geçişleri 300 ms.
- Mobil e2e: "giriş ekranına bağlantı" testi mobil (Pixel 7) projede tekrar tekrar başarısız; aynı tıklama hidrasyon beklendiğinde çalışıyor. Baseline ile karşılaştırılmadı; regresyon olduğu kanıtlanmadı.
