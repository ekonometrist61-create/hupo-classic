import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";
import { defineConfig, globalIgnores } from "eslint/config";

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  {
    // React 19 / eslint-plugin-react-hooks v6 ile gelen yeni kural.
    // Bu panel TailAdmin şablonundan türetilmiş; tema, kenar çubuğu ve takvim
    // modalı bileşenleri "prop/dış durumu effect içinde state'e yansıt"
    // desenini kullanıyor. Bu bilinçli bir teknik borç olarak HATA değil
    // UYARI seviyesine çekildi; ilgili bileşenler elden geçirilirken
    // (useSyncExternalStore / lazy initializer ile) gerçek refaktör yapılacak.
    rules: {
      "react-hooks/set-state-in-effect": "warn",
    },
  },
  // Override default ignores of eslint-config-next.
  globalIgnores([
    // Default ignores of eslint-config-next:
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
  ]),
]);

export default eslintConfig;
