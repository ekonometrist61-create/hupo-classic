# Analitik ve saklama bildirimi — TASLAK

> **Durum: TASLAK. Hukuk onayı yok. Yayınlanmaz, sayfaya bağlanmaz.**
> Bu metin bir hukukçu tarafından gözden geçirilmeden kullanılamaz. Aşağıdaki süreler teknik ön öneridir; yasal süre olarak yazılmamalıdır.

## A. Ölçüm ve çerez (web)
Web sitemizde analitik amaçlı ölçüm yapıyoruz. Bu ölçüm yalnızca siz "Kabul et" dediğinizde çalışır. Analitik çerez onayınızı istediğiniz zaman geri çekebilirsiniz. Ölçüm, sayfa ziyaretlerini ve tıklama olaylarını anonim olarak kaydeder; kişisel e-posta, ad veya çocuk bilgisi ölçüme gönderilmez. Ölçüm sağlayıcısı: [sağlayıcı adı ve bölgesi — hukuk onayı]. Oturum kaydı kullanılmaz.

## B. Uygulama ve ekran süresi
Uygulamada ekran süresi bilgisi, ürünü geliştirmek için tutulur. Çocuk uygulamasında bu ölçüm [varsayılan kapalı / veli onayıyla açık — hukuk kararı].

## C. Saklama süreleri (ÖNERİ, hukuk onayı yok)
| Veri | Öneri | Not |
|---|---|---|
| Anonim web olayları (bağlı değil) | 180 gün | Kodda: `SAKLAMA_ANONIM_GUN` |
| Hane bağlı web olayları | 400 gün | Kodda: `SAKLAMA_WEB_GUN` |
| Ekran süresi kayıtları | 300 veya 400 gün | Çelişki var; hukuk tek değer seçecek |
| Hane silindiğinde ilgili olaylar | Anında | Kodda uygulanır |

## D. Haklarınız
Verilerinize erişme, düzeltme, silme ve dışa aktarma haklarınızı kullanmak için [iletişim adresi] üzerinden bize ulaşabilirsiniz. Silme ve dışa aktarma işlemleri yönetim panelinde ilgili hane için mevcuttur; yasal süreler hukuk kararıyla kesinleşir.

## E. Açık noktalar (hukuk)
1. Ölçüm sağlayıcısı ve veri bölgesi.
2. Çocuk uygulamasında ekran süresi için rıza modeli.
3. Saklama sürelerinin kesinleşmesi (300 mü 400 mü).
4. Veli rızası metni ve çocuk verisi için ek koruma.
5. Yayın tarihi ve sürüm numarası (`ANALYTICS_CONSENT_VERSION`).
