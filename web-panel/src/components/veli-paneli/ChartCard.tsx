interface ChartCardProps {
  title: string;
  desc?: string;
  children: React.ReactNode;
}

export default function ChartCard({ title, desc, children }: ChartCardProps) {
  return (
    <div className="rounded-2xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-white/3">
      <div className="px-5 pt-5 pb-4 sm:px-6 sm:pt-6">
        <h3 className="text-lg font-semibold text-gray-800 dark:text-white/90">
          {title}
        </h3>
        {desc && (
          <p className="mt-1 text-theme-sm text-gray-500 dark:text-gray-400">
            {desc}
          </p>
        )}
      </div>
      <div className="px-3 pb-5 sm:px-6 sm:pb-6">{children}</div>
    </div>
  );
}
