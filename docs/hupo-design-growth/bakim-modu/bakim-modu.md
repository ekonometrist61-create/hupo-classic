# Bakım modu ekranı — tasarım kaydı

> Durum: **taslak şablon**. Canlı web rotasına bağlı değil; uygulanmadı.
> Önizleme: `bakim-modu.html` (açık: varsayılan, koyu: `?tema=dark`).

## Kaynak ve onay durumu
- Marka rengi: `#147D8A` — mobil `app_theme.dart` (`AppColors.primary`) ile birebir.
  - Not: `BRAND_AND_VISUAL_RULES.md` `#147D82` yazıyor (öneri). Kod değeri esas alındı; fark onaylanmalı.
- Arka plan `#FFF9ED` (mobil `AppColors.background`), ikincil metin `#4A6A85` (mobil `AppColors.muted`), ana metin `#17324D` (web `--color-navy`).
- Logo: `web-panel/public/hupo/logo-icon.webp`. Onaylı master olup olmadığı doğrulanmadı.
- Koyu tema renkleri (`#0E2630`, `#143240`, `#4FB3BF`) **öneridir**; onaylı kaynak değildir.

## Token eşlemesi
| Token | Açık | Koyu | Kullanım |
|---|---|---|---|
| `--color-bg` | #FFF9ED | #0E2630 | Sayfa zemini |
| `--color-surface` | #FFFFFF | #143240 | Kart |
| `--color-text` | #17324D | #FFF9ED | Başlık |
| `--color-muted` | #4A6A85 | #B9CCD3 | Açıklama |
| `--color-primary` | #147D8A | #4FB3BF | Buton, durum |
| `--color-on-primary` | #FFFFFF | #0E2630 | Buton metni |
| `--color-focus` | #0D5762 | #F5C842 | Odak halkası |

## Ölçülen kontrast (WCAG)
| Çift | Oran | Hedef | Sonuç |
|---|---|---|---|
| Beyaz / #147D8A (buton) | 4.85:1 | 4.5:1 | geçer |
| #147D8A / #FFF9ED (durum metni) | 4.62:1 | 4.5:1 | geçer (sınırda) |
| #17324D / #FFF9ED | 12.52:1 | 4.5:1 | geçer |
| #4A6A85 / #FFF9ED | 5.42:1 | 4.5:1 | geçer |
| #FFF9ED / #0E2630 | 14.96:1 | 4.5:1 | geçer |
| #0E2630 / #4FB3BF (buton) | 6.37:1 | 4.5:1 | geçer |
| #B9CCD3 / #0E2630 | 9.44:1 | 4.5:1 | geçer |

## Durumlar
- Odak: görünür halka (`:focus-visible`), 3px.
- Buton: hover, active (ölçek 0.98), `disabled` ve `aria-busy` (kontrol sırasında).
- Hareket: logo hafif yüzer, durum noktası yanıp söner; `prefers-reduced-motion` ile ikisi de kapanır.
- Renk tek bilgi taşımaz: durum etiketi metin olarak yazılı.

## Doğrulama (tarayıcı, 390px genişlik)
- Açık ve koyu tema: konsol hatası 0, başarısız istek 0, yatay taşma yok.
- Logo yüklendi (128×128 doğal boyut). İlk görsel incelemede kare zemin dairenin dışına taşıyordu; daire kırpması eklenerek düzeltildi.
- Doğrulanmadı: gerçek cihaz, ekran okuyucu, Outfit fontu (şablonda yüklenmiyor; sistem yedek fontu görünüyor — Next uygulamasında `next/font` ile gelir).

## Açık işler
1. Web tarafında bakım kontrolü yok. Admin `yonetim/ayarlar` içindeki `bakim_modu` anahtarı yalnızca mobil `MaintenanceGate` tarafından okunuyor; web-panel bu anahtarı kullanmıyor.
2. Metin: `mesaj` alanı admin'den gelmeli; şablonda varsayılan metin var.
3. Next.js rotası olarak bağlanması (middleware veya layout kontrolü) ve mobil `MaintenanceScreen` ile görsel eşleme ayrı iş; onay sonrası yapılacak.
