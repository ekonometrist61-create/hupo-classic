"use client";

import { useCallback, useEffect, useState } from "react";

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

type Loaded<T> = { key: string; data: T | null; error: string | null; missing: boolean };

type PgError = { message: string; code?: string };

function isMissing(err: PgError): boolean {
  return (
    err.code === "PGRST202" ||
    err.code === "42883" ||
    /could not find the function|schema cache/i.test(err.message)
  );
}

/** Admin RPC çağrısı için ortak okuma kancası.
 *  `demo` verilirse ve DEMO_MODE açıksa ağ çağrısı yapılmaz, örnek veri döner (yalnızca yerel önizleme). */
export function useAdminRpc<T>(
  fn: string,
  args?: Record<string, unknown>,
  opts?: { demo?: T; enabled?: boolean },
): RpcState<T> {
  const argKey = JSON.stringify(args ?? {});
  const [tick, setTick] = useState(0);
  const reqKey = `${fn}|${argKey}|${tick}`;
  const enabled = opts?.enabled ?? true;
  const useDemo = DEMO_MODE && opts?.demo !== undefined;
  const [loaded, setLoaded] = useState<Loaded<T> | null>(null);

  useEffect(() => {
    if (!enabled || useDemo) return;
    let cancelled = false;
    const run = async () => {
      const { data, error } = await createClient().rpc(
        fn,
        args as Record<string, unknown> | undefined,
      );
      if (cancelled) return;
      setLoaded({
        key: reqKey,
        data: error ? null : (data as T),
        error: error ? error.message : null,
        missing: error ? isMissing(error) : false,
      });
    };
    void run();
    return () => {
      cancelled = true;
    };
    // args yalnızca argKey üzerinden izlenir.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [reqKey, enabled, useDemo]);

  const reload = useCallback(() => setTick((t) => t + 1), []);

  if (useDemo) {
    return { data: opts?.demo as T, error: null, missing: false, loading: false, reload };
  }
  if (!enabled) {
    return { data: null, error: null, missing: false, loading: false, reload };
  }
  const ready = loaded !== null && loaded.key === reqKey;
  return {
    data: ready ? loaded.data : null,
    error: ready ? loaded.error : null,
    missing: ready ? loaded.missing : false,
    loading: !ready,
    reload,
  };
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
