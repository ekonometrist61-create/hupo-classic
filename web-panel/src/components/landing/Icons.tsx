import type { SVGProps } from "react";

type IconProps = SVGProps<SVGSVGElement>;

function Base({ children, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
      {...props}
    >
      {children}
    </svg>
  );
}

export const IconTimer = (p: IconProps) => (
  <Base {...p}>
    <circle cx="12" cy="13" r="8" />
    <path d="M12 9v4l2.5 2.5M9 2h6" />
  </Base>
);

export const IconSteps = (p: IconProps) => (
  <Base {...p}>
    <path d="M4 6h3M4 12h3M4 18h3" />
    <path d="M11 6h9M11 12h9M11 18h9" />
  </Base>
);

export const IconChart = (p: IconProps) => (
  <Base {...p}>
    <path d="M4 20V10M10 20V4M16 20v-7M22 20H2" />
  </Base>
);

export const IconShield = (p: IconProps) => (
  <Base {...p}>
    <path d="M12 3l8 3v6c0 4.5-3.2 8-8 9-4.8-1-8-4.5-8-9V6l8-3z" />
    <path d="M9 12l2 2 4-4" />
  </Base>
);

export const IconUserCheck = (p: IconProps) => (
  <Base {...p}>
    <circle cx="9" cy="8" r="3.5" />
    <path d="M2.5 20c.6-3.3 3.2-5.5 6.5-5.5s5.9 2.2 6.5 5.5" />
    <path d="M16.5 11l2 2 3.5-3.5" />
  </Base>
);

export const IconLock = (p: IconProps) => (
  <Base {...p}>
    <rect x="5" y="11" width="14" height="9" rx="2" />
    <path d="M8 11V8a4 4 0 018 0v3" />
  </Base>
);

export const IconCompass = (p: IconProps) => (
  <Base {...p}>
    <circle cx="12" cy="12" r="9" />
    <path d="M15.5 8.5l-2 5-5 2 2-5 5-2z" />
  </Base>
);

export const IconRepeat = (p: IconProps) => (
  <Base {...p}>
    <path d="M17 2l3 3-3 3" />
    <path d="M4 11V9a4 4 0 014-4h12" />
    <path d="M7 22l-3-3 3-3" />
    <path d="M20 13v2a4 4 0 01-4 4H4" />
  </Base>
);

export const IconCheck = (p: IconProps) => (
  <Base {...p}>
    <path d="M5 12.5l4.5 4.5L19 7.5" />
  </Base>
);

export const IconArrowRight = (p: IconProps) => (
  <Base {...p}>
    <path d="M5 12h14M13 6l6 6-6 6" />
  </Base>
);

export const IconChevronDown = (p: IconProps) => (
  <Base {...p}>
    <path d="M6 9l6 6 6-6" />
  </Base>
);

export const IconInfo = (p: IconProps) => (
  <Base {...p}>
    <circle cx="12" cy="12" r="9" />
    <path d="M12 11v5M12 8h.01" />
  </Base>
);

export const IconMenu = (p: IconProps) => (
  <Base {...p}>
    <path d="M4 7h16M4 12h16M4 17h16" />
  </Base>
);

export const IconClose = (p: IconProps) => (
  <Base {...p}>
    <path d="M6 6l12 12M18 6L6 18" />
  </Base>
);

export const IconDevice = (p: IconProps) => (
  <Base {...p}>
    <rect x="6" y="2" width="12" height="20" rx="2.5" />
    <path d="M10 18h4" />
  </Base>
);

export const IconImage = (p: IconProps) => (
  <Base {...p}>
    <rect x="3" y="4" width="18" height="16" rx="2" />
    <circle cx="9" cy="10" r="1.75" />
    <path d="M21 16l-5.5-5.5a1.5 1.5 0 00-2.12 0L5 19" />
  </Base>
);

export const IconSparkle = (p: IconProps) => (
  <Base {...p}>
    <path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8L12 3z" />
  </Base>
);

export const IconCrown = (p: IconProps) => (
  <Base {...p}>
    <path d="M3 19h18M5 19l2-8 5 4 5-4 2 8" />
    <circle cx="5" cy="9" r="1.5" />
    <circle cx="19" cy="9" r="1.5" />
    <circle cx="12" cy="5" r="1.5" />
  </Base>
);

export const IconStar = (p: IconProps) => (
  <Base {...p}>
    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
  </Base>
);

