> Hukuk onayı bekliyor, yayın yok. (GÖR-083 taslağı; mağaza formuna girilmedi, hukuki görüş değildir.)

# Veri güvenliği formu: güncel olmayan yanıtlar

Kaynak belge: `mobile-app/store/VERI_GUVENLIGI_VE_GIZLILIK.md` (sürüm 2026-10-29). Karşılaştırma: `web-panel/src/lib/legal/content.ts`, `mobile-app/pubspec.yaml`, `supabase/functions/*`.

Kod doğrulaması özeti:
- `pubspec.yaml`: `sentry_flutter`, `firebase_messaging`, `webview_flutter` var. Qonversion bulunmadı; yani şu an geçerli olan A sürümü.
- `supabase/functions`: `_shared/iyzico.ts`, `payments-checkout`, `payments-callback` iyzico'yu çağırıyor; PayTR/Param için kodda eşleşme bulunmadı. E-posta için `_shared/eposta.ts` ortama göre sağlayıcı seçiyor (Brevo/Resend referansları var).
- Ödeme ve e-posta sunucu tarafıdır, mobil SDK değildir.

## Güncel olmayan veya çelişen yanıtlar

### 1) Brevo ve Resend
- Belgedeki durum: §3 sonunda "sunucu tarafı, mobil SDK değil; gizlilik politikasında yazılır" deniyor, mağaza formunda yer almıyor.
- Sorun: Web gizlilik metni (satır 107) Brevo ve Resend'i alıcı olarak sayıyor; mobilde kullanıcı e-postası bu sağlayıcılara gidiyor (hesap/hizmet e-postaları). Google Data Safety, uygulamanın topladığı verinin sunucu tarafında üçüncü taraflara iletilmesini de kapsar; "paylaşım: Hayır" yanıtı bu iletim "hizmet sağlayıcı" sayılırsa korunabilir, ancak bu kesin değil.
- Önerilen yanıt: Paylaşım "Hayır" kalır, yalnızca "hizmet sağlayıcı (işleyen)" varsayımı belgede Brevo ve Resend'i de sayacak şekilde genişletilir. Gizlilik politikasında alıcı olarak yer alır.
- Doğrulanmadı: hangi sağlayıcının canlıda aktif olduğu (ortam değişkenine bağlı), sağlayıcıların DPA/sözleşme durumu, Brevo ve Resend'in veriyi kendi amaçları için kullanıp kullanmadığı.

### 2) Sentry
- Belgedeki durum: "Çökme günlükleri" ve "Tanılama" beyan edilmiş; "kişisel veri temizlenir".
- Sorun: Beyan temiz ama iki şey eksik. (a) Cihaz kimliği/Installation benzeri bir değer Sentry'ye gidiyor mu belirsiz. (b) Apple "Tanılama: hesaba bağlı değil" yanıtı, Sentry olayına kullanıcı kimliği eklenip eklenmediğine bağlı.
- Önerilen yanıt: Çökme günlükleri + Tanılama kalır, amaç "Uygulama işlevi ve analiz". Apple'da "hesaba bağlı değil" yanıtı yalnız kullanıcı kimliğinin olaya eklenmediği doğrulanırsa girilir; aksi halde "hesaba bağlı".
- Doğrulanmadı: `lib/services/error_reporting.dart` içeriğini bu görevde tekrar okumadım; `sendDefaultPii=false` ve `beforeSend` temizliği belgenin iddiası. Sürüm build'inde ağ trafiğiyle teyit gerekli (belge §8-4).

