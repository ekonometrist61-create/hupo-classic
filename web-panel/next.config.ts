import type { NextConfig } from "next";
import createNextIntlPlugin from "next-intl/plugin";

import { STUDENT_APP_URL } from "./src/lib/app-url";

const withNextIntl = createNextIntlPlugin("./src/i18n/request.ts");

// ── Güvenlik başlıkları ─────────────────────────────────────────────────────
// Çocuk verisi işleyen bir platform olduğu için sıkı CSP zorunlu.
// 'unsafe-inline' kaldırmak için Tailwind/Next.js nonce entegrasyonu gerekir;
// şimdilik inline script'lere izin veriliyor, ileriki sürümde nonce'a geçilecek.
// Geliştirme (HMR) dışında 'unsafe-eval' açılmaz (TASKS.md §11.3).
const isDev = process.env.NODE_ENV === "development";

const securityHeaders = [
  {
    key: "X-Frame-Options",
    value: "DENY",
  },
  {
    key: "X-Content-Type-Options",
    value: "nosniff",
  },
  {
    key: "Referrer-Policy",
    value: "strict-origin-when-cross-origin",
  },
  {
    key: "Permissions-Policy",
    // Çocuk uygulaması: kamera, konum, mikrofon, ilgi çekici içerik YOK
    value: "camera=(), microphone=(), geolocation=(), interest-cohort=()",
  },
  {
    key: "X-DNS-Prefetch-Control",
    value: "on",
  },
  {
    key: "Strict-Transport-Security",
    value: "max-age=63072000; includeSubDomains; preload",
  },
  {
    key: "Content-Security-Policy",
    value: [
      "default-src 'self'",
      // Supabase API + Realtime
      "connect-src 'self' https://*.supabase.co wss://*.supabase.co",
      // Next.js hot reload için 'unsafe-eval' yalnızca geliştirmede açık
      `script-src 'self' 'unsafe-inline'${isDev ? " 'unsafe-eval'" : ""}`,
      "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
      "font-src 'self' https://fonts.gstatic.com",
      // Uygulama logoları ve kullanıcı avatarları (ileriki sürümde kısıtlanacak)
      "img-src 'self' data: blob: https://*.supabase.co",
      "frame-ancestors 'none'",
      "object-src 'none'",
      "base-uri 'self'",
      "form-action 'self'",
    ].join("; "),
  },
];

const nextConfig: NextConfig = {
  // Windows'ta node_modules taraması çok yavaş olduğu için dışarıda bırakılır.
  ...(process.platform === "win32"
    ? { outputFileTracingExcludes: { "*": ["node_modules/**"] } }
    : {}),
  // Turbopack için SVG → React component dönüşümü
  turbopack: {
    rules: {
      "*.svg": {
        loaders: ["@svgr/webpack"],
        as: "*.js",
      },
    },
  },
  webpack(config) {
    config.module.rules.push({
      test: /\.svg$/,
      use: ["@svgr/webpack"],
    });
    return config;
  },
  images: {
    localPatterns: [
      {
        pathname: "/**",
      },
    ],
  },
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: securityHeaders,
      },
    ];
  },
  // Öğrenci uygulaması artık app.hupolingo.com üzerinde (Flutter web).
  async redirects() {
    return [
      {
        source: "/ogrenci",
        destination: STUDENT_APP_URL,
        permanent: true,
      },
      {
        source: "/ogrenci/:path*",
        destination: STUDENT_APP_URL,
        permanent: true,
      },
    ];
  },
};

export default withNextIntl(nextConfig);
