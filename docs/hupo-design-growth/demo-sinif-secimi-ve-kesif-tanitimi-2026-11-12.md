# Demo sınıf seçimi, veli özeti ve keşif tanıtımı (2026-11-12)

Yüzey: public site (`/` landing, `/demo`). Hedef kitle: veli. Ana eylem: sınıfı seç, 5 örnek soruyu çöz, veli özetini gör, ardından veli hesabı oluştur. Ana metrik: `demo_tamamlandi` (artık `sinif` özelliğiyle). Durum: kod yazıldı, commit/deploy yok.

## Ekran sözleşmesi

| Ekran | Hedef | Ana eylem | Durumlar |
|---|---|---|---|
| `/demo` sınıf seçimi | Velinin çocuğuna uygun içeriği görmesi | 3–7 arası sınıf düğmesi | seçim, `?sinif=N` ile atlama |
| `/demo` soru | Sınıfa uygun, altı çizili anahtarlı soru; bazıları şekilli | Seçenek seç, "Cevabımı kontrol et" | cevaplanıyor, kontrol edildi (doğru/yanlış), şekilli/şekilsiz |
| `/demo` sonuç | Veliye açıklanabilir özet | "Veli hesabı oluştur" | beceri bazlı doğru sayısı, evde destek önerisi, "örnek özet" rozeti |
| Landing demo bölümü | Sınıf seçimini göstermek | Sınıf düğmesi veya "Sınıfı seç, soruları dene" | — |
| Landing "Senin Hikâyen" | Okuma dünyasını anlatmak | "Veli hesabı oluştur" | `okuma_site_ozeti` verisi var: "Erken erişim" + sayılar; yok/hata: "Yakında" |
| Landing keşif bölümü | Çarpım Şifreleri, Kelime Evreni, Arena | — (bilgi) | durum rozeti: Erken erişim / Yakında |

## Kabul kriterleri
1. Her sınıf (3, 4, 5, 6, 7) için tam 5 soru; her sorunun tek doğru cevabı ve açıklama adımları var; sorular özgündür, kazanım kodu yazılmaz, 4. sınıf için TYMM denmez.
2. Her sınıfta 2 şekilli soru (toplam 10): kesir şeridi, sütun grafiği (2), dikdörtgen, elektrik devresi, sayı doğrusu (2), nokta grupları, üçgen, yol-zaman grafiği. Şekil koddan çizilir (inline SVG), `role="img"` + veriyi söyleyen ama cevabı söylemeyen `aria-label`.
3. Altı çizili anahtar sözcük/ifade her soruda var (kalın + altı çizili); seçeneklerde de kullanılabilir.
4. Yanlış cevapta: "Bu kez olmadı" + (varsa) seçilen seçeneğin neden cazip göründüğü + adım adım çözüm + cesaretlendirme cümlesi. Utandırma ve puan baskısı yok.
5. Sonuçta veli özeti: ilk denemede doğru sayısı, beceri bazlı doğru/toplam (renk dışında ikon ve metin), tekrar gereken en çok 2 beceri için evde destek önerisi, küçük örneklem uyarısı. XP ve süre gösterilmez.
6. Klavye ile tamamlanabilir; odak ilgili başlığa taşınır; mobil 390 px'te yatay taşma yok; tr + en birlikte.
7. Hazır olmayan özellik yayında gibi sunulmaz: rozet gerçek duruma bağlı.

## Durum doğrulaması (kodda/belgede)
| Özellik | Kanıt | Landing durumu |
|---|---|---|
| Senin Hikâyen (Okuma Dünyası) | Genel bayrak açık (K-0142); K-0244: 100 yayında hikâye, yalnız insan onayı yayınlar (K-0239). Landing RPC canlıda 100 hikâye döndürdü (geliştirme ortamı, salt okuma). Mobil mağaza sürümü yok (footer "Mobil uygulama yakında"). | Erken erişim (veri yoksa Yakında) |
| Çarpım Şifreleri | `mobile-app/lib/screens/cipher/`, `carpim_sifreleri` seed (10 şifre, 20260927000015), RPC'ler uzakta. | Erken erişim |
| Kelime Evreni | Mobil ekran var, uzak migrasyonlar uygulanmış, 271 soru yayında ama dört göz/dil uzmanı kapısı yok (GÖR-091, karar bekliyor). | Yakında ("içerik incelemesi sürüyor") |
| Arena | `arena_screen.dart`: Ay Ligi + günün meydan okuması; "arkadaşla yarışma" kodda "yakında". | Erken erişim (arkadaşla yarışma "yakında") |

## Konumlandırma (ajan önerisi, kullanıcı onayı bekliyor)
- Senin Hikâyen = değer çıpası: velinin "çocuğum ne okuyor, neyi anlıyor" sorusuna karşılık, bölüm büyük ve adım adım anlatılır (kahraman seç, oku, küçük sorularla dene). Hipotez: ürünün farkını tek bakışta göstermek ilk ziyarette anlamayı artırır (K3, test edilmedi).
- Çarpım Şifreleri, Kelime Evreni, Arena = merak alanları ("çalışmanın içindeki keşifler"). Çocuğun kendi isteğiyle açtığı alanlar olarak anlatılır; ödül baskısı, süre dayatması ve çocuğa satış yok, ölçüt öğrenme. Sitede "çıpa/havuç" terimleri geçmez (nöropazarlama terimi kamuya açık metinde yok).
- Arena kartında veliye açık not: rekabet öğrenme ölçütü değildir.

## Ölçüm
`demo_tamamlandi` özelliklerine `sinif` (3–7) eklendi: puan, toplam, sinif. Ad, cevap, serbest metin yok; PostHog yalnız çerez onayıyla. Yeni olay eklenmedi. Not: `OLAY_TAKSONOMISI.md` içindeki `demo_tamamlandi` tanımı `sinif` özelliğiyle güncellenmeli.
Tek deney önerisi (trafik yetmezse nitel): landing demo bölümünde sınıf düğmeleri doğrudan `?sinif=N` ile açar; hipotez: tek tıkla başlayan demo tamamlanma oranını artırır. Ana metrik demo başlatıldı→tamamlandı; koruma metriği veli kaydı başlatma. Baseline yok; önce 2–4 hafta ölçüm.

## Açık kararlar / çelişkiler
1. K-0258 kararı "sitede genel sınıf iddiası yok, kaynak teyidi yok" demişti; kullanıcı bu işte 3–7. sınıfı belirtti. Demo ve landing demo bölümü "3–7. sınıf" diyor; `/yontem` metninden sınıf aralığı K-0255'te kaldırılmıştı. Hikâye RPC'si ise yayındaki hikâyeler için "2–8. sınıf" döndürüyor (dinamik). Üç yerde aralık tutarsız; tek bir resmî aralığa karar verilmeli.
2. Soru içeriği için `meb-soru-sozcuk-uzmani` incelemesi ve bağımsız kör çözüm yapılmadı (aşağıya bak).
3. Rozet durumları (Erken erişim / Yakında) kullanıcı onayı bekliyor; özellikle Çarpım Şifreleri ve Arena'nın canlı ortamda çocuğa açık olup olmadığı doğrulanmadı.