### 3) iyzico (ve ödeme sağlayıcısı)
- Belgedeki durum: Mobil A sürümünde finansal bilgi "Hayır"; web ödemesi "PayTR / Param (mobil kapsam dışı)"; §7'de içerik.ts "iyzico → PayTR/Param" güncellenecek denmiş.
- Sorun: Kodda canlı ödeme akışı iyzico (`supabase/functions/payments-*`, `_shared/iyzico.ts`). PayTR/Param için kodda iz bulunmadı. Belge sağlayıcıyı PayTR/Param diye yazıyor, web metni iyzico diyor. Sağlayıcı kararı netleşmeden iki belge de yanlış olabilir.
- Önerilen yanıt: Mobil formda A sürümü için "Finansal bilgi: toplanmıyor" doğru kalır, çünkü çocuk ekranında ödeme yok. Ancak sağlayıcı adı belgelerde tek kaynağa bağlanmalı: [DOLDURULACAK: ödeme sağlayıcısı kararı]. Web gizlilik metni ve bu belge aynı sağlayıcıyı yazmalı.
- Doğrulanmadı: yayında aktif sağlayıcı, PayTR/Param entegrasyonunun hiç yazılıp yazılmadığı (yalnız `supabase/functions` tarandı; web-panel kaynağı taranmadı).

### 4) Bildirim belirteci (FCM)
- Belgedeki durum: "Cihaz veya diğer kimlikler" kategorisinde "Evet, isteğe bağlı"; paylaşım "Hayır".
- Sorun: Belirteç Google'ın FCM hizmetine ve Supabase'e gidiyor. Web metni (satır 64, 111) bunu yazıyor. FCM'in Firebase Installations kimliği toplayıp toplamadığı belgede de "doğrulanmalı" olarak duruyor. Ayrıca belirtecin hesap silinince silindiği doğrulanmadı.
- Önerilen yanıt: "Cihaz veya diğer kimlikler: Evet; amaç: uygulama işlevi (bildirim); isteğe bağlı: Evet (izin verilirse); paylaşım: Hayır (hizmet sağlayıcı varsayımıyla)". Firebase Installations ayrı satır gerekip gerekmediği sağlayıcı belgesiyle teyit edilene kadar "gerekebilir" notuyla tutulur.
- Doğrulanmadı: `lib/services/push/*` ve `register_device_token` içeriği bu görevde okunmadı; silme davranışı bilinmiyor.

### 5) Hedef kitle ve Qonversion (A / B sürümü)
- Belge Qonversion'ı B sürümüne bağlıyor; kodda yok, doğru. Mağazaya A sürümü gidecekse Qonversion satırları girilmez. Ödeme mimarisi kararı (Qonversion + Supabase) uygulanmadan B yanıtı girilmemeli.

### 6) Belgenin kendi içindeki çelişki
- §7 ve §3 PayTR/Param diyor, §1 sonu ve web `content.ts` iyzico diyor. Yukarıdaki madde 3 ile çözülmeli.

## Özet tablo

| Konu | Mevcut yanıt | Durum | Önerilen yanıt | Doğrulama |
|---|---|---|---|---|
| Brevo / Resend | Formda yok | Eksik | Paylaşım Hayır, hizmet sağlayıcı olarak sayılır; politikada alıcı | Doğrulanmadı (aktif sağlayıcı, DPA) |
| Sentry | Çökme+Tanılama var | Kısmen güncel | Aynı; Apple "hesaba bağlı" durumu teyide bağlı | Doğrulanmadı (ağ trafiği) |
| iyzico / PayTR / Param | Belge PayTR/Param, kod iyzico | Çelişkili | Sağlayıcı adı tek kaynağa bağlanır; mobil A'da finansal veri yok | Doğrulanmadı (aktif sağlayıcı) |
| Bildirim belirteci | Var | Kısmen güncel | Kimlik + isteğe bağlı + hizmet sağlayıcı | Doğrulanmadı (Installations, silme) |

## Karar / onay gereken noktalar
1. Ödeme sağlayıcısı hangisi (iyzico mi, PayTR/Param mı)?
2. Brevo ve Resend'den hangisi canlıda, hangisiyle DPA var?
3. "Üçüncü tarafla paylaşım: Hayır" sınıflandırması avukat ve sağlayıcı sözleşmeleriyle teyit.
4. Hedef kitle kararı (Aileler Politikası / Kids kategorisi) alınmadan form kesinleşmez.
5. Mağazaya A mı B mi gidecek.
