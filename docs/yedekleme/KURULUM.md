# Günlük veritabanı yedeği — kurulum ve geri yükleme

> Durum: **kod hazır, canlıda çalıştırılmadı.** Aşağıdaki adımlar hesap sahibi tarafından yapılmalı.
> Akış: GitHub Actions (her gün 03:30 TR) → `pg_dump` → AES-256 şifreleme → Google Drive (`hupo-yedek-*.dump.enc`), 30 gün saklanır.
> Dosyalar: `.github/workflows/yedek.yml`, `tools/yedek/drive-yukle.mjs`.

## 1. Neden bu tasarım
- Yedek Supabase ve Vercel'den bağımsız bir yerde (Google Drive) durur. Saldırı veya silme olursa geri dönüş mümkün.
- Dosya şifreli olduğu için Drive hesabı ele geçse bile veri okunmaz. **Parolayı kaybederseniz yedek açılamaz.** Parolayı şifre yöneticinize de kaydedin.
- Vercel Hobby planı `pg_dump` çalıştıramaz; GitHub Actions bunu yapar.

## 2. Google tarafı (bir kez)
1. Google Cloud Console → yeni proje → **Google Drive API**'yi etkinleştir.
2. **OAuth consent screen**: kullanıcı türü *External*. **Uygulamayı "In production" durumuna geçir.** Testing modunda yenileme jetonu 7 günde bir sona erer ve yedekler sessizce durur.
3. **OAuth client ID** → türü *Desktop app* → Client ID ve Client Secret'ı kaydet.
4. Drive'da `hupo-yedekler` adında bir klasör oluştur; URL'deki klasör kimliğini (`/folders/<ID>`) kaydet.
5. Yenileme jetonu almak için (bir kez, yerelde): OAuth Playground (`developers.google.com/oauthplayground`) → ayarlardan kendi Client ID/Secret'ını gir → kapsam: `https://www.googleapis.com/auth/drive.file` → *Authorize* → *Exchange authorization code for tokens* → **Refresh token**'ı kopyala.
   - Kapsam `drive.file`'dır: uygulama yalnızca kendi oluşturduğu dosyalara erişir; Drive'ınızın geri kalanını görmez.

## 3. Supabase bağlantısı
- Dashboard → Connect → **Session pooler** bağlantı dizesini kopyala (GitHub Actions IPv4 kullanır; "Direct connection" IPv6 gerektirebilir).
- Parolayı yerine koy. Bu bağlantı tam veritabanı okuma yetkisi taşır: yalnızca GitHub Secrets'ta tut.

## 4. GitHub Secrets (Settings → Secrets and variables → Actions)
| Secret | Açıklama |
|---|---|
| `SUPABASE_DB_URL` | Session pooler bağlantı dizesi (parola dahil) |
| `BACKUP_PASSPHRASE` | Yedek şifresi. Uzun ve rastgele (en az 32 karakter). Yedek de kopyası da bunu gerektirir |
| `GDRIVE_CLIENT_ID` | OAuth Client ID |
| `GDRIVE_CLIENT_SECRET` | OAuth Client Secret |
| `GDRIVE_REFRESH_TOKEN` | Adım 2.5'te alınan yenileme jetonu |
| `GDRIVE_FOLDER_ID` | `hupo-yedekler` klasör kimliği |

## 5. İlk çalıştırma ve kontrol
1. Actions → **Veritabanı yedeği** → *Run workflow* (elle tetikleme).
2. Yeşil olmalı. Log'da `Yüklendi: hupo-yedek-....dump.enc` satırını ara.
3. Drive'da `hupo-yedekler` klasöründe dosyayı gör.
4. Geri yükleme provası yapmadan yedeğe güvenmeyin (aşağıda).

## 6. Geri yükleme (felaket anı)
Asla doğrudan üretim veritabanına yükleme. Önce yeni bir Supabase projesi (veya yerel Postgres) aç.

```bash
# 1. Drive'dan indir, sonra çöz
openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 \
  -in hupo-yedek-YYYYMMDD-HHMMSS.dump.enc -out yedek.dump -pass env:BACKUP_PASSPHRASE

# 2. Hedef veritabanına geri yükle (HEDEF_URL: yeni proje bağlantısı)
pg_restore --no-owner --no-privileges --clean --if-exists -d "HEDEF_URL" yedek.dump
```

Geri yükleme sonrası kontrol: `supabase/tests/kurtarma_tests.sql` veya `kelime_evreni_tests.sql` çalıştırılabilir. Storage dosyaları (görseller/PDF'ler) bu yedekte **yoktur**; ayrı yedeklenmeli.

Bu provayı en az ayda bir yapmanız önerilir; ilk provayı ilk yedekten sonra yapın.

## 7. Bilinen sınırlar
- Storage (dosya) yedeği yok; yalnızca veritabanı.
- GitHub Actions zamanlaması birkaç dakika gecikebilir.
- Başarısız yedekte Actions kırmızı olur; GitHub bildirimlerini açık tutun. Otomatik SMS/e-posta uyarısı yoktur.
- Yedek saklama 30 gün. Bu süre `YEDEK_SAKLAMA_GUN` ile değişir (minimum 7).
