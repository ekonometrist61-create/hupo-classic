"use client";

import { useRouter } from "@/i18n/navigation";
import { MFA_YAYINCI } from "@/lib/auth/mfa";
import { createClient } from "@/utils/supabase/client";
import { useTranslations } from "next-intl";
import { useEffect, useRef, useState } from "react";
import MfaKayitPaneli from "./MfaKayitPaneli";
import { adminFieldClass } from "./SignInForm";

// Yönetim iki adımlı doğrulama formu (GÖR-106).
//   dogrula: doğrulanmış TOTP faktörü var → 6 haneli kod → oturum aal2'ye yükselir.
//   kayit:   faktör yok → enroll (QR + gizli anahtar) → ilk kodla doğrulanınca faktör açılır.
//   hata:    sunucu oturum durumunu okuyamadı → yeniden dene / farklı hesap.
// Doğrulama tarayıcıdaki Supabase istemcisiyle yapılır; yeni oturum cookie'si yazılır ve
// yönetim layout'u bir sonraki istekte aal2'yi sunucuda görür.
type Mod = "dogrula" | "kayit" | "hata";

type Kayit = { faktorId: string; qrKod: string; anahtar: string };

type Props = {
  mod: Mod;
  faktorId: string | null;
  zorunlu: boolean;
  hedef: string;
  eposta: string;
};

type HataAnahtari = "hataKod" | "hataKodBicim" | "hataCokDeneme" | "hataGenel";

// Supabase Auth MFA hata kodları → metin. Ham İngilizce metin arayüze çıkmaz.
function hataAnahtari(hata: { code?: string | null } | null, varsayilan: HataAnahtari): HataAnahtari {
  const kod = hata?.code ?? "";
  if (kod === "mfa_verification_failed" || kod === "mfa_challenge_expired" || kod === "mfa_verification_rejected") {
    return "hataKod";
  }
  if (kod.startsWith("over_") && kod.endsWith("_rate_limit")) return "hataCokDeneme";
  return varsayilan;
}

const KOD_BICIMI = /^[0-9]{6}$/;

const birincilDugme =
  "inline-flex h-11 w-full cursor-pointer items-center justify-center rounded-lg bg-navy px-6 text-sm font-semibold text-white transition-colors hover:bg-navy-light focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:opacity-60";

const ikincilDugme =
  "inline-flex min-h-11 w-full cursor-pointer items-center justify-center rounded-lg border border-gray-300 bg-white px-6 text-sm font-semibold text-navy transition-colors hover:bg-gray-50 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500 disabled:cursor-not-allowed disabled:opacity-60";

const linkDugme =
  "inline-flex min-h-11 cursor-pointer items-center text-sm font-semibold text-brand-700 underline underline-offset-4 hover:text-brand-800 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500";

