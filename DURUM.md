# Proje Durumu — 27 Eylül 2026

> Bu dosya, oturumun sonunda nerede olduğumuzu anlatır. Yeni bir sohbete
> başlarsan önce bunu oku.

---

## 1. Proje ne?

**Proje Okulu** — Türkçe eğitim uygulaması. Üç parçadan oluşuyor:

| Klasör | Ne | Durum |
|---|---|---|
| `mobile-app/` | Flutter uygulama (öğrenci) | ✅ Çalışıyor |
| `web-panel/` | Next.js yönetim + veli paneli | ✅ Çalışıyor |
| `supabase/` | Veritabanı (12 migration, Edge Functions) | ✅ Hazır |

> **Not:** `reports/` ve `research_notes/` içindeki fizibilite raporları
> (ithalat fırsat ürünü) bu projeyle **ilgisi yok**. Ayrı bir iş fikri.
> Karıştırma.

---

## 2. Yapılanlar (bu oturumda)

### 2.1 Kurtarma — kaybolan yönetim paneli geri geldi

`web-panel` içindeki kaynak dosyalar silinmişti, derlenmiş `.next/` vardı.
Next.js sourcemap'leri `sourcesContent` ile kaynak kodu taşıdığı için oradan
geri çıkarıldı.

- **210 dosya, 12.878 satır** TypeScript/TSX kurtarıldı
- 58 SVG ikon derlenmiş JS'ten gerçek SVG'ye çevrildi
- Silinen yapılandırma dosyaları (`package.json`, `tsconfig.json`,
  `next.config.ts`, `next-env.d.ts`) yeniden yazıldı

### 2.2 Mükerrer dosya temizliği — tek proje haline getirildi

`web-panel`, bir **TailAdmin free-nextjs-admin-dashboard** kopyasıydı.
Kurtarma çıktısıyla upstream arasında karşılaştırma yapıldı
(`web-panel/tools/compare-template.js` — sonra silindi):

| Çakışma | Çözüm |
|---|---|
| `postcss.config.mjs` | Silindi — şablon `postcss.config.js` içeriyor |
| `src/icons/index.ts` | Silindi — şablon `index.tsx` kullanıyor |
| `icons/index.tsx` | `TrFlagIcon` eklendi (şablonda yoktu) |

**Artık tek doğruluk kaynağı upstream şablon + bizim eklediklerimiz.**

### 2.3 Eksik katmanlar yeniden yazıldı

- **`src/messages/`** — 4 çift, 240+ anahtar:
  `tr.json` / `en.json`, `veli-paneli.*`, `yonetim-panel.*`, `yonetim-sorular.*`
  Yönetim ve veli metinleri **tam Türkçe**. Demo sayfalarının 500+ çevirisi
  İngilizce fallback'li.
- **`i18n/routing.ts`** — `tr` birincil locale
- **`i18n/request.ts`** — 3 parçalı mesaj birleştirme
- **`proxy.ts`** — next-intl + Supabase oturum yenileme, `/yonetim` ve
  `/veli-paneli`'ye giriş zorunluluğu
- **2 tip dosyası** — bileşenlerin gerçek alan adları okunarak
  (`DashboardData.ozet/haftalik/ders_basari`, `Paged.satirlar`, `Plan.kod/ad` vb.)
- **`lib/types.ts`** — `SupportedStorage` arayüzü
- **`package.json`** — Supabase, papaparse, recharts, lucide eklendi

### 2.4 Çalışma sırasında bulunan ve düzeltilen hatalar

| # | Hata | Düzeltme |
|---|---|---|
| 1 | `next` paketi `.d.ts` dosyaları olmadan kurulmuş (300 tip hatası) | Yeniden kurulum |
| 2 | `next-env.d.ts` yok | Oluşturuldu |
| 3 | 30 SVG'de BOM vardı → `svgo` "Non-whitespace before first tag" | Temizlendi |
| 4 | `angle-left/right.svg` boş, `flag-tr.svg` yanlış uzantıyla JSX'ti | Yeniden yazıldı |
| 5 | `createNextIntlPlugin()` parametresiz → next-intl mesaj dosyasını bulamıyor, `en`'e düşüyor | Yol açıkça verildi |
| 6 | `NextIntlClientProvider`'a locale geçilmemiş | `locale={locale}` eklendi |
| 7 | **Giriş ekranı TailAdmin'in çalışmayan demosuydu** (Google/X butonları, İngilizce metin, `<form>` yok) | Gerçek Supabase Auth formu |
| 8 | `QuestionMix` `approved/pending/rejected` bekliyordu, dosyalarda Türkçe karşılıkları vardı | Anahtarlar eklendi |
| 9 | `layout.tsx`'te `localePrefix: "never"` ile `params.locale` gelmiyor | Varsayılan dile düşen yol yazıldı |

### 2.5 Ortam kurulumu

Bu makinede **hiçbiri yoktu**, kuruldu:

- **git** 2.50.1 → `C:\Users\cengi\.local\git`
- **npm** 12.1.0 → `C:\Users\cengi\.local\npm\pkg\package`
- **Flutter** 3.47.5 → `C:\Users\cengi\Downloads\flutter-sdk`

Hepsi kalıcı PATH'e eklendi. **VS Code'u yeniden başlatınca PATH geçerli olacak.**

---

## 3. Şu an çalışanlar

### Web paneli

```powershell
cd web-panel
npm run dev
```

→ http://localhost:3000/yonetim

> **Turbopack bu projede takılıyor** (hem `build` hem `dev` compile aşamasında).
> Bu yüzden `package.json` script'lerine `--webpack` bayrağı yazıldı.
> `npm run dev` ve `npm run build` elle parametre istemiyor.

