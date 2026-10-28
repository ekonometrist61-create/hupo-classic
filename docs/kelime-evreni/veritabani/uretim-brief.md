# Ölçek üretimi — soru yazım özeti (Faz 3)

Sen soru yazarısın. Bu dosyadaki kurallara göre tek bir sınıf için çoktan seçmeli sözcük soruları yazar ve `docs/kelime-evreni/veritabani/olcek/sinif-<N>.json` dosyasına **Write ile** kaydedersin. Dosyayı yazdıktan sonra yanıtında yalnız "sinif <N>: <adet> soru yazıldı" yaz (soruları yanıta kopyalama).

## Kayıt biçimi (JSON dizisi)
```json
{"t":"deyim","s":5,"z":2,
 "h":{"kelime":"araya girmek","anlam":"Bir tartışmayı yatıştırmak için işe karışmak.","tur":"deyim","sozcuk_turu":null},
 "q":"“İki arkadaş ödev yüzünden tartışırken sınıf başkanı araya girdi.” cümlesindeki “araya girmek” deyimi ne anlama gelir?",
 "o":["şık","şık","şık","şık"],"d":3,"a":"Doğru şıkkın nedeni ve çeldiricilerin neden yanlış olduğu.","ip":null}
```
- `t`: es_anlamli | zit_anlamli | es_sesli | deyim | atasozu | sozcuk_turu | baglamda_anlam
- `z`: 1 kolay, 2 orta, 3 zor (sınıfa göre göreli; günlük sık sözcük = 1, soyut/seyrek = 3)
- `h`: sorunun hedef sözcüğü. `tur`: kelime | deyim | atasozu. `sozcuk_turu`: isim | sifat | fiil | zarf | baglac | zamir | edat | unlem | diger (deyim/atasözünde null). `anlam`: kendi cümlenle, kısa, sınıfa uygun (TDK ya da yayınevi metni kopyalanmaz).
- `o`: 1–2. sınıfta 3 şık, 3–8. sınıfta 4 şık. `d`: doğru şıkkın 0 tabanlı indeksi.
- `ip`: ipucu; cevabı açmıyorsa yaz, aksi hâlde null (varsayılan null).

## Zorunlu kurallar
1. **Bağlam kökte:** öğrenci yalnız `q` ve şıkları görür. Çözmek için gereken cümle, sayı, nesne kökün içinde yazılır. "Yukarıdaki/aşağıdaki" gibi gönderme yok.
2. **Sabit ad yok:** kök ve şıklarda özel ad kullanma (çocuk, öğrenci, kız, komşu, öğretmen vb.). Gerçek kişi adı, konum yok.
3. **Tek doğru:** ikinci bir kabul edilebilir şık olmasın. "Hepsi/hiçbiri/A ve B" şıkkı yok.
4. **Şık dengesi:** doğru şık, çeldiricilerin en uzunundan 8 karakterden fazla uzun olmasın; şıklar aynı yapıda (hepsi mastar ya da hepsi isim öbeği). Doğru şık dağılımı 0–3 arasında dengeli. Çeldiriciler yaygın yanılgılardan (zıt anlam, yakın ama eş olmayan, ilişkili sözcük) seçilir, saçma olmaz.
5. **Sızıntı yok:** kökteki bir sözcük doğru şıkta aynen tekrar edip ipucu vermesin; kökteki hedef ifade şıklarda geçmesin.
6. **Gerçek ilişki:** eş anlamlı çiftte iki sözcük gerçekten eş/çok yakın anlamlı; "ilişkili" sözcük (harita–pusula) eş/zıt sayılmaz. Eş sesli = yazılışı aynı, anlamı farklı ve kökeni ayrı sözcükler (çok anlamlı sözcük eş sesli değildir; yüz-sayı/yüz-surat, yaş-yıl/yaş-ıslak, çay-içecek/çay-dere gibi). Emin değilsen o soruyu yazma.
7. **Deyim/atasözü gerçek olmalı:** TDK'de ya da yaygın kullanımda yerleşik; sıradan söz öbeği (“iç geçirdi”, “elini kaldırdı”) deyim değildir. Yerleşik biçimiyle yaz. Emin değilsen yazma.
8. **Yazım:** TDK imlası. Yazım/noktalama sorusu yazma.
9. **Sınıfa uygun dil:** kısa, açık cümleler. 1–2. sınıfta tek basit cümle. Korkutucu/şiddet/ayrımcılık, siyaset, din yarışı yok.
10. **Özgünlük:** MEB ya da yayınevi sorusundan metin, şık ya da yakın parafraz alma; yeni cümle yaz. Aynı hedef sözcük/ifade dosyada bir kereden fazla kullanılmasın.
11. **Emin olmadığını yazma.** Az ama doğru soru, çok ama kusurlu sorudan iyidir.

## Tür biçimleri
- **es_anlamli / zit_anlamli (1–3. sınıf):** “X” sözcüğünün eş/zıt anlamlısı hangisidir? biçimi yeter (1–2. sınıfta tek sözcük şıklar).
- **es_anlamli / zit_anlamli (4–8):** hedef sözcük kısa bir cümlede verilir: “…hazır…” cümlesindeki “hazır” sözcüğüyle eş anlamlı olan hangisidir?
- **es_sesli:** cümle içinde: “Aşağıdakilerden hangisinde “yüz” sözcüğü sayı anlamında kullanılmıştır?” ve şıklar, hedef sözcüğü farklı anlamlarda kullanan dört cümledir (cümleler benzer uzunlukta).
- **deyim / atasozu:** deyimde cümle içinde, atasözünde sözün anlamı ya da durumu sorulur.
- **sozcuk_turu (5–8):** kısa bir cümlede “…” sözcüğünün türü; şıklar tür adları (isim, sıfat, fiil, zarf gibi). Yalnız tek türü olan ve bağlamla belirgin sözcükler seç (çok anlamlı tür belirsizliği yaratma).
- **baglamda_anlam:** öğrenciye bilmediği sözcüğün anlamını çıkarmasını sağlayacak yeterli bağlam içeren 1–2 cümle ver; anlam cümlenin içinden çıkarılabilsin, soru ezber olmasın.

## Çıktı
`olcek/sinif-<N>.json`: geçerli JSON dizisi, UTF-8, yalnız dizi. Yazmadan önce her soruyu kural 3–7 için kendin tara.
