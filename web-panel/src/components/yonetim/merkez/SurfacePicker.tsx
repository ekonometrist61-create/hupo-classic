"use client";

import { labelClass } from "../panel/styles";
import type { SurveySurface } from "./types";

interface SurfacePickerProps<T extends SurveySurface> {
  /** Seçilebilecek mecralar. Anket: ANKET_SURFACES; duyuru: DUYURU_SURFACES. */
  surfaces: readonly T[];
  value: T[];
  onChange: (next: T[]) => void;
  legend: string;
  help: string;
  requiredMessage: string;
  surfaceLabel: (surface: T) => string;
}

/** Yayın mecrası seçici. Hangi mecraların listeleneceğini çağıran belirler (anket ve duyuru farklı liste kullanır). */
export default function SurfacePicker<T extends SurveySurface>({
  surfaces,
  value,
  onChange,
  legend,
  help,
  requiredMessage,
  surfaceLabel,
}: SurfacePickerProps<T>) {
  const toggle = (y: T) =>
    onChange(value.includes(y) ? value.filter((x) => x !== y) : [...value, y]);

  return (
    <fieldset className="mt-4">
      <legend className={labelClass}>{legend}</legend>
      <div className="grid gap-2 sm:grid-cols-2">
        {surfaces.map((y) => (
          <label key={y} className="flex items-center gap-2 text-theme-sm">
            <input
              type="checkbox"
              className="size-4 accent-brand-500"
              checked={value.includes(y)}
              onChange={() => toggle(y)}
            />
            {surfaceLabel(y)}
          </label>
        ))}
      </div>
      <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">{help}</p>
      {value.length === 0 && <p className="mt-2 text-theme-xs text-error-600">{requiredMessage}</p>}
    </fieldset>
  );
}
