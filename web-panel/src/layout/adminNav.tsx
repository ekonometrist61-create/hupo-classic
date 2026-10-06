import type { AppRole } from "@/hooks/useCurrentRole";
import {
  BoltIcon,
  BoxIcon,
  DocsIcon,
  DollarLineIcon,
  GridIcon,
  GroupIcon,
  LockIcon,
  MailIcon,
  PaperPlaneIcon,
  PieChartIcon,
  PlugInIcon,
  ShootingStarIcon,
  TableIcon,
  TaskIcon,
  UserCircleIcon,
} from "../icons/index";

export type NavEntry = {
  /** `yonetim.shell.nav.*` çeviri anahtarı */
  key: string;
  icon: React.ReactNode;
  /** Yoksa ekran henüz yok; "Yakında" olarak tıklanamaz görünür. */
  path?: string;
  roles: AppRole[];
};

export type NavGroup = {
  /** `yonetim.shell.groups.*` çeviri anahtarı */
  key: string;
  items: NavEntry[];
};

const ADMIN: AppRole[] = ["admin"];

export const NAV_GROUPS: NavGroup[] = [
  {
    key: "workspace",
    items: [
      { key: "overview", icon: <GridIcon />, path: "/yonetim", roles: ADMIN },
      { key: "members", icon: <GroupIcon />, path: "/yonetim/kullanicilar", roles: ADMIN },
      { key: "leads", icon: <UserCircleIcon />, path: "/yonetim/veli-adaylari", roles: ADMIN },
      { key: "classes", icon: <TableIcon />, path: "/yonetim/siniflar", roles: ADMIN },
      { key: "myClasses", icon: <TableIcon />, path: "/yonetim/siniflar", roles: ["ogretmen"] },
    ],
  },
  {
    key: "content",
    items: [
      { key: "questions", icon: <DocsIcon />, path: "/yonetim/sorular", roles: ADMIN },
    ],
  },
  {
    key: "growth",
    items: [
      { key: "notifications", icon: <MailIcon />, path: "/yonetim/bildirimler", roles: ADMIN },
      { key: "coupons", icon: <ShootingStarIcon />, path: "/yonetim/kuponlar", roles: ADMIN },
      { key: "segments", icon: <PieChartIcon />, path: "/yonetim/segmentler", roles: ADMIN },
      { key: "campaigns", icon: <PaperPlaneIcon />, path: "/yonetim/kampanyalar", roles: ADMIN },
      { key: "journeys", icon: <BoltIcon />, path: "/yonetim/otomasyonlar", roles: ADMIN },
      { key: "forms", icon: <TaskIcon />, path: "/yonetim/anketler", roles: ADMIN },
    ],
  },
  {
    key: "business",
    items: [
      { key: "payments", icon: <DollarLineIcon />, path: "/yonetim/odemeler", roles: ADMIN },
      { key: "plans", icon: <BoxIcon />, path: "/yonetim/planlar", roles: ADMIN },
      { key: "analytics", icon: <PieChartIcon />, path: "/yonetim/analitik", roles: ADMIN },
      { key: "access", icon: <LockIcon />, path: "/yonetim/ekip", roles: ADMIN },
      { key: "channels", icon: <PlugInIcon />, path: "/yonetim/kanal-ayarlari", roles: ADMIN },
    ],
  },
  {
    key: "other",
    items: [
      {
        key: "parentPanel",
        icon: <UserCircleIcon />,
        path: "/veli-paneli",
        roles: ["admin", "veli"],
      },
    ],
  },
];

/** Verilen rol için görünür grupları döndürür; boş kalan gruplar atılır. */
export function navForRole(role: AppRole | null): NavGroup[] {
  if (role === null) return [];
  return NAV_GROUPS.map((g) => ({
    ...g,
    items: g.items.filter((i) => i.roles.includes(role)),
  })).filter((g) => g.items.length > 0);
}

/** /yonetim/* altında en uzun eşleşen girdiyi bulur (breadcrumb için). */
export function findNavEntry(pathname: string): NavEntry | null {
  let best: NavEntry | null = null;
  for (const g of NAV_GROUPS) {
    for (const i of g.items) {
      if (!i.path) continue;
      const match = pathname === i.path || pathname.startsWith(i.path + "/");
      if (match && (!best || i.path.length > (best.path?.length ?? 0))) best = i;
    }
  }
  return best;
}
