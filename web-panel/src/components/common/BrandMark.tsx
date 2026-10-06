import Image from "next/image";

/** Onaylı Hupo maskotu + "hupolingo" yazısı. Repoda resmi logo dosyası bulunana kadar
 *  TailAdmin logolarının yerine geçer. `onDark`: lacivert zemin için açık yazı rengi. */
export default function BrandMark({
  onDark = false,
  compact = false,
}: {
  onDark?: boolean;
  compact?: boolean;
}) {
  return (
    <span className="flex items-center gap-2.5">
      <span className="grid size-9 shrink-0 place-items-center rounded-xl bg-gold-500">
        <Image
          src="/hupo/hosgeldin.webp"
          alt={compact ? "Hupolingo" : ""}
          width={28}
          height={28}
          priority
          className="size-7 object-contain"
        />
      </span>
      {!compact && (
        <span
          className={`text-[25px] leading-none font-extrabold tracking-[-1.5px] ${
            onDark ? "text-white" : "text-navy dark:text-white"
          }`}
        >
          hupolingo
        </span>
      )}
    </span>
  );
}
