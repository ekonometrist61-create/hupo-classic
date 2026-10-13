import { createClient } from "@/utils/supabase/server";
import { getTranslations } from "next-intl/server";

interface AktifDuyuru {
  id: string;
  baslik: string;
  metin: string;
  bitis_at: string | null;
}

// Yönetim panelinden yayına alınmış en yeni, süresi dolmamış duyuruyu gösterir.
// Duyuru yoksa, okuma hata verirse (ör. migration henüz uygulanmamışsa) hiçbir şey çizilmez;
// ana sayfa bu şerit yüzünden bozulmamalı.
export async function DuyuruSeridi() {
  let duyuru: AktifDuyuru | null = null;
  try {
    const supabase = await createClient();
    const { data, error } = await supabase.rpc("get_aktif_duyuru");
    if (error || !data) return null;
    duyuru = data as AktifDuyuru;
  } catch {
    return null;
  }

  if (!duyuru?.baslik) return null;

  const t = await getTranslations("landing.duyuruSeridi");

  return (
    <section
      aria-label={t("etiket")}
      className="border-b border-success-800 bg-success-700 text-white dark:border-success-900 dark:bg-success-800 dark:text-white"
    >
      <div className="mx-auto flex max-w-6xl flex-col gap-1 px-4 py-3 text-sm sm:flex-row sm:items-center sm:gap-3 sm:px-6 lg:px-8">
        <span className="inline-flex w-fit shrink-0 rounded-full bg-gold-500 px-2.5 py-0.5 text-xs font-extrabold uppercase tracking-wide text-navy shadow-sm">
          {t("etiket")}
        </span>
        <p className="font-bold">{duyuru.baslik}</p>
        {duyuru.metin && (
          <p className="text-white">{duyuru.metin}</p>
        )}
      </div>
    </section>
  );
}
