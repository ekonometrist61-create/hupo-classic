# HR-026 · Kelime Makinesinin Karışıklığı · Ajan A (olgu ve doğruluk)
Karar: review_needed
Özet: Olgusal sözlük anlamları ve paket soruların cevap anahtarları metinle büyük ölçüde uyumlu; bilimsel/sağlık/güvenlik iddiası yok. Ancak hikâyenin md front matter'ındaki soru seti (4 soru, 4 bölüm) ile paket içindeki soru seti (5 soru, 7 sayfa) farklı; hangisinin kanonik olduğu belirsiz, ayrıca bir açıklama metinle tam örtüşmüyor.

Bulgular:
- [yüksek] hikaye.md front matter `sorular` ile paket.json `sorular` alanları: iki ayrı soru seti var. md'de s1 (hatırlama, dayanak 1), s2–s3 (çıkarım, dayanak 3), s4 (sözcük bağlamı, dayanak 2); paket'te s1 (dayanak 2, gül çizimi), s2 (dayanak 3, yüz resmi), s3 (dayanak 6, kural kartı), s4 (dayanak 4, "yaz"), s5 (dayanak 2, "gül" iki anlam). Yalnız "Bize kâr kaldı" ve "yüz" sorusu ortak kavramda. Paket 7 sayfa, md ise 4 bölüm; iki kaynağın sayfa numaraları aynı şemaya bağlı değil. Öneri: Tek kanonik soru seti belirlenmeli; diğeri kaldırılmalı ya da sayfa numaraları yeniden eşlenmeli. Kanonik set belirlenmeden yayın kapısı açılmamalı.
- [orta] hikaye.md front matter `sorular` s3, açıklama: "düğmelere rastgele basmak işe yaramadı". Alıntı metinde: "Makinenin hatasını bulmak… düğmelerine rastgele basmaktan daha çok zaman almış ama daha eğlenceli olmuştu." Metin "işe yaramadı" demiyor, yalnız daha uzun sürdüğünü söylüyor. Öneri: Açıklama "rastgele basmak daha uzun sürdü; ipuçlarını okumak yolu buldurdu" gibi metne sadık bir cümleyle değiştirilmeli.
- [orta] sözlük.json `hr026_zarar` anlamı: "Bir işten elde edilen kayıp." Alıntı: "Bir işten elde edilen kayıp." "Elde edilen kayıp" ifadesi anlam olarak çelişkili duruyor (kayıp elde edilmez). Öneri: "Bir işte uğranılan kayıp, kazanılamayan para." gibi düzeltilmeli. (Bu girdi metinde doğrudan geçmiyor; yalnız sözlük/kavram alanında.)
- [düşük] hikaye.md front matter `tur: bilim_kurgu` ve `konu: cok_anlamlilik`; paket.json `tur: "mizah"`, `konu: "kelime_makinesi"`. Tür etiketi iki kaynakta farklı. Öneri: Tek tür etiketi seçilmeli (metin mizah/okuma kurgusu gibi görünüyor).
- [düşük] hikaye.md ve paket.json `deger_anahtarlari`/`maarif` değerleri farklı (D14/D6 ve D3/D2). Bu Ajan B'nin etiket alanı; yalnız not olarak yazıldı.
- [düşük] paket.json `ogrenme_hedefleri` içinde deyim hedefi yok, md front matter'da `deyim_hr026` var. Öneri: İki kaynak hedef listesinde eşitlenmeli.
- [düşük] sözlük.json `hr026_gulmek` yazım alanı "güldü" (geçmiş zaman çekimi), sözlük girdisi için sözcük biçimi değil. Öneri: Sözlük yazımı "gülmek" ya da çekimli biçimin açıklaması olarak netleştirilmeli.

Doğrulanamayan iddialar: yok. (Sözlük anlamları: gül, güldü, yüz (sayı ve surat), sayfa, kar, kâr, yaz, iki büklüm olmak, ağzı açık kalmak genel Türkçe anlamlarıyla uyumlu; "kar/kâr" ayrımı metindeki "aynı yazılmıyor" ifadesiyle doğru. Kazanım kodu verilmemiş, `kazanim_kodu: null`; kod iddiası yok.)

Güçlü yanlar:
- Paket soruların cevap anahtarları ilgili sayfa metniyle örtüşüyor; "gül" (çiçek / gülmek) ve "yaz" (mevsim / yazmak) çok anlamlılığı metinde açıkça kuruluyor ve sözlükte doğru ayrılmış.
- Hikâyede sağlık, güvenlik, yetişkin içerik ya da olgusal bilimsel iddia yok; yalnız kurgusal bir mekanizma ve dil oyunu var.
