# AGENTS.md — Proje Okulu / Öğrenci Hazırlık (Hupo)

> Bu dosya, bu depoda çalışan **her ajan** ve **her insan** için kuralları tanımlar.
> Başlamadan önce `MASTER_BRIEF.md`'yi oku.

---

## 0. Alt ajan çalıştırma

Bu depoda alt ajan desteği **yoktur**. Her işi, tek ajan olarak sen yapacaksın.
Karmaşık işleri `todo_list` ile adımlara böl ve ilerlemeyi gerçek zamanlı işaretle.

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

| Klasör | Neden |
|---|---|
| `mobile-app/lib/` | Uygulama kaynağı |
| `mobile-app/assets/` | Varlıklar (font, PNG, lottie) |
| `web-panel/src/` | Panel kaynağı |
| `supabase/migrations/`, `functions/`, `tests/` | Backend |
| `kurtarilan/` | Kurtarma kanıtı — **git'e girmemeli** |

## 3. Silinebilir yapılar

`node_modules/`, `.next/`, `build/`, `.dart_tool/`, `*.log`,
`kurtarilan/strings-*.txt` (5 dökümden 4'ü fazlalık),
`e.innerText)`, `e.innerText)})`, `proje-okulu-app/`, `reports/`, `research_notes/`

Detaylı gerekçe: `TEMIZLIK_RAPORU.md`

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
set search_path = public, pg_temp   -- ZORUNLU
as $$
begin
  if auth.uid() is null then
    raise exception 'Oturum bulunamadı';
  end if;
  ...
end;
$$;

revoke execute on function public.ornek_fonksiyon(uuid) from public, anon;
grant  execute on function public.ornek_fonksiyon(uuid) to authenticated;
```
- `SECURITY DEFINER` **her zaman** `set search_path` ile birlikte
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
