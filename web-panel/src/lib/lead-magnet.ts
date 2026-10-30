// Lead magnet (veli rehberleri) özellik bayrağı. Varsayılan KAPALI: hukuk onayı (GÖR-078) ve şirket
// bilgileri gelmeden yayın yok. NEXT_PUBLIC_ olduğu için derleme zamanında değerlenir.
export const LEAD_MAGNET_ACIK = process.env.NEXT_PUBLIC_LEAD_MAGNET_ACIK === "true";

export const CARPIM_MAGNET = "carpim-pif-noktalari";
export const KVKK_SURUM = "lead-magnet-kvkk-2026-10-v1";
export const IZIN_SURUM = "lead-magnet-izin-2026-10-v1";
