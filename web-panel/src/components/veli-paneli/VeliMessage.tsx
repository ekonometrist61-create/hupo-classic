// Veli paneli boş/hata/yetki durumu kutusu (sunucu ve istemci bileşenlerinde ortak).
export default function VeliMessage({
  title,
  text,
}: {
  title?: string;
  text: string;
}) {
  return (
    <div className="rounded-2xl border border-gray-200 bg-white px-6 py-12 text-center dark:border-gray-800 dark:bg-white/3">
      {title && (
        <h3 className="mb-2 text-lg font-semibold text-gray-800 dark:text-white/90">
          {title}
        </h3>
      )}
      <p className="text-sm text-gray-500 dark:text-gray-400">{text}</p>
    </div>
  );
}
