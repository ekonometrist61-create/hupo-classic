import { DEMO_MODE } from "@/lib/demo-mode";
import type { Student } from "@/components/veli-paneli/types";
import { createClient } from "@/utils/supabase/server";

// Veli paneli sayfalarının erişim kararı (yalnızca sunucu tarafında çalışır).
// - ok: veli oturumu; students bağlı çocuklar (çocuk yoksa boş dizi)
// - admin: yönetici oturumu; çağıran sayfa yönetim paneline yönlendirir
// - ogretmen: öğretmen oturumu (K1); öğretmen veli panelinde kalmaz, sınıf sayfasına yönlendirilir
// - forbidden: oturum yok ya da veli/yönetici/öğretmen rolünde değil
// - error: çocuk listesi okunamadı
export type VeliAccess =
  | { kind: "ok"; students: Student[] }
  | { kind: "admin" }
  | { kind: "ogretmen" }
  | { kind: "forbidden" }
  | { kind: "error" };

const DEMO_STUDENTS: Student[] = [
  {
    id: "c1",
    full_name: "Öğrenci A",
    username: "ogrenci.a",
    avatar_url: null,
    sinif: "4",
  },
  {
    id: "c2",
    full_name: "Öğrenci B",
    username: "ogrenci.b",
    avatar_url: null,
    sinif: "5",
  },
];

export async function loadVeliAccess(): Promise<VeliAccess> {
  if (DEMO_MODE) return { kind: "ok", students: DEMO_STUDENTS };

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { kind: "forbidden" };

  // Rol ve çocuk listesi aynı kimlikle okunur; sıralı beklemek sayfayı gereksiz geciktirir.
  // Çocuk listesi yalnızca veli için anlamlıdır; diğer rollerde sonuç yok sayılır.
  const [{ data: profile }, { data: students, error }] = await Promise.all([
    supabase.from("profiles").select("role").eq("id", user.id).maybeSingle(),
    supabase
      .from("profiles")
      .select("id, full_name, username")
      .eq("parent_id", user.id)
      .order("full_name"),
  ]);

  if (profile?.role === "admin") return { kind: "admin" };
  if (profile?.role === "ogretmen") return { kind: "ogretmen" };
  if (profile?.role !== "veli") return { kind: "forbidden" };

  if (error) return { kind: "error" };
  return { kind: "ok", students: (students ?? []) as Student[] };
}
