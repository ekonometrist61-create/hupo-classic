import { useTranslations } from "next-intl";

export default function SidebarWidget() {
  const t = useTranslations("sidebar.widget");
  return (
    <div className="pb-20">
      <div className="mx-auto rounded-2xl bg-gray-50 px-4 py-5 text-center dark:bg-white/3">
        <p className="text-xs text-gray-400 dark:text-gray-500">{t("version")}</p>
      </div>
    </div>
  );
}