export default function YonetimMfaForm({ mod, faktorId, zorunlu, hedef, eposta }: Props) {
  const t = useTranslations("yonetimMfa");
  const router = useRouter();
  const [kod, setKod] = useState("");
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<HataAnahtari | null>(null);
  const [kayit, setKayit] = useState<Kayit | null>(null);
  const [kurulumHatasi, setKurulumHatasi] = useState(false);
  const [kurulumDenemesi, setKurulumDenemesi] = useState(0);
  // React geliştirme modunda effect iki kez çalışır; aynı denemede ikinci enroll engellenir.
  // (Bu yüzden iptal bayrağı kullanılmaz: ilk çalışmanın sonucu ekrana yazılmalıdır.)
  const baslatilanDeneme = useRef<number | null>(null);

  // Kayıt modu: önce yarım kalmış (doğrulanmamış) TOTP faktörleri silinir, sonra yeni kayıt açılır.
  // Aynı adla ikinci doğrulanmamış faktör Supabase'de çakışma hatası verir.
  useEffect(() => {
    if (mod !== "kayit" || baslatilanDeneme.current === kurulumDenemesi) return;
    baslatilanDeneme.current = kurulumDenemesi;

    (async () => {
      const supabase = createClient();
      const { data: faktorler, error: listeHatasi } = await supabase.auth.mfa.listFactors();
      if (listeHatasi) {
        setKurulumHatasi(true);
        return;
      }
      for (const f of faktorler.all) {
        if (f.factor_type === "totp" && f.status === "unverified") {
          await supabase.auth.mfa.unenroll({ factorId: f.id });
        }
      }
      const { data, error } = await supabase.auth.mfa.enroll({
        factorType: "totp",
        friendlyName: MFA_YAYINCI,
        issuer: MFA_YAYINCI,
      });
      if (error || !data) {
        setKurulumHatasi(true);
        return;
      }
      setKayit({ faktorId: data.id, qrKod: data.totp.qr_code, anahtar: data.totp.secret });
    })();
  }, [mod, kurulumDenemesi]);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setHata(null);
    const hedefFaktor = mod === "kayit" ? kayit?.faktorId : faktorId;
    if (!hedefFaktor) return;
    if (!KOD_BICIMI.test(kod)) {
      setHata("hataKodBicim");
      return;
    }

    setYukleniyor(true);
    const supabase = createClient();
    // challenge + verify tek çağrıda; başarılıysa oturum aal2 olur ve cookie yenilenir.
    const { error } = await supabase.auth.mfa.challengeAndVerify({ factorId: hedefFaktor, code: kod });
    if (error) {
      setHata(hataAnahtari(error, "hataGenel"));
      setKod("");
      setYukleniyor(false);
      return;
    }
    router.replace(hedef);
    router.refresh();
  }

  async function sonraYap() {
    // Yarım kayıt bırakılmaz; silinemezse bir sonraki kayıtta temizlenir.
    if (kayit) {
      const supabase = createClient();
      await supabase.auth.mfa.unenroll({ factorId: kayit.faktorId });
    }
    router.replace(hedef);
  }

  async function baskaHesap() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.replace("/yonetim-giris");
  }

  function kurulumuYenile() {
    setKurulumHatasi(false);
    setKayit(null);
    setKurulumDenemesi((n) => n + 1);
  }

  const kayitModu = mod === "kayit";
  const baslik = kayitModu ? t("kayitBaslik") : t("dogrulaBaslik");
  const aciklama = kayitModu
    ? zorunlu
      ? t("kayitAciklamaZorunlu")
      : t("kayitAciklamaOneri")
    : mod === "dogrula"
      ? t("dogrulaAciklama")
      : t("hataDurum");
  const formHazir = mod === "dogrula" || (kayitModu && kayit !== null);

  return (
    <div>
      <p className="text-xs font-semibold tracking-[0.14em] text-navy-muted uppercase">{t("eyebrow")}</p>
      <h1 className="mt-2 text-2xl font-bold tracking-tight text-navy">{baslik}</h1>
      <p className="mt-2 text-sm leading-relaxed text-navy-muted">{aciklama}</p>
      {eposta && <p className="mt-1 text-sm font-medium break-all text-navy">{eposta}</p>}

      <div className="mt-8 rounded-xl bg-white p-6 ring-1 ring-navy/10 shadow-[0_1px_2px_rgb(23_50_77/0.06),0_16px_36px_-18px_rgb(23_50_77/0.28)] sm:p-7">
        {mod === "hata" && (
          <div className="space-y-4">
            <div role="alert" className="rounded-xl border border-error-200 bg-error-50 px-4 py-3 text-sm font-medium text-error-700">
              <p>{t("hataDurum")}</p>
            </div>
            <button type="button" onClick={() => router.refresh()} className={birincilDugme}>
              {t("yeniden")}
            </button>
          </div>
        )}

        {kayitModu && (
          <MfaKayitPaneli
            qrKod={kayit?.qrKod ?? null}
            anahtar={kayit?.anahtar ?? null}
            kurulumHatasi={kurulumHatasi}
            onYeniden={kurulumuYenile}
          />
        )}

        {formHazir && (
          <form onSubmit={handleSubmit} className={`space-y-5 ${kayitModu ? "mt-6 border-t border-navy/10 pt-6" : ""}`} aria-busy={yukleniyor}>
            {kayitModu && <p className="text-sm text-navy">{t("adim2")}</p>}
            <div>
              <label htmlFor="mfa-kod" className="block text-sm font-semibold text-navy">
                {t("kodEtiket")}
              </label>
              <input
                id="mfa-kod"
                name="code"
                type="text"
                inputMode="numeric"
                autoComplete="one-time-code"
                pattern="[0-9]{6}"
                maxLength={6}
                required
                autoFocus
                spellCheck={false}
                value={kod}
                onChange={(e) => setKod(e.target.value.replace(/\D/g, "").slice(0, 6))}
                aria-describedby={hata ? "mfa-ipucu mfa-hata" : "mfa-ipucu"}
                aria-invalid={hata ? true : undefined}
                className={`${adminFieldClass} tracking-[0.3em]`}
              />
              <p id="mfa-ipucu" className="mt-1.5 text-xs text-navy-muted">
                {t("kodIpucu")}
              </p>
            </div>

            {hata && (
              <div
                id="mfa-hata"
                role="alert"
                className="rounded-xl border border-error-200 bg-error-50 px-4 py-3 text-sm font-medium text-error-700"
              >
                <p>{t(hata)}</p>
              </div>
            )}

            <button type="submit" disabled={yukleniyor} className={birincilDugme}>
              {yukleniyor ? t("dogrulaniyor") : kayitModu ? t("kayitTamamla") : t("dogrula")}
            </button>
          </form>
        )}

        {kayitModu && !zorunlu && (
          <div className="mt-4">
            <button type="button" onClick={sonraYap} disabled={yukleniyor} className={ikincilDugme}>
              {t("sonraYap")}
            </button>
            <p className="mt-2 text-center text-xs text-navy-muted">{t("sonraNot")}</p>
          </div>
        )}
      </div>

      <p className="mt-6 text-center">
        <button type="button" onClick={baskaHesap} className={linkDugme}>
          {t("baskaHesap")}
        </button>
      </p>
    </div>
  );
}
