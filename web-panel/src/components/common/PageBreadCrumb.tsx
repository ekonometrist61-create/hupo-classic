interface PageHeaderProps {
  pageTitle: string;
  /** Başlığın üstündeki küçük etiket (örn. "HUPO / OPERASYON"). */
  eyebrow?: string;
  description?: string;
  /** Sağ üstte duran birincil/ikincil eylemler. */
  actions?: React.ReactNode;
}

/** Hupo Yönetim Merkezi sayfa başlığı: eyebrow + H1 + açıklama + eylemler.
 *  (Dosya adı geçmiş uyumluluğu için korunuyor; tüm sayfalar bunu kullanır.) */
const PageBreadcrumb: React.FC<PageHeaderProps> = ({
  pageTitle,
  eyebrow = "H U P O  /  O P E R A S Y O N",
  description,
  actions,
}) => {
  return (
    <div className="mb-6 flex flex-wrap items-end justify-between gap-4">
      <div className="min-w-0">
        <div className="mb-1.5 text-[11px] font-bold tracking-[1px] text-brand-500 dark:text-brand-400">
          {eyebrow}
        </div>
        <h1 className="text-2xl font-semibold tracking-tight text-navy md:text-[28px] dark:text-white/90">
          {pageTitle}
        </h1>
        {description && (
          <p className="mt-1.5 text-theme-sm text-gray-500 dark:text-gray-400">
            {description}
          </p>
        )}
      </div>
      {actions && <div className="flex flex-wrap items-center gap-2.5">{actions}</div>}
    </div>
  );
};

export default PageBreadcrumb;
