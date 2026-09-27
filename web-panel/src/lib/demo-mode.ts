/**
 * Demo modu bayrağı — TEK DOĞRULUK KAYNAĞI.
 *
 * Yerel geliştirmede paneli Supabase oturumu/verisi olmadan görmek için kullanılır
 * (`NEXT_PUBLIC_DEMO_MODE=1`, bkz. `.env.local`). Bu değişken başka hiçbir yerde
 * doğrudan okunmaz; tüm tüketiciler (proxy, yönetim layout'u, AdminDashboard)
 * bu sabiti kullanır.
 *
 * GÜVENLİK (AGENTS.md §5): Üretim derlemesinde (`NODE_ENV === "production"`)
 * ortam değişkeni yanlışlıkla tanımlı olsa bile demo modu ASLA etkinleşmez.
 * Böylece bir yapılandırma hatası oturum/rol kontrolünü atlayamaz.
 */
export const DEMO_MODE =
  process.env.NODE_ENV !== "production" &&
  process.env.NEXT_PUBLIC_DEMO_MODE === "1";
