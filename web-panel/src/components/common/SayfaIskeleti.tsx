/** Sayfa geçişinde yeni içerik gelene kadar gösterilen iskelet (loading.tsx dosyaları kullanır).
 *  Kenar menü ve üst çubuk layout'ta kaldığı için yerinde durur; yalnızca içerik alanı bu iskeleti gösterir. */
export default function SayfaIskeleti({ etiket }: { etiket: string }) {
  const kutu = "animate-pulse motion-reduce:animate-none bg-gray-200 dark:bg-gray-800";

  return (
    <div role="status" aria-live="polite" className="space-y-5">
      <span className="sr-only">{etiket}</span>
      <div aria-hidden className="space-y-2">
        <div className={`h-8 w-56 max-w-full rounded-lg ${kutu}`} />
        <div className="h-4 w-80 max-w-full animate-pulse rounded bg-gray-100 motion-reduce:animate-none dark:bg-gray-800/70" />
      </div>
      <div aria-hidden className="grid gap-4 md:grid-cols-3">
        {[0, 1, 2].map((i) => (
          <div key={i} className={`h-28 rounded-2xl ${kutu}`} />
        ))}
      </div>
      <div aria-hidden className={`h-72 rounded-2xl ${kutu}`} />
    </div>
  );
}
