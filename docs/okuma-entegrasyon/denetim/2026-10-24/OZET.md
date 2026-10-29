# Okuma Dünyası · 112 satır denetim özeti · 2026-10-24

Kapsam: canlı DB'de taslak olan 112 satır (107 benzersiz HR kodu; 5 kodda iki satır). Her satır için Ajan A (olgu ve doğruluk) ve Ajan B (uygunluk ve kalite) raporu yazıldı. Karar kuralı: pass = yüksek bulgu yok ve en fazla bir orta bulgu; review = en az bir yüksek veya iki ve üzeri orta bulgu.

Bu özet yalnızca belgedir. DB'ye yazılmadı, hiçbir sürüm yayınlanmadı (`published` / `durum='yayinda'` değişmedi), denetim alanları (`denetim` jsonb) güncellenmedi.

## Özet sayılar

| Sonuç | Satır |
|---|---|
| Ajan A pass | 49 |
| Ajan B pass | 16 |
| İkisi de pass (yayın kapısına aday, insan onayı yok) | 16 |
| En az bir ajan review | 96 |
| Benzersiz HR kodu | 107 |
| Aynı kodda iki satır | 5 (HR-034, 035, 036, 039, 042) |

İkisi de pass olan 16 satır: HR-001, 002, 003, 004, 005, 006, 007, 008, 009, 010, 012, 014, 015, 016, 018, 022.

## Karar tablosu

Ajan A / Ajan B sütunları: pass veya review. Tekrar eden kodlarda iki satır (a/b) ayrı yazılmıştır. Dosya adı kodu ve slug'ı verir.

