import type { AdminQuestion, AjanDurumu } from "../types";

// Ajan kapısı yardımcıları. Sunucu sözleşmesi: anahtar eksikse "bekliyor" sayılır;
// insan onayı (onaylandi) yalnızca ajan A ve B ikisi de "pass" iken mümkündür.

/** Liste süzgeci; sunucuya p_denetim olarak gider. Boş seçim = null (hepsi). */
export type AjanSuzgeci = "ajan_gecti" | "ajan_bekliyor" | "ajan_reddi";

export function ajanDurumu(q: Pick<AdminQuestion, "denetim">, ajan: "ajan_a" | "ajan_b"): AjanDurumu {
  return q.denetim?.[ajan] ?? "pending";
}

/** Ajan A ve B ikisi de geçtiyse soru insan onayına hazırdır. */
export function ajanGecti(q: Pick<AdminQuestion, "denetim">): boolean {
  return ajanDurumu(q, "ajan_a") === "pass" && ajanDurumu(q, "ajan_b") === "pass";
}
