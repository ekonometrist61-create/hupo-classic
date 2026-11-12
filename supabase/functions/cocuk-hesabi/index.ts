// Supabase Edge Function: cocuk-hesabi  (JWT DOĞRULAMASI AÇIK kalır)
// Veli (web paneli / mobil) çağırır: POST + Authorization: Bearer <velinin JWT'si>
//   { islem: "olustur", ad, sinif, kullanici_adi, sifre }  -> { ok: true, ogrenci_id, kullanici_adi }
//   { islem: "sifre_sifirla", ogrenci_id, sifre }          -> { ok: true }
//   hata                                                    -> { ok: false, hata: "Türkçe mesaj" }
// Çocuk hesabı e-postasız açılır: giriş e-postası <kullanici_adi>@ogrenci.hupolingo.com
// ŞİFRELER HİÇBİR ZAMAN GÜNLÜĞE YAZILMAZ.
// Gizli anahtar: WEB_PANEL_URL (CORS). SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY otomatik gelir.
// Kurulum: supabase/functions/cocuk-hesabi/OKU-BENI.md

import { createClient } from "npm:@supabase/supabase-js@2";

declare const Deno: {
  env: { get(k: string): string | undefined };
  serve(handler: (req: Request) => Promise<Response> | Response): void;
};

const EPOSTA_ALANI = "ogrenci.hupolingo.com";
const MAKS_COCUK = 5;

function cors(req: Request): Record<string, string> {
  const allowed = (Deno.env.get("WEB_PANEL_URL") ?? "").replace(/\/+$/, "");
  const origin = req.headers.get("origin") ?? "";
  const h: Record<string, string> = {
    "access-control-allow-headers": "authorization, content-type, apikey, x-client-info",
    "access-control-allow-methods": "POST, OPTIONS",
    vary: "Origin",
  };
  // Yalnızca veli panelinin adresine izin; mobil uygulama Origin göndermez
  if (allowed && origin === allowed) h["access-control-allow-origin"] = origin;
  return h;
}

