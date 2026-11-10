# HR-132 · Araç ve İki Zaman Çizelgesi · Düzeltme günlüğü

Dosya: `icerik/okuma/hikaye/hr132-arac-iki-zaman-cizelgesi.hikaye.md`
Girdi: HR-132-ajan-a.md, HR-132-ajan-b.md
Sonuç: 11 bulgudan 10'u uygulandı, 1'i atlandı (gerekçesi aşağıda). Durum `taslak`, `denetim` alanları `pending` olarak bırakıldı.

## Uygulanan bulgular

1. **[A orta] Son sahnede pano hangi istasyonda belli değildi** (sayfa 1: kalkış; sayfa 6: son durak)
   - Önce: "Son durakta istasyon görevlisi panodaki iki çizelgenin üzerine açık tarih etiketleri koydu."
   - Sonra: "Son durakta istasyon görevlisi, aynı iki çizelgenin asılı olduğu panoya açık tarih etiketleri koydu."
   - s5 dayanağı aynı cümleyle güncellendi (metinde birebir).

2. **[A düşük] Tanıtım metninde karar treni yapıyormuş gibi okunuyordu**
   - Önce: "Gece treni, hangi çizelgenin geçerli olduğunu tarihlere bakarak belirler."
   - Sonra: "{kahraman}, hangi çizelgenin geçerli olduğunu tarihlere bakarak anlar."

3. **[A düşük] s4 açıklaması iki kaynağı (merkez bilgisi ve görevli talimatı) yansıtmıyordu**
   - Önce: "Duraklama süreleri görevli talimatlarına bağlıydı; bu yüzden değiştirilmedi."
   - Sonra: "Ek bekleme merkezden bildirildi; duraklama süreleri ise görevli talimatlarına bağlıydı, bu yüzden yolcuların telafi önerisi doğrudan uygulanmadı."

4. **[B orta] Sayfa 4 genelleme ve "fark etti" kalıbı**
   - Önce: "{kahraman}, herkese aynı çözümün uymadığını fark etti. Tren için ortak güzergâh vardı ama yolcuların sonraki adımları kendi koşullarına göre değişiyordu."
   - Sonra: "{kahraman}, bağlantısı olan her yolcuya kendi güzergâhını ve sonraki aktarmasını ayrı ayrı sordu." (genelleme yerine iki yolcunun ayrı tepkisi/eylemi; "güzergâh" sözcüğü hedef olarak korundu.)

5. **[B orta] Sayfa 5 anlatıcı kurgu dışına çıkıp bilgi veriyordu**
   - Önce: "Bir çizelge, belli bir zamanda yapılması planlanan işleri gösteriyordu. Oysa plan, değişen koşullar karşısında yetkili kişilerce güncellenebilirdi."
   - Sonra: çıkarıldı.

6. **[B orta] s1 D şıkkı metinde geçmeyen bir kavramdı** ("Kıyı hattı çizelgesi")
   - Önce: "Kıyı hattı çizelgesi" → Sonra: "Bu gece hiçbiri geçerli değildi" (metinle ilişkili, yanlış seçenek).

7. **[B düşük] Sayfa 6 tekil fiil uyuşmazlığı**
   - Önce: "ertesi gün gelecek yolcular hangi bilgiyi kullanacağını anlayacaktı."
   - Sonra: "ertesi gün gelecek yolcular hangi bilgiyi kullanacaklarını anlayacaklardı."

8. **[B düşük] s4 çeldiricileri metinle açıkça çelişiyordu**
   - B önce: "Çizelge tamamen kaybolmuştu" → sonra: "Yolcular bekleme süresini kendileri seçmişti"
   - C önce: "İstasyon o gece kapanmıştı" → sonra: "Kontrol merkezi o gece kapalıydı"
   - Her iki çeldirici metinle ilişkili ama yanlış; doğru şık (A) değişmedi.

9. **[B düşük] Sayfa 2 beş dakikalık bekleme bilgisi sonra kullanılmıyordu**
   - Önce: "Eski çizelgede bir küçük istasyonda beş dakikalık bekleme vardı. Yeni çizelgede bu bekleme kaldırılmıştı."
   - Sonra: çıkarıldı. Sayfa 2'deki tarih karşılaştırması (ana fikir) korunur.

10. **[B düşük] Front matter `yetiskin_uygun` eksik**
    - `yetiskin_uygun: false` eklendi.

## Atlanan bulgular

- **[B düşük] Edebi tekrar: "{kahraman}" öznesinin çok sık tekrarı.** Atlandı. Gerekçe: bulgu "düşük" önceliklidir ve metindeki birkaç özne değişikliği, kurgu sırasını ve ritmi değiştirme riski taşır; kural 5 gereği düzeltme minimal tutuldu. Editör kalem düzeltmesinde değerlendirebilir.

## Doğrulanamayan olgular (değiştirilmedi, listelendi)
- Teknik inceleme, yürürlük tarihi ve duraklama talimatı gibi işleyişlerin gerçek demiryolu prosedürüne uygunluğu doğrulanmadı; kurgusal hatta tutarlı.
- TDK karşılıkları ("güzergâh", "telafi", "aktarma") doğrulanmadı (`sozluk_tdk: pending`).
- D16 ve D1 değer kodlarının anlamı ve maarif eşlemesi doğrulanmadı.
- Kazanım kodu yok (`curriculum_status: source_pending`).
