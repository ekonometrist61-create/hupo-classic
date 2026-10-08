export interface CharacterDef {
  kod: string;
  displayOrder: number; // order within the class (1=first/revealed, 5=last/hardest)
}

export interface CharacterClass {
  kod: string;
  color: string;
  bgClass: string;
  characters: CharacterDef[];
}

export const CHARACTER_CLASSES: CharacterClass[] = [
  {
    kod: "ozgur_ruhlar",
    color: "#6CAF45",
    bgClass: "bg-green-100 dark:bg-green-900/30",
    characters: [
      { kod: "ozgur_ruh", displayOrder: 1 },
      { kod: "kivilcim", displayOrder: 2 },
      { kod: "ateskanat", displayOrder: 3 },
      { kod: "gece_kartali", displayOrder: 4 },
      { kod: "oba_muhafizi", displayOrder: 5 },
    ],
  },
  {
    kod: "firtina",
    color: "#4EA9D9",
    bgClass: "bg-blue-100 dark:bg-blue-900/30",
    characters: [
      { kod: "ruzgar_ciragi", displayOrder: 1 },
      { kod: "ruzgar_kosucusu", displayOrder: 2 },
      { kod: "simsek", displayOrder: 3 },
      { kod: "firtina_binicisi", displayOrder: 4 },
      { kod: "firtina_ustasi", displayOrder: 5 },
    ],
  },
  {
    kod: "kasifler",
    color: "#F59E42",
    bgClass: "bg-orange-100 dark:bg-orange-900/30",
    characters: [
      { kod: "iz_surucu", displayOrder: 1 },
      { kod: "yol_bulucu", displayOrder: 2 },
      { kod: "sir_avcisi", displayOrder: 3 },
      { kod: "buyuk_kasif", displayOrder: 4 },
      { kod: "dunya_kasifi", displayOrder: 5 },
    ],
  },
  {
    kod: "bozkir",
    color: "#B07D4B",
    bgClass: "bg-amber-100 dark:bg-amber-900/30",
    characters: [
      { kod: "bozkir_yoldasi", displayOrder: 1 },
      { kod: "bozkir_izci", displayOrder: 2 },
      { kod: "bozkir_kurdu", displayOrder: 3 },
      { kod: "bozkir_kartali", displayOrder: 4 },
      { kod: "bozkir_reisi", displayOrder: 5 },
    ],
  },
  {
    kod: "zihin_ustalari",
    color: "#8B5CF6",
    bgClass: "bg-purple-100 dark:bg-purple-900/30",
    characters: [
      { kod: "fikir_kivilcimi", displayOrder: 1 },
      { kod: "bilgi_avcisi", displayOrder: 2 },
      { kod: "bulmaca_ustasi", displayOrder: 3 },
      { kod: "akil_ustasi", displayOrder: 4 },
      { kod: "zihin_simsegi", displayOrder: 5 },
    ],
  },
  {
    kod: "muhafizlar",
    color: "#147D8A",
    bgClass: "bg-teal-100 dark:bg-teal-900/30",
    characters: [
      { kod: "genc_muhafiz", displayOrder: 1 },
      { kod: "kale_bekcisi", displayOrder: 2 },
      { kod: "gok_muhafizi", displayOrder: 3 },
      { kod: "ates_muhafizi", displayOrder: 4 },
      { kod: "bas_muhafiz", displayOrder: 5 },
    ],
  },
  {
    kod: "ustalar",
    color: "#F5C842",
    bgClass: "bg-yellow-100 dark:bg-yellow-900/30",
    characters: [
      { kod: "genc_kemankes", displayOrder: 1 },
      { kod: "usta_kemankes", displayOrder: 2 },
      { kod: "gok_akincisi", displayOrder: 3 },
      { kod: "ustalar_firtina", displayOrder: 4 },
      { kod: "buyuk_usta", displayOrder: 5 },
    ],
  },
  {
    kod: "efsaneler",
    color: "#6B7280",
    bgClass: "bg-gray-100 dark:bg-gray-800",
    characters: [
      { kod: "ay_kasifi", displayOrder: 1 },
      { kod: "gunes_muhafizi", displayOrder: 2 },
      { kod: "goklerin_akincisi", displayOrder: 3 },
      { kod: "simsek_kagani", displayOrder: 4 },
      { kod: "efsaneler_efsanesi", displayOrder: 5 },
    ],
  },
];
