# Supabase Migration Kullanımı

Bu projede migration'lar **Supabase SQL migration**'larıdır (`supabase/migrations/*.sql`).
Prisma/Drizzle gibi ikinci bir migration sistemi **yoktur**; tek yol budur.

Migration'lar **uzak Supabase projesine** Supabase CLI ile uygulanır. Docker, yerel
PostgreSQL veya yerel Supabase sunucusu **gerekmez** — `db push` doğrudan uzak
veritabanına bağlanır.

CLI, kök `package.json`'a sabit sürümle (`supabase@2.119.0`) devDependency olarak
eklendi; `npx supabase ...` ya da aşağıdaki `npm run db:*` script'leriyle çalıştırılır.

---

## Hedef proje

- **Proje ref:** `ccozfrpnvyrnktpffkwo`
- **Yerel ad (config.toml):** `proje-okulu-app`
- Bu, projenin **tek canlı** Supabase projesidir (web-panel `.env` içindeki
  `...supabase.co` URL'i ile aynı). Başka/çelişen bir proje yoktur.

> Uygulamadan önce bağlı projeyi **her zaman** `npm run db:status` ile doğrula;
> çıktının en üstünde hangi projeye bağlı olduğun görünür.

---

## İlk bağlantı (bir kez)

Bu iki adım **senin** güvenli girişini gerektirir (token/parola sohbete yazılmaz):

```bash
# 1) Giriş — tarayıcıda açılır ya da erişim token'ı ister
npx supabase login

# 2) Doğru projeye bağla — veritabanı parolanı ister
npx supabase link --project-ref ccozfrpnvyrnktpffkwo
```

Alternatif (parolasız istemci): `SUPABASE_ACCESS_TOKEN` ortam değişkenini ayarlarsan
`login` adımını atlayabilirsin; token'ı dosyaya/Git'e yazma.

Bağlantı bilgisi `supabase/.temp/` altına yazılır ve `.gitignore` ile Git dışında tutulur.

---

## Günlük kullanım

```bash
npm run db:status    # Yerel ve uzak migration geçmişini karşılaştır
npm run db:preview   # Uygulanacak migration'ları listele (dry-run; SQL testi DEĞİL)
npm run db:deploy    # Bekleyen migration'ları bağlı uzak projeye uygula (db push)
```

Tipik sıra: **status → preview → deploy**.

- `db:preview` yalnızca *hangi dosyaların* uygulanacağını gösterir; SQL'in doğru
  çalışacağını kanıtlamaz.
- `db:deploy` yalnızca uzak `schema_migrations` geçmişinde **bulunmayan** dosyaları
  uygular.

---

## Hedef proje kontrolü

Yanlış projeye uygulama riskine karşı:

1. `npm run db:status` çıktısındaki bağlı proje ref'inin `ccozfrpnvyrnktpffkwo`
   olduğunu gör.
2. Emin değilsen `npx supabase projects list` ile hesabındaki projeleri listele.

---

## Sık görülen hatalar

- **`Access token not provided`** → `npx supabase login` yapılmamış.
- **`project not linked` / ref yok** → `npx supabase link --project-ref ccozfrpnvyrnktpffkwo`.
- **Migration geçmişi uyuşmazlığı** (uzakta SQL Editor'den elle uygulanmış değişiklikler
  olabilir): Körlemesine `migration repair`, `db push --include-all` veya **uzakta
  `db reset`** çalıştırma. Önce `db:status` ile farkı incele, gerçek şema ile dosyaların
  uyumunu doğrula, sonra gerekçesiyle düzelt. Uzak veritabanı sıfırlanmaz.
- **Parola hatası** → `link` sırasında girilen veritabanı parolası yanlış; tekrar
  `npx supabase link ...` ile düzelt.

---

## Dikkat

- `supabase db reset` **yalnızca yereldir** ve bu projede kullanılmaz (uzakta asla).
- Veri kaybı riski taşıyan migration'lar (tablo/sütun silme, tip değişimi, politika
  zayıflatma) önce incelenir ve açıkça onaylanır.
- Migration geçmişi doğrulaması ile gerçek şema doğrulaması ayrı şeylerdir; ikincisi
  salt okunur sorgularla yapılır.
