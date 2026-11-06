// 7. sınıf Fen Bilimleri — ışığın kırılması (FB.7.4.1), mercekler (FB.7.4.2), atom modeli (FB.7.5.1), periyodik tabloda grup ve periyot (FB.7.5.6).
import { sayiSik, pencereSik, kirilmaHesap, katmanDagilim, periyodikKonumlar, grupNo } from '../tipler-b2.mjs';
const MUFREDAT = 'MEB 2026-2027 çerçeve yıllık plan (Fen Bilimleri 7. sınıf; program: TYMM)';
const HARF = ['K', 'L', 'M', 'N'];

// ---- kırılma ----
const AD = { hava: 'hava', su: 'su', cam: 'cam' };
const YOGUN = { hava: 0, su: 1, cam: 2 };
const PARLAR = [['hava', 'su'], ['hava', 'cam'], ['su', 'hava'], ['cam', 'hava'], ['su', 'cam'], ['cam', 'su']];
export function kurKirilma({ sec, karistir, ekle, konum }) {
  function kirilmaSorusu() {
    const k = konum(), [ust, alt] = sec(PARLAR), th = sec([20, 25, 30, 35, 40, 45, 50, 55]), r = kirilmaHesap(ust, alt, th);
    if (r == null) throw new Error('tam_yansima');
    const yaklasir = YOGUN[alt] > YOGUN[ust], f = yaklasir ? 1 : -1, fark = Math.abs(th - r);
    const yanlis = [th, th + f * (10 + fark), th + f * (22 + fark)];
    const dig = karistir(yanlis), acilar = [...dig]; acilar.splice(k, 0, r);
    const durum = (a) => (Math.abs(a - th) < 1e-9 ? 'duz' : (a > th) === yaklasir ? 'ters' : 'dogru');
    ekle({ kod: 'FB.7.4.1', konu: 'Işık', alt_konu: 'Işığın kırılması', zorluk: 2,
      spec: { tip_id: 'b2-kirilma', parametreler: { ust, alt, gelen: th, adaylar: acilar.map((aci, i) => ({ ad: HARF[i], aci })) } }, sirali: HARF, dogru: HARF[k],
      kok: sec([`Şekilde bir ışık ışını ${AD[ust]} ortamından ${AD[alt]} ortamına geçerken gösterilmiştir. Işın ${AD[alt]} ortamında hangi harfle gösterilen yolu izler?`, `Yukarıdaki şekilde ${AD[ust]} ortamından ${AD[alt]} ortamına gelen bir ışın vardır. Işının ${AD[alt]} ortamındaki yolu aşağıdakilerden hangisidir?`]),
      gerekce: HARF.map((h, i) => (i === k ? '' : durum(acilar[i]) === 'duz' ? `${h} yolu, ışının ortam değiştirirken doğrultusunu hiç değiştirmediğini gösterir; ışık, ortam değiştirirken kırılır.` : `${h} yolunda ışın ${yaklasir ? 'normalden uzaklaşacak biçimde' : 'normale yaklaşacak biçimde'} kırılmıştır; ${AD[ust]} ortamından ${AD[alt]} ortamına geçen ışın ise ${yaklasir ? 'normale yaklaşır' : 'normalden uzaklaşır'}.`)),
      ipucu: yaklasir ? 'Işık daha yoğun ortama geçerken normale yaklaşarak kırılır.' : 'Işık daha az yoğun ortama geçerken normalden uzaklaşarak kırılır.',
      cozum: [`${AD[alt]} ortamı ${AD[ust]} ortamından ${yaklasir ? 'daha yoğundur' : 'daha az yoğundur'}.`, `Işın ${yaklasir ? 'normale yaklaşarak' : 'normalden uzaklaşarak'} kırılır; bu yol ${HARF[k]} ile gösterilmiştir.`],
      dogrulama: [{ yol: ['kirilan'], beklenen: HARF[k] }] });
  }
  return { kirilmaSorusu };
}

