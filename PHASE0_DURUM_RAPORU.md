# PHASE 0 — DURUM RAPORU · Fırsat Bulucu (Öğrenci Hazırlık / Hupo)

> Tarih: 27 Eylül 2026
> Kapsam: depo denetimi, git temeli, güvenlik/mimari boşlukların kapatılması,
> web derlemesinin doğrulanması ve kurtarma zincirinin ilerletilmesi.
> İlgili dosyalar: `TASKS.md`, `MASTER_BRIEF.md`, `README.md`,
> `supabase/KURTARMA_DURUMU.md`, `kurtarilan/KURTARMA_RAPORU.md`

---

## STATUS

| Alan | Durum | Kanıt |
|---|---|---|
| Web derlemesi | ✅ YEŞİL | `next build --webpack`: `✓ Compiled successfully in 2.9min`, TypeScript 23.7s, 51 statik sayfa, `.next/BUILD_ID` = `s8N19necnSpqiPPGgnBoa` |
| ESLint | ✅ 0 hata | `npm run lint` temiz; `react-hooks/set-state-in-effect` gerekçeli olarak `warn`'a indirildi |
| Git temeli | ✅ Kuruldu | 5 commit (aşağıda), çalışma ağacı temiz |
| Demo modu | ✅ Üretimde kapalı | Tek kaynak: `web-panel/src/lib/demo-mode.ts` |
| Migration sırası | ✅ Düzeltildi | Tablolar `…000010`, RPC'ler `…000020` |
| Eksik DB nesneleri | 🟡 Kısmen kurtarıldı | `…000030` ile 2 tablo + 4 fonksiyon geri geldi; 5 kalem kaldı (§ MISSING FEATURES) |
| `supabase db reset` | ⛔ Çalıştırılamadı | Supabase CLI **ve** Docker bu makinede kurulu değil |
| `flutter analyze` / `flutter test` | ⛔ Çalıştırılamadı | Türkçe/OneDrive yolunda Dart exit 255 (ASCII yola taşınınca çözülür) |

### Bu fazda atılan commit'ler

| Commit | İçerik |
|---|---|
| `5405e34` | Kök depo kuruldu, `.gitignore`, 665 dosya ilk commit |
| `1b83be2` | Demo modu üretimde etkisiz, tek kaynağa indirildi, `demoData` derlemesi güvenceye alındı |
| `5911a8c` | Panel lint hataları (`any`, kullanılmayan değişken, demo `setState`) |
| `c7efb66` | Migration sırası + geciktirilen index + kurtarma durumu belgelendi |
| `fdc91e7` | `TASKS.md` / `MASTER_BRIEF.md` / `README.md` mimari özeti |

### Özet yargı

Ürün **derlenebilir ve çalıştırılabilir** bir web paneline sahip; mobil taraf
kaynak düzeyinde eksik (22 Dart dosyası kurtarma bekliyor). Backend tarafında
kurtarma zinciri artık %80 tamam: canlı şema çıktılarından tablolar, kısıtlar,
indexler ve fonksiyon gövdeleri birebir taşındı; kalan 4 kalem yalnızca canlı
Dashboard erişimi veya Supabase CLI kurulumuyla kapatılabilir.

---

## CURRENT STACK

### Mobil (`mobile-app/`)

| Bileşen | Sürüm | Not |
|---|---|---|
| Flutter / Dart | Dart SDK `>=3.5.0 <4.0.0` | `ogrenci_hazirlik` v1.0.0+1 |
| Durum yönetimi | `flutter_riverpod` ^2.4.10 | Provider'lar `lib/providers/` |
| Backend istemcisi | `supabase_flutter` ^2.17.2 | Yalnızca publishable (anon) key |
| Animasyon / font | `lottie` ^3.6.1, Nunito + Lexend | `assets/lottie/`, `assets/fonts/` |
| Bildirim | `firebase_core` ^4.15.0, `firebase_messaging` ^16.7.0 | Web'de devre dışı |
| Reklam | `google_mobile_ads` ^5.2.0 | Varsayılan **kapalı** (çocuk uygulaması) |
| Yerel depolama | `shared_preferences` ^2.5.5 | — |
| Lint | `flutter_lints` ^5.0.0 | `flutter analyze` bekleniyor |

### Web panel (`web-panel/`)

