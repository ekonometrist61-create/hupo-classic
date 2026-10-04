# DENETİM NOTU — Mimari İnceleme Bulguları (Claude için)

> Oluşturma: 04 Ekim 2026
> Kaynak: Bir ajanın yaptığı mimari inceleme. Bu not, **Claude'un bulguları
> bağımsız olarak doğrulaması** için yazıldı. Her madde bir kanıt/komut içerir.
> Kural: doğrulanmadan hiçbir şeyi "silinmiş/temizlenmiş" sayma (AGENTS.md §8).
> İlgili dosyalar: `MASTER_BRIEF.md`, `AGENTS.md`, `TASKS.md`,
> `TEMIZLIK_RAPORU.md`, `PHASE0_DURUM_RAPORU.md`.

---

## 0. Claude'a görev tanımı

Bu nottaki her bulguyu **kendin doğrula**. Şunları yap:

1. Her maddeyi belirtilen komut/dosya ile teyit et veya çürüt.
2. Doğrulanan/yanlışlanan durumu bu dosyanın sonundaki "Doğrulama Sonucu"
   bölümüne işaretle.
3. Kritik maddeleri (özellikle §1) düzeltme önerisiyle birlikte raporla.
4. Emin olmadığın yeri `// TODO(denetim):` ile işaretle, sessizce uydurma.

---

## 1. 🔴 KRİTİK — Gerçek API anahtarları git'e commit edilmiş

**İddia:** `.claude/settings.json` ve `.claude/mcp.json` **takip ediliyor** ve
içlerinde gerçek (düz metin) API anahtarları var. `.mcp.json` ve
`.claude/settings.local.json` ise `.gitignore`'da (doğru), ama bu iki dosya unutulmuş.

**Doğrulama komutları:**
```powershell
cd "c:\Users\cengi\OneDrive\Desktop\çıkarıldı\Fırsat Bulucu-Ürün Geliştirme"
git ls-files | Select-String -Pattern "\.claude|\.mcp"
git show HEAD:.claude/settings.json
git show HEAD:.claude/mcp.json
git log --oneline -- .claude/settings.json .claude/mcp.json
git remote -v
```

**Beklenen kanıt:** `git ls-files` çıktısında `.claude/mcp.json` ve
`.claude/settings.json` görünür; `git show` anahtarları basar; `git log` en az bir
commit gösterir (iddia edilen: `9b4ee9c`); `git remote -v` boş (henüz sızmamış).

**Anahtar türleri (iddia):** `STITCH_API_KEY`, `GEMINI_API_KEY`,
`X-Goog-Api-Key` — hepsi `AQ.Ab8RN6...` ile başlıyor.

**Önerilen düzeltme (onay gerektirir, uygulamadan önce kullanıcıya sor):**
1. Kök `.gitignore`'a ekle: `.claude/settings.json`, `.claude/mcp.json`
2. `git rm --cached .claude/settings.json .claude/mcp.json`
3. Geçmiş temizliği: `git filter-repo` veya BFG (uzak depo yokken en kolay an)
4. Anahtarları Google Cloud / AI Studio'da **iptal edip yenile** (rotasyon şart)

> Not: AGENTS.md §5 kural 1 ihlali. Ayrıca `MASTER_BRIEF.md` §4 yalnızca Supabase
> anahtarından söz ediyor; `.claude` sızıntısı hiçbir belgede yazılı değil.

---

## 2. 🟠 Kök dizin dağınıklığı — çift/eski dokümanlar

**İddia:** Kökte birbiriyle çelişen birden çok doküman var; hangisinin geçerli
olduğu belirsiz.

| Dosya | İddia edilen sorun |
|---|---|
| `TASKS.md` | ✅ Güncel (03 Ekim 2026), tek doğruluk kaynağı olmalı |
| `Task.md` | ❌ Eski ad; kendisi "ikisi de var, TASKS esas" diyor (satır 51) |
| `DURUM.md` | ❌ 27 Eylül oturum notu; "Proje Okulu", "12 migration" diyor (eskimiş) |
| `PHASE0_DURUM_RAPORU.md` | ⚠️ Tarihli rapor (28 Eylül), arşive taşınabilir |
| `cm.txt` | ❌ Commit mesajı metin dosyası olarak duruyor |
| `KARAKTER_KOLEKSIYON_PLANI.md` | ✅ Güncel plan (03 Ekim) |

