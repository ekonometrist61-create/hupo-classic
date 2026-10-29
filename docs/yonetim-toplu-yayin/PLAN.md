# Toplu seçim ve yayın yönetimi — Sorular ve Kelime Evreni (2026-10-25)

## Hedef
Admin, soru ve kelime listelerinde birden çok kayıt seçebilsin, "tümünü seç" yapabilsin, seçilileri
**yayına alsın** veya **yayından kaldırsın**.

## Mevcut durum (kodda doğrulandı)
- Sorular (`QuestionsManager.tsx`, `QuestionsTable.tsx`): çoklu seçim + sayfa içi tümünü seç + toplu
  Onayla/Reddet/Beklemede/Sil VAR. Eksik: filtredeki TÜM sonucu (sayfalar ötesi) seçmek; "yayın" dili.
  Sunucu: `admin_set_question_status(p_ids, p_durum)`; durumlar `beklemede|onaylandi|reddedildi`.
  Öğrenciye yalnız `onaylandi` görünür → "Yayına al" = onaylandi, "Yayından kaldır" = beklemede.
- Kelime Evreni (`KelimeEvreniManager.tsx`): ana listede seçim YOK; toplu yayın yalnız inceleme
  kuyruğunda (`KelimeIncelemeKuyrugu.tsx`, `kelime_toplu_yayinla`, referans alınacak desen).
  Durumlar: `taslak|incelemede|yayinda|arsiv`. Tek kayıt RPC: `kelime_soru_durum_degistir(p_id,p_hedef)`.
- Yayın kapısı (iki bağımsız model `pass` + insan onayı) sunucuda; istemci atlatmaz, atlananları gösterir.

## Kararlar
- Yeni migrasyon YOK. Sunucu kuralı değişmez.
- Kelime yayına al: `kelime_toplu_yayinla` (önce kuru çalıştırma `p_kuru:true`, özet göster, onayla,
  sonra `p_kuru:false`). Yalnız `incelemede` olanlar yayınlanır; diğerleri "atlandı" olarak sayılır.
- Kelime yayından kaldır: seçilenlerden `yayinda` olanlar için `kelime_soru_durum_degistir(id,'arsiv')`,
  10'arlı paralel gruplarla; hata alan sayılır, durmaz.
- Metinler Türkçe + İngilizce (mevcut i18n dosyaları), dokunma hedefi 44 px (`dokunmaHedefi`/`min-h-11`).

## İş paketleri
- **İP-1 Sorular** (dosyalar: `QuestionsManager.tsx`, gerekirse `QuestionsTable.tsx`,
  `web-panel/src/messages/yonetim-sorular.{tr,en}.json`)
  1. Filtredeki tüm soruları seç: mevcut `approveAllFiltered` deseniyle (`admin_list_questions`,
     100'lük sayfalar) tüm id'leri topla → `selected`. Düğme: "Filtredekilerin tümünü seç (N)".
     Seçili çubuğunda "Seçimi temizle".
  2. Toplu çubuk etiketleri: "Yayına al" (onaylandi), "Yayından kaldır" (beklemede), "Reddet", "Sil".
     Çoklu işlemde (>1 kayıt) `window.confirm` ile sayı göster.
  3. Mevcut davranış ve kazanımsız mod bozulmasın.
- **İP-2 Kelime Evreni** (dosyalar: `KelimeEvreniManager.tsx`, `kelimeEvreni.ts` gerekirse, i18n dosyası
  `yonetim.kelimeEvreni` anahtarlarının bulunduğu `web-panel/src/messages/yonetim-panel.{tr,en}.json`)
  1. Kart ve tabloda onay kutusu (44 px sarmalayıcı), başlıkta "sayfadakilerin tümünü seç",
     üstte "Listedeki tümünü seç (N)" ve "Seçimi temizle". Seçim filtre/yenilemede sıfırlanır.
  2. Seçili çubuğu: "Yayına al" (kuru çalıştırma → özet → onay → yayın; en fazla 200 id), "Yayından kaldır".
     Sonuç mesajı: "X yayınlandı, Y atlandı". `ErrorNote`/mesaj desenini kullan.
  3. Satır içi tek kayıt eylemleri değişmez.
- **İP-3 Doğrulama** (asistan yapar): `tsc`, lint, i18n tr/en anahtar eşitliği, mevcut testler,
  PROJE_GUNLUGU kaydı. Görsel kontrol yapılamazsa açıkça yazılır.

## Kabul ölçütleri
- Sorular: 60 soruluk filtrede "tümünü seç" 60 seçer; Yayına al → hepsi onaylandi; Yayından kaldır → beklemede.
- Kelime: 3 incelemede + 2 yayında seçilince Yayına al "3 yayınlandı, 2 atlandı" (kapı geçmeyen atlanır);
  Yayından kaldır 2 yayındakini arşivler, diğerlerini atlar.
- tsc/lint temiz; tr ve en anahtar kümeleri eşit; 375 px genişlikte çubuk taşmaz (kod düzeyinde: flex-wrap).
