import { DEMO_MODE } from "@/lib/demo-mode";
import type { Student } from "@/components/veli-paneli/types";
import { createClient } from "@/utils/supabase/server";

// Veli paneli sayfalarının erişim kararı (yalnızca sunucu tarafında çalışır).
// - ok: veli oturumu; students bağlı çocuklar (çocuk yoksa boş dizi)
// - admin: yönetici oturumu; çağıran sayfa yönetim paneline yönlendirir
// - forbidden: oturum yok ya da veli rolünde değil
// - error: çocuk listesi okunamadı
export type VeliAccess =
  | { kind: "ok"; students: Student[] }
  | { kind: "admin" }
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

  const { data: profile } = user
    ? await supabase
        .from("profiles")
        .select("role")
        .eq("id", user.id)
        .maybeSingle()
    : { data: null };

  if (profile?.role === "admin") return { kind: "admin" };
  if (!user || profile?.role !== "veli") return { kind: "forbidden" };

  const { data: students, error } = await supabase
    .from("profiles")
    .select("id, full_name, username")
    .eq("parent_id", user.id)
    .order("full_name");

  if (error) return { kind: "error" };
  return { kind: "ok", students: (students ?? []) as Student[] };
}
