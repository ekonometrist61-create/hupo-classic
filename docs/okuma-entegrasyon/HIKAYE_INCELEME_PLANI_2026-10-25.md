# Hikâye gözden geçirme planı (2026-10-25)

Amaç: 45 taslak hikâyeyi en az token ile "Ajan A geçti + Ajan B geçti + insan onayı" durumuna getirmek. Kaynak: `denetim/2026-10-23/OZET.md` (90 rapor). Skill: `meb-soru-sozcuk-uzmani`. Kural: iki bağımsız denetçi `pass` + insan onayı olmadan `published=true` yapılmaz; AI ile hikâye yazma yasağı (MEB yarışması) hikâyenin yayın dışı kullanımını etkilemez, ama düzeltmeler insan editör kararıyla yapılır.

## Önce bilinmesi gereken
- Panelde "Bekliyor" yazması, denetim sonuçlarının veritabanına hiç yazılmamasındandır; sonuçlar yalnız `HR-XXX-ajan-a/b.md` dosyalarında. Parti 0 bunu kapatır.
- Bugünkü sonuç: iki ajandan da `pass` alan 0 hikâye; Ajan A 16 pass, Ajan B 0 pass (44 `review_needed`, HR-017 `fail`).

## Parti 0: Durumu panele yansıt (ucuz, ilk iş)
- OZET.md tablosundaki Ajan A/B değerlerini 45 sürümün `denetim` alanına yaz (insan `pending` kalır). Tek betik, model çağrısı yok.
- Sonuç: panelde rozetler gerçek durumu gösterir; "Ajan A ve B geçti" süzgeci çalışır.

## Parti 1: HR-017 (ajan A ve B `fail`)
- Tek hikâye, ayrı ele alınır: bulgu raporu oku, düzelt veya yayın dışı bırak kararı (kullanıcıda).

## Parti 2: Ajan A geçmiş 16 hikâye (yalnız Ajan B bulguları)
HR-009, 012, 014, 015, 018, 019, 022, 023, 024, 025, 026, 027, 029, 032, 036, 037.
- Her hikâye için yalnız `ajan-b.md` okunur (hikâyenin tamamı değil); bulgu satırındaki cümle düzeltilir.
- 4'erli 4 alt parti. Her alt partide: düzelt, yalnız değişen hikâyelere Ajan B yeniden çalıştır, sonuçları panele yaz.
- Hedef: bu 16 hikâye ilk iki ajan kapısını geçer; insan okuması için hazır olur.

## Parti 3: İkisi de `review_needed` olan 28 hikâye (düşük/orta bulgu)
HR-001…008, 010, 013, 016, 021, 028, 030, 031, 033…035, 038…040.
- 7'şerli 4 alt parti. Sıra: önce bulgusu en az olanlar (rapordaki bulgu sayısına göre).
- Her hikâye için A ve B raporundaki bulgular tek listede birleştirilir, bir kez düzeltilir, A ve B yalnız değişen hikâyelerde yeniden çalışır.

## Parti 4: Yüksek bulgulular
HR-041…047: yazar/editör düzeltmesi gerekir. Yüksek bulgu satırları kullanıcıya özetlenir, karar sonrası düzeltilir. En sona bırakıldı, çünkü en pahalısı.

## Parti 5: İnsan onayı
- İnsan okuması kullanıcıda. Panelde süzgeç "Ajan A ve B geçti" ile gelen hikâyeler okunur, sonra **Seçilenleri onayla** ile toplu onaylanır (yalnız A ve B geçmiş taslak/incelemedekiler onaylanır).
- Onaydan sonra sürümü "incelemeye gönder", dört göz kuralına göre ikinci kişi yayınlar.

## Token tasarrufu kuralları
1. Hikâyenin tamamı yerine yalnız bulgu satırı ve ilgili cümle okunur.
2. Yeniden denetim yalnız değişen hikâyelerde ve yalnız önceki bulgu maddeleri için yapılır.
3. Her partiden sonra `ogrenme-gunlugu.md` ve PROJE_GUNLUGU.md tek satır güncellenir; parti bitmeden sonrakine geçilmez.
4. Yinelenen bulgu türleri (ör. aynı cümle kalıbı) bir kez kurala çevrilir, sonraki hikâyelerde baştan uygulanır.
