import { redirect } from "@/i18n/navigation";
import { RolKapisi } from "@/layout/RoleGuard";
import { DEMO_MODE } from "@/lib/demo-mode";
import { mfaDurumuCoz, sunucuAalOku, YONETIM_DOGRULAMA, YONETIM_MFA_ZORUNLU } from "@/lib/auth/mfa";
import { createClient } from "@/utils/supabase/server";

// Yönetim bölümü admin ve öğretmen rollerine açıktır. (Asıl yetki veritabanında da zorunludur:
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
  // RolKapisi, rol çözülene kadar içeriği gizler (istemci tarafı flaşını önler).
  if (DEMO_MODE) return <RolKapisi>{children}</RolKapisi>;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: profile } = user
    ? await supabase.from("profiles").select("role").eq("id", user.id).maybeSingle()
    : { data: null };

  // Öğretmen yalnızca /yonetim/siniflar'ı kullanır; diğer sayfalardan RolKapisi onu oraya yönlendirir,
  // veri erişimi ise veritabanında rol kontrolüyle kapalıdır.
  if (profile?.role !== "admin" && profile?.role !== "ogretmen") {
    redirect({ href: "/yonetim-giris", locale });
  }

  // İki adımlı doğrulama kapısı (GÖR-106). Doğrulanmış faktörü olan hesap her zaman kod girer;
  // faktörsüz hesap yalnız zorunluluk bayrağı açıkken kayıt ekranına gönderilir.
  // AAL okunamazsa kapı kapalı davranır (doğrulama sayfası hatayı kullanıcıya gösterir).
  const aal = await sunucuAalOku(supabase);
  if (!aal || mfaDurumuCoz(aal, YONETIM_MFA_ZORUNLU) !== "tamam") {
    redirect({ href: YONETIM_DOGRULAMA, locale });
  }

  // Rol burada doğrulandı; istemciye aktarılır ki içerik tarayıcıdaki ikinci rol okumasını beklemesin.
  return (
    <RolKapisi sunucuRolu={profile?.role === "ogretmen" ? "ogretmen" : "admin"}>
      {children}
    </RolKapisi>
  );
}