// ---- mercek ----
const TUM = ['cift-tumsek', 'duz-tumsek', 'cift-cukur', 'duz-cukur'], TUMSEK = ['cift-tumsek', 'duz-tumsek'], CUKUR = ['cift-cukur', 'duz-cukur'];
export function kurMercek({ R, sec, ekle, konum }) {
  function mercekSorusu() {
    const k = konum(), topla = R() < 0.5, hedefGrup = topla ? TUMSEK : CUKUR, digGrup = topla ? CUKUR : TUMSEK;
    const sekiller = HARF.map((_, i) => (i === k ? sec(hedefGrup) : sec(digGrup)));
    void TUM;
    ekle({ kod: 'FB.7.4.2', konu: 'Işık', alt_konu: 'Mercek çeşitleri', zorluk: 2,
      spec: { tip_id: 'b2-mercek', parametreler: { paneller: HARF.map((ad, i) => ({ ad, sekil: sekiller[i] })) } }, sirali: HARF, dogru: HARF[k],
      kok: topla ? sec(['Şekilde dört mercek ve merceklere gelen paralel ışınlar gösterilmiştir. Hangi mercek, ışınları bir noktada toplar (yakınsatır)?', 'Aşağıdaki panellerde farklı mercekler ve ışınların merceklerden geçişi gösterilmiştir. Hangi panelde ışınları toplayan mercek vardır?'])
        : sec(['Şekilde dört mercek ve merceklere gelen paralel ışınlar gösterilmiştir. Hangi mercek, ışınları dağıtır (ıraksatır)?', 'Aşağıdaki panellerde farklı mercekler ve ışınların merceklerden geçişi gösterilmiştir. Hangi panelde ışınları dağıtan mercek vardır?']),
      gerekce: HARF.map((h, i) => (i === k ? '' : topla ? `${h} panelindeki mercek kenarları ortasından kalın (çukur) bir mercektir; ışınları toplamaz, dağıtır.` : `${h} panelindeki mercek kenarları ortasından ince (tümsek) bir mercektir; ışınları dağıtmaz, toplar.`)),
      ipucu: 'Işınların merceği geçtikten sonra birbirine yaklaşıp yaklaşmadığına ve merceğin kenarlarının kalın mı ince mi olduğuna bak.',
      cozum: [topla ? 'İnce kenarlı (tümsek) mercekler ışınları toplar.' : 'Kalın kenarlı (çukur) mercekler ışınları dağıtır.', `${HARF[k]} panelinde ışınlar merceği geçtikten sonra ${topla ? 'bir noktada birleşiyor' : 'birbirinden uzaklaşıyor'}.`],
      dogrulama: HARF.map((h, i) => ({ yol: ['tur', h], beklenen: (i === k) === topla ? 'yakinsak' : 'iraksak' })) });
  }
  return { mercekSorusu };
}

// ---- atom ----
const ELEMENT_N = { 3: 4, 4: 5, 5: 6, 6: 6, 7: 7, 8: 8, 9: 10, 10: 10, 11: 12, 12: 12, 13: 14, 14: 14, 15: 16, 16: 16, 17: 18, 18: 22 };
export function kurAtom({ R, sec, ekle, konum }) {
  const kod = { kod: 'FB.7.5.1', konu: 'Madde ve Değişim', alt_konu: 'Atomun yapısı ve temel parçacıkları' };
  const giris = 'Şekilde bir atomun modeli verilmiştir. Çekirdekteki p proton, n nötron sayısını; halkalar üzerindeki noktalar elektronları göstermektedir.';
  function atomSorusu() {
    const k = konum(), z = sec(Object.keys(ELEMENT_N).map(Number)), n = ELEMENT_N[z], kat = katmanDagilim(z), tur = sec(['elektron', 'sonkatman', 'kutle', 'atomno', 'katman']);
    const spec = { tip_id: 'b2-atom', parametreler: { z, n } };
    let dogru, kok, tercih, ipucu, cozum, gerekceF, olgu, bicim = (v) => String(v), min = 0, max = 40;
    if (tur === 'elektron') { dogru = z; kok = `${giris} Bu atom toplam kaç elektrona sahiptir?`; tercih = [z + n, kat[kat.length - 1], kat.length]; olgu = 'elektron'; min = 1; max = 40;
      ipucu = 'Halkalardaki tüm noktaları (elektronları) say.'; cozum = ['Her halkadaki elektron sayısını bulup topla.', `${kat.join(' + ')} = ${z} elektron.`];
      gerekceF = (v) => (v === kat[kat.length - 1] ? `${v}, yalnız son halkadaki elektron sayısıdır; tüm halkalardaki elektronlar sayılmalıdır.` : v === z + n ? `${v}, proton ve nötron sayılarının toplamıdır (kütle numarası); elektron sayısı değildir.` : `${v}, halkalardaki noktaların sayısıyla uyuşmuyor.`); }
    else if (tur === 'sonkatman') { dogru = kat[kat.length - 1]; kok = `${giris} Bu atomun en dış katmanında (son halkasında) kaç elektron vardır?`; tercih = [z, kat[0], kat.length]; olgu = 'son_katman'; min = 1; max = 9;
      ipucu = 'En dıştaki halkada bulunan noktaları say.'; cozum = ['En dıştaki halkaya bak.', `Son halkada ${dogru} elektron vardır.`];
      gerekceF = (v) => (v === z ? `${v}, atomdaki toplam elektron sayısıdır; son katmandaki elektron sayısı değildir.` : `${v}, en dıştaki halkadaki nokta sayısı değildir.`); }
    else if (tur === 'kutle') { dogru = z + n; kok = `${giris} Bu atomun kütle numarası (proton sayısı + nötron sayısı) kaçtır?`; tercih = [z, n, z + z]; olgu = 'kutle'; min = 1; max = 45;
      ipucu = 'Çekirdeğin içinde yazan proton ve nötron sayılarını topla.'; cozum = [`Çekirdekte ${z} proton ve ${n} nötron vardır.`, `Kütle numarası: ${z} + ${n} = ${z + n}.`];
      gerekceF = (v) => (v === z ? `${v}, yalnız proton sayısıdır; kütle numarası için nötronlar da eklenmelidir.` : v === n ? `${v}, yalnız nötron sayısıdır; kütle numarası için protonlar da eklenmelidir.` : `${v}, proton ve nötron sayılarının toplamı değildir.`); }
    else if (tur === 'atomno') { dogru = z; kok = `${giris} Bu atomun atom numarası kaçtır? (Atom numarası, proton sayısına eşittir.)`; tercih = [z + n, n, kat[kat.length - 1]]; olgu = 'proton'; min = 1; max = 45;
      ipucu = 'Atom numarası, çekirdekteki proton sayısıdır.'; cozum = ['Atom numarası proton sayısına eşittir.', `Çekirdekte ${z} proton vardır.`];
      gerekceF = (v) => (v === z + n ? `${v}, kütle numarasıdır; atom numarası yalnız proton sayısıdır.` : v === n ? `${v}, nötron sayısıdır; atom numarası proton sayısıdır.` : `${v}, çekirdekteki proton sayısı değildir.`); }
    else { dogru = kat.length; kok = `${giris} Bu atomun elektronları kaç katmana (halkaya) yerleşmiştir?`; tercih = []; olgu = 'katman'; min = 1; max = 4;
      ipucu = 'Çekirdeği çevreleyen halkaları say.'; cozum = ['Her halka bir elektron katmanını gösterir.', `Şekilde ${dogru} halka vardır.`];
      gerekceF = (v) => `${v} katman, şekildeki halka sayısıyla uyuşmuyor.`; }
    const s = sayiSik(dogru, k, R, { min, max, genislik: 3, tercih, bicim });
    const dogrulama = [{ yol: [olgu], beklenen: dogru }];
    ekle({ ...kod, zorluk: tur === 'kutle' ? 3 : 2, spec, sirali: s.sirali, dogru: String(dogru), kok, gerekce: s.degerler.map((v) => (v === dogru ? '' : gerekceF(v))), ipucu, cozum, dogrulama });
  }
  return { atomSorusu };
}

