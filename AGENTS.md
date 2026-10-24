# AGENTS.md — Proje Okulu / Öğrenci Hazırlık (Hupo)

> Bu dosya, bu depoda çalışan **her ajan** ve **her insan** için kuralları tanımlar.
> Başlamadan önce `MASTER_BRIEF.md`'yi ve `PROJE_GUNLUGU.md` açık işler panosunu (§9) oku.

---

## 0. Alt ajan çalıştırma ve token tasarrufu

### Token tasarrufu — ana ilke
**Token harcamalarını azaltmak için işleri zorluk/uzmanlık derecesine göre alt modellere devret.**

| İş türü | Tercih edilen model |
|----------|-------------------|
| Tasarım, UX, pazarlama, iletişim | `hupo-design-growth-director` (proje agent'ı) |
| Geniş kapsamlı keşif, çoklu dosya araştırması | `Explore` subagent (salt okunur, hızlı) |
| Bağımsız paralel sorgular | `Agent` aracıyla paralel çalıştır |
| Rutin kod yazma (çeviriler, şablon bileşenler) | Haiku-sınıfı model (alt model) |
| Mimari karar, güvenlik, karmaşık SQL | Mevcut oturum / Sonnet veya üzeri |

**Devretme kuralları:**
- Tasarım/UX/metin görevi → `/claude:hupo-design-growth-director` çağır, kodu sen yazma
- 3'ten fazla dosya gerektiren arama → `Explore` subagent
- Bağımsız iki iş aynı anda yapılabiliyorsa → tek mesajda iki paralel araç çağrısı
- Sürüm numarası veya basit çeviri eklemek → minimum token, doğrudan yaz
- Büyük dosyayı tamamen okumak yerine `Grep` / `offset+limit` kullan

### Alt ajan desteği
`.claude/agents/hupo-design-growth-director.md` tasarım, UX, pazarlama ve iletişim
görevleri için kurulu proje agent'ıdır; kod/güvenlik/backend kurallarını değiştirmez.
Ayrıntı: `docs/hupo-design-growth/`.

---

## 1. Dil

- **Arayüz metinleri:** Türkçe, samimi ve çocuğa dost (2. tekil şahıs: "sen")
- **Kod yorumları:** Türkçe
- **Değişken/alan adları:** Türkçe, `snake_case` (alan adları Supabase ile eşleşir)
- **Sınıf adları / dosya adları:** `PascalCase` / `lowercase_snake_case` (İngilizce,
  çünkü Flutter/Next.js konvansiyonu ve APK'taki isimlerle birebir eşleşmeli)
- Kod içi anahtar sözcükler (değişken, fonksiyon adı) **İngilizce kalabilir**
  ama tutarlı olsun

### Birebir korunacak metinler

`kurtarilan/missing-turkish.txt` içindeki 153 metin **kopyalanmalı**, yeniden
yazılmamalı. Bunlar telefondaki APK'dan çıkarıldı, orijinal ürün metinidir.

---

## 2. Silinmez yapılar

| Klasör                                         | Neden                                 |
| ---------------------------------------------- | ------------------------------------- |
| `mobile-app/lib/`                              | Uygulama kaynağı                      |
| `mobile-app/assets/`                           | Varlıklar (font, PNG, lottie)         |
| `web-panel/src/`                               | Panel kaynağı                         |
| `supabase/migrations/`, `functions/`, `tests/` | Backend                               |
| `kurtarilan/`                                  | Kurtarma kanıtı — **git'e girmemeli** |

## 3. Silinebilir yapılar

`node_modules/`, `.next/`, `build/`, `.dart_tool/`, `*.log`,
`kurtarilan/strings-*.txt` (5 dökümden 4'ü fazlalık),
`e.innerText)`, `e.innerText)})`, `proje-okulu-app/`, `reports/`, `research_notes/`

Detaylı gerekçe: `docs/arsiv/TEMIZLIK_RAPORU.md` (arşiv)

---

## 4. Kod kuralları

### Flutter

- Riverpod (`flutter_riverpod`) — provider dosyaları `lib/providers/`
- Hata durumu **her zaman** kullanıcıya gösterilir, yutulmaz:
  ```dart
  // YANLIŞ
  try { ... } catch (_) {}
  // DOĞRU
  } catch (e) {
    if (context.mounted) showSnack(context, 'Sorular yüklenemedi, birazdan tekrar deneyelim.');
  }
  ```
- Boş widget ağacı yasak; en az bir `const` çıktı
- Ağ isteği `FutureProvider` / `AutoDispose` ile, `ref.keepAlive()` bilinçli kullanılır
- Metinler `const String` olarak tanımlanır, gömülü değil

### Supabase / SQL

```sql
create or replace function public.ornek_fonksiyon(p_x uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''   -- ZORUNLU (GÖR-004 standardı; gövdedeki her nesne public. ile nitelenir)
as $$
begin
  if auth.uid() is null then
    raise exception 'Oturum bulunamadı';
  end if;
  ...   -- örn. select ... from public.profiles where ...
end;
$$;

revoke execute on function public.ornek_fonksiyon(uuid) from public, anon;
grant  execute on function public.ornek_fonksiyon(uuid) to authenticated;
```

- `SECURITY DEFINER` **her zaman** `set search_path = ''` ile birlikte; gövdede tablo, fonksiyon ve tip adları `public.` ile nitelenir (eski `public, pg_temp` tanımları uygulanmış migration'larda kalır, GÖR-004)
- `service_role` fonksiyonları: `from public, anon, authenticated` revoke edilir
- Her RPC'in `revoke` / `grant` satırı migration'da **mutlaka** bulunur
- Yeni tablo → `enable row level security` + açık politika

### Next.js / web-panel

- `next-intl` kullanılır; `localePrefix: "never"`, birincil dil `tr`
- Sunucu bileşeninde `getTranslations`, istemci bileşeninde `useTranslations`
- Yeni metin **her iki** `messages/*.json` dosyasına da eklenir (`tr`, `en`)
- Supabase çağrısı yalnızca server bileşeninde; anahtar istemciye sızmaz

---

## 5. Güvenlik kuralları — ihlal etme

1. **`service_role` / `sb_secret_` anahtarı ASLA uygulamaya, `pubspec.yaml`'a,
   `.env.local`'e veya log'a yazılmaz.** Mobil uygulamada publishable (anon) key
   kullanılır; koruma RLS ile sağlanır.
2. Yeni RPC yazarken yetkileri genişletme; `from public` revoke etmeyi unutma.
3. Öğrenci verisi veli onayı olmadan veli paneline düşmez.
4. Ödeme (iyzico) tutarı **istemciden gelen veriden** hesaplanmaz; `plans` tablosundan okunur.
5. PII (ad, e-posta) log'a yazılmaz.
6. Çocuk uygulaması olduğu için varsayılanlar: reklam kapalı, takip kapalı,
   konum isteme yok. Yeni özellik eklerken bunları açma.

---

## 6. Yeni özellik eklerken kontrol listesi

- [ ] Model dosyası `lib/models/`, `.fromMap` factory'si ile
- [ ] Repository metodu `lib/services/`, `supabase.rpc(...)` çağrısı ile
- [ ] Provider `lib/providers/`, hata durumunda kullanıcı metni ile
- [ ] Widget `lib/widgets/`, tema renkleriyle (`app_theme.dart`), sabit renk yok
- [ ] Ekran `lib/screens/`, geri tuşu davranışı tanımlı
- [ ] Türkçe metinler `const`, hata mesajı **her** yol var
- [ ] SQL migration eklendi, `revoke`/`grant` yazıldı, test `supabase/tests/` altında
- [ ] Pubspec'e paket eklendiyse `--dart-define` gerektirmiyor mu kontrol edildi

---

## 7. Kurtarma ile ilgili özel not

Bu projede 22 Dart dosyası ve 12 SQL fonksiyonu silinmişti, telefondaki APK'dan
kurtarıldı. Yeniden yazarken:

1. `kurtarilan/KURTARMA_RAPORU.md` bölüm 4 → o özelliğin dosyaları, sınıfları, metinleri
2. `kurtarilan/feature-tokens.txt` → kesin sınıf, provider ve RPC adları
3. `kurtarilan/missing-turkish.txt` → birebir kullanılacak Türkçe metinler
4. Tahmin yürütürken isimlendirmeyi **APK'daki adlarla birebir tut**
5. Emin olmadığın yeri `// TODO(kurtarma):` ile işaretle, sessizce uydurma

`libapp.so` derlenmiş makine kodudur; kaynak kod içermez. Metin ve isim dışında
hiçbir şey birebir kopyalanamaz.

---

## 8. Doğrulama

```bash
# Flutter
cd mobile-app && flutter analyze          # 0 hata olmalı
cd mobile-app && flutter test

# Panel
cd web-panel && npm run lint
cd web-panel && npm run build

# SQL
supabase db reset                      # tüm migration'lar sırayla çalışmalı
supabase test db                       # supabase/tests/*.sql
```

Bir değişiklik yapmadan önce hangi katmanı etkilediğini söyle. Katmanlar arası
bağımlılık: `supabase` → `mobile-app`/`web-panel` → (ortak) mesaj anahtarları.

---

## 9. Proje Günlüğü (`PROJE_GUNLUGU.md`)

Projenin planlarını, kararlarını, gelişmelerini, sorunlarını ve açık işlerini tuttuğu
tek günlük. Eski adı `TASKS.md`; 2026-10-17'de yeniden adlandırıldı. Eski bölüm
numaraları (`§11.7` gibi) aynen geçerlidir; kod yorumları bu numaralara atıf yapar.

Bu dosya sohbet bitince de bağlamı taşır. Ana oturum ve alt ajanlar aşağıdaki kurallara uyar.

### 9.1 Başlamadan önce
1. `PROJE_GUNLUGU.md` içindeki **A. Açık işler panosunu** oku.
2. Görevin konusuna ait kayıtları bul: konu kodu ile (ör. `grep "· VEL ·"`).
3. Görev bir açık işe (`GÖR-###`) bağlıysa onu kullan; değilse yeni GÖR numarası aç.

### 9.2 Ne zaman kayıt açılır
Zorunlu:
- Plan çıkarıldığında veya değiştiğinde → `Tür: Plan`
- Karar alındığında ya da önerildiğinde → `Tür: Karar`
- Önemli gelişmede (dağıtım, migration, büyük değişiklik, canlı veri) → `Tür: Gelişme`
- Sorun veya hata bulunduğunda → `Tür: Sorun`
- İş ertelendiğinde → `Durum: ERTELENDİ` (gerekçe ile)
- İş bittiğinde veya doğrulanamadığında → `Durum` ve `Doğrulama` alanları

Gerekmez: yazım düzeltmesi, tek satırlık yorum, dışarıyı etkilemeyen okuma/arama adımları.

### 9.3 Kayıt biçimi

```
### K-0042 · 2026-10-17 14:05 · VEL · Kısa başlık
- **Tür:** Plan | Karar | Gelişme | Sorun | Yapılacak | Not
- **Konu:** VEL
- **Bağlam:** Neden bu kayıt açıldı, ne tetikledi.
- **Plan:** Adımlar (numaralı).
- **Karar:** Ne karar verildi, kim verdi. Kullanıcı kararı `ONAYLI`; ajan önerisi `ONAY BEKLİYOR`.
- **Durum:** PLANLANDI | DEVAM | BEKLİYOR | ENGELLİ | ERTELENDİ | TAMAMLANDI | İPTAL
- **Doğrulama:** DOĞRULANDI | KISMİ | DOĞRULANMADI | — (yalnızca Plan/Karar/Not türünde)
- **Sahip:** Ajan | Kullanıcı | Hukuk | Dış hizmet
- **Önem:** Kritik | Yüksek | Orta | Düşük
- **Açıklama:** Kısa düz metin: ne oldu, ne kaldı.
- **Kanıt:** Commit, dosya yolu, komut ve sonucu (ör. `npm run lint` — 0 hata).
- **İlgili:** GÖR-…, eski § numaraları, dosya yolları.
```

Konu kodları:

| Kod | Alan | Kod | Alan |
|---|---|---|---|
| GÜV | Güvenlik | YÖN | Yönetim paneli |
| VT | Veritabanı ve migration | WEB | Web sitesi ve landing |
| MOB | Mobil uygulama | TSR | Tasarım ve UX |
| VEL | Veli paneli ve anket | BYM | Büyüme ve ölçüm |
| DEN | Deneme sınavı | HUK | Hukuk ve KVKK |
| ALT | Altyapı, dağıtım, alan adı | BEL | Belge ve süreç |

### 9.4 Açık işler panosu (A bölümü)
- Her açık iş bir `GÖR-###` satırıdır. Numara bir kez verilir, yeniden kullanılmaz.
- İş kapanınca önce K kaydı yazılır (`TAMAMLANDI` + `DOĞRULANDI`), sonra satır panodan çıkarılır.
- Yeni açık iş panonun sonuna eklenir.

### 9.5 Değişmez kurallar
1. **Kayıt silinmez.** Eski kayıt yeniden yazılmaz; değişiklik gerekirse aynı kaydın altına `- **Güncelleme 2026-10-18 10:30:** …` eklenir.
2. **`TAMAMLANDI` yalnızca `DOĞRULANDI` ile birlikte.** Kod yazıldı ama test, ekran veya canlı kontrol yapılmadıysa `Doğrulama: DOĞRULANMADI` ve durum `DEVAM` ya da `BEKLİYOR` olur.
3. **Görsel iş ekran kanıtı olmadan `DOĞRULANDI` olamaz.** Tarayıcı veya cihaz yoksa bunu açıkça yaz.
4. **Karar kaynağı yazılır.** Kullanıcının onayı `ONAYLI`; ajan önerisi onaylanana kadar `ONAY BEKLİYOR`. Onay gelince yeni kayıt değil, aynı kaydın güncellemesi yazılır.
5. **Erteleme gerekçesiz olmaz.** `ERTELENDİ` yanına neden ve tekrar açılma koşulu yazılır.
6. **Hassas bilgi yazılmaz.** Anahtar, şifre, jeton ve kişisel veri (bkz. §5). "Anahtar yenilendi" yazılır, değeri yazılmaz.
7. **Zaman.** Tarih `2026-10-17`, saat 24 saat, Türkiye saati. Saat tahmin edilmez; `Get-Date` ile alınır.
8. **Numara sırası.** K numaraları sırayla artar. Yeni K kaydı B bölümünde en üste eklenir.
9. **Eş zamanlı yazım.** Yazmadan önce dosyayı yeniden oku, yalnızca kendi kaydını ekle, başka ajanın satırını değiştirme.
10. **Alt ajanlar** kendi işinin kaydını yazar ve raporundaki `FILES` / `TEST` alanlarını kayda aktarır. Ana oturum kaydın durumunu doğrular.
11. `.claude/agents/` ve `.claude/skills/` altındaki tüm tanımlar bu kurala tabidir.
