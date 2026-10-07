# Yönetim Merkezi — veritabanı notları (2026-10-07)

Üç migration **2026-10-07'de canlı veritabanına uygulandı** (`supabase db push`). Test dosyası
`supabase db query --linked -f supabase/tests/yonetim_merkezi_tests.sql` ile canlıda çalıştırıldı: **28/28 geçti**,
veri geri alındı. Ortamda henüz uygulanmamışsa web-panelde yeni ekranlar "veritabanı güncellemesi uygulanmamış"
uyarısı gösterir; veli panelindeki kartlar görünmez.

## Uygulama sırası

1. `20261007000010_crm_profil_tercihler_ve_denetim.sql`
2. `20261007000020_segment_kampanya_ve_iletisim_ayarlari.sql` (1'e bağlıdır: `iletisim_tercihleri`)
3. `20261007000030_anket_otomasyon_analitik_ve_mutabakat.sql` (2'ye bağlıdır: `olay_kutusu` ve önceki iki dosya)

```bash
npm run db:status    # bağlı projenin ccozfrpnvyrnktpffkwo olduğunu gör
npm run db:preview   # yalnızca bu 3 dosya bekliyor olmalı
npm run db:deploy
```

Test dosyası kalıcı kayıt bırakmaz (sonunda geri alınır); SQL Editor'de veya yukarıdaki CLI komutuyla çalışır.

## Bilinçli sınırlar

- **Gönderici/otomasyon worker'ı yok.** `planlandi` ve otomasyon `hazir` durumları niyet kaydıdır; hiçbir mesaj
  gönderilmez. Worker'ın yapması gerekenler: kilit/lease, idempotency, retry, **gönderim anında** izin ve sıklık
  yeniden kontrolü (`iletisim_tercihleri`, `iletisim_ayarlari`), sessiz saat.
- Mutabakat (`admin_odeme_mutabakat`) sağlayıcı olaylarını doğrulamaz; yalnızca kayıtlar arası tutarsızlığa bakar.
- Analitik kohortu `user_answers.created_at` (ilk cevap tarihi) ile hesaplanır; tekrar cevaplar sayılmaz.
- Anonim ankette katılım (kim katıldı) `anket_katilimlari`'nda tutulur, yanıt içeriği tutulmaz; yanıtın zamanı güne
  yuvarlanır. Anonimlik yanıt geldikten sonra değiştirilemez.
- Rol matrisi (`/yonetim/ekip`) yalnızca planlanan modeldir; gerçek roller hâlâ `admin` ve `ogretmen`.

## Güvenlik özeti

- Yeni tabloların hepsi RLS açık + istemciye tüm yetki kapalı; yalnızca `SECURITY DEFINER` RPC'ler (`set search_path = ''`).
- İç yardımcılar (`_tercih_yaz`, `_segment_veliler`, `_sessiz_saat_mi`, `_anket_sorulari_hatasi`,
  `_otomasyon_adimlari_hatasi`) istemciden çağrılamaz.
- İzin değişikliği ve dışa aktarma gerekçe ister; gerekçe/adet denetim izine yazılır, kişi verisi yazılmaz.
- Çocuk hesaplarına iletişim tercihi tanımlanamaz; segmentler yalnızca `role = 'veli'` kayıtlarından kurulur.

## Bağımsız inceleme (2026-10-07) ve açık kararlar

Migration/test dosyaları ayrı bir gözden geçirmeden geçti; düzeltilenler: testteki iki yarıda kesen hata
(OUT parametresi–kolon çakışması, kapalı tabloya doğrudan okuma), segment kriterlerinin sessizce yok sayılması,
kontrol edilmiş kampanyanın segmentinin sonradan değişmesi, sıklık sınırında izinsiz alıcıların sayılması,
anket yanıtında çifte gönderim yarışı, NULL ile geçen doğrulamalar, kohortun `answer_events`'ten hesaplanması.

Kullanıcı kararıyla (2026-10-07) sıkılaştırılanlar:
- **Anonim anket:** katılım zamanı güne yuvarlanır; 5''ten az yanıtta sonuçlar sunucuda gizlenir.
- **`iletisim_tercih_gecmisi`:** tetikleyiciyle silinemez/güncellenemez; veli silinirse yalnızca `veli_id` null olur
  (kanıt kalır — KVKK silme hakkı ile ispat yükümlülüğü dengesi için hukuki onay önerilir).
- **Admin izin veremez:** `admin_veli_tercih_ayarla` yalnızca `izin=false` kabul eder; izni yalnızca veli verir.
- Sıklık sınırı ±6 gün pencereli muhafazakâr yaklaşımdır; tam "kayan 7 gün" hesabı yapılmaz.