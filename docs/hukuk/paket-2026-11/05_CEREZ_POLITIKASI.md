> TASLAK · Sürüm: `cerez-2026-11-v1` · KVKK Çerez Uygulamaları Hakkında Rehber (2022) esas alındı · Avukat onayı bekliyor.

# Çerez Politikası

**Son güncelleme:** [TARİH]

## Kısaca

- Sitenin çalışması için gereken çerezler her zaman açıktır.
- Ölçüm çerezleri yalnızca siz izin verirseniz çalışır. "Reddet" en az "Kabul et" kadar kolaydır.
- Şu anda reklam/pazarlama çerezi kullanmıyoruz.

> **İç not (K-0256):** Lansmanda pazarlama kategorisi ve reklam pikselleri KAPALI. Aşağıdaki pazarlama satırları ve bant metninin pazarlama kısmı, Meta/Google ile standart sözleşme sağlandığında açılmak üzere hazır tutulur; o zamana kadar sitede gösterilmez.
- Veli, öğrenci ve yönetim panellerinde ve uygulamanın çocuk ekranlarında reklam çerezi yoktur.

## 1. Çerez nedir?

Çerezler ve benzeri teknolojiler (yerel depolama, pikseller, SDK'lar) web sitesini ziyaret ettiğinizde cihazınıza kaydedilen küçük veri dosyalarıdır.

## 2. Hangi çerezleri kullanıyoruz?

| Kategori | Ne işe yarar? | Örnek | Hukuki sebep | Varsayılan |
|---|---|---|---|---|
| **Zorunlu** | Giriş, oturum, güvenlik, bot koruması, çerez tercihinizin hatırlanması | Supabase oturum çerezi, Cloudflare Turnstile, `hupo_cookie_consent` | Sözleşme (m.5/2-c), meşru menfaat (m.5/2-f) | Açık (kapatılamaz) |
| **Analitik** | Hangi sayfaların ziyaret edildiğini toplu olarak ölçmek, siteyi iyileştirmek | PostHog (AB sunucuları) | Açık rıza | Kapalı |
| **Pazarlama** | Reklamların etkisini ölçmek, siteyi ziyaret edenlere reklam göstermek | Meta Pikseli, Google Ads etiketi, [TikTok Pikseli] | Açık rıza | Kapalı |

Tam liste (ad, sağlayıcı, süre, amaç):

| Ad | Sağlayıcı | Kategori | Süre | Amaç |
|---|---|---|---|---|
| `sb-*-auth-token` | Supabase | Zorunlu | Oturum / [X] gün | Giriş |
| `cf_clearance` | Cloudflare | Zorunlu | 30 dk–1 yıl | Bot koruması |
| `hupo_cookie_consent` | Hupolingo | Zorunlu | 12 ay | Tercihinizi hatırlamak |
| `ph_*` | PostHog | Analitik | 12 ay | Ölçüm |
| `_fbp` | Meta | Pazarlama | 3 ay | Reklam ölçümü |
| `_gcl_*` | Google | Pazarlama | 3 ay | Reklam ölçümü |
| [DOLDURULACAK — yayından önce tarayıcıda gerçek çerezler listelenip doğrulanmalı] | | | | |

## 3. Çerez bandı metni

**Lansman sürümü (yalnız zorunlu + analitik):**

> **Çerez tercihleriniz**
> Sitenin çalışması için gerekli çerezleri kullanıyoruz. İzin verirseniz siteyi geliştirmek için toplu ölçüm çerezleri de kullanırız. Reklam çerezi kullanmıyoruz. Seçiminizi istediğiniz zaman değiştirebilirsiniz. [Çerez Politikası]
>
> [Reddet] [Kabul et]

**Pazarlama kategorisi açıldığında kullanılacak sürüm:**

> **Çerez tercihleriniz**
> Sitenin çalışması için gerekli çerezleri kullanıyoruz. İzin verirseniz siteyi geliştirmek için ölçüm, reklamlarımızı ölçmek için pazarlama çerezleri de kullanırız. Seçiminizi istediğiniz zaman değiştirebilirsiniz. [Çerez Politikası]
>
> [Reddet] [Ayarla] [Kabul et]

**Ayarla ekranı:**
- Zorunlu çerezler — her zaman açık
- ☐ Analitik çerezler — "Hangi sayfaların ziyaret edildiğini toplu olarak ölçeriz."
- ☐ Pazarlama çerezleri — "Reklamlarımızın işe yarayıp yaramadığını ölçer, siteyi ziyaret edenlere Hupolingo reklamı gösteririz. Veriler Meta ve Google ile paylaşılır."
- [Seçimimi kaydet]

Kurallar: Üç düğme eşit boyut ve görünürlükte; izin verilmeden analitik/pazarlama betiği **yüklenmez**; kapatılan çerez sayfayı kilitlemez; tercih 12 ayda bir yeniden sorulur; tercih footer'daki "Çerez tercihleri" bağlantısıyla her an değiştirilir.

## 4. Mobil uygulama

Mobil uygulamada reklam SDK'sı ve çapraz uygulama takibi yoktur. Hata izleme (Sentry) ve bildirim (Firebase) yalnızca hizmet için çalışır. Mağaza gizlilik etiketleri bununla uyumlu doldurulur (`mobile-app/store/VERI_GUVENLIGI_VE_GIZLILIK.md`).

## 5. Yurt dışı ve haklar

Pazarlama çerezleriyle toplanan veriler Meta ve Google'a (AB/ABD) aktarılır; dayanak [Aydınlatma Metni §6](02_KVKK_AYDINLATMA_METNI.md). Haklarınız ve başvuru yolu için aydınlatma metninin 9. ve 10. bölümlerine bakın.
