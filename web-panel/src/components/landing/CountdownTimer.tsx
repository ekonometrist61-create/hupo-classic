"use client";

import { useEffect, useState } from "react";

interface TimeLeft {
  days: number;
  hours: number;
  minutes: number;
  seconds: number;
}

function calcTimeLeft(targetDate: Date): TimeLeft | null {
  const diff = targetDate.getTime() - Date.now();
  if (diff <= 0) return null;
  return {
    days: Math.floor(diff / (1000 * 60 * 60 * 24)),
    hours: Math.floor((diff / (1000 * 60 * 60)) % 24),
    minutes: Math.floor((diff / (1000 * 60)) % 60),
    seconds: Math.floor((diff / 1000) % 60),
  };
}

interface CountdownTimerProps {
  targetDate: Date;
  labels: { days: string; hours: string; minutes: string; seconds: string; started: string };
}

export function CountdownTimer({ targetDate, labels }: CountdownTimerProps) {
  const [timeLeft, setTimeLeft] = useState<TimeLeft | null>(() => calcTimeLeft(targetDate));

  useEffect(() => {
    const id = setInterval(() => setTimeLeft(calcTimeLeft(targetDate)), 1000);
    return () => clearInterval(id);
  }, [targetDate]);

  if (!timeLeft) {
    return (
      <p className="text-center text-xl font-extrabold text-gold-500">{labels.started}</p>
    );
  }

  const units = [
    { value: timeLeft.days, label: labels.days },
    { value: timeLeft.hours, label: labels.hours },
    { value: timeLeft.minutes, label: labels.minutes },
    { value: timeLeft.seconds, label: labels.seconds },
  ];

  return (
    <div className="flex items-center gap-3 sm:gap-4" aria-live="off">
      {units.map(({ value, label }, i) => (
        <div key={label} className="flex items-center gap-3 sm:gap-4">
          <div className="flex flex-col items-center">
            <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 sm:h-16 sm:w-16">
              <span className="text-2xl font-extrabold tabular-nums sm:text-3xl">
                {String(value).padStart(2, "0")}
              </span>
            </div>
            <span className="mt-1 text-[10px] font-bold uppercase tracking-widest opacity-75">
              {label}
            </span>
          </div>
          {i < units.length - 1 && (
            <span className="mb-5 text-2xl font-extrabold opacity-50 sm:text-3xl">:</span>
          )}
        </div>
      ))}
    </div>
  );
}