// ---- periyodik tablo ----
export function kurPeriyodik({ R, sec, karistir, ekle, konum }) {
  const kod = { kod: 'FB.7.5.6', konu: 'Madde ve Değişim', alt_konu: 'Periyodik tabloda grup ve periyot' };
  const TUMK = periyodikKonumlar();
  const ciftler = [['K', 'L'], ['K', 'M'], ['K', 'N'], ['L', 'M'], ['L', 'N'], ['M', 'N']], ciftMetin = (c) => `${c[0]} ve ${c[1]}`;
  const giris = 'Şekilde periyodik tablonun ilk 18 elementi gösterilmiştir. K, L, M ve N harfleri bazı elementlerin yerlerini göstermektedir (harfler elementlerin sembolü değildir).';
  const ayni = (a, b, alan) => a[alan] === b[alan];
  function periyodikSorusu() {
    const tur = sec(['konum', 'grup', 'periyot']), k = konum();
    let hucreler;
    if (tur === 'konum') {
      hucreler = karistir(TUMK).slice(0, 4);
      const hedef = HARF[k], c = hucreler[k];
      const spec = { tip_id: 'b2-periyodik', parametreler: { isaretler: hucreler.map((h, i) => ({ ad: HARF[i], satir: h.satir, sutun: h.sutun })) } };
      ekle({ ...kod, zorluk: 2, spec, sirali: HARF, dogru: hedef,
        kok: `${giris} Hangi harfle gösterilen element ${c.satir + 1}. periyot ${grupNo(c.sutun)}. gruptadır?`,
        gerekce: HARF.map((h, i) => (i === k ? '' : `${h} ile gösterilen element ${hucreler[i].satir + 1}. periyot ${grupNo(hucreler[i].sutun)}. gruptadır.`)),
        ipucu: 'Periyotlar yatay satırlardır, gruplar dikey sütunlardır. Satır ve sütun numaralarını kullan.',
        cozum: [`${c.satir + 1}. periyodun satırını ve ${grupNo(c.sutun)}. grubun sütununu bul.`, `Bu satır ve sütunun kesiştiği yerde ${hedef} harfi vardır.`],
        dogrulama: [{ yol: ['konum', hedef], beklenen: { periyot: c.satir + 1, grup: grupNo(c.sutun) } }] });
      return;
    }
    // aynı grupta / aynı periyotta olan iki element
    const alan = tur === 'grup' ? 'sutun' : 'satir', diger = tur === 'grup' ? 'satir' : 'sutun';
    for (let deneme = 0; deneme < 30; deneme++) {
      const adaylar = karistir(TUMK), a = adaylar[0], b = adaylar.find((x) => x !== a && x[alan] === a[alan] && x[diger] !== a[diger]);
      if (!b) continue;
      const kalan = adaylar.filter((x) => x !== a && x !== b && x[alan] !== a[alan]), secilen = [];
      for (const x of kalan) if (secilen.length < 2 && secilen.every((y) => y[alan] !== x[alan]) && (tur === 'grup' || secilen.every((y) => y[alan] !== x[alan]))) secilen.push(x);
      if (secilen.length < 2) continue;
      const dort = karistir([a, b, ...secilen]);
      const idxA = dort.indexOf(a), idxB = dort.indexOf(b), cift = [HARF[Math.min(idxA, idxB)], HARF[Math.max(idxA, idxB)]];
      const dogruIdx = ciftler.findIndex((c) => c[0] === cift[0] && c[1] === cift[1]);
      const sec4 = pencereSik(ciftler, dogruIdx, k, R);
      const sirali = sec4.map((i) => ciftMetin(ciftler[i]));
      const spec = { tip_id: 'b2-periyodik', parametreler: { isaretler: dort.map((h, i) => ({ ad: HARF[i], satir: h.satir, sutun: h.sutun })) } };
      const bilgi = (h) => dort[HARF.indexOf(h)];
      ekle({ ...kod, zorluk: 2, spec, sirali, dogru: ciftMetin(cift),
        kok: `${giris} Hangi iki harfle gösterilen element ${tur === 'grup' ? 'aynı grupta' : 'aynı periyotta'} bulunur?`,
        gerekce: sec4.map((i) => { if (i === dogruIdx) return ''; const [p, q] = ciftler[i], P = bilgi(p), Q = bilgi(q); return tur === 'grup' ? `${p} elementi ${grupNo(P.sutun)}. grupta, ${q} elementi ${grupNo(Q.sutun)}. gruptadır; farklı gruplardadır.` : `${p} elementi ${P.satir + 1}. periyotta, ${q} elementi ${Q.satir + 1}. periyottadır; farklı periyotlardadır.`; }),
        ipucu: tur === 'grup' ? 'Aynı gruptaki elementler tabloda aynı dikey sütundadır.' : 'Aynı periyottaki elementler tabloda aynı yatay satırdadır.',
        cozum: [tur === 'grup' ? 'Aynı grup, aynı sütun demektir.' : 'Aynı periyot, aynı satır demektir.', `${cift[0]} ve ${cift[1]} harfleri tabloda aynı ${tur === 'grup' ? 'sütunda' : 'satırda'} yer alır.`],
        dogrulama: [{ yol: ['konum', cift[0], tur === 'grup' ? 'grup' : 'periyot'], beklenen: tur === 'grup' ? grupNo(bilgi(cift[0]).sutun) : bilgi(cift[0]).satir + 1 }, { yol: ['konum', cift[1], tur === 'grup' ? 'grup' : 'periyot'], beklenen: tur === 'grup' ? grupNo(bilgi(cift[1]).sutun) : bilgi(cift[1]).satir + 1 }] });
      return;
    }
    throw new Error('yerlesim_bulunamadi');
    void ayni;
  }
  return { periyodikSorusu };
}

export const KAYIT = [
  { id: 'b2-fen7-kirilma', ders: 'Fen Bilimleri', sinif: 7, idOnek: 'FEN7-KIR', mufredat_surum: MUFREDAT, kodlar: ['FB.7.4.1'], fabrika: kurKirilma, uret: (f) => f.kirilmaSorusu() },
  { id: 'b2-fen7-mercek', ders: 'Fen Bilimleri', sinif: 7, idOnek: 'FEN7-MER', mufredat_surum: MUFREDAT, kodlar: ['FB.7.4.2'], fabrika: kurMercek, uret: (f) => f.mercekSorusu() },
  { id: 'b2-fen7-atom', ders: 'Fen Bilimleri', sinif: 7, idOnek: 'FEN7-ATM', mufredat_surum: MUFREDAT, kodlar: ['FB.7.5.1'], fabrika: kurAtom, uret: (f) => f.atomSorusu() },
  { id: 'b2-fen7-periyodik', ders: 'Fen Bilimleri', sinif: 7, idOnek: 'FEN7-PER', mufredat_surum: MUFREDAT, kodlar: ['FB.7.5.6'], fabrika: kurPeriyodik, uret: (f) => f.periyodikSorusu() },
];
