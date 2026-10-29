# Geri bildirim: okuma hikâyeleri denetiminden çıkan bilgi (2026-10-24)

Kime: `meb-soru-sozcuk-uzmani` skill'i üzerinde çalışan oturum (7. sınıf paketleri, 8. sınıf geçişi).
Kaynak: 45 yeni taslak hikâye için Ajan A (olgu ve doğruluk) ve Ajan B (uygunluk ve kalite) denetimi, 90 rapor.
Dayanak: `docs/okuma-entegrasyon/denetim/2026-10-23/OZET.md` ve `HR-XXX-ajan-a/b.md`.

## 1. Sonuç özeti
- 45 hikâyenin hiçbiri iki denetçiden de `pass` almadı. Ajan A: 16 pass, 28 review_needed, 1 fail. Ajan B: 44 review_needed, 1 fail.
- Yüksek bulgu: Ajan A 9, Ajan B 34 kez geçiyor. Yüksek bulgusu olmayan 24 hikâye var (bkz. K-0110).
- Kural notu: talimatta `pass` = kritik ve yüksek yok, yalnız düşük/orta. Ama birçok `review_needed` raporunda yüksek bulgu yok, yalnızca birden fazla orta bulgu var. Skill'de bu iki ölçütü ayır: "yüksek yok" ile "pass" aynı şey değildir.

## 2. Tekrar eden hatalar (ne aranmalı)

1. **Yer tutucu hal eki (en sık).** `[?kahraman]` gibi yer tutucuların hal bilgisi yok; `YOLDAŞ`'ta `hal=yalin` var. Ad durum ekini almadan cümleye girince cümleler bozuluyor (HR-033, 041, 046, 047). Kural: her yer tutucu, cümlede kullanıldığı hâli (yalın, iyelik, yönelme) taşımalı.
2. **Sabit ad ile yer tutucu karışması.** Açıklamada veya soruda sabit bir ad ("Ece", "Bora") geçiyor; hikâyede kahraman yer tutucu. Çocuğun seçtiği kahramanla açıklama tutmuyor (HR-006, 028, 042). Kural: soru kökü ve açıklama yer tutucu ile yazılır ya da adsız anlatılır.
3. **Ders cümlesi (vaaz) sayfaya yapışıyor.** Neredeyse her sayfa "fark etti / anladı / öğrendi" kalıbıyla kapanıyor (HR-041, 043, 044, 046; HR-005, 014). Kural: bir hikâyede en fazla bir ahlak cümlesi, sahneye kurulu olmalı; anlatıcı öğüt vermez.
4. **Şık dengesi (soru).** Altı, yedi ya da sekiz sorunun hepsinde doğru şık açık ara en uzun ve en ayrıntılı şık; çeldiriciler çoğu zaman saçma (HR-031, 043, 047). Kural: doğru şık diğerleriyle aynı uzunlukta; çeldiriciler metinle ilgili ve makul olmalı.
5. **Olay sırası ve tanıtım.** Karakter ve yer tanıtılmadan kullanılıyor; aynı olay iki kez anlatılıyor (belediye yanıtı, HR-043; raf keşfi, HR-045); sayfalar yamalı (HR-042, 046, 047). Kural: her öğe ilk geçtiği yerde tanıtılır; olay sırası zaman çizgisinde kontrol edilir.
6. **Karakter sesi.** Replik yanlış karaktere verilmiş (HR-006: parası olan kahraman değil Yoldaş konuşuyor). Kural: replik–karakter eşlemesi her sayfada kontrol edilir.
7. **Atasözü ve deyim biçimi.** Atasözü yerleşik biçimiyle yazılmamış ("Sormakla yol bulunur" yerine "Yol sormakla bulunur", HR-005). Atasözü öğrenme hedefi, metinde anlatılan anlamla eşleşmiyor (HR-006). Kural: atasözü yerleşik biçimde ve sözlük anlamıyla yazılır.
8. **Yoldaş yer tutucusu imla.** Yedek ad ünlüyle bitiyorsa bağlaç ünlü uyumuyla yazılmalı ("Hupo d", "Hupo de" değil; HR-004).
9. **Matematik örüntüsü.** Dizi "farklı" diye tanımlanıp aynı dizi "sabit fark" olarak da yazılıyor (HR-047). Kural: örüntü tanımı ve örnek tutarlı olmalı.
10. **Bilmece ve çözüm.** Eş anlamlı iki cevap birden kabul ediliyor, çözüm keyfi (HR-010).

## 3. Soru üretimi için somut kurallar (K kayıtlarından)
- Zorluk 3 hedefi (%20) hiçbir derste tutmadı: Türkçe ve Hayat Bilgisi'nde %11 (K-0102). Yazarlar tek adımlı soru üretiyor. Zorluk 3 için en az iki metin parçasını birleştiren soru yazımı açık bir yöntem olarak tanımlanmalı.
- Dinleme ve konuşma kazanımları (İngilizce L/S kodları) yazılı soruyla ölçülemez. Vekil ölçüm kazanımı yanlış beyan eder (K-0104, K-0105). Kural: yalnız yazılı beceri ölçülen kodlar yazılı soruya bağlanır.
- Benzerlik: kaynak parmak izi ve veritabanı içi 6-gram kontrolü birlikte kullanılmalı (K-0108).
- İnsan örneklemi (REHBER §15) yapılmadan yayınlanan sorular `kalite_durumu='sari'` olarak kalır. Kullanıcı kararıyla yayına alındılar (K-0104). Bu durum skill'de açıkça işaretlenmeli.

## 4. Denetim süreci (ajanlar için)
- Kör denetim: denetçi yalnız hikâye ve ölçütü görür, diğer denetçinin raporunu okumaz. Bu desen 90 raporda uygulandı.
- Ajan A (olgu): iddialar, sözlük anlamları, cevap anahtarı, dayanak sayfası, kurgu tutarlılığı.
- Ajan B (uygunluk): yaş ve kelime yükü, güvenlik, vaaz, dil bilgisi, soru kalitesi, etiket tutarlılığı.
- Denetçi kaynak dosyayı değiştirmez; yalnız kendi raporunu yazar.
- Yayın kapısı: iki denetçi de `pass` ve insan `approved` olmadan yayınlanmaz. Bu kapı veritabanında da zorlanıyor. Kullanıcı kararıyla (K-0110) yayın kapısı yüksek bulgusu olmayan hikâyeler için gevşetilecek; bu değişiklik henüz uygulanmadı.

## 5. Skill'e önerilen ekler
- Yukarıdaki on hatayı "Önce kontrol et" listesine koy.
- `pass` ve `review_needed` ölçütünü açıkça ayır (bkz. 1).
- Her hikâye için sayfa ve soru bazlı kontrol tablosu üret; yalnız genel yorum değil.
- Öğrenme günlüğüne bu belgeyi referans olarak ekle; yeni hatalar buraya değil `ogrenme-gunlugu.md` dosyasına.

Son not: Bu belgedeki sayılar denetim raporlarından alındı; yeni bir hikâye için mutlaka yeniden denetle.
