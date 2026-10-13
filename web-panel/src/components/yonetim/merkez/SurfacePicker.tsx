"use client";

import { labelClass } from "../panel/styles";
import { SURVEY_SURFACES, type SurveySurface } from "./types";

interface SurfacePickerProps {
  value: SurveySurface[];
  onChange: (next: SurveySurface[]) => void;
  legend: string;
  help: string;
  requiredMessage: string;
  surfaceLabel: (surface: SurveySurface) => string;
}

/** Yayın mecrası seçici: anket ve duyuru aynı mecra listesini (SURVEY_SURFACES) paylaşır. */
export default function SurfacePicker({
  value,
  onChange,
  legend,
  help,
  requiredMessage,
  surfaceLabel,
}: SurfacePickerProps) {
  const toggle = (y: SurveySurface) =>
    onChange(value.includes(y) ? value.filter((x) => x !== y) : [...value, y]);

  return (
    <fieldset className="mt-4">
      <legend className={labelClass}>{legend}</legend>
      <div className="grid gap-2 sm:grid-cols-2">
        {SURVEY_SURFACES.map((y) => (
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
