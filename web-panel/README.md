# Hupolingo — Yönetim ve Veli Paneli

Next.js, Tailwind CSS ve Supabase üzerine kurulu Hupolingo yönetim, veli ve öğrenci panelleri.

## Teknoloji

- Next.js (App Router; `package.json` içinde sürüm 16), TypeScript
- Tailwind CSS
- Supabase
- next-intl
- Recharts

## Geliştirme

```bash
npm install
npm run dev      # geliştirme sunucusu
npm run build    # üretim derlemesi
```

## Yapı

- `/yonetim` — yönetim (admin) paneli
- `/veli-paneli` — veli paneli
- `/(student)/ogrenci` — öğrenci alanı
- Landing sayfası — herkese açık tanıtım sayfası

## Ortam değişkenleri

`.env.example` dosyasını `.env.local` olarak kopyalayıp doldurun.

| Değişken | Açıklama |
| --- | --- |
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase proje adresi |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | Supabase herkese açık (anon/publishable) anahtar; eski adı `NEXT_PUBLIC_SUPABASE_ANON_KEY` |
| `NEXT_PUBLIC_DEMO_MODE` | Yalnızca yerel geliştirme için (`1`); Supabase oturumu olmadan örnek veri gösterir |

Gizli (secret) anahtarlar `NEXT_PUBLIC_` önekiyle tanımlanmaz.

## Dağıtım

Dağıtım Vercel üzerindedir. Ortam değişkenleri Vercel panelinde tutulur.