**Doğrulama:**
```powershell
Get-ChildItem -Force | Select-Object Name, Length
Get-Content DURUM.md -TotalCount 20
Get-Content cm.txt
```

**Not:** `PHASE0_DURUM_RAPORU.md` §ARCHITECTURAL RISKS #5 bu dağınıklığı zaten
tespit etmiş ama temizlik uygulanmamış. Çelişki var.

---

## 3. 🟠 Kökte takip edilen görsel/debug artıkları

**İddia:** Şu dosyalar git'te takipli ama ürünle ilgisiz:
`kontrol-1.png`, `kontrol-2.png`, `kontrol-3.png`, `şema-gecici.png`,
`web-panel/banner.png`.

**Doğrulama:**
```powershell
git ls-files | Select-String -Pattern "\.png"
```

**Beklenen:** Yukarıdaki PNG'ler takipli çıkar. `web-panel/banner.png` şablon
artığı; `kontrol-*.png` ekran görüntüsü; `şema-gecici.png` geçici şema görseli.

---

## 4. 🟠 `web-panel/src/app/[locale]/(admin)/page.tsx` — ürünle ilgisiz demo

**İddia:** Kök rota (`/`) e-ticaret demosu gösteriyor; fonksiyon adı hâlâ
`Ecommerce`; içeriği `EcommerceMetrics`, `MonthlySalesChart`, `RecentOrders`,
`DemographicCard` vb. Gerçek panel `/yonetim`'de.

**Doğrulama:**
```powershell
Get-Content "web-panel\src\app\[locale]\(admin)\page.tsx"
```

**Beklenen:** Dosya 41 satır, `export default function Ecommerce()` içeriyor,
`@/components/ecommerce/*` import ediyor.

**Ek kanıt:** `git grep -l "ecommerce" -- "web-panel/src/**/*.tsx"` çıktısı bu
dosyayı ve `components/ecommerce/*` altındaki tüm bileşenleri listeler.

---

## 5. 🟡 Ürüne dahil edilmemiş TailAdmin şablon kalıntıları

**İddia:** 16 adet ürün dışı demo rotası ve şablon bileşeni var.

**Doğrulama:**
```powershell
Get-ChildItem -Recurse "web-panel\src\app\[locale]\(admin)\(others-pages)"
Get-ChildItem -Recurse "web-panel\src\app\[locale]\(admin)\(ui-elements)"
```

**Beklenen klasörler:** `(others-pages)/{blank,calendar,profile,(chart),(forms),(tables)}`,
`(ui-elements)/{alerts,avatars,badge,buttons,images,modals,videos}`.

