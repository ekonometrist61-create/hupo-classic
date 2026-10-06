// Recharts renkleri (globals.css @theme paletinden; grafik seçenekleri için hex kullanımı şablonda istisnadır)
export const CHART_COLORS = {
  brand: "#147D8A", // brand-500 Learning Teal
  success: "#12b76a", // success-500
  warning: "#f79009", // warning-500
  error: "#f04438", // error-500
  axis: "#98a2b3", // gray-400
} as const;

export function successColor(percent: number): string {
  if (percent >= 70) return CHART_COLORS.success;
  if (percent >= 40) return CHART_COLORS.warning;
  return CHART_COLORS.error;
}