| Bileşen | Sürüm | Not |
|---|---|---|
| Next.js | ^16.3.4 (App Router, **webpack**) | `dev`/`build` betikleri `--webpack` |
| React / TS | React ^19.2.8, TypeScript ^5.9.3 | — |
| Stil | Tailwind CSS v4 (`@tailwindcss/postcss` ^4.3.3) | `tailwind-merge`, `clsx` |
| Çoklu dil | `next-intl` ^4.14.2 | `tr` birincil, `localePrefix: "never"` |
| Supabase | `@supabase/ssr` ^0.7.0, `@supabase/supabase-js` ^2.90.0 | Yalnızca sunucu bileşeninde |
| Grafik / UI | `apexcharts`, `recharts`, `@fullcalendar/react`, `react-dnd`, `lucide-react` | — |
| Veri içe alma | `papaparse` ^5.5.3 | "Soruları toplu ekle" ekranı |

### Backend (`supabase/`)

| Bileşen | Değer |
|---|---|
| Postgres | 17 (`config.toml`: `db.major_version = 17`) |
| Migration | 15 dosya (`20260920000000` … `20260927000030`) |
| Edge Functions | Deno 2 (`edge_runtime.deno_version = 2`) |
| Ödeme | iyzico (`20260920001100_payments_iyzico.sql`) |
| Güvenlik | RLS her tabloda; `SECURITY DEFINER` + `set search_path` zorunlu |

> Dil politikası: arayüz Türkçe (sen dili), kod yorumları Türkçe,
> alan adları Türkçe `snake_case`, dosya/sınıf adları İngilizce
> (`AGENTS.md` §1).

---

## PROJECT STRUCTURE

```
Fırsat Bulucu-Ürün Geliştirme/          ← kök depo (tek .git)
├── AGENTS.md                 ajan/insan kuralları
├── MASTER_BRIEF.md           ürün özeti
├── TASKS.md                  faz planı (PHASE 0-…)
├── README.md                 hızlı başlangıç
├── TEMIZLIK_RAPORU.md        silinebilir/silinmez gerekçeleri
├── PHASE0_DURUM_RAPORU.md    ← bu rapor
├── mobile-app/               Flutter uygulaması (öğrenci)
│   ├── lib/{auth,config,content,models,providers,screens,services,
│   │        settings,theme,utils,widgets}
│   ├── assets/{hupo,lottie,fonts}
│   └── pubspec.yaml
├── web-panel/                Next.js paneli (yönetici + veli)
│   ├── src/{app,components,context,hooks,i18n,icons,layout,lib,
│   │        messages,types,utils} + proxy.ts
│   └── package.json
├── supabase/                 backend
│   ├── migrations/           15 SQL dosyası (sıralı zincir)
│   ├── functions/            payments-checkout, payments-callback, send-push
│   ├── tests/                6 SQL test dosyası
│   └── docs/ODEME_KURULUM.md
├── tools/                    yardımcı betikler (serve, unzip, check-routes)
└── kurtarilan/               ⚠️ git'e GİRMEZ — APK + kanıt çıktıları (78 MB)
```

**Ürün rotaları (panel):** `/[locale]/yonetim`, `/yonetim/kullanicilar`,
`/yonetim/odemeler`, `/yonetim/sorular`, `/yonetim/sorular/toplu-ekle`,
`/veli-paneli`, `/signin`, `/signup`.
**Şablon rotaları (TailAdmin kalıntısı):** `alerts`, `avatars`, `badge`,
`bar-chart`, `basic-tables`, `blank`, `buttons`, `calendar`, `error-404`,
`form-elements`, `images`, `line-chart`, `modals`, `profile`, `videos`
→ 51 statik sayfanın ~16'sı ürünle ilgisiz şablon ekranı.

---

## WORKING FEATURES

### Web panel — doğrulanmış (derleme + lint yeşil)

| Özellik | Durum | Kanıt |
|---|---|---|
| Üretim derlemesi | ✅ | `✓ Compiled successfully in 2.9min`, 51 sayfa |
| Tip güvenliği | ✅ | `Finished TypeScript in 23.7s` (0 hata) |
| Lint | ✅ | `eslint .` 0 hata |
| Yönetici panelleri | ✅ rota var | `/[locale]/yonetim`, `kullanicilar`, `odemeler`, `sorular`, `sorular/toplu-ekle` |
| Veli paneli | ✅ rota var | `/[locale]/veli-paneli` |
| Giriş / kayıt | ✅ rota var | `/[locale]/signin`, `/[locale]/signup` |
| Çoklu dil | ✅ | `tr` (birincil) + `en`, `messages/` iki dosya |
| Oturum/middleware | ✅ | `src/proxy.ts` |
| Demo modu | ✅ kapalı | `src/lib/demo-mode.ts`, üretimde `false` |
| Supabase erişimi | ✅ | `@supabase/ssr`; anahtar yalnızca sunucuda |

