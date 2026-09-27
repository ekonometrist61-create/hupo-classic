import { redirect } from "@/i18n/navigation";
import { createClient } from "@/utils/supabase/server";

// Yönetim bölümü yalnızca admin rolüne açıktır. (Asıl yetki veritabanında da zorunludur:
// tüm admin fonksiyonları rolü kendileri doğrular; bu kontrol yalnızca yanlış kişiyi yönlendirir.)
export default async function YonetimLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;

  // Yerel gelistirmede paneli oturum olmadan gormek icin.
  if (process.env.NEXT_PUBLIC_DEMO_MODE === "1") return <>{children}</>;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: profile } = user
    ? await supabase.from("profiles").select("role").eq("id", user.id).maybeSingle()
    : { data: null };

  if (profile?.role !== "admin") {
    redirect({ href: "/veli-paneli", locale });
  }

  return <>{children}</>;
}