export const IconUsers = (p: IconProps) => (
  <Base {...p}>
    <circle cx="9" cy="7" r="3.5" />
    <path d="M2.5 21c.6-3.3 3.2-5.5 6.5-5.5s5.9 2.2 6.5 5.5" />
    <path d="M17 8c1.7.1 3 1.5 3 3.2 0 1.4-.8 2.6-2 3.2" />
    <path d="M21 21c-.5-2.6-2.3-4.5-4.5-5" />
  </Base>
);

export const IconTrophy = (p: IconProps) => (
  <Base {...p}>
    <path d="M8 21h8M12 17v4" />
    <path d="M7 4H5a1 1 0 00-1 1v3a4 4 0 004 4h1" />
    <path d="M17 4h2a1 1 0 011 1v3a4 4 0 01-4 4h-1" />
    <path d="M8 4h8v8a4 4 0 01-8 0V4z" />
  </Base>
);

export const IconBook = (p: IconProps) => (
  <Base {...p}>
    <path d="M4 19.5A2.5 2.5 0 016.5 17H20" />
    <path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z" />
  </Base>
);

export const IconTarget = (p: IconProps) => (
  <Base {...p}>
    <circle cx="12" cy="12" r="9" />
    <circle cx="12" cy="12" r="5" />
    <circle cx="12" cy="12" r="1" />
  </Base>
);

export const IconHeart = (p: IconProps) => (
  <Base {...p}>
    <path d="M20.8 4.6a5.5 5.5 0 00-7.8 0L12 5.6l-1-1a5.5 5.5 0 00-7.8 7.8l1 1L12 21l7.8-7.8 1-1a5.5 5.5 0 000-7.6z" />
  </Base>
);

export const IconCalendar = (p: IconProps) => (
  <Base {...p}>
    <rect x="3" y="4" width="18" height="18" rx="2" />
    <path d="M16 2v4M8 2v4M3 10h18" />
  </Base>
);

export const IconClock = (p: IconProps) => (
  <Base {...p}>
    <circle cx="12" cy="12" r="9" />
    <path d="M12 7v5l3.5 3.5" />
  </Base>
);

export const IconGlobe = (p: IconProps) => (
  <Base {...p}>
    <circle cx="12" cy="12" r="9" />
    <path d="M2 12h20M12 3c-2.3 2.8-3.5 5.8-3.5 9s1.2 6.2 3.5 9c2.3-2.8 3.5-5.8 3.5-9S14.3 5.8 12 3z" />
  </Base>
);

export const IconTextSize = (p: IconProps) => (
  <Base {...p}>
    <path d="M4 7V5h16v2M9 5v14M15 11v8M11 19h4M7 19h4" />
  </Base>
);

export const IconGamepad = (p: IconProps) => (
  <Base {...p}>
    <rect x="2" y="7" width="20" height="12" rx="4" />
    <path d="M7 13h4M9 11v4M17 12h.01M15 14h.01" />
  </Base>
);

export const IconMedal = (p: IconProps) => (
  <Base {...p}>
    <circle cx="12" cy="15" r="5" />
    <path d="M8.5 15l-4-9M15.5 15l4-9M7 6h10" />
  </Base>
);

export const IconTwitter = (p: IconProps) => (
  <Base {...p}>
    <path d="M4 4l16 16M4 20L20 4" strokeWidth={2.5} />
    <path d="M4 4h4l4 6 4-6h4L12 14l8 6h-4l-4-6-4 6H4l8-6L4 4z" />
  </Base>
);

export const IconInstagram = (p: IconProps) => (
  <Base {...p}>
    <rect x="3" y="3" width="18" height="18" rx="5" />
    <circle cx="12" cy="12" r="4" />
    <circle cx="17.5" cy="6.5" r="1" fill="currentColor" stroke="none" />
  </Base>
);

export const IconLinkedIn = (p: IconProps) => (
  <Base {...p}>
    <rect x="2" y="2" width="20" height="20" rx="4" />
    <path d="M7 10v7M7 7h.01M11 17v-4a2 2 0 014 0v4M11 10v7" />
  </Base>
);

export const IconYoutube = (p: IconProps) => (
  <Base {...p}>
    <rect x="2" y="5" width="20" height="14" rx="4" />
    <path d="M10 9l6 3-6 3V9z" fill="currentColor" stroke="none" />
  </Base>
);

export const IconCheckCircle = (p: IconProps) => (
  <Base {...p}>
    <circle cx="12" cy="12" r="9" />
    <path d="M9 12l2 2 4-4" />
  </Base>
);

export const IconX = (p: IconProps) => (
  <Base {...p}>
    <circle cx="12" cy="12" r="9" />
    <path d="M15 9l-6 6M9 9l6 6" />
  </Base>
);
