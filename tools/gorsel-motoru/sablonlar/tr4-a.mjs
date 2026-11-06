// 4. sınıf Türkçe (önceki program) — T.4.4.9 Formları yönergelerine uygun doldurur.
// Form kartında bir alana başka bir alanın bilgisi yazılmıştır; hatalı alan kodla belirlenir.
import { surum } from './turkce3-ortak.mjs';

const MUFREDAT = surum('kazanim_4_turkce_onceki');
const ADLAR = ['Elif Kaya', 'Mert Demir', 'Ada Yılmaz', 'Can Aydın', 'Zeynep Arslan', 'Emir Çelik', 'Defne Koç', 'Kerem Şahin', 'Işıl Öztürk', 'Barış Güneş'];
const HAVUZ = {
  'Adı soyadı': ADLAR,
  'Sınıfı': ['4-A', '4-B', '4-C', '4-D', '4-E'],
  'Doğum yeri': ['Konya', 'Samsun', 'Edirne', 'Van', 'Sivas', 'Muğla', 'Bursa', 'Rize'],
  'Boyu': ['128 cm', '131 cm', '134 cm', '137 cm', '140 cm', '143 cm', '146 cm'],
};

export function kur({ R, sec, karistir, ekle }) {
  function formSorusu() {
    const etiketler = Object.keys(HAVUZ);
    const hatali = sec(etiketler);
    const kaynak = sec(etiketler.filter((e) => e !== hatali));
    const satirlar = etiketler.map((etiket) => ({ etiket, deger: sec(HAVUZ[etiket]) }));
    satirlar.find((s) => s.etiket === hatali).deger = sec(HAVUZ[kaynak]);
    const cel = etiketler.filter((e) => e !== hatali);
    const yanlis = satirlar.find((s) => s.etiket === hatali).deger;
    ekle({ kod: 'T.4.4.9', konu: 'Form doldurma', alt_konu: 'Formdaki alanın yönergesine uygun doldurulup doldurulmadığını denetleme', zorluk: 2,
      spec: { tip_id: 'belge-kart', parametreler: { tur: 'Form', baslik: 'Öğrenci Bilgi Formu', satirlar } },
      kok: 'Her alana o alanın istediği bilgi yazılmalıdır. Öğrenci bilgi formunda hangi alan yönergeye uygun doldurulmamıştır?',
      dogru: hatali, celdirici: cel,
      gerekce: cel.map((c) => `"${c}" alanına bu alanın istediği türden bilgi yazılmıştır.`),
      ipucu: 'Her alanın adını ve yanına yazılan bilgiyi sırayla oku; bilginin alanla uyuşup uyuşmadığına bak.',
      cozum: ['Her alandaki bilgi, alanın adıyla karşılaştırılır.', `"${hatali}" alanına "${yanlis}" yazılmıştır; bu bilgi bu alanın istediği türden değildir.`],
      dogrulama: [{ yol: ['alanlar', hatali], beklenen: yanlis }] });
  }
  return { formSorusu };
}

export const KAYIT = [
  { id: 'tr4-form', ders: 'Türkçe', sinif: 4, idOnek: 'TR4-FRM', mufredat_surum: MUFREDAT, kodlar: ['T.4.4.9'], fabrika: kur, uret: (f) => f.formSorusu() },
];