| HR | Slug | A | B |
|---|---|---|---|
| 001 | kayip-canin-izinde | pass | pass |
| 002 | renkli-ucurtma | pass | pass |
| 003 | corabini-arayan-robot | pass | pass |
| 004 | ters-gun-okulda | pass | pass |
| 005 | hocanin-golundeki-umut | pass | pass |
| 006 | dudek-kimin-olacak | pass | pass |
| 007 | kaplumbaga-ve-tavsan | pass | pass |
| 008 | aslan-ve-fare | pass | pass |
| 009 | konusan-kalem-kutusu | pass | pass |
| 010 | kelogan-ve-konusan-tas | pass | pass |
| 012 | yeni-arkadasin-gizli-yetenegi | pass | pass |
| 013 | kirilan-oyuncak-kopru | pass | review |
| 014 | yagmur-damlasinin-yolculugu | pass | pass |
| 015 | tohumun-kucuk-sirri | pass | pass |
| 016 | golgeyi-kim-buyuttu | pass | pass |
| 017 | mahallenin-en-hizli-bisikleti | pass | review |
| 018 | deniz-fenerindeki-sinyal | pass | pass |
| 019 | magaranin-uc-isareti | pass | review |
| 021 | kayip-sandigin-sifresi | pass | review |
| 022 | saat-kulesi-neden-durdu | pass | pass |
| 023 | hoca-ve-gorunmeyen-misafir | pass | review |
| 024 | bulut-postacisinin-son-mektubu | pass | review |
| 025 | bremen-yolcularinin-yeni-sarkisi | pass | review |
| 026 | kelime-makinesinin-karisikligi | pass | review |
| 027 | karagozun-kayip-golgesi | pass | review |
| 028 | uc-renkli-takim | pass | review |
| 029 | minik-mucit-ve-gunes-firini | pass | review |
| 030 | ormanin-kaybolan-patikasi | pass | review |
| 031 | muzede-sessiz-alarm | pass | review |
| 032 | keloglan-ve-akilli-terazi | pass | review |
| 033 | ye-kurkum-ye-peki-neden | pass | review |
| 034a | 2040-konusan-okul-cantasi | pass | review |
| 034b | 2040-in-konusan-okul-cantasi | review | review |
| 035a | aya-giden-ilk-posta | pass | review |
| 035b | ay-a-giden-ilk-posta | review | review |
| 036a | yedi-renkli-koprunun-koruyucusu | pass | review |
| 036b | yedi-renkli-kopruun-koruyucusu | review | review |
| 037 | son-pasin-hikayesi | pass | review |
| 038 | muzik-kutusunun-sifresi | pass | review |
| 039a | ankanin-kaybolan-tuyu | pass | review |
| 039b | anka-nin-kaybolan-tuyu | review | review |
| 040 | trenin-penceresindeki-turkiye | pass | review |
| 041 | yedi-adimda-kayip-ada | pass | review |
| 042a | kapadokyanin-gizli-gecidi | pass | review |
| 042b | kapadokya-nin-gizli-gecidi | review | review |
| 043 | kuledeki-son-isik | pass | review |
| 044 | buz-golunun-haritasi | pass | review |
| 045 | kutuphanenin-on-ucuncu-rafi | pass | review |
| 046 | bilinmeyen-posta-pulu | pass | review |
| 047 | kirmizi-defterin-sifresi | review | review |
| 048 | muzedeki-eksik-parca | review | review |
| 049 | keloglan-ve-yedi-soz-kapisi | review | review |
| 050 | yildiz-terzisinin-haritasi | review | review |
| 051 | orman-saatini-kim-durdurdu | review | review |
| 052 | sahmeranin-bilgelik-cesmesi | review | review |
| 053 | robot-sinif-baskani-secildi | review | review |
| 054 | karagoz-dijital-sozlukte | review | review |
| 055 | deyim-dedektifleri-kulubu | review | review |
| 056 | takimin-gorunmeyen-oyuncusu | review | review |
| 057 | sessiz-mesajlar-kulubu | review | review |
| 058 | gokyuzundeki-balonun-sirri | review | review |
| 059 | sifreli-ari-dansi | pass | review |
| 060 | geri-donusum-laboratuvari | pass | review |
| 061 | marsa-giden-sessiz-mesaj | review | review |
| 062 | hafizasi-karisan-android | pass | review |
| 063 | hocanin-tersine-giden-saati | review | review |
| 064 | cinili-kutunun-yolculugu | pass | review |
| 065 | ruzgara-karsi-son-tur | review | review |
| 066 | uc-ulkenin-tek-sofrasi | review | review |
| 067 | golgeler-vadisinin-rotasi | review | review |
| 068 | kayip-geminin-gunlugu | pass | review |
| 069 | sular-altindaki-sehir | review | review |
| 070 | uc-dakikalik-kesinti | review | review |
| 071 | tarihi-yanlis-yazan-heykel | review | review |
| 072 | sinifin-gorunmez-yazari | review | review |
| 073 | bogacin-adil-karari | review | review |
| 074 | ay-isigindaki-dort-kapi | review | review |
| 075 | okulun-yanlis-anlayan-yapay-zekasi | review | review |
| 076 | mizah-gazetesinin-ilk-sayisi | review | review |
| 077 | yarim-kalan-takim-oyunu | review | review |
| 078 | golun-sessiz-alarmi | review | review |
| 079 | zaman-kapsulunun-sifresi | review | review |
| 080 | robot-kentin-son-agaci | review | review |
| 081 | kacis-odasinin-sahte-kapisi | review | review |
| 082 | aynali-koridordaki-yedinci-iz | review | review |
| 083 | kayip-kodun-ardindaki-insan | review | review |
| 084 | cevrilmeyen-son-sayfa | review | review |
| 085 | firtina-oncesi-son-sefer | review | review |
| 086 | gunes-dagi-haritasi | review | review |
| 087 | buzulun-kalbindeki-kayit | review | review |
| 088 | sahmeranin-sakladigi-ikinci-soru | review | review |
| 089 | beyrekin-sozunun-agirligi | review | review |
| 090 | gece-kutuphanesinin-nobetcileri | review | review |
| 091 | ankanin-kayip-rotasi | review | review |
| 092 | denizalti-09dan-mesaj | review | review |
| 093 | sahte-ay-fotografi | review | review |
| 099 | iki-takim-tek-proje | review | review |
| 100 | son-turda-yon-degistirmek | review | review |
| 101 | kayip-arsivin-yedi-tanigi | review | review |
| 102 | golgenin-sahibi-kim | review | review |
| 103 | kutuphanedeki-son-sifre | review | review |
| 104 | sifirinci-katin-sirri | review | review |
| 105 | kuzey-ruzgarinin-pesinde | review | review |
| 106 | col-haritasindaki-bosluk | review | review |
| 107 | seksen-gunde-bir-durak | review | review |
| 108 | dumrulun-zor-sorusu | review | review |
| 109 | karanliktaki-filin-bes-yorumu | review | review |
| 110 | yitik-zamanin-haritacilari | review | review |
| 111 | cam-sehrin-kirik-yasasi | review | review |
| 112 | 2055-hatirlayan-sehir | review | review |
| 113 | yorunge-disi | review | review |
| 114 | dunyanin-son-kutuphanesi | review | review |

Kodlar 011, 020, 094, 095, 096, 097, 098 bu 112 satırın içinde yoktur.

## Kalıp bulgular

Bu bulgular birçok raporda tekrar ediyor. Düzeltme, yazar ya da editör işidir; bu denetimde metne dokunulmadı.

