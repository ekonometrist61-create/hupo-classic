"use client";

import { createClient } from "@/utils/supabase/client";
import { useEffect, useSyncExternalStore } from "react";

export type AppRole = "veli" | "ogrenci" | "admin" | "ogretmen";

/** Giriş yapmış kullanıcının ortak bilgileri. Yetki kontrolü DEĞİL, yalnızca arayüz içindir:
 *  asıl yetki veritabanında (admin fonksiyonları ve RLS) uygulanır. */
export type OturumBilgisi = {
  /** Kullanıcı ve profil okuması tamamlandı mı. */
  hazir: boolean;
  kullaniciId: string | null;
  email: string | null;
  adSoyad: string | null;
  rol: AppRole | null;
};

const BOS: OturumBilgisi = { hazir: false, kullaniciId: null, email: null, adSoyad: null, rol: null };

// Kenar menü, üst çubuk, rol kapısı, komut paleti... hepsi aynı kaynağı paylaşır.
// Önceden her bileşen kendi getUser + profiles çiftini çalıştırıyordu; bir yönetim sayfası açılışında
// bu çift altı kez gidiyordu. Şimdi bilgi bellekte tek kez okunur ve oturum değişince sıfırlanır.
let durum: OturumBilgisi = BOS;
let yukleme: Promise<OturumBilgisi> | null = null;
let dinlemeBaslatildi = false;
const dinleyiciler = new Set<() => void>();
const sifirlamaDinleyicileri = new Set<() => void>();

function yayinla(yeni: OturumBilgisi) {
  durum = yeni;
  dinleyiciler.forEach((d) => d());
}

function abone(dinleyici: () => void) {
  dinleyiciler.add(dinleyici);
  return () => {
    dinleyiciler.delete(dinleyici);
  };
}

/** Oturum değişince (çıkış, başka kullanıcının girişi) önbelleğini temizlemek isteyen modüller için. */
export function oturumSifirlamaDinle(dinleyici: () => void): () => void {
  sifirlamaDinleyicileri.add(dinleyici);
  return () => {
    sifirlamaDinleyicileri.delete(dinleyici);
  };
}

function sifirla() {
  yukleme = null;
  sifirlamaDinleyicileri.forEach((d) => d());
  yayinla(BOS);
  // Bağlı bileşenler varsa bilgiyi yeniden okusun. Auth olayı içinde await etmek kilitlenmeye yol açabilir,
  // bu yüzden bir tur ertelenir.
  if (dinleyiciler.size > 0) {
    setTimeout(() => {
      void oturumuYukle();
    }, 0);
  }
}

function oturumDinleyicisiBaslat() {
  if (dinlemeBaslatildi || typeof window === "undefined") return;
  dinlemeBaslatildi = true;
  createClient().auth.onAuthStateChange((olay, oturum) => {
    if (olay === "SIGNED_OUT") {
      sifirla();
      return;
    }
    // Başka bir kullanıcı girdiyse (ya da bilgi "oturum yok" iken giriş yapıldıysa) önceki durum geçersizdir.
    // Sayfa ilk açılışındaki INITIAL/SIGNED_IN olayı aynı kullanıcıyı gösterdiğinden sıfırlamaz.
    if (olay === "SIGNED_IN") {
      const yeniKullanici = oturum?.user.id ?? null;
      const mevcut = durum.kullaniciId;
      if (mevcut === null ? durum.hazir : mevcut !== yeniKullanici) sifirla();
    }
  });
}

/** Kullanıcı ve profili bir kez okur; eş zamanlı çağrılar aynı isteği paylaşır. */
function oturumuYukle(): Promise<OturumBilgisi> {
  if (!yukleme) {
    oturumDinleyicisiBaslat();
    yukleme = (async () => {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        yayinla({ ...BOS, hazir: true });
        return durum;
      }
      const { data: profil, error } = await supabase
        .from("profiles")
        .select("role, full_name")
        .eq("id", user.id)
        .maybeSingle();
      yayinla({
        hazir: !error,
        kullaniciId: user.id,
        email: user.email ?? null,
        adSoyad: profil?.full_name ?? null,
        rol: (profil?.role as AppRole | undefined) ?? null,
      });
      // Geçici profil hatasında bir sonraki çağrı yeniden denesin.
      if (error) yukleme = null;
      return durum;
    })();
  }
  return yukleme;
}

const anlik = () => durum;
const sunucuAnlik = () => BOS;

/** Giriş yapmış kullanıcının oturum bilgisi (yüklenene kadar hazir false). Arayüz içindir. */
export function useOturumBilgisi(): OturumBilgisi {
  const oturum = useSyncExternalStore(abone, anlik, sunucuAnlik);
  useEffect(() => {
    if (!durum.hazir) void oturumuYukle();
  }, []);
  return oturum;
}

/** Giriş yapmış kullanıcının rolü (yüklenene kadar null). Yetki kontrolü DEĞİL, yalnızca arayüz içindir:
 *  asıl yetki veritabanında (admin fonksiyonları ve RLS) uygulanır.
 *  `sunucuRolu` verilirse (rol sunucuda zaten doğrulandıysa) ilk çizim istemci okumasını beklemez. */
export function useCurrentRole(sunucuRolu?: AppRole | null): AppRole | null {
  const oturum = useOturumBilgisi();
  useEffect(() => {
    if (sunucuRolu && durum.rol === null) yayinla({ ...durum, rol: sunucuRolu });
  }, [sunucuRolu]);
  return oturum.rol ?? sunucuRolu ?? null;
}

/** Hook dışında (olay işleyicisi, async akış) oturum bilgisini bekler. */
export function oturumuBekle(): Promise<OturumBilgisi> {
  return durum.hazir ? Promise.resolve(durum) : oturumuYukle();
}
