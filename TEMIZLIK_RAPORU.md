# TEMİZLİK RAPORU — Tek Temiz Proje

> Analiz tarihi: 27 Eylül 2026
> Ölçüm: `Fırsat Bulucu-Ürün Geliştirme` ana dizini

---

## Özet

| Tür | Boyut | Karar |
|---|---|---|
| Sadece silinmeli | **1 122 MB** | 🗑️ Sil |
| Koşullu (taşımalı veya silmeli) | 16,8 MB | ⚠️ Karar verilmeli |
| **Korunmalı** | **~90 MB** | ✅ Elde tut |

Ana dizinde toplam **1 190 MB** var; **%94'ü çöp**. Temizlik sonrası
~90 MB kalır ve 707 → ~90 dosya düşer.

---

## 1. Hemen sil — 1 122 MB

### 1.1 `web-panel/node_modules/` — 555,7 MB, 39 789 dosya
`npm install` ile 1 dakikada yeniden üretilir. Sürüm kontrolünde değil, diskte tutulmaz.

### 1.2 `web-panel/.next/` — 504,2 MB, 556 dosya
Next.js derleme çıktısı. `npm run build` ile yeniden üretilir.
> Not: DURUM.md'ye göre bu klasörden 210 dosya / 12 878 satır TypeScript
> **kurtarıldı** ve `src/` altına yazıldı. Yani artık gerekli değil — silinmesi güvenli.

### 1.3 `kurtarilan/` içindeki 5 gereksiz döküm
Beş farklı string-döküm denemesi yapıldı, dördü başarısız oldu. Boyut ~62 MB.

| Dosya | Boyut | Durum |
|---|---|---|
| `ogrenci_hazirlik-base.apk` | 66,7 MB | **KEEP** (orijinal kanıt) |
| `libapp.so` | 7,4 MB | **KEEP** |
| `turkish-utf16.txt` | 25 KB | **KEEP** (153 metnin kaynağı) |
| `missing-turkish.txt` | 8 KB | **KEEP** |
| `feature-tokens.txt` | 4 KB | **KEEP** |
| `tokens.txt` | 3,9 MB | **KEEP** (sınıf/RPC araması için) |
| `strings-ascii.txt` | 8,4 MB | 🗑️ sil — `tokens.txt` bunu kapsıyor |
| `strings-clean.txt` | 6,3 MB | 🗑️ sil — ayraçlar bozuktu |
| `strings-final.txt` | 3,6 MB | 🗑️ sil — Türkçe karakterler kayıp |
| `strings-final2.txt` | 3,6 MB | 🗑️ sil — aynı sorun |
| `strings-final3.txt` | 1,2 MB | 🗑️ sil — aynı sorun |
| `strings-utf8.txt` | 6,3 MB | 🗑️ sil — aynı sorun |
| `strings-utf16.txt` | 30 KB | 🗑️ sil — `turkish-utf16.txt` türevi |

> Not: `strings-ascii.txt` silinmeden **önce** `tokens.txt` üretildi ve doğrulandı.
> `tokens.txt` = ascii dökümün `?` ayraçlarına bölünmüş hali, aynı bilgiyi içerir.

### 1.4 `reports/` + `research_notes/` — 0,5 MB, 13 dosya
**Bu projeye ait değil.** İthalat fırsat ürünü için ayrı bir iş fikri fizibilite
raporları. DURUM.md bölüm 1 bunu açıkça belirtiyor:
> "Bu projeyle **ilgisi yok**. Ayrı bir iş fikari. Karıştırma."

