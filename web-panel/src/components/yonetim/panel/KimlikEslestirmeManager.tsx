"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import { cardClass, outlineBtn, primaryBtn, thClass, tdClass } from "./styles";
import ErrorNote from "./ErrorNote";

interface OgrenciOzet {
  id: string;
  ad: string;
  sinif: number;
  username: string;
}

interface MergeCandidate {
  id: string;
  reason: string;
  confidence: number;
  created_at: string;
  ogrenci_a: OgrenciOzet;
  ogrenci_b: OgrenciOzet;
}

const REASON_LABEL: Record<string, string> = {
  same_name_grade: "Aynı ad + sınıf",
  same_household: "Aynı hane",
};

const CONFIDENCE_COLOR = (c: number) =>
  c >= 0.8 ? "text-red-600 dark:text-red-400" : c >= 0.6 ? "text-yellow-600 dark:text-yellow-400" : "text-gray-500";

export default function KimlikEslestirmeManager() {
  const [adaylar, setAdaylar] = useState<MergeCandidate[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState<string | null>(null); // candidate id

  useEffect(() => {
    createClient()
      .rpc("admin_list_merge_candidates")
      .then(({ data, error: rpcErr }) => {
        setLoading(false);
        if (rpcErr || !Array.isArray(data)) {
          setError("Adaylar yüklenemedi.");
          return;
        }
        setAdaylar(data as MergeCandidate[]);
      });
  }, []);

  async function resolve(id: string, action: "merged" | "distinct" | "ignored") {
    setSaving(id);
    const { error: rpcErr } = await createClient().rpc("admin_resolve_merge_candidate", {
      p_candidate_id: id,
      p_action: action,
    });
    setSaving(null);
    if (rpcErr) {
      setError(rpcErr.message);
      return;
    }
    setAdaylar((prev) => prev.filter((c) => c.id !== id));
  }

  if (loading) {
    return (
      <div className={cardClass}>
        <p className="text-sm text-gray-400">Yükleniyor...</p>
      </div>
    );
  }

  return (
    <div className={cardClass}>
      {error && (
        <div className="flex items-center justify-between">
          <ErrorNote message={error} />
          <button onClick={() => setError(null)} className="text-xs text-gray-400 hover:text-gray-600">✕</button>
        </div>
      )}

      {adaylar.length === 0 ? (
        <p className="py-8 text-center text-sm text-gray-400">
          Bekleyen birleştirme adayı yok. İyi!
        </p>
      ) : (
        <>
          <p className="mb-4 text-sm text-gray-500 dark:text-gray-400">
            {adaylar.length} bekleyen aday. Her satırda iki öğrenci aynı çocuk olabilir.
          </p>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead>
                <tr>
                  <th className={thClass}>Öğrenci A</th>
                  <th className={thClass}>Öğrenci B</th>
                  <th className={thClass}>Sebep</th>
                  <th className={thClass}>Güven</th>
                  <th className={thClass}>Karar</th>
                </tr>
              </thead>
              <tbody>
                {adaylar.map((aday) => (
                  <tr key={aday.id} className="border-t border-gray-100 dark:border-gray-800">
                    <td className={tdClass}>
                      <p className="font-medium">{aday.ogrenci_a.ad}</p>
                      <p className="text-xs text-gray-400">
                        {aday.ogrenci_a.sinif}. sınıf · @{aday.ogrenci_a.username}
                      </p>
                    </td>
                    <td className={tdClass}>
                      <p className="font-medium">{aday.ogrenci_b.ad}</p>
                      <p className="text-xs text-gray-400">
                        {aday.ogrenci_b.sinif}. sınıf · @{aday.ogrenci_b.username}
                      </p>
                    </td>
                    <td className={tdClass}>
                      {REASON_LABEL[aday.reason] ?? aday.reason}
                    </td>
                    <td className={`${tdClass} ${CONFIDENCE_COLOR(aday.confidence)} font-bold`}>
                      %{Math.round(aday.confidence * 100)}
                    </td>
                    <td className={tdClass}>
                      <div className="flex gap-1.5">
                        <button
                          disabled={saving === aday.id}
                          onClick={() => resolve(aday.id, "merged")}
                          className={primaryBtn}
                          title="Aynı kişi — birleştir (not: veri birleştirme henüz manuel)"
                        >
                          Birleştir
                        </button>
                        <button
                          disabled={saving === aday.id}
                          onClick={() => resolve(aday.id, "distinct")}
                          className={outlineBtn}
                        >
                          Farklı
                        </button>
                        <button
                          disabled={saving === aday.id}
                          onClick={() => resolve(aday.id, "ignored")}
                          className="text-xs text-gray-400 hover:text-gray-600"
                        >
                          Atla
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
