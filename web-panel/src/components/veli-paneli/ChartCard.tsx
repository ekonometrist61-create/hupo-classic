interface ChartCardProps {
  title: string;
  desc?: string;
  /** Veri kaynağı ve ölçüm tanımı (açıklanabilirlik): ne ölçüldüğü ve nereden geldiği. */
  kaynak?: string;
  children: React.ReactNode;
}

export default function ChartCard({ title, desc, kaynak, children }: ChartCardProps) {
  return (
    <div className="min-w-0 rounded-2xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-white/3">
      <div className="px-5 pt-5 pb-4 sm:px-6 sm:pt-6">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">
          {title}
        </h3>
        {desc && (
          <p className="mt-1 text-theme-sm text-gray-500 dark:text-gray-400">
            {desc}
          </p>
        )}
        {kaynak && (
          <p className="mt-2 text-theme-xs text-gray-500 dark:text-gray-400">
            {kaynak}
          </p>
        )}
      </div>
      <div className="min-w-0 px-3 pb-5 sm:px-6 sm:pb-6">{children}</div>
    </div>
  );
}
