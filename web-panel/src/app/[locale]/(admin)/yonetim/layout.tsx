import { redirect } from "@/i18n/navigation";
import { DEMO_MODE } from "@/lib/demo-mode";
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
  // Uretimde bu bayrak her zaman false olur (bkz. src/lib/demo-mode.ts).
  if (DEMO_MODE) return <>{children}</>;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: profile } = user
    ? await supabase.from("profiles").select("role").eq("id", user.id).maybeSingle()
    : { data: null };

  // Öğretmen yalnızca /yonetim/siniflar'ı kullanır; diğer sayfalardan istemci tarafındaki
  // RoleGuard onu oraya döndürür, veri erişimi ise veritabanında rol kontrolüyle kapalıdır.
  if (profile?.role !== "admin" && profile?.role !== "ogretmen") {
    redirect({ href: "/veli-paneli", locale });
  }

  return <>{children}</>;
}
