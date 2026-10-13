// Türkiye sabit UTC+3'tür (yaz saati uygulaması yok); yönetim formlarındaki tarih girişi bu saate göre yapılır.
const TURKIYE_SAAT_DILIMI = "Europe/Istanbul";
const TURKIYE_UTC_OFSETI = "+03:00";

// ISO (UTC) → datetime-local değeri ("2026-11-15T09:00", Türkiye saatiyle)
export function isoToTurkiyeInput(iso: string): string {
  const d = new Date(iso);
  if (isNaN(d.getTime())) return "";
  return new Intl.DateTimeFormat("sv-SE", {
    timeZone: TURKIYE_SAAT_DILIMI,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  })
    .format(d)
    .replace(" ", "T");
}

// datetime-local değeri (Türkiye saatiyle) → ISO (UTC); geçersizse null
export function turkiyeInputToIso(local: string): string | null {
  const d = new Date(`${local}:00${TURKIYE_UTC_OFSETI}`);
  return isNaN(d.getTime()) ? null : d.toISOString();
}
