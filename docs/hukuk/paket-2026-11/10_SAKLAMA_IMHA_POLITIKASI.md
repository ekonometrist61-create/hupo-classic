> TASLAK · Kişisel Verilerin Silinmesi, Yok Edilmesi veya Anonim Hale Getirilmesi Hakkında Yönetmelik esas alındı · Avukat ve SMMM teyidi bekliyor.
> VERBİS'e kayıt yükümlülüğü yoksa bu politika yasal zorunluluk değildir; yine de saklama sürelerini ispatlamak ve aydınlatma metniyle tutarlılık için tutulur.

# Kişisel Veri Saklama ve İmha Politikası

## 1. Amaç ve kapsam
Hupolingo'nun işlediği kişisel verilerin ne kadar saklanacağını ve süre bitince nasıl imha edileceğini belirler. Tüm sistemleri (Supabase, e-posta/SMS sağlayıcıları, analitik, yedekler, ekip cihazları, CRM) kapsar.

## 2. Sorumlular
| Rol | Görev |
|---|---|
| Veri sorumlusu temsilcisi: [AD] | Politikanın onayı, Kurul ile iletişim |
| Teknik sorumlu: [AD] | Otomatik silme işleri, yedek döngüsü |
| Pazarlama sorumlusu: [AD] | İzin, bastırma listesi, İYS eşleşmesi |

## 3. Saklama süreleri

| Veri | Süre | Dayanak | Süre bitince |
|---|---|---|---|
| Veli/öğrenci hesap ve öğrenme verisi | Hesap süresince + silmeden sonra 30 gün | Sözleşme | Silme; istatistik için anonimleştirme |
| Hareketsiz hesap | Son girişten itibaren 3 yıl; 30 gün önce e-posta uyarısı | Meşru menfaat / veri en aza indirme | Silme veya anonimleştirme |
| Ödeme, fatura, sipariş | 10 yıl | VUK m.253, TTK m.82 | Silme |
| Mesafeli sözleşme ve ön bilgilendirme onayı | 10 yıl | TTK, TKHK ispat | Silme |
| Ticari ileti onay/ret kaydı | İzin süresince + 3 yıl | 6563 Yönetmelik (ispat) | Silme |
| Kampanya gönderim kaydı | 3 yıl | İspat | Silme |
| Bastırma listesi (ret edenler) | Süresiz, yalnız hash'li iletişim bilgisi | Rete saygı (tekrar göndermemek için) | — |
| Aday/ön kayıt | Son etkileşimden 24 ay | Açık rıza / meşru menfaat | Silme |
| Güvenlik ve trafik kayıtları | 2 yıl | 5651 s. Kanun | Silme |
| Giriş olayları | 180 gün | Güvenlik | Silme |
| Hata kayıtları (Sentry) | 90 gün | Meşru menfaat | Sağlayıcıda otomatik silme |
| Analitik (PostHog) | 24 ay | Açık rıza / meşru menfaat | Otomatik silme |
| Destek yazışmaları | 3 yıl | Zamanaşımı/ispat | Silme |
| KVKK başvuru dosyası | 3 yıl (sonuçlanmadan sonra) | İspat | Silme |
| Yorum/başarı hikâyesi | İzin süresi (2 yıl) veya geri alınana kadar | Açık rıza | Yayından kaldırma + silme |
| Ses kaydı (varsa) | [X] gün | Açık rıza | Otomatik silme |
| Yedekler | En çok 30 gün | Süreklilik | Döngüyle üzerine yazma |

Uyuşmazlık, inceleme veya resmî talep varsa ilgili kayıtlar, süreç bitene kadar imhadan çıkarılır (hukuki bekletme).

## 4. İmha yöntemleri
- **Silme:** Veritabanından kalıcı silme; ilgili kullanıcıların erişimi kaldırılır.
- **Yok etme:** Fiziksel belgelerde kâğıt imha makinesi; cihazlarda güvenli silme.
- **Anonimleştirme:** Kimlik bilgileri silinir, öğrenme verileri yalnızca sınıf düzeyi + toplu istatistik olarak tutulur; küçük gruplarda (k < 10) yayımlanmaz.

## 5. Periyodik imha
Otomatik işler günlük çalışır (hesap silme kuyruğu, giriş olayları, hız sınırı kayıtları). Diğerleri **6 ayda bir** gözden geçirilir; her imha işlemi tarih, veri türü, kayıt sayısı ve yöntemle kayıt altına alınır ve bu kayıt 3 yıl saklanır.

## 6. Güncelleme
Politika yılda bir ve yeni bir veri işleme faaliyeti başladığında gözden geçirilir.