### Mobil uygulama

```powershell
C:\Users\cengi\flutterwork\serve.bat
```

→ http://localhost:8080

> ⚠️ **Neden başka bir klasör?** Flutter, OneDrive içindeki Türkçe karakterli
> yola (`çıkarıldı`, `Fırsat Bulucu-Ürün Geliştirme`) **yazamıyor** —
> `build/flutter_assets` silinemiyor. Bu yüzden `mobile-app` kopyası
> `C:\Users\cengi\flutterwork\mobile-app` altında sunuluyor.
>
> **Android/iOS derlemesi yapacaksan projeyi ASCII karakterli bir yola taşı.**

---

## 4. Doğrulama sonuçları

| Kontrol | Sonuç |
|---|---|
| `npm run build --webpack` | ✅ Compiled successfully in 95s, 23 rota |
| `tsc --noEmit` | ✅ 0 hata |
| `flutter analyze` | ✅ No issues found! |
| 6 web rotası | ✅ HTTP 200, Türkçe |
| Web konsol hatası | ✅ 0 |
| Mobil konsol hatası | ✅ 0 |

---

## 5. Commit durumu

**`web-panel`** — çalışma ağacı TEMİZ, 3 commit:

```
1d823e1  chore: turbopack yerine webpack'i varsayilan yap
6a4d231  fix: layout locale guvenligi ve QuestionMix ceviri anahtarlari
b83b27d  fix: Turkce locale, gercek giris formu ve yerel demo modu
a5d3e60  feat: yonetim paneli, veli paneli ve Turkce i18n katmani
4fba024  chore: make component titles clear   ← TailAdmin upstream
```

**`mobile-app`** — 157 değişiklik var, **commit edilmedi** (bunlar senin
değişikliklerin, benim yaptıklarım değil).

**`proje-okulu-app/`** — silinmedi ama **kullanma.** İkinci, eski bir şema
kopyası. Tek doğruluk kaynağı kökteki `supabase/`.

---

## 6. Kalan işler

### 🔴 Yüksek öncelik

1. **Veritabanı tiplerini teyit et.**
   `DashboardSummary`, `PaymentList`, `AdminQuestion`, `Plan` alan adlarını
   bileşenlerden türettim, `supabase/migrations/` ile karşılaştırmadım.
   Yanlışsa dashboard boş gelir.

2. **`.env.local` sürpriz yapabilir.**
   Supabase bilgileri mobil uygulamanın `lib/config/env.dart` dosyasından
   alındı. Doğruysa dokunma. Farklıysa düzelt.
   İçinde `NEXT_PUBLIC_DEMO_MODE=1` var — bu, paneli verisiz göstermek için.
   Gerçek veriyle çalışacaksan **sil**.

3. **Demo modunu temizle.**
   `NEXT_PUBLIC_DEMO_MODE=1` iken:
   - `src/proxy.ts` giriş kontrolünü atlar
   - `src/app/[locale]/(admin)/yonetim/layout.tsx` rol kontrolünü atlar
   - `src/components/yonetim/panel/demoData.ts` örnek veri yükler
     (bu dosya `.gitignore`'da, commit'te yok)

### 🟡 Orta öncelik

4. **TailAdmin demo kalıntıları** — silme/temizleme kararı verilmedi:
   - Sidebar'da menüler: `/ecommerce`, `/analytics`, `/calendar`, `/forms`,
     `/tables`, `/ui-elements`, `/profile`
   - Header'da şablon başlığı (**"Musharof"** yazıyor — kullanıcı adı gibi)
   - Giriş ekranında **"Back to dashboard"** bağlantısı

5. ~~**Turbopack'i tamamen kapat veya düzelt.**~~ **YAPILDI** — `--webpack`
   `package.json` script'lerine yazıldı (commit `1d823e1`). Artık
   `npm run dev` doğrudan çalışıyor.

6. **Kayıp dosya: `src/AuthAdminApi.ts`.** Sourcemap silinmişti (.next'i
   sildiğimde kayboldu), git geçmişinde de yok. Hiçbir yerde kullanılmıyor,
   yani şu an sorun değil — ama ne işe yaradığını bilmiyoruz.

### 🟢 Düşük öncelik

7. Mobil projeyi ASCII yola taşı (mağaza yayını için şart).
8. `mobile-app`'deki 157 değişikliği commit et.
9. `proje-okulu-app/` klasörünü sil veya arşivle.

---

## 7. Kurtarma sırasında silinen yardımcı betikler

Bu oturumda geçici olarak yazıp sonra sildiklerim (gerekirse yeniden
yazılabilir, işlevleri yorumlarda duruyordu):

`web-panel/tools/compare-template.js` · `collect-i18n-keys.js` ·
`validate-messages.js` · `diff-messages.js` · `sync-messages.js` ·
`fill-tr-messages.js` · `check-imports.js` · `convert-icons.js` ·
`restore-icons.js` · `fix-svg-bom.js` · `fix-encoding.ps1`

Kök `tools/` altında kalanlar (kalıcı):
- `check-routes.js` — geliştirme sunucusundaki rotaları tek tek kontrol eder
- `fix-mix-keys.js` — QuestionMix çeviri anahtarlarını ekler
- `read-flutter.mjs` — Flutter web uygulamasını tarayıcıda okur
- `serve.ps1` / `serve-mobile.ps1` — mobil sunucu betikleri
- `resume-download.js` — büyük dosya indirmeyi yarıda kesilse devam ettirir
- `unzip-flutter.ps1` — 1 GB+ ZIP açma (PowerShell'in Expand-Archive çöküyor)
