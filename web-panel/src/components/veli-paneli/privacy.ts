// Gizlilik / veli açık rıza metninin sürümü. Mobil uygulamadaki
// `kPrivacyNoticeVersion` (lib/content/privacy_notice.dart) ile AYNI olmalıdır.
//
// ÖNEMLİ: Metinler taslaktır; yayına almadan önce KVKK uzmanı bir hukukçu tarafından
// gözden geçirilmelidir. Metin değişince bu değeri artırın: onay durumu yeniden sorulur.
export const PRIVACY_NOTICE_VERSION = "2026-09-taslak-1";

export type ParentConsent = "yok" | "verildi" | "geri_cekildi";
