import Badge from "@/components/ui/badge/Badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

import ChartCard from "./ChartCard";
import type { ReviewTopic } from "./types";

interface ReviewTopicsListProps {
  topics: ReviewTopic[];
  labels: {
    title: string;
    desc: string;
    /** Veri kaynağı ve oranın ne anlama geldiği (açıklanabilirlik). */
    kaynak?: string;
    /** Oran yeterli veri olmadığında gösterilen metin (ör. "az veri"). */
    azVeri: string;
    empty: string;
    topic: string;
    subject: string;
    wrong: string;
    due: string;
    success: string;
  };
}

function successBadgeColor(percent: number | null) {
  if (percent === null) return "light" as const;
  if (percent >= 70) return "success" as const;
  if (percent >= 40) return "warning" as const;
  return "error" as const;
}

// Tekrar önerileri: 768 px altında kart listesi, md ve üzerinde tablo (R4).
// Tablo kendi kapsayıcısında kayar; sayfa yatay taşmaz.
export default function ReviewTopicsList({
  topics,
  labels,
}: ReviewTopicsListProps) {
  const headerClass =
    "py-3 pe-4 text-start text-theme-xs font-medium text-gray-500 dark:text-gray-400";
  const cellClass = "py-3 pe-4 text-theme-sm text-gray-700 dark:text-gray-300";

  return (
    <ChartCard title={labels.title} desc={labels.desc} kaynak={labels.kaynak}>
      {topics.length === 0 ? (
        <p className="py-10 text-center text-sm text-gray-500 dark:text-gray-400">
          {labels.empty}
        </p>
      ) : (
        <>
          <ul className="space-y-3 md:hidden">
            {topics.map((topic) => (
              <li
                key={`m-${topic.ders}-${topic.konu}`}
                className="min-w-0 rounded-xl border border-gray-100 p-4 dark:border-gray-800"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <p className="font-medium wrap-break-word text-gray-800 dark:text-white/90">
                      {topic.konu}
                    </p>
                    <p className="mt-0.5 text-theme-xs text-gray-500 dark:text-gray-400">
                      {topic.ders}
                    </p>
                  </div>
                  <Badge size="sm" color={successBadgeColor(topic.oran)}>
                    {topic.oran === null ? labels.azVeri : `%${topic.oran}`}
                  </Badge>
                </div>
                <dl className="mt-3 grid grid-cols-1 gap-3 text-theme-sm sm:grid-cols-2">
                  <div>
                    <dt className="text-gray-500 dark:text-gray-400">{labels.wrong}</dt>
                    <dd className="font-medium text-gray-800 dark:text-white/90">{topic.yanlis}</dd>
                  </div>
                  <div>
                    <dt className="text-gray-500 dark:text-gray-400">{labels.due}</dt>
                    <dd className="font-medium text-gray-800 dark:text-white/90">{topic.bekleyen}</dd>
                  </div>
                </dl>
              </li>
            ))}
          </ul>

          <div className="hidden max-w-full overflow-x-auto md:block">
            <Table>
              <TableHeader className="border-b border-gray-100 dark:border-gray-800">
                <TableRow>
                  <TableCell isHeader className={headerClass}>
                    {labels.topic}
                  </TableCell>
                  <TableCell isHeader className={headerClass}>
                    {labels.subject}
                  </TableCell>
                  <TableCell isHeader className={headerClass}>
                    {labels.wrong}
                  </TableCell>
                  <TableCell isHeader className={headerClass}>
                    {labels.due}
                  </TableCell>
                  <TableCell isHeader className={headerClass}>
                    {labels.success}
                  </TableCell>
                </TableRow>
              </TableHeader>
              <TableBody className="divide-y divide-gray-100 dark:divide-gray-800">
                {topics.map((topic) => (
                  <TableRow key={`${topic.ders}-${topic.konu}`}>
                    <TableCell
                      className={`${cellClass} font-medium text-gray-800 dark:text-white/90`}
                    >
                      {topic.konu}
                    </TableCell>
                    <TableCell className={cellClass}>{topic.ders}</TableCell>
                    <TableCell className={cellClass}>{topic.yanlis}</TableCell>
                    <TableCell className={cellClass}>{topic.bekleyen}</TableCell>
                    <TableCell className={cellClass}>
                      <Badge size="sm" color={successBadgeColor(topic.oran)}>
                        {topic.oran === null ? labels.azVeri : `%${topic.oran}`}
                      </Badge>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </>
      )}
    </ChartCard>
  );
}
