# Proje Okulu

Türkçe eğitim uygulaması: öğrenci mobil uygulaması + veli/yönetici web paneli.

> **Yeni bir sohbete başlarsan önce [`DURUM.md`](DURUM.md) dosyasını oku.**
> Projenin nereye geldiği, neyin çalıştığı ve neyin kaldığı orada yazılı.

## Klasörler

| Klasör | Ne |
|---|---|
| `mobile-app/` | Flutter uygulaması (öğrenci) |
| `web-panel/` | Next.js yönetim paneli + veli paneli |
| `supabase/` | Veritabanı migration'ları ve Edge Functions |
| `tools/` | Yardımcı betikler (sunucu, kontrol, okuma) |
| `kurtarilan/` | Kurtarma kanıtı (APK, `libapp.so`, dökümler) — **git'e girmez** |
| `.vscode/` | Eklenti önerileri — [EKLENTILER.md](.vscode/EKLENTILER.md) |

> **Versiyon kontrolü:** Bu depo **tek kök git deposudur** (27 Eylül 2026'da
> kuruldu). İç içe eski depolar `Desktop\çıkarıldı\_firsat-git-arsiv-20260927\`
> altına arşivlendi. Sırlar ve kurtarma kanıtı kök `.gitignore` ile dışarıda tutulur.

> `proje-okulu-app/` eski bir şema kopyasıdır — **kullanma.**
> Tek doğruluk kaynağı kökteki `supabase/`.

## Hızlı başlangıç

### Web paneli

```powershell
cd web-panel
npm run dev
```

> Turbopack bu projede takılıyor; script'lerde `--webpack` bayrağı var,
> yani `npm run dev` doğrudan çalışıyor.

→ http://localhost:3000/yonetim

`.env.local` dosyası gerekli. Şablon: `.env.example`

### Mobil uygulama

```powershell
C:\Users\cengi\flutterwork\serve.bat
```

Sonra http://localhost:8080

> ⚠️ Flutter, OneDrive içindeki Türkçe karakterli yola yazamıyor.
> Bu yüzden `mobile-app` kopyası `C:\Users\cengi\flutterwork\mobile-app`
> altında sunuluyor. Android/iOS derlemesi için projeyi ASCII yola taşı.

## Ortam

git, npm ve Flutter bu makinede kuruldu ve PATH'e eklendi. Ayrıntı ve
eksikler (Android Studio, JDK, Android SDK) için [`.vscode/EKLENTILER.md`](.vscode/EKLENTILER.md).
