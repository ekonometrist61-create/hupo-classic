import { vurguParcalari } from "@/lib/soru-vurgu";

interface QuestionRichTextProps {
  /** Ham soru kökü metni (değiştirilmez). */
  metin: string;
  /** [{ start, end }] kod noktası ofsetleri; geçersizse düz metin gösterilir. */
  highlights?: unknown;
}

/**
 * Soru kökünü akıllı vurgu ile gösterir: kalın (700) + altın alt çizgi.
 * Çağıran kendi <p> / <h*> öğesini sarar; bu bileşen yalnız içeriği üretir.
 * Görünüm .soru-vurgu sınıfından (globals.css) ve --soru-vurgu-* token'larından gelir.
 * Yalnız soru köküne uygulanır; seçenek metni veya doğru cevap durumuyla bağlantısı yoktur.
 */
export default function QuestionRichText({ metin, highlights }: QuestionRichTextProps) {
  const parcalar = vurguParcalari(metin, highlights);
  if (parcalar.length === 1 && !parcalar[0].vurgulu) return <>{metin}</>;
  return (
    <>
      {parcalar.map((p, i) =>
        p.vurgulu ? (
          <strong key={i} className="soru-vurgu" data-soru-vurgu="">
            {p.metin}
          </strong>
        ) : (
          <span key={i}>{p.metin}</span>
        ),
      )}
    </>
  );
}
