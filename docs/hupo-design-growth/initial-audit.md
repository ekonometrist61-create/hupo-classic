# İlk denetim — web satış yüzeyi (6 Ekim 2026)

Yöntem: dev sunucuda (`localhost:3000`) gerçek sayfaların headless Edge ekran görüntüleri (1280 ve 390 px) + kaynak kod okuma.
**Görsel doğrulanan:** landing (`/`), giriş (`/signin`). **Yalnızca kodla incelenen (görsel doğrulanmadı):** veli paneli, admin toplu soru yükleme, mobil ana/soru/sonuç ekranları. Giriş gerektiren sayfalar oturumsuz görüntülenemedi.

## Mevcut durum
Landing, TailAdmin şablonunun üstüne yazılmış genel bir SaaS sayfasıydı: emoji ikonlar, Hupo karakteri yok, gerçek ürün görüntüsü/demo yok, fiyat bölümü i18n içine gömülmüş uydurma içerik. Giriş sayfası ve açılış ekranı şablonun markasını taşıyor.

## En önemli 5 sorun
| # | Öncelik | Sorun (kanıt) | Kullanıcı / ticari etki | Durum |
|---|---|---|---|---|
| 1 | **P0** | **Uydurma ticari iddialar.** Landing'de ₺49 / ₺99 aylık fiyat, "Günde 5 soru", "Aile paketi (3 çocuk)", "İlk 7 gün tamamen ücretsiz. Kartına herhangi bir ücret yansımaz." metinleri `tr/en.json` içinden geliyordu; `plans` tablosundan değil. Kapsam kayıtlarında onaylı fiyat/deneme yok. Ayrıca ham anahtar `landing.pricing.plans.free.features.4` ekranda görünüyordu (dev overlay "1 Issue"). | Güven ve hukuki risk; AGENTS.md §5.4 ve kit kuralı (onaysız fiyat/deneme yok) ihlali | **Açık** — landing yeniden yazımında kalkacak |
| 2 | **P0** | **Şablon markası.** Karşılama ekranı her ilk ziyarette "TailAdmin" logosu ve geri dönen kullanıcıya yönelik "Hoş geldin! … devam edelim" gösteriyordu (halka açık landing dahil). Giriş sayfasının sağ panelinde "TailAdmin — Free and Open-Source Tailwind CSS Admin Dashboard Template" yazıyor. Sidebar/header de aynı logoyu kullanıyor. | Velinin ilk izlenimi: "bu bir şablon" — satın alma yolunda güven kaybı | Karşılama ekranı halka açık yüzeylerden **çıkarıldı** (yalnız panel layout'larında). Giriş sayfası ve sidebar logosu **açık** |
| 3 | **P1** | **Hupo yok, gerçek ürün yok.** Landing'de maskot, ürün ekranı, demo ve örnek veli raporu yok; ikonlar emoji; bölümler her SaaS sayfasında aynı. | Fayda anlaşılmıyor; marka farkı sıfır | Açık — yeniden tasarım |
| 4 | **P1** | **Türkçe tipografi hatası.** `Outfit` yalnızca `latin` alt kümesiyle yükleniyordu (`layout.tsx`); ğ ş ı İ Ğ Ş glifleri latin-ext'te, yani yedek fonta düşüyordu. Outfit `latin-ext` destekliyor (font-data doğrulandı). | Kelime ortasında font karışması; "özensiz" izlenim | **Düzeltildi** (`subsets: ["latin","latin-ext"]`) |
| 5 | **P1** | **Boş vaat / kırık akış.** CTA'lar girişsiz çalışmayan `/ogrenci/soru`'ya gidiyordu ve "hesap gerekmez" yazıyordu; `/demo` yok. | İlk tıklamada `/signin`'e atılma; yanlış vaat | CTA'lar `/signup`'a, vaat kaldırıldı. Gerçek `/demo` **yapılacak** |

Diğer gözlemler (P2): footer'da doğrulanmamış "KVKK Aydınlatma" bağlantısı; FAQ'de "güvenli", "editör onaylı", "müfredata uygun" gibi kodla kanıtlanmamış ifadeler; reduced-motion açıkken splash animasyon uyarısı; `public/images` altında şablon görselleri.

## Henüz denetlenmeyenler
Veli paneli (6-soru eşiği önceki turda eklendi, görsel doğrulanmadı), admin toplu soru yükleme akışı, mobil ana/soru/sonuç ekranları (ayrı dalga; `tool/*_previews_test.dart` ile görüntü alınabilir).

## Önerilen ilk dar kapsamlı görev
Landing'i kit sırasına göre yeniden kur (fayda → demo → nasıl çalışır → örnek veli raporu → güven → planlar → SSS), uydurma fiyat/deneme içeriğini kaldır, Hupo master pozunu şeffaf WebP olarak yerleştir, gerçek `/demo` ekle.