**Ek maddeler:**
- `web-panel/AGENTS.md` → **TailAdmin şablonunun kendi dokümanı** ("AGENTS.md —
  TailAdmin Pro"), kök `AGENTS.md` ile çelişiyor. Doğrula:
  `Get-Content web-panel\AGENTS.md -TotalCount 5`
- `web-panel/src/layout/AppSidebar.tsx` — ürün menüleri doğru ama şablon
  demolarına giden menü var mı kontrol et.

---

## 6. 🟡 `(student)/ogrenci/` rotası kullanılmıyor olabilir

**İddia:** `web-panel/src/app/[locale]/(student)/ogrenci/page.tsx` gerçek bir
öğrenci arayüzü ama `AppSidebar`'da linki yok ve `proxy.ts`'te yönlendirmesi yok;
ölü rota olabilir.

**Doğrulama:**
```powershell
git grep -rn "ogrenci/page\|(student)" -- "web-panel/src/**/*.tsx" "web-panel/src/**/*.ts"
git grep -n "ogrenci" -- "web-panel/src/layout/AppSidebar.tsx"
git grep -n "ogrenci" -- "web-panel/src/proxy.ts"
```

**Beklenen:** İlk komut boş dönebilir (rota hiçbir yerden referans edilmiyor).
Karar: sil veya bilinçli olduğunu belgele.

---

## 7. 🟡 `mobile-app/telefonda-ac/` — ürün dışı yardımcı

**İddia:** `sunucu.dart` (32 satır, Dart statik web sunucusu) + `telefonda-ac.bat`
+ `OKU-BENI.md`. `lib/` dışında bir `.dart` dosyası; `flutter analyze`
kapsamına girip gereksiz hata üretebilir. `tools/` altına taşınmalı.

**Doğrulama:**
```powershell
Get-ChildItem -Recurse mobile-app\telefonda-ac
Get-Content mobile-app\telefonda-ac\sunucu.dart -TotalCount 5
```

---

## 8. 🟡 Tek seferlik `tools/` scriptleri

**İddia:** Şunlar tek kullanımlık, silinebilir: `unzip.ps1`, `unzip.js`,
`unzip-flutter.ps1`, `resume-download.js`, `fix-mix-keys.js`, `check-routes.js`,
`read-flutter.mjs`. Değerli olanlar: `serve.ps1`, `serve-mobile.ps1`,
`sql-sozdizim-denetimi.mjs`, `dart-statik-denetim.mjs`.

**Doğrulama:**
```powershell
Get-ChildItem tools | Select-Object Name, Length
```

> Not: `TEMIZLIK_RAPORU.md` §2.3 aynı listeyi zaten önermiş, uygulanmamış.

---

## 9. ✅ Doğru yapılanlar (bozmaya gerek yok — yine de teyit et)

- `.gitignore` kapsamı: `kurtarilan/`, `node_modules/`, `.next/`, `.env*`,
  `key.properties`, `*.jks`, `.mcp.json` — doğru dışlanmış.
  `Get-Content .gitignore`
- `kurtarilan/`, `Silinecekler/`, `proje-okulu-app/`, `reports/`,
  `research_notes/`, `e.innerText)` dosyaları **temizlenmiş**.
  `Get-ChildItem -Force` ile kökte bunların olmadığını doğrula.
- İç içe `web-panel/.git` ve `mobile-app/.git` depoları kaldırılmış.
  `Test-Path web-panel\.git` → `False` olmalı.
- `mobile-app/lib/config/env.dart` yalnızca publishable key içeriyor (doğru).
- `web-panel/src/lib/demo-mode.ts` üretimde zorunlu kapalı (güvenli tasarım).
- Karakter koleksiyon sistemi temiz katmanlı:
  `models/character_models.dart` → `providers/app_providers.dart` →
  `widgets/character/*` → `screens/collection_screen.dart`.

---

## 10. ⏳ Bilinen açık konular (mimari değil, veri)

- `supabase/` şema sapması: `question_quality_config` tablosu ve
  `questions.inceleme_gerekli` kolonu diskte var, canlıyla uyuşmuyor →
  `db reset` bloke. Kaynak: `supabase/KURTARMA_DURUMU.md`.
- 22 Dart dosyası kurtarma durumu → `TASKS.md` §2 (tamamlandı işaretli).
- Proje Türkçe/OneDrive yolunda → `flutter analyze` çöküyor (PHASE0 risk #1).

---

## 11. Öncelik sırası (iddia)

| # | İş | Önem |
|---|---|---|
| 1 | API anahtarlarını git'ten çıkar + rotasyon (§1) | 🔴 Kritik |
| 2 | Kök dağınıklığı: `Task.md`, `cm.txt`, `kontrol-*.png`, `şema-gecici.png`, `DURUM.md` (§2, §3) | 🟠 Yüksek |
| 3 | `(admin)/page.tsx` e-ticaret demosu (§4) | 🟠 Yüksek |
| 4 | Şablon rotaları + `web-panel/AGENTS.md` + `banner.png` (§5) | 🟡 Orta |
| 5 | `(student)/ogrenci/` kararı, `telefonda-ac/`, `tools/` (§6, §7, §8) | 🟡 Orta |

---

## Doğrulama Sonucu (Claude dolduracak)

> Her satırı doğruladıktan sonra işaretle: ✅ doğrulandı · ❌ yanlış · ⚠️ kısmi

| § | Bulgu | Durum | Not |
|---|---|---|---|
| 1 | API anahtarları git'te | | |
| 2 | Kök doküman dağınıklığı | | |
| 3 | Takipli PNG artıkları | | |
| 4 | `(admin)/page.tsx` e-ticaret demosu | | |
| 5 | 16 şablon rotası + `web-panel/AGENTS.md` | | |
| 6 | `(student)/ogrenci/` ölü rota | | |
| 7 | `mobile-app/telefonda-ac/` | | |
| 8 | Tek seferlik `tools/` scriptleri | | |
| 9 | Doğru yapılanlar | | |