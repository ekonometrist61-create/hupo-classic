---
baslik: "Bremen Yolcularının Yeni Şarkısı"
slug: "hr025-bremen-yolcularinin-yeni-sarkisi"
fis_kodu: "HR-025"
tur: hayvanlar
konu: uyum_ritim
sinif_alt: 3
sinif_ust: 3
okuma_bandi: 2
dunya_tipi: masalsi
izinli_turler: [hayvan, hayali]
deger_anahtarlari: [D4, D14]
yetiskin_uygun: false
tanitim: "Eşek, köpek, kedi ve horoz aynı anda şarkı söyleyince ne oldu? Uyum nasıl kuruldu?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 3
  okuma_zorlugu: 2
  kavram_zorlugu: 2
  ilgi_egilimi: ortak
  temalar: [hayvanlar, sanat_yaraticilik]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D4
    yardimci_deger: D14
  ogrenme_hedefleri:
    - {id: degirmen_hr025, tur: lexeme, etiket: "değirmen", yuva: hr025_degirmen, islev: first_hint}
    - {id: ritim_hr025, tur: lexeme, etiket: "ritim", yuva: hr025_ritim, islev: application}
    - {id: uyum_hr025, tur: lexeme, etiket: "uyum", yuva: hr025_uyum, islev: application}
    - {id: deyim_hr025, tur: idiom, etiket: "Kulak vermek", yuva: hr025_kulak_vermek, islev: application}
    - {id: kavram_hr025, tur: concept, etiket: "Farklı seslerin uyumu", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pass, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Eşek, köpek, kedi ve horoz küçük bir orman yolunda yürüyordu.", metin: "Bremen yolunda yürüyen hayvanlar kimlerdi?", secenekler: [{id: A, metin: "Kedi, köpek, kuş ve tavşan"}, {id: B, metin: "Eşek, köpek, kedi ve horoz"}, {id: C, metin: "Koyun, inek, kedi ve horoz"}], dogru: B, aciklama: "Hikâyenin dört yolcusu eşek, köpek, kedi ve horozdur."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, dayanak: "Birinin sesi ötekini bastırdığında durup yeniden başladılar.", metin: "Hayvanlar şarkıya neden ara verip yeniden başladı?", secenekler: [{id: A, metin: "Çocuklar kapıdan içeri bakmıştı"}, {id: B, metin: "Horoz yorulup uyumuştu"}, {id: C, metin: "Bir ses ötekini bastırmıştı"}], dogru: C, aciklama: "Sesler birbirini bastırınca uyum bozuluyor, hayvanlar da yeniden başlıyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 4, dayanak: "Güzel olan zaten farklı seslerimiz.", metin: "Kedi, şarkıyı neyin güzel yaptığını düşünüyordu?", secenekler: [{id: A, metin: "Herkesin aynı sesle şarkı söylemesini"}, {id: B, metin: "Seslerin birbirinden farklı olmasını"}, {id: C, metin: "Yalnız eşeğin gür sesini"}], dogru: B, aciklama: "Kedi, farklı seslerin şarkıyı güzel yaptığını söyledi."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, dayanak: "Önce horoz {kelime:hr025_ritim} tuttu.", metin: "“Horoz ritim tuttu” cümlesinde ritim ne demektir?", secenekler: [{id: A, metin: "Düzenli tekrar eden vuruşlar"}, {id: B, metin: "Çatıdaki deliklerin sayısı"}, {id: C, metin: "Eski değirmenin kapısı"}], dogru: A, aciklama: "Ritim, düzenli olarak tekrar eden vuruşlar demektir."}
deyim_cumleleri:
  hr025_kulak_vermek: "Kedi, değirmenin duvarına kulak verdi."
---
@omurga
Eşek, köpek, kedi ve horoz küçük bir orman yolunda yürüyordu. Bremen'e giden uzun yolun ortasında yağmur başladı. Yol kenarında eski bir {kelime:hr025_degirmen} vardı. Dördü koşup oraya sığındı. Çatıdan düşen damlalar taşlara farklı seslerle vuruyordu: tak, tik, tuk.

Horoz kanatlarını çırptı. “Harika bir konser salonu bulduk!” dedi. Eşek yüksek sesle anırdı. Köpek havladı, kedi miyavladı, horoz da öttü. Fakat hepsi aynı anda ses verince ortaya anlaşılmaz bir gürültü çıktı.

Kedi kulaklarını kapattı. “Hepimiz duyulmak istiyoruz ama kimse kimseyi dinlemiyor.” {isaret:kedi}

Eşek biraz alındı. “Benim sesim zaten böyle güçlü. Sessiz mi olayım?”
---
@omurga
“Hayır,” dedi köpek. “Sırayla söyleyelim.”

Önce horoz {kelime:hr025_ritim} tuttu. Bir, iki, üç, dört. Kedi ince sesini ikinci vuruşa, köpek kalın sesini üçüncüye koydu. Eşek dördüncü vuruşta öyle gür anırdı ki değirmenin içi neşeyle doldu. Birinin sesi ötekini bastırdığında durup yeniden başladılar.

Bir süre sonra eşek vuruşu kaçırdı. Çatıdan damlayan suyun sesi hızlanmıştı. “Ben mi yanlış söylüyorum?” diye sordu. Kedi sessizce duvara yaklaştı. [[deyim:hr025_kulak_vermek]] Damlalar bir yavaşlıyor, bir hızlanıyordu. “Yağmur hızını değiştiriyor,” dedi.

Köpek adımlarıyla düzeni gösterdi: dört eşit adım, sonra küçük bir durak. Dört sesin arasına kısa bir sessizlik koyunca şarkı daha anlaşılır oldu. Sessiz kalan vuruşta horoz kanadını kaldırdı, herkes ona baktı.
---
@omurga
Eşek bir daha anırmadan önce arkadaşlarına baktı. Horoz kanadını indirince sesini yükseltti. Değirmenin damlaları da sanki onlara eşlik ediyordu. Yağmurun sesi azaldıkça yeni bir ezgi kurdular.

Dışarıda yağmur hafifledi. Yol kenarında bir grup çocuk vardı. Çocuklar değirmenin içinden gelen müziği merak etmişti; {yoldas:yalin|bir arkadaş} da onlarla birlikte bekliyordu. Hayvanlar kapıya çıktı ve kısa şarkılarını söylediler. {yoldas:yalin|bir arkadaş} ellerini çırparak eşlik etti. Bir başkası yağmur damlalarının sesini taklit etti. Böylece şarkıya yeni bir ritim eklendi.

Horoz şaşkınlıkla kabardı. “Şimdi hepimiz aynı sesle mi söyleyeceğiz?” diye sordu.
---
@omurga
“Hayır,” dedi kedi. “Güzel olan zaten farklı seslerimiz.”

Sesler artık birbirine karışmıyordu; ortaya bir {kelime:hr025_uyum} çıkmıştı. “Bence yolculuğumuzun bir şarkısı oldu,” dedi eşek. Horoz bunu her molada yeniden söylemeyi önerdi.

Yağmur tamamen dinince yola devam ettiler. Köpek yürürken adımlarını saydı. Eşek, su birikintilerinden geçerken yavaşladı. Kedi ve horoz da ona göre adım attı.

Akşama doğru uzaktan Bremen'in çanları duyuldu. Dört arkadaş birbirine baktı. Çanların sesini de kendi şarkılarına katmak için yeniden başladılar.

Not: Bu hikâye, Grimm Kardeşler’in derlediği Bremen Mızıkacıları masalından esinlenen özgün bir uyarlamadır.
