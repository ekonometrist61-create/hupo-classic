import type { MetadataRoute } from "next";

// Telefonda "Ana ekrana ekle" ile yonetim panelini uygulama gibi acmak icin.
// Tarayici ayni adresi acar; giris zorunlulugu proxy.ts'te kalir.
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Hupo Yönetim",
    short_name: "Hupo",
    description: "Hupolingo yönetim paneli",
    start_url: "/yonetim",
    scope: "/",
    display: "standalone",
    orientation: "portrait",
    background_color: "#147D8A",
    theme_color: "#147D8A",
    lang: "tr",
    icons: [
      { src: "/pwa/icon-192.png", sizes: "192x192", type: "image/png" },
      { src: "/pwa/icon-512.png", sizes: "512x512", type: "image/png" },
    ],
  };
}