1. **Tanıtım ve soru adları gövdeyle uyuşmuyor (yüksek).** Tanıtımda veya sorularda geçen ad, gövdede yer almıyor ya da gövdede karakter [KAHRAMAN] olarak anılıyor. Örnekler: HR-099 (tanıtım adları), HR-107 (Ada), HR-108 (Dumrul), HR-109 (s1'de Lalin), HR-110 (Mira, Tuna), HR-111 (Ada), HR-112 (Elif), HR-113 (Deniz), HR-114 (Leyla). Eski oturumdaki satırlarda da aynı kalıp bulunuyor; ilgili raporlara bakın.
2. **Öğreticilik yoğunluğu (B, yüksek).** Çoğu hikâyede her bölüm bir ilke cümlesiyle kapanıyor; VURGU işaretleri tez cümlesi taşıyor. Bu, 8. ve 7. sınıf okurunun okuma akışını bozuyor. En yoğun örnekler: HR-107 ile HR-114 arası 8. sınıf hikâyeleri.
3. **Deyim işareti, deyim cümlesi metinde yok.** HR-107, 108, 109, 110, 111, 112, 113 ve 114 satırlarında `[DEYİM yuva=…]` işareti konmuş, ama deyim cümlesi (`deyim_cumleleri`) metnin o yerinde bulunmuyor. Render sırasında deyim cümlesi eklenmeli ya da işaret yeniden yerleştirilmeli.
4. **Sözlük yazımı çekimli.** Girdinin `yazım` alanı çekimli biçimde (ör. "karoları", "sorumluluğu", "tahmini", "arşivlerini", "belirsizliği") yazılmış. Sözlük temel biçimle yazılmalı. Örnek satırlar: HR-107, 108, 109, 111, 112, 113, 114.
5. **Geçersiz hal değeri.** HR-075 s20 `hal="ayrilma"`; HR-100 sayfa 11 `hal=bulunma`, sayfa 24 `hal=ayrilma`. Geçerli değerler: yalın, ilgi, yönelme, belirtme (ve diğer tanımlı olanlar). Render öncesi doğrulama bu hataları yakalamıyor.
6. **Ürün adı kurgunun içinde.** HR-091 sayfa 13: "HupoRead için en güzel hikâyeler…" (B: yüksek; A: orta). Kurgu dışı ifade kaldırılmalı.
7. **Yayın denetim notu gövdede.** HR-099 sayfa 32: dil, disiplin, değer, ikon adayları ve "kazanım kodu ve telif denetimi henüz yapılmadı" notu okura yönelik metinde. Ayrı bir yayın dosyasına taşınmalı.
8. **Kopya cümle.** HR-075 sayfa 20'de bir cümle iki kez yazılmış.
9. **Uzunluk.** Çoğu satır 3.000–4.000 kelime ve 27–41 yoldaş yeri taşıyor. Okuma bandı 3 için hedef uzunluk sorusu yazar kararıdır; ama kapanış sayfalarında tekrar (örn. HR-112 s25–33, HR-113 s29–34, HR-114 s26–35) kırpılabilir.
10. **Kazanım kodu ve kaynak.** Bu denetimde TDK ve kazanım kodu kaynak kontrolü yapılmadı. Künyelerde "TYMM 2026-27 (okuma evresi insan editörce kontrol edilecek)" ibaresi var. Kazanım kodu yalnızca kaynakta görülürse yazılmalı; görülmediyse `source_pending`.

## Bağımsızlık sınırı

- Bu raporlar tek bir oturumda, aynı model tarafından yazıldı. Ajan A ve Ajan B ayrımı rol ayrımıdır; iki bağımsız insan denetimi değildir.
- Hiçbir rapor, yayın kararı yerine geçmez. Yayın kapısı (`ajan_a=pass`, `ajan_b=pass`, `insan=approved`, `inceleyen_id`) insan onayı ve admin yetkisi gerektirir.
- Bu raporlar "doğruluk" iddialarını yalnızca metnin kendi içinde ve genel ilkeler düzeyinde kontrol etti. Ülkeye özgü hukuki süre, telif ve gerçek kurum adları için uzman doğrulaması ayrıca gerekir (ör. HR-111, HR-114 telif/rıza ayrıntıları).

## Eski klasör notu

`docs/okuma-entegrasyon/denetim/2026-10-24/denetim-girdisi/` klasöründe 107 adet `HR-XXX.txt` girdi dosyası kaldı. Beş kodda (HR-034, 035, 036, 039, 042) çakışma olduğu için girdiler slug adlı dosyalarla yeniden üretildi. Eski klasör silinemedi (ortam silme komutlarını engelledi). Bu klasör güncel denetimin parçası değildir; kullanıcı elle silebilir ya da bırakabilir.

## Sonraki adımlar (yazılı kayıt)

1. Yazar ya da editör 96 review satırını düzeltir; önceliğe göre ad uyuşmazlığı, deyim yerleşimi, sözlük yazımı ve geçersiz hal değerleri önce gelir.
2. HR-034/035/036/039/042 çiftlerinden hangisinin kalacağı admin kararıdır.
3. İkisi de pass olan 16 satır, insan editör incelemesine ve yayın kararına aday. Yayın kararı kullanıcıya aittir; bu oturumda yapılmadı.
