"use client";

import { useCallback, useEffect, useReducer, useState } from "react";

import { oturumSifirlamaDinle } from "@/hooks/useCurrentRole";
import { DEMO_MODE } from "@/lib/demo-mode";
import { createClient } from "@/utils/supabase/client";

export type RpcState<T> = {
  data: T | null;
  error: string | null;
  /** RPC henüz veritabanında yok (migration uygulanmamış). */
  missing: boolean;
  loading: boolean;
  reload: () => void;
};

type PgError = { message: string; code?: string };

function isMissing(err: PgError): boolean {
  return (
    err.code === "PGRST202" ||
    err.code === "42883" ||
    /could not find the function|schema cache/i.test(err.message)
  );
}

// Başarılı RPC sonuçlarının bellek içi önbelleği. Sayfadan çıkıp dönünce veri anında gelir ve
// arka planda yenilenir. Yalnızca bellekte tutulur; oturum değişince temizlenir.
const ONBELLEK_SINIRI = 60;
const onbellek = new Map<string, unknown>();
// Aynı sorgunun yalnızca en son başlatılan isteği sonucunu yazar; eski yanıt yeniyi ezmez.
const surenIstekler = new Map<string, number>();
let istekSayaci = 0;

oturumSifirlamaDinle(() => {
  onbellek.clear();
  surenIstekler.clear();
});

function onbellegeYaz(anahtar: string, veri: unknown) {
  onbellek.delete(anahtar);
  onbellek.set(anahtar, veri);
  if (onbellek.size > ONBELLEK_SINIRI) {
    const enEski = onbellek.keys().next().value;
    if (enEski !== undefined) onbellek.delete(enEski);
  }
}

type HataDurumu = { anahtar: string; tick: number; mesaj: string; eksik: boolean };

/** Admin RPC çağrısı için ortak okuma kancası.
 *  Sonuç önbellekteyse anında gösterilir ve arka planda yenilenir. Yeniden yüklemede liste boşalmaz;
 *  böylece bir kayıttan sonra ekran "Yükleniyor"a düşüp geri gelmez.
 *  `demo` verilirse ve DEMO_MODE açıksa ağ çağrısı yapılmaz, örnek veri döner (yalnızca yerel önizleme). */
export function useAdminRpc<T>(
  fn: string,
  args?: Record<string, unknown>,
  opts?: { demo?: T; enabled?: boolean },
): RpcState<T> {
  const argKey = JSON.stringify(args ?? {});
  const anahtar = `${fn}|${argKey}`;
  const [tick, setTick] = useState(0);
  const [hata, setHata] = useState<HataDurumu | null>(null);
  const [, yenile] = useReducer((n: number) => n + 1, 0);
  const enabled = opts?.enabled ?? true;
  const useDemo = DEMO_MODE && opts?.demo !== undefined;

  useEffect(() => {
    if (!enabled || useDemo) return;
    const istekNo = ++istekSayaci;
    surenIstekler.set(anahtar, istekNo);
    void (async () => {
      const { data, error } = await createClient().rpc(
        fn,
        args as Record<string, unknown> | undefined,
      );
      if (surenIstekler.get(anahtar) !== istekNo) return;
      surenIstekler.delete(anahtar);
      if (error) {
        setHata({ anahtar, tick, mesaj: error.message, eksik: isMissing(error) });
        return;
      }
      onbellegeYaz(anahtar, data);
      yenile();
    })();
    // args yalnızca argKey üzerinden izlenir.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [anahtar, tick, enabled, useDemo]);

  const reload = useCallback(() => setTick((t) => t + 1), []);

  if (useDemo) {
    return { data: opts?.demo as T, error: null, missing: false, loading: false, reload };
  }
  if (!enabled) {
    return { data: null, error: null, missing: false, loading: false, reload };
  }
  // Önbellekteki veri, yenileme sürerken de gösterilir.
  if (onbellek.has(anahtar)) {
    return { data: onbellek.get(anahtar) as T, error: null, missing: false, loading: false, reload };
  }
  // Hata yalnızca o yüklemeye aittir; yeniden denemede (tick değişince) yükleniyor durumuna döner.
  const hatali = hata && hata.anahtar === anahtar && hata.tick === tick ? hata : null;
  if (hatali) {
    return { data: null, error: hatali.mesaj, missing: hatali.eksik, loading: false, reload };
  }
  return { data: null, error: null, missing: false, loading: true, reload };
}

/** Yazma/eylem RPC'si. Demo modunda hiçbir şey kaydedilmez. */
export async function adminCall<T = unknown>(
  fn: string,
  args?: Record<string, unknown>,
): Promise<{ data: T | null; error: string | null; missing: boolean }> {
  if (DEMO_MODE) {
    return { data: null, error: "DEMO", missing: false };
  }
  const { data, error } = await createClient().rpc(fn, args);
  if (error) return { data: null, error: error.message, missing: isMissing(error) };
  return { data: data as T, error: null, missing: false };
}