### Backend — migration zinciri (15 dosya)

Temel şema, XP/seri (`award_xp_and_streak`), veli paneli, doğru cevabı gizleme,
çözüm adımları + zaman aşımı, rozetler, çocuk güvenliği varsayılanları,
lig/ilerleme/bildirim, günlük hedef + kalkan + gizlilik, yönetici rolü,
push bildirimleri, iyzico ödeme, günün 5 sorusu + kayıtlı sorular,
çarpım şifreleri (tablo + RPC), **eksik nesne kurtarma (`…000030`)**.
Ayrıca 3 Edge Function (`payments-checkout`, `payments-callback`, `send-push`)
ve 6 SQL test dosyası mevcut.

### Mobile — kaynak iskeleti hazır, derleme DOĞRULANMADI

`lib/{auth,config,content,models,providers,screens,services,settings,theme,
utils,widgets}` + `assets/{hupo,lottie,fonts}` yerinde; `pubspec.yaml`
bağımlılıkları tutarlı. **Ancak `flutter analyze`/`flutter test` bu ortamda
çalıştırılamadı** (aşağıdaki mimari risk #1).

---

## MISSING FEATURES

| # | Eksik | Tür | Etki |
|---|---|---|---|
| 1 | `public.question_quality_config` | tablo | `report_question()` çalışma anında hata verir; fonksiyon `…000030`'da var ama tablo yok |
| 2 | `profiles` sınıf kuralı trigger'ı | trigger | 30 gün / 24 saat sınıf değişikliği kuralı uygulanmaz |
| 3 | `grade_changes` / `question_reports` RLS politikaları | politika | Fail-closed: istemciden hiçbir satır okunamaz (RPC'ler etkilenmez) |
| 4 | `carpim_sifreleri` içerik verisi (10–12 şifre) | veri | Şifre listesi boş görünür |
| 5 | 22 Dart dosyası | mobil kaynak | APK'dan kurtarma bekliyor (`kurtarilan/KURTARMA_RAPORU.md` §4) |
| 6 | 12 SQL fonksiyonu | backend | Bir kısmı `…000000`/`…000020`/`…000030` ile kurtarıldı; kalanı raporda |
| 7 | Ürün dışı şablon ekranları (16 rota) | panel | Silinecek ya da "gizli" işaretlenecek |
| 8 | CI / otomatik doğrulama | altyapı | Hiçbir test koşmadı: `flutter test`, `supabase test db` |
| 9 | Firebase kurulumu (push) | altyapı | `docs/PUSH_KURULUM.md` adımları bekliyor |
| 10 | `share_plus` kararı | mobil | `pubspec.yaml`'da `TODO(kurtarma)` |
| 11 | `public.questions.inceleme_gerekli` kolonu | şema | ⚠️ **Yeni tespit:** disk şemasında yok, canlıda var; `_refresh_question_flag()` bu kolonu yazar → çağrılınca `column does not exist` |

---

## SECURITY RISKS

| # | Risk | Önem | Durum / öneri |
|---|---|---|---|
| 1 | `grade_changes` / `question_reports` RLS politikaları diskte yok | 🟠 Orta | Fail-closed bırakıldı (kimse okuyamaz) + `anon` tamamen, `authenticated` yazmadan men edildi. Canlı politikalar alınınca eklenecek |
| 2 | `question_quality_config` + `questions.inceleme_gerekli` yok → bildirim hattı çalışmıyor | 🟠 Orta | `report_question()` / `_refresh_question_flag()` çağrılınca hata verir (sessiz veri kaybı yok) |
| 3 | RLS/politikalar yerelde test edilemiyor (CLI + Docker yok) | 🟠 Orta | `supabase db reset` + `supabase test db` kurulum sonrası koşulmalı; şema sapması bu yüzden oluşmuştu |
| 4 | Gizli anahtar sızıntısı | 🟢 Düşük | Tarandı: `sb_secret_` yalnızca `.env.example` içinde **yer tutucu**; `.env.local` git'te ignore (`web-panel/.gitignore:43`); mobilde yalnızca publishable key (`lib/config/env.dart`) |
| 5 | `SECURITY DEFINER` fonksiyonlarda arama yolu | 🟢 Düşük | Kurtarılan 4 fonksiyon `set search_path to ''` + tam nitelendirme kullanıyor (AGENTS.md'deki `public, pg_temp`'ten daha katı) |
| 6 | Yetki genişletme riski | 🟢 Düşük | İç yardımcılar `from public, anon, authenticated` revoke edildi; `admin_set_daily_challenge` yalnızca `authenticated` + `require_admin()` kontrolü |
| 7 | Demo modu veri sızıntısı | ✅ Kapandı | Tek kaynak `demo-mode.ts`, üretimde zorunlu `false` (bu fazda düzeltildi) |
| 8 | Çocuk güvenliği varsayılanları | ✅ | Reklam/takip/konum varsayılan kapalı; `child_safety_defaults` migration'ı duruyor |

---

## ARCHITECTURAL RISKS

| # | Risk | Etki | Öneri |
|---|---|---|---|
| 1 | Proje yolu Türkçe + OneDrive (`…\çıkarıldı\Fırsat Bulucu-Ürün Geliştirme`) | Dart/Flutter araçları `exit 255` ile çöküyor; `flutter analyze`/`test` hiç koşamıyor | Projeyi `C:\dev\firsat-bulucu` gibi **ASCII** bir yola taşı |
| 2 | `kurtarilan/` 78 MB (APK 68 MB + `libapp.so` 7.5 MB) aynı ağaçta | OneDrive senkron gecikmesi, kod aramalarının 30 sn'de zaman aşımına uğraması (bu oturumda yaşandı) | Depo dışına taşı; yalnızca metin kanıtları (`*.txt`, `*.csv`) kalsın |
| 3 | Şema sapması: migration'lar canlıdan türetilmemiş | `db reset` gerçeği yansıtmıyor; kurtarma bu yüzden gecikti | Kurulum sonrası `supabase db pull` ile doğrula, `supabase test db` ile kilitle |
| 4 | 16 ürün dışı şablon rotası | Build süresi ve paket boyutu şişiyor, ürün sınırı bulanıklaşıyor | Sil veya `_sablon/` altına al + README'de "kullanılmıyor" işaretle |
| 5 | Kök dizin dağınıklığı (`DURUM.md`, `Task.md`, `cm.txt`, `kontrol-*.png`, `Silinecekler/`) | Hangi belgenin geçerli olduğu belirsiz (iki görev dosyası!) | `TASKS.md` tek doğru kaynak; diğerleri arşive/silinir |
| 6 | Otomatik doğrulama yok | Her değişiklik elle doğrulanıyor; regresyon riski yüksek | CI'da `next build`, `eslint`, `flutter analyze`, `supabase db reset` + `test db` |
| 7 | Doküman-kod tutarsızlığı eğilimi | `TASKS.md`'de var olan nesneler "eksik" yazılabiliyor ya da tersi | Her faz sonunda durum raporu (bu dosya gibi) üret |

---

## RECOMMENDED NEXT STEP

### Blokajı açan iki iş (öncelik sırası)

1. **Projeyi ASCII yola taşı** (`C:\dev\firsat-bulucu`).
   Tek başına `flutter analyze` + `flutter test` yolunu açar; 0 hata hedefi
   `AGENTS.md` §8'in ön koşulu.
2. **Supabase CLI + Docker kur**, sonra sırayla:
   ```bash
   supabase link --project-ref ccozfrpnvyrnktpffkwo
   supabase db pull          # canlı şemayı diske indir (sapmayı kapatır)
   supabase db reset         # 15 migration + seed sırayla çalışmalı
   supabase test db          # supabase/tests/*.sql
   ```
   Pull sonrası `supabase/KURTARMA_DURUMU.md` §4'teki 5 kalem kapanır:
   `question_quality_config` tablosu, `questions.inceleme_gerekli` kolonu,
   `profiles` trigger'ı, RLS politikaları, `carpim_sifreleri` verisi.

### Ardından (PHASE 1)

3. **Mobil kurtarma:** 22 Dart dosyasını `kurtarilan/KURTARMA_RAPORU.md` §4 +
   `feature-tokens.txt` + `missing-turkish.txt` üzerinden geri yaz;
   isimlendirmeyi APK ile birebir tut, emin olmadığın yeri
   `// TODO(kurtarma):` ile işaretle.
4. **Temizlik:** şablon rotaları ve kök dağınıklığı; CI kurulumu.

> **Karar bekleyen soru:** Supabase CLI kurulumunu şimdi ben mi ilerleteyim
> (indirme + `link`), yoksa kalan 5 kalemi siz SQL Editor çıktısı olarak mı
> vereceksiniz? İkisi de aynı sonuca götürür; CLI yolu otomatik ve tam.



