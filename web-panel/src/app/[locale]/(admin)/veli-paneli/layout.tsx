import { redirect } from "@/i18n/navigation";
import VeliPaneliKabuk from "@/components/veli-paneli/VeliPaneliKabuk";
import { DEMO_MODE } from "@/lib/demo-mode";
import { createClient } from "@/utils/supabase/server";

// Veli paneli sunucu rol kapısı (W10). Veli olmayan oturum rolüne uygun ana sayfaya gider:
// yönetici /yonetim, öğretmen /yonetim/siniflar, öğrenci /ogrenci.
// Oturum yoksa mevcut davranış korunur (sayfa "yalnızca veli" mesajını gösterir).
// Asıl yetki veritabanındadır (RPC'lerde auth.uid() ve rol kontrolü); bu kapı yalnızca yanlış kişiyi yönlendirir.
export default async function VeliPaneliLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;

  // Yerel geliştirmede oturumsuz görüntüleme için (üretimde bayrak false).
  if (!DEMO_MODE) {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (user) {
      const { data: profile } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", user.id)
        .maybeSingle();

      if (profile?.role === "admin") redirect({ href: "/yonetim", locale });
      if (profile?.role === "ogretmen") redirect({ href: "/yonetim/siniflar", locale });
      if (profile?.role === "ogrenci") redirect({ href: "/ogrenci", locale });
    }
  }

  return <VeliPaneliKabuk>{children}</VeliPaneliKabuk>;
}
