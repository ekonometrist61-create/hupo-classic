// Başarılı girişi giris_olaylari tablosuna kaydeder (W7).
// Yalnızca başarılı giriş sonrası çağrılmalıdır; başarısız denemeler burada kaydedilmez (kimliksiz).
// Hata yutulur: kayıt başarısız olsa bile giriş akışı bozulmaz ve kullanıcıya hata gösterilmez.
// Bu çağrı kişisel veri göndermez (e-posta, IP, user-agent yok); yalnız kanal bilgisi gider.
import { createClient } from "@/utils/supabase/client";

export type GirisKanali = "web" | "mobil";

export async function girisKaydiYaz(kanal: GirisKanali = "web"): Promise<void> {
  try {
    const supabase = createClient();
    // Dönüş (true/false) önemsizdir; dakikalık tekilleştirme sunucuda yapılır.
    await supabase.rpc("giris_olayi_kaydet", { p_kanal: kanal });
  } catch {
    // Yutulur: giriş kaydı yardımcıdır, girişi bozmaz.
  }
}
