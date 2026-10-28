# HUPO — Pedagoji, Hikâye, Soru, Sözcük ve Sınav Skill Paketi (v1.0)

**24 sınıfa özel skill + 1 ana orkestratör.** 24 Ekim 2026. Hupolingo/HupoRead/Hupo Atlas için Claude Code deposuna yerleştirilmeye hazır; **MEB onaylı değildir**.

## Kurulum

1. Bu ZIP'i açın; içindeki `.claude/` klasörünü ve `CLAUDE.md` dosyasını Claude Code proje köküne **birleştirerek** kopyalayın. Mevcut CLAUDE.md'niz varsa dosyayı silmeyin, Hupo bölümünü ekleyin.
2. Claude Code içinde `/hupo-egitim-uzmani` komutuyla ana skill'i çağırın veya talepte adı belirtin.
3. İlgili sınıf ve iş türüne göre `hupo-s{1..8}-hikaye`, `hupo-s{1..8}-soru`, `hupo-s{1..8}-sozcuk` skill'leri de bulunur.
4. Gerekirse `python scripts/validate_content.py --file examples/soru_ornek.json --mode question` çalıştırın. Toplu yapısal kontrol: `python scripts/audit_package.py`.

## Dosya düzeni

- `.claude/skills/hupo-egitim-uzmani/SKILL.md` → ana koordinasyon, routing, yayın kapıları.
- `.claude/skills/hupo-s1-hikaye/SKILL.md` ... `.claude/skills/hupo-s8-sozcuk/SKILL.md` → 24 bağımsız, sınıfa özgü skill.
- `docs/` → pedagojik formasyon, öğrenme bilimi, kaynak denetimi, blueprint, sınav ve hikâye süreci.
- `data/` → program sürümü, sınıf profilleri, kaynak kayıtları; **241 doğrulanmamış aday kavram** özgün CSV.
- `references/onceki_hupo_calismalari/` → kullanıcının daha önceki rehberlerinden ve özgün hikâye taslaklarından seçili çalışma referansları.
- `scripts/` → basit otomatik kalite kontrolleri. Bunlar öğretmen/pedagog onayının yerine geçmez.

## Kırmızı çizgiler

- 2026–27 için TYMM **1,2,3,5,6,7**; **4 ve 8 önceki program**. İçeriğin üretildiği yıl değişirse yeniden doğrula.
- 241 kavram listesi MEB'in zorunlu listesi **değildir**. Kaynak→öğrenme çıktısı→insan onayı olmadan resmî kazanım diye yazma.
- HupoRead 2026 yarışma sınıf uzunlukları proje içi **tam hikâye hedefi** olarak kullanılır; tüm MEB metinlerinin zorunlu kelime sayısı değildir.
- Fikir aşamasındaki hikâyeye `published=true` deme. Uzunluk uygunluğu tek başına editoryal/müfredat onayı değildir.
- Okul yazılısı, LGS, İOKBS, günlük alıştırma **farklı sınav modlarıdır**. Senaryo yoksa sınavı kesin kapsamlı sayma.
- MEB veya yayınevi sorularını metinsel taklitle çoğaltma; yalnız **özellik/blueprint analizi** yap.
- 2026 MEB hikâye yarışması **AI kullanımını yasaklar**; HupoRead üretimleri o yarışmaya bu şekilde sunulamaz.

## İlk komut önerisi

> /hupo-egitim-uzmani 5. sınıf Fen Bilimleri, 2026–27 1. dönem ilk yazılı için okul senaryosu henüz yok. MEB'i kontrol et; senaryosuz kesin sınav deme; önce öğrenme çıktısı listesi ve beceri haritası çıkar, sonra 10 özgün soru, cevap anahtarı ve açık uçlu rubrik üret. Hataları raporla.

Bu paket mevcut Hupo içeriklerini **otomatik olarak yayımlamaz/sertifikalandırmaz**; üretim–denetim işleyişi kurar. Öğrenci uygulama verileri mahrem ve toplu analizle değerlendirilmelidir.
