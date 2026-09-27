// Tarayici tarafindan desteklenen depolama arayuzu.
// localStorage veya bellek ici (SSR) adapter'lar bu arayuzu saglar.

export interface SupportedStorage {
  getItem(key: string): string | null;
  setItem(key: string, value: string): void;
  removeItem(key: string): void;
}
