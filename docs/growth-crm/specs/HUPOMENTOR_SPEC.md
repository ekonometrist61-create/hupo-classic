# HupoMentor spesifikasyonu (H-GIE Faz 6)

Durum: **taslak spec, kod yok.** Tarih: 2026-10-28. Bu ürün çocuklara dönük bir yapay zekâ öğretmenidir; bu nedenle spec, ürün kodundan önce güvenlik ve hukuk kapılarını tanımlar.

## 1. Amaç
1–8. sınıf öğrencisine, MEB kazanımlarıyla uyumlu, yönlendirici (cevap vermeyen) bir özel ders deneyimi sağlamak. Veli, öğrenme ilerlemesini görür.

## 2. Kapsam dışı (kesin)
- Öğrenciye doğrudan sınav cevabı vermek; ipucu ve yönlendirme esastır.
- Serbest sohbet: konu dışı, kişisel bilgi isteyen veya yetişkin içeriği olan konuşmalar reddedilir.
- Öğrenci konuşması ve yanlış cevap verileri growth (pazarlama) katmanına gitmez.
- Çocuk verisinin reklam hedeflemesinde kullanılması (proje kuralı).

## 3. Ön koşullar (kod başlamadan kapanmalı)
1. **Hukuk:** çocuğa dönük yapay zekâ kullanımı için KVKK değerlendirmesi, veli açık rızası metni ve veri işleyen sözleşmesi. Sağlayıcı (Gemini dahil) için veri işleme koşulları.
2. **Pedagoji:** kazanım haritası ve yönlendirme ilkeleri (`docs/pedagoji-paketi/`). Her konu için MEB kazanım kodu yalnız kaynakta görülürse yazılır; yoksa `source_pending`.
3. **Güvenlik:** içerik filtresi, prompt injection savunması (öğrenci girdisi güvenilmezdir), kişisel bilgi tespiti ve maskeleme.
4. **Kırmızı takım seti:** en az 100 zararlı/kapsam dışı istem içeren test seti; geçme ölçütü belirlenmeden pilot açılmaz.

## 4. Mimari ilkeler
- LLM yalnız yönlendirme metni üretir; şema değiştirmez, SQL çalıştırmaz, veri yazmaz.
- Her yanıt, önceden onaylı kazanım/konu kapsamı içinde kalır; kapsam dışıysa reddedilir.
- Sistem istemi ve kurallar istemci tarafından değiştirilemez.
- Öğrenci mesajları saklanırsa yalnız veli onayıyla, sınırlı süreyle; loglarda kişisel bilgi yok.
- Sağlayıcı arayüzü soyutlanır; sağlayıcı değişince davranış testleri yeniden koşulur.

## 5. Veli görünürlüğü
- Veli: konu bazında ilerleme, oturum sayısı, tamamlanan konular. Sohbet içeriği görmez (ilk sürüm).
- Growth katmanına yalnız toplulaştırılmış kullanım metriği gider (oturum sayısı, tamamlama oranı; eşik 10 öğrenci).

## 6. Aşamalar ve kapılar
| Aşama | İçerik | Kapı |
|---|---|---|
| M0 | Bu spec, hukuk ve pedagoji ön koşulları | Hukuk onayı (ZORUNLU) |
| M1 | Kapsam ve yönlendirme politikası, kırmızı takım seti | Test geçmeden M2 yok |
| M2 | Kapalı pilot: rızası alınmış veli ve öğrenciler, sınırlı kullanım | Veli onayı, izleme ekibi |
| M3 | Genel kullanım | M2 bulguları kapatılmış |

## 7. Kabul ölçütleri (pilot için)
- Kırmızı takım setinde kapsam dışı/zararlı yanıt oranı belirlenen eşiğin altında (eşik M1'de yazılır).
- Kişisel bilgi (ad, adres, okul) yanıtlarda ve loglarda sızmaz (test).
- Veli rızası olmayan hesapta sohbet açılmaz (test).
- Growth'a giden verilerde öğrenci kimliği ve yanlış cevap yoktur (test).

## 8. Karar (2026-10-28)
Bu ürün **hukuk onayı alınmadan kodlanmaz**. Şimdi yapılacak tek iş M0 kapsamındaki belgelerin taslağıdır. Pilot tarihi için karar yoktur.
