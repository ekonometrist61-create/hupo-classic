# VS Code Eklentileri — Proje Okulu

`.vscode/extensions.json` içinde şu an yalnızca AI eklentisi var.
Bu proje için gerekenler:

## Kesin gerekli

| Eklenti | Neden |
|---|---|
| `dart-code.dart-code` | Flutter geliştirmenin temeli — tanım, tamamlama, hata ayıklama |
| `alexisvt.flutter-snippets` | `stlessWidget`, `stfulApp` gibi şablonlar |
| `usernamehw.errorlens` | Derleme hatalarını satır içinde gösterir |
| `esbenp.prettier-vscode` | Kod biçimlendirme |
| `dbaeumer.vscode-eslint` | Web paneli (Next.js) lint kontrolü |

## Faydalı

| Eklenti | Neden |
|---|---|
| `bradlc.vscode-tailwindcss` | Tailwind sınıfları için otomatik tamamlama + renk önizleme |
| `mtxr.sqltools` + `mtxr.sqltools-driver-pg` | Supabase migration'larını SQL olarak incelemek |
| `github.vscode-github-copilot` / `chatgpt.chatgpt` | AI kod desteği |
| `esbenp.prettier-vscode` | (üstte) |
| `christian-kohler.path-intellisense` | Dosya yolları için otomatik tamamlama |
| `eamodio.gitlens` | Git geçmişini satır bazında görmek |
| `vscodevim.vim` *(isteğe bağlı)* | Vim tuşları |

## Ayarlanması önerilen

`web-panel/.vscode/settings.json` içinde:

- **Tailwind**: `css.validate: false` — Tailwind v4 `@apply` kurallarını
  yanlış işaretlemesin
- **ESLint**: `eslint.validate: ["javascript", "typescript", "typescriptreact"]`

## Zaten kurulu

`.vscode/extensions.json` dosyasında bir AI eklentisi tanımlı — onu silme,
diğerlerini ekle.

---

## Not: Bu oturumda kurulan komut satırı araçları

Bunlar VS Code eklentisi değil, PATH'e kalıcı eklendi. **VS Code'u yeniden
başlatınca tanınır:**

| Araç | Konum |
|---|---|
| git 2.50.1 | `C:\Users\cengi\.local\git\extracted\cmd` |
| npm 12.1.0 | `C:\Users\cengi\.local\npm\pkg\package\bin` |
| Flutter 3.47.5 | `C:\Users\cengi\Downloads\flutter-sdk\flutter\bin` |
| Android Studio | **yok** — kurulu değil |
| Java (JDK) | **yok** — kurulu değil |
| Android SDK | **yok** — kurulu değil |

> Mobil uygulamayı **web'de** çalıştırmak için Flutter yeterli (Chrome var).
> **Android APK** üretmek için Android Studio + JDK + Android SDK gerekir.