const reply = (req: Request, status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json", ...cors(req) } });
const hata = (req: Request, status: number, mesaj: string) => reply(req, status, { ok: false, hata: mesaj });

const str = (v: unknown) => (typeof v === "string" ? v : "");

function sifreHatasi(sifre: string): string | null {
  if (sifre.length < 6 || sifre.length > 64) return "Şifre 6 ile 64 karakter arasında olmalıdır";
  return null;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(req) });
  if (req.method !== "POST") return hata(req, 405, "Yalnızca POST isteği kabul edilir");

  const url = Deno.env.get("SUPABASE_URL")!;
  const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // 1) Çağıran kim?
  const auth = req.headers.get("authorization") ?? "";
  if (!auth.toLowerCase().startsWith("bearer ")) return hata(req, 401, "Lütfen önce giriş yapın");
  const userClient = createClient(url, anon, { global: { headers: { Authorization: auth } } });
  const { data: u, error: uErr } = await userClient.auth.getUser();
  if (uErr || !u?.user) return hata(req, 401, "Oturumunuzun süresi dolmuş, lütfen tekrar giriş yapın");
  const veliId = u.user.id;

  // 2) Veli mi?
  const admin = createClient(url, service, { auth: { persistSession: false, autoRefreshToken: false } });
  const { data: prof } = await admin.from("profiles").select("role").eq("id", veliId).maybeSingle();
  if (!prof || prof.role !== "veli") return hata(req, 403, "Bu işlemi yalnızca veli hesapları yapabilir");

  // 3) Gövde
  let b: Record<string, unknown> = {};
  try {
    const j = await req.json();
    if (j && typeof j === "object") b = j as Record<string, unknown>;
  } catch { /* boş gövde */ }
  const islem = str(b.islem);

  // ------------------------------------------------------------------
  if (islem === "olustur") {
    const ad = str(b.ad).trim().replace(/\s+/g, " ");
    const kullaniciAdi = str(b.kullanici_adi).trim().toLowerCase();
    const sifre = str(b.sifre);
    const sinif = typeof b.sinif === "number" ? b.sinif : Number.parseInt(str(b.sinif), 10);

    if (ad.length < 2 || ad.length > 40) return hata(req, 400, "Ad 2 ile 40 karakter arasında olmalıdır");
    if (!/^[a-z0-9._]{3,20}$/.test(kullaniciAdi)) {
      return hata(req, 400,
        "Kullanıcı adı 3 ile 20 karakter arasında olmalı; yalnızca küçük harf (Türkçe karakter olmadan), rakam, nokta ve alt çizgi içerebilir");
    }
    const sHata = sifreHatasi(sifre);
    if (sHata) return hata(req, 400, sHata);

    const { data: siniflar, error: sErr } = await admin.rpc("_desteklenen_siniflar");
    if (sErr || !Array.isArray(siniflar)) return hata(req, 500, "Bir sorun oluştu, lütfen daha sonra tekrar deneyin");
    if (!Number.isInteger(sinif) || !siniflar.includes(sinif)) return hata(req, 400, "Seçtiğiniz sınıf şu an desteklenmiyor");

    const { data: sayi, error: cErr } = await admin.rpc("veli_cocuk_sayisi", { p_veli: veliId });
    if (cErr) return hata(req, 500, "Bir sorun oluştu, lütfen daha sonra tekrar deneyin");
    if ((sayi ?? 0) >= MAKS_COCUK) return hata(req, 409, "En fazla 5 çocuk hesabı oluşturabilirsiniz");

    const { data: mevcut } = await admin.from("profiles").select("id").eq("kullanici_adi", kullaniciAdi).maybeSingle();
    if (mevcut) return hata(req, 409, "Bu kullanıcı adı alınmış, lütfen başka bir ad deneyin");

    const { data: yeni, error: aErr } = await admin.auth.admin.createUser({
      email: `${kullaniciAdi}@${EPOSTA_ALANI}`,
      password: sifre,
      email_confirm: true,
      user_metadata: { role: "ogrenci", full_name: ad },
    });
    if (aErr || !yeni?.user) {
      const kod = (aErr as { code?: string } | null)?.code ?? "";
      const durum = (aErr as { status?: number } | null)?.status ?? 0;
      if (kod === "email_exists" || kod === "user_already_exists") {
        return hata(req, 409, "Bu kullanıcı adı alınmış, lütfen başka bir ad deneyin");
      }
      if (kod === "weak_password") return hata(req, 400, "Şifre çok zayıf, lütfen daha güçlü bir şifre seçin");
      console.error("cocuk-hesabi: createUser başarısız", kod, durum);
      return hata(req, 500, "Çocuk hesabı oluşturulamadı, lütfen daha sonra tekrar deneyin");
    }
    const ogrenciId = yeni.user.id;

    const { error: bErr } = await admin.rpc("_cocuk_hesabi_bagla", {
      p_ogrenci: ogrenciId, p_veli: veliId, p_sinif: sinif, p_kullanici_adi: kullaniciAdi,
    });
    if (bErr) {
      // Yetim hesap kalmasın
      const { error: dErr } = await admin.auth.admin.deleteUser(ogrenciId);
      if (dErr) console.error("cocuk-hesabi: yarım kalan hesap silinemedi", ogrenciId, dErr.message);
      console.error("cocuk-hesabi: profil bağlanamadı", bErr.code, bErr.message);
      if (bErr.code === "23505") return hata(req, 409, "Bu kullanıcı adı alınmış, lütfen başka bir ad deneyin");
      if (bErr.code === "22023") return hata(req, 409, bErr.message);
      return hata(req, 500, "Çocuk hesabı oluşturulamadı, lütfen daha sonra tekrar deneyin");
    }

    return reply(req, 200, { ok: true, ogrenci_id: ogrenciId, kullanici_adi: kullaniciAdi });
  }

  // ------------------------------------------------------------------
  if (islem === "sifre_sifirla") {
    const ogrenciId = str(b.ogrenci_id);
    const sifre = str(b.sifre);
    if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(ogrenciId)) {
      return hata(req, 400, "Geçersiz çocuk hesabı");
    }
    const sHata = sifreHatasi(sifre);
    if (sHata) return hata(req, 400, sHata);

    const { data: cocuk } = await admin.from("profiles").select("id")
      .eq("id", ogrenciId).eq("parent_id", veliId).eq("role", "ogrenci").maybeSingle();
    if (!cocuk) return hata(req, 403, "Yalnızca kendi çocuğunuzun şifresini değiştirebilirsiniz");

    const { error: pErr } = await admin.auth.admin.updateUserById(ogrenciId, { password: sifre });
    if (pErr) {
      const kod = (pErr as { code?: string }).code ?? "";
      if (kod === "weak_password") return hata(req, 400, "Şifre çok zayıf, lütfen daha güçlü bir şifre seçin");
      console.error("cocuk-hesabi: şifre güncellenemedi", kod);
      return hata(req, 500, "Şifre değiştirilemedi, lütfen daha sonra tekrar deneyin");
    }
    return reply(req, 200, { ok: true });
  }

  return hata(req, 400, "Geçersiz işlem");
});
