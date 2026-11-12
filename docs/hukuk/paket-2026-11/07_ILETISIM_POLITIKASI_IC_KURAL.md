> İç kural · 2026-11-12 · CRM, kampanya, bildirim ve otomasyon işlerinde (insan ve ajan) uyulur. Avukat onayı bekliyor.

# İletişim politikası: hangi ileti, kime, hangi izinle?

Amaç: izin gerektirmeyen alanı sonuna kadar kullanmak, izin gerektiren alanda hata yapmamak.

## 1. Üç ileti sınıfı

| Sınıf | Tanım | İzin | İYS | Kime |
|---|---|---|---|---|
| **H — Hizmet/işlem** | Hesap, güvenlik, ödeme, fatura, şifre, doğrulama kodu, destek yanıtı, yasal bildirim | Gerekmez | Gerekmez | Veli, öğrenci |
| **K — Kullanım/hesap durumu** | Satın alınan hizmetin kullanımı, değişikliği, bakımı: gelişim raporu, kota doldu, deneme bitiyor, plan bitiyor, yeni özellik paketinize eklendi, bakım duyurusu, kullanım ipucu, memnuniyet anketi | Gerekmez (6563 m.6/1: "temin edilen hizmete ilişkin değişiklik, kullanım ve bakım") | Gerekmez | Veli; öğrenciye yalnızca çalışma hatırlatması |
| **T — Ticari** | Kampanya, indirim, başka paket/yükseltme önerisi, lansman, davet/referans teklifi, etkinlik tanıtımı, bülten | **İzin 1** | **Zorunlu** (SMS, e-posta) | Yalnızca izinli veli/aday |

**Sınıf kayması kuralı:** K sınıfındaki bir iletiye indirim, fiyat, "kaçırma", başka ürünün tanıtımı eklenirse ileti **T** olur. Şüphede T say.

Örnekler:

| İleti | Sınıf |
|---|---|
| "Ayşe bu hafta 4 gün çalıştı, kesirlerde %80 doğru." | K |
| "Deneme süreniz 3 gün sonra bitiyor. Planları görmek için: [bağlantı]" | K |
| "Planınız 7 gün sonra bitiyor. Kendiliğinden yenilenmez; devam etmek isterseniz: [bağlantı]" (30/7/1 gün kala) | K |
| "Deneme süreniz bitiyor — bugüne özel %30 indirim!" | **T** |
| "Paketinize Kelime Evreni eklendi." | K |
| "Kelime Evreni'ni Tam pakette deneyin, ilk ay 99 TL." | **T** |
| "Yarın 02:00–03:00 bakım var." | K |
| "Arkadaşını davet et, 1 ay bedava." | **T** |
| "Hizmetimizi değerlendirir misiniz? (anket)" | K (ödül/çekiliş varsa T) |
| Doğrulama kodu SMS'i | H (koda pazarlama eklenmez) |

## 2. Kanal kuralları

- **E-posta:** T iletilerinde gönderici kimliği, iletişim adresi ve tek tıkla ret bağlantısı zorunlu. Konu satırı yanıltıcı olmaz ("Re:", "Faturanız" gibi sahte işlem izlenimi yok).
- **SMS:** T iletilerinde marka adı ve "RET yazıp [KISA NO]'ya gönder" ibaresi; İYS'den marka kodu ile. Gönderim saati 09:00–21:00 [hukuken zorunlu değil, iyi uygulama].
- **Arama:** **Yapılmaz** (karar 2026-11-12, K-0256). Tanıtım amaçlı arama için onay toplanmaz; eski "telefon" onayları kullanılmaz. Destek talebine dönüş araması (kullanıcı istediyse) H sınıfıdır.
- **Push:** İki kategori: `calisma` (K, öğrenci ve veli) ve `kampanya` (T, yalnız veli cihazı, İzin 1 + cihaz izni). Öğrenci rolünde `kampanya` kategorisi kayıtlı olamaz.
- **Uygulama içi duyuru/banner:** Veli panelinde T içerik gösterilebilir (izin gerekmez, ileti değil), çocuk ekranında gösterilemez.

## 3. Sıklık ve saygı sınırları

- T iletileri: veli başına haftada en çok 2 (e-posta + push toplamı), SMS ayda en çok 4.
- Sessiz saat: 21:00–09:00 arası T push ve SMS yok.
- Ret gelen kanal en geç 3 iş günü içinde (hedef: anında) bastırma listesine girer; diğer kanallar etkilenmez.
- 12 ay hiçbir iletiyi açmayan izinli kişi "uyuyan" sayılır; bir kez hatırlatma, sonra T gönderimi durur (onay silinmez).

## 4. Hedefleme ve veri kullanımı

İzin 1 sahibi velide kullanılabilir: plan/deneme durumu, kullanım sıklığı, kullandığı modüller, çocuk sayısı ve **sınıf düzeyi**, kampanya etkileşimleri, kayıt kaynağı (UTM).
Kullanılmaz: çocuğun ayrıntılı cevapları, puanları, zayıf olduğu konular, okuma kayıtları, ses kaydı, takma adı.
> Ör. ✅ "5. sınıf velilerine LGS hazırlık lansmanı" ✅ "30 gündür giriş yapmayan velilere geri dönüş teklifi" ❌ "Kesirlerde zayıf öğrencilerin velilerine kesir paketi indirimi"

Reklam platformlarına yükleme (özel kitle, dönüşüm API, piksel) **lansmanda yapılmaz** (K-0256). Reklam ölçümü UTM parametreleri + PostHog (AB) ile, kişisel veri göndermeden yapılır. İleride açılırsa: yalnızca **İzin 2** sahipleri, yalnızca hash'li e-posta/telefon; öğrenci hesabı hiçbir zaman.

## 5. Gönderim öncesi kontrol (otomasyon da uygular)

1. Sınıf H/K/T belirlendi mi?
2. T ise: alıcı İzin 1 sahibi mi, ilgili kanal açık mı, İYS'de onaylı mı, bastırma listesinde değil mi?
3. Alıcı veli/aday mı (öğrenci değil)?
4. Sıklık ve sessiz saat sınırı aşılmıyor mu?
5. İçerikte sahte kıtlık, uydurma sayı, puan garantisi yok mu?
6. Ret bağlantısı/ibaresi var mı?

## 6. Kayıt

Her T kampanyası için: hedef kitle sorgusu, alıcı sayısı, kanal, metin, gönderim zamanı, İYS sorgu sonucu saklanır (3 yıl). Şikâyet hâlinde ispat bu kayıtlarla yapılır.
