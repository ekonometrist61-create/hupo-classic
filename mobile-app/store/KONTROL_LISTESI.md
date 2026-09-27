# Yayın Kontrol Listesi ve Ekran Görüntüsü Planı

Sırayla ilerleyin. Kutucukları işaretleyin.

## A) Kararlar ve hesaplar
- [ ] Uygulama kimliği (paket adı) kesinleştirildi (`KIMLIK_VE_HESAPLAR.md`) - ilk yüklemeden sonra DEĞİŞMEZ
- [ ] Google Play Console hesabı açıldı (tek seferlik yaklaşık 25 USD; kimlik doğrulama günler sürebilir)
- [ ] (iOS için) Apple Developer Program (yıllık yaklaşık 99 USD) ve Mac/bulut CI kararı
- [ ] İletişim e-postası belirlendi (mağazada herkese açık görünür)

## B) Hukuk ve gizlilik
- [ ] KVKK avukatı aydınlatma metnini inceledi, düzeltmeler uygulamaya işlendi (`kPrivacyNoticeVersion` artırıldı)
- [ ] Gizlilik politikası herkese açık bir URL'de yayında
- [ ] Veri Güvenliği formu dolduruldu (`VERI_GUVENLIGI_VE_GIZLILIK.md`)
- [ ] Hedef kitle / yaş kararı verildi (Aileler Politikası etkisi)
- [ ] Web'den hesap silme talebi bağlantısı hazır (Google isteyebilir)

## C) Teknik
- [ ] Android Studio + SDK kuruldu (`ANDROID_KURULUM.md`), `flutter doctor` Android'de yeşil
- [ ] `store\anahtar-olustur.bat` çalıştırıldı, anahtar dosyası ve şifre YEDEKLENDİ (en az 2 yer)
- [ ] `pubspec.yaml` sürümü artırıldı (ör. `1.0.0+1`)
- [ ] `flutter build appbundle --release` başarılı, `app-release.aab` üretildi
- [ ] Release APK gerçek telefonda denendi: giriş, soru çözme, veli onayı, hesap silme, internet yokken davranış
- [ ] Bildirim çalışıyor mu (kurulduysa): Android 13+ izin penceresi, bildirime dokununca uygulama açılıyor
- [ ] Supabase üretim ayarları: doğru proje, migrasyonlar uygulanmış, e-posta doğrulama/şifre sıfırlama ayarı gözden geçirilmiş
- [ ] Uygulama simgesi ve açılış ekranı telefonda kontrol edildi

## D) Mağaza sayfası
- [ ] Başlık / kısa / tam açıklama girildi (`MAGAZA_METINLERI.md`)
- [ ] İkon 512x512, öne çıkan görsel 1024x500 yüklendi
- [ ] Gerçek ekran görüntüleri yüklendi (aşağıdaki plan)
- [ ] İçerik derecelendirme anketi dolduruldu
- [ ] Uygulama erişimi için test hesabı yazıldı
- [ ] Kategori Eğitim seçildi; ülkeler seçildi (Türkiye)

## E) Yayın
- [ ] Önce **dahili test / kapalı test** kanalına yükleyin, birkaç kişiye denetin (yeni kişisel hesaplarda kapalı test şartı olabilir)
- [ ] Sorunsuzsa **üretim (production)** kanalına gönderin; Google incelemesi birkaç gün sürebilir
- [ ] Yayından sonra yorumları ve çökme raporlarını (Play Console > Android vitals) takip edin

## Ekran görüntüsü planı (GERÇEK telefondan alınmalı)

`tool/previews/` klasöründeki "golden" görüntüler yalnızca tasarım ham maddesi/prova içindir; mağaza kuralları gereği yayında **gerçek cihazdan** alınmış görüntüler kullanılmalıdır (test verisi ve gerçek kişi bilgisi içermemeli, örnek hesap kullanın).

Önerilen 6 ekran (telefonu dikey tutun, `Güç + Sesi kısma` ile görüntü alın, tarih/saat çubuğunda bildirim olmasın):
1. Karşılama / ana ekran: Hupo ve günlük hedef
2. Soru çözme ekranı (bir soru ve seçenekler)
3. Doğru cevap sonrası tebrik (Hupo sevinçli) + XP
4. Seri ve rozetler
5. Anonim lig sırası (isim yok, sadece sıra)
6. Ayarlar: "Bilgilerimi kopyala / Hesabımı sil" (gizlilik güvencesi)

İpucu: Her görüntüye kısa bir Türkçe başlık bandı eklemek isterseniz bir tasarımcıya verin; ancak altındaki ekran görüntüsü gerçek olmalı.
