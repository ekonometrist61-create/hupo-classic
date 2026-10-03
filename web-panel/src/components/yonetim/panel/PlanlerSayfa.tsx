"use client";

import { useCallback, useEffect, useState } from "react";

import { createClient } from "@/utils/supabase/client";
import type { Plan } from "../types";
import PlanManager from "./PlanManager";

/** Planları kendi çeken bağımsız sarmalayıcı — /yonetim/planlar sayfası için. */
export default function PlanlerSayfa() {
  const [plans, setPlans] = useState<Plan[]>([]);
  const [reloadKey, setReloadKey] = useState(0);

  const reload = useCallback(() => setReloadKey((k) => k + 1), []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const { data } = await createClient()
        .from("plans")
        .select("*")
        .order("kod");
      if (!cancelled && data) setPlans(data as Plan[]);
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [reloadKey]);

  return <PlanManager plans={plans} onChanged={reload} />;
}
