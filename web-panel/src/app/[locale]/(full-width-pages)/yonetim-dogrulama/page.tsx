import YonetimMfaForm from "@/components/auth/YonetimMfaForm";
import BrandMark from "@/components/common/BrandMark";
import { redirect } from "@/i18n/navigation";
import { mfaDurumuCoz, sunucuAalOku, YONETIM_MFA_ZORUNLU } from "@/lib/auth/mfa";
import { guvenliYonlendirme } from "@/lib/auth/yonlendirme";
import { DEMO_MODE } from "@/lib/demo-mode";
import { createClient } from "@/utils/supabase/server";
import { Metadata } from "next";
import { getTranslations, setRequestLocale } from "next-intl/server";

// Yönetim iki adımlı doğrulama sayfası (GÖR-106). Yönetim alanının (/yonetim/*) dışında durur ki
// yönetim layout'undaki MFA kapısı buraya yönlendirirken döngü oluşmasın. Oturum ve rol burada
// sunucuda yeniden doğrulanır; mod (kod doğrulama / faktör kaydı) sunucudaki AAL'den çıkar.
export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "meta.yonetimDogrulama" });
  return { title: t("title"), description: t("description"), robots: { index: false, follow: false } };
}

export default async function YonetimDogrulama({
  params,
  searchParams,
}: {
  params: Promise<{ locale: string }>;
  searchParams: Promise<{ next?: string | string[] }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const { next } = await searchParams;
  // Dönüş yolu yalnız yönetim alanında olabilir (açık yönlendirme engellenir).
  const hedef = guvenliYonlendirme(typeof next === "string" ? next : null, ["/yonetim"], "/yonetim");

  if (DEMO_MODE) redirect({ href: "/yonetim", locale });

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect({ href: "/yonetim-giris", locale });

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user!.id)
    .maybeSingle();
  if (profile?.role !== "admin" && profile?.role !== "ogretmen") {
    redirect({ href: "/yonetim-giris", locale });
  }

  // Bu sayfada faktörsüz hesaba kayıt ekranı her zaman gösterilir (zorunlu değilse atlanabilir).
  const aal = await sunucuAalOku(supabase);
  const durum = aal ? mfaDurumuCoz(aal, true) : null;
  if (durum === "tamam") redirect({ href: hedef, locale });

  // Kod doğrulamada kullanılacak faktör: doğrulanmış ilk TOTP faktörü (listFactors Auth
  // sunucusundaki kullanıcı kaydından okur).
  let faktorId: string | null = null;
  if (durum === "dogrula") {
    const { data: faktorler } = await supabase.auth.mfa.listFactors();
    faktorId = faktorler?.totp[0]?.id ?? null;
  }

  return (
    <main className="flex min-h-dvh items-center justify-center bg-[#f3f5f8] px-4 py-12 text-navy sm:px-8">
      <div className="w-full max-w-[440px]">
        <div className="mb-8">
          <BrandMark />
        </div>
        <YonetimMfaForm
          mod={durum === "dogrula" && faktorId ? "dogrula" : durum === "kayit" ? "kayit" : "hata"}
          faktorId={faktorId}
          zorunlu={YONETIM_MFA_ZORUNLU}
          hedef={hedef}
          eposta={user!.email ?? ""}
        />
      </div>
    </main>
  );
}