Ayrı klasöre taşı (örn. `C:\Users\cengi\OneDrive\Desktop\firsat-fizibilite\`)
veya sil.

### 1.5 `web-panel/.idea/` — 5 dosya
JetBrains IDE ayarları. VS Code kullanıldığı (.vscode/ var) gereksiz.

---

## 2. Koşullu — 16,8 MB

### 2.1 `proje-okulu-app/` — 23 dosya
Bir **eski Supabase kovası**. İçinde:
- `.git/` — iç içe boş klasör, bozuk repo
- `supabase/migrations/20260920123532_initial_schema.sql` (12 683 bayt)
- `supabase/config.toml` (15 629 bayt)

Ana `supabase/migrations/20260920000000_initial_schema.sql` **20 713 bayt** ve
tüm sonraki migration'lar (11 dosya) burada. Bu klasörün eski şeması artık
kullanılmıyor.

**Öneri:**
- `config.toml` → `supabase/config.toml` olarak **taşı** (CLI için gerekli)
- geri kalanı sil

### 2.2 `web-panel/.git/` — 16,7 MB, 203 dosya
Panel kendi git deposunu içeriyor. Ana dizinde de git yok, yani bu depo
kullanılmıyor. Silinmeden önce emin ol:

```bash
cd web-panel
git log --oneline -5
git status
```

Eğer "hiç commit edilmedi" veya "uzak depo tanımlı değil" ise → sil.
Ama bu **senin kararın**, ben kendiliğinden silmiyorum.

### 2.3 `tools/` — 9 dosya
| Dosya | Durum |
|---|---|
| `unzip.ps1`, `unzip.js`, `unzip-flutter.ps1`, `resume-download.js`, `read-flutter.mjs` | Flutter SDK indirme/çıkarma — tek seferlik, silinebilir |
| `serve.ps1`, `serve-mobile.ps1` | Geliştirme sunucusu — faydalı, **tut** |
| `check-routes.js`, `fix-mix-keys.js` | Panel için tek seferlik düzeltme scriptleri — silinebilir |

---

## 3. Yanlış adla oluşmuş dosyalar

Kök dizinde iki dosya var:
```
e.innerText)      27 Eylül 16:25
e.innerText)})    27 Eylül 16:24
```

Muhtemelen terminalden `>` yönlendirmesiyle yanlışlıkla oluşmuşlar
(`grep ... > e.innerText)` gibi). İçerikleri de kırpılmış cümle parçaları.
**🗑️ Sil.**

---

## 4. Korunmalı

| Klasör | Boyut | Neden |
|---|---|---|
| `mobile-app/lib/` | 0,6 MB | Uygulama kaynağı |
| `mobile-app/assets/` | 4,9 MB | 23 hupo PNG + 4 lottie + 2 font |
| `mobile-app/android/`, `ios/` | — | Platform yapılandırması |
| `mobile-app/pubspec.yaml`, `analysis_options.yaml` | — | Derleme yapılandırması |
| `web-panel/src/` | 0,8 MB | Panel kaynağı (247 dosya) |
| `web-panel/public/` | 7,6 MB | Statik varlıklar |
| `web-panel/package.json`, `tsconfig.json`, `next.config.ts` | — | Derleme yapılandırması |
| `supabase/` | 0,3 MB | Backend: 12 migration, 4 Edge Function, 6 test |
| `kurtarilan/` (seçili dosyalar) | 78 MB | Kurtarma kanıtı |
| `.vscode/` | — | Editör ayarları |
| `DURUM.md`, `README.md` | — | Oturum notları |

> `mobile-app/.dart_tool/`, `mobile-app/build/`, `*.log` dosyaları da var
> (80,6 MB'ın bir kısmı). Bunlar da silinebilir ama küçük, öncelik değil.

---

## 5. Uygulama komutu (Windows PowerShell)

Önce: yedek al.
```powershell
$src = "C:\Users\cengi\OneDrive\Desktop\çıkarıldı\Fırsat Bulucu-Ürün Geliştirme"
$dst = "D:\Yedek\FirsatBulucu-20260927"
robocopy $src $dst /MIR /R:1 /W:1
```

Sonra sırayla sil:
```powershell
# 1. Üretilmiş dosyalar (~1 GB)
Remove-Item "$src\web-panel\node_modules" -Recurse -Force
Remove-Item "$src\web-panel\.next" -Recurse -Force
Remove-Item "$src\web-panel\.idea" -Recurse -Force

# 2. Başka projeye ait klasörler (taşımayı unutma!)
Move-Item "$src\reports" "C:\Users\cengi\OneDrive\Desktop\firsat-fizibilite\reports"
Move-Item "$src\research_notes" "C:\Users\cengi\OneDrive\Desktop\firsat-fizibilite\research_notes"

# 3. Eski Supabase kovası (config.toml'u taşı)
New-Item -ItemType Directory -Path "$src\supabase" -Force | Out-Null
Move-Item "$src\proje-okulu-app\supabase\config.toml" "$src\supabase\config.toml" -Force
Remove-Item "$src\proje-okulu-app" -Recurse -Force

# 4. Fazlalık dökümler
cd "$src\kurtarilan"
Remove-Item strings-ascii.txt,strings-clean.txt,strings-final.txt,`
              strings-final2.txt,strings-final3.txt,strings-utf8.txt,`
              strings-utf16.txt -Force

# 5. Yanlış adlı dosyalar
Remove-Item "$src\e.innerText)","$src\e.innerText)})" -Force
```

Sonra doğrula:
```powershell
cd "$src\web-panel"
npm install          # ~1 dk
npm run build
```

---

## 6. `kurtarilan/` için öneri

84 MB binary **git'e girmemeli**. Kök dizinde `.gitignore` yok — ekle:
```gitignore
kurtarilan/
node_modules/
.next/
.dart_tool/
build/
*.log
```
APK ve `libapp.so` yerelde dursun yeter; GitHub'a gerekmez.
Gerekirse yedek bir harici diske kopyala.

---

## 7. Öneriler (isteğe bağlı, kod değişikliği)

1. **`.gitignore` kökte yok** — sürüm kontrolü başlatılacaksa önce ekle.
2. **`git` kurulu değil** — `git --version` hata veriyor. Kurulum gerekli mi?
3. **İki proje kopyası** — `Desktop\Fırsat Bulucu-Ürün Geliştirme` bu klasörün
   birebir aynısı (59/59 dosya doğrulandı). İkisi de OneDrive'da → 2 GB yer kaplıyor.
   Birini silmek mantıklı.
4. **Flutter SDK yolu** — `mobile-app/android/local.properties` içinde
   `flutter.sdk` yolu var. Flutter kurulu mu, kontrol et.
