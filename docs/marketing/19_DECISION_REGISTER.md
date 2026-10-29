# 19 Karar Kaydı

Durum: Taslak · Tarih: 2026-10-29 · Rol: CMO · Bağımlı: tümü. Bu dosya diğer belgelerin hedef kitle, konumlandırma, fiyat/deneme/kota alanlarını **kilitler**. Çelişki bulunursa buraya uyulur. `docs/hupo-design-growth/decisions.md` kararları üstündür.

## 1. Kilitli kararlar (K-n; "MAR" önerisi = kullanıcı onaylı değil)
| ID | Karar | Durum | Kaynak |
|---|---|---|---|
| K-1 | Marka Hupolingo, maskot Hupo; yeni karakter/lig/XP adı yok | KİLİTLİ (repo) | PROJECT_CONTEXT |
| K-2 | Satın alan = veli; çocuk yüzeyi reklamsız/baskısız; pazarlama yalnız veliye | KİLİTLİ | decisions |
| K-3 | Fiyat/kota/deneme admin plan kaydından; bu planda rakam üretilmez | KİLİTLİ | decisions 2026-10-06/09 |
| K-4 | Ödeme tek seferlik; otomatik yenileme/abonelik/iptal dili yok | KİLİTLİ | K-0196 |
| K-5 | "Ücretsiz deneme" dili, akış kartsız self-serve çalışana ve hukuk metni onaylanana dek hiçbir yüzeyde yok | KİLİTLİ | STRATEJI Y5, GIE §34 |
| K-6 | Güven rozetleri (iade garantisi, %100, gizli ücret yok, istediğin zaman iptal, %40) hiçbir yüzeyde yok | KİLİTLİ | decisions 2026-10-29 |
| K-7 | Mağaza "indir" iddiası yok (mağaza yayını yok) | KİLİTLİ | Y1 |
| K-8 | Yayın öncesi liste Y1–Y5 kapanmadan trafik yönlendirilmez | KİLİTLİ | K-0199 |
| K-9 | Kanal: Instagram birincil, YouTube/Shorts ikincil, LinkedIn ayda 2; TikTok/Facebook/X ertelendi/önerilmedi; ücretli sosyal ilk 6 ay yok | MAR önerisi (KANAL planı onay bekliyor) | KANAL_OTOMASYON_PLANI |
| K-10 | Yayın insan eliyle platform aracında; API/OAuth bağlama, otomatik DM yok | MAR önerisi | KANAL §5.4 |
| K-11 | Okul bitiş, LGS, ortak yazılı tarihleri doğrulanmadı; planda tarih sözü yok | AÇIK (R-4) | 08 |
| K-12 | Kazanım kodu/iddiası yalnız kaynak görülünce; 4 ve 8. sınıf önceki program → kazanım iddiası yok | KİLİTLİ | CLAUDE.md |
| K-13 | Ana kategori "veli görünürlüklü günlük soru rutini"; "AI özel ders", "sınav garantisi" kategorisi yok | MAR önerisi | 03 |
| K-14 | Kurum/okul satışı ve resmî ortaklık iddiası 12 ayda yok; öğretmen yalnız organik | MAR önerisi | 05 |
| K-15 | Teşvikli veli→veli davet/referans programı 12. ay sonrası; çocuktan referans/ödül yok | MAR önerisi | 20 #14 |
| K-16 | Marka mimarisi A (tek çatı Hupolingo); HupoRead/Okuma, Kelime Evreni, Görselli soru, Deneme, HupoMentor pazarlamada anılmaz (pilot/planlı) | MAR önerisi | 01, 03 |
| K-17 | Ücretli reklam: ödeme canlı + aktif→ücretli ölçüldü + CAC tavanı + ayrı onay olmadan yok | MAR önerisi | 15 |
| K-18 | Sosyal içerik tam veli hedefli; çocuğa yönelik içerik/CTA yok | MAR önerisi | 07 |
| K-19 | MEBİ ile nötr, tamamlayıcı dil; karşılaştırmada yalnız kamu bilgisi | MAR önerisi | 02 |
| K-20 | Otomasyon: durum makinesi taslak→marka-denetimi→insan-onayi→planlandi→yayinlandi; kodda onaysız yayın imkânsız (ağ kodu yok) | UYGULANDI (yerel MVP, test 14/14) | automation/ |
| K-21 | Bütçe/CAC/LTV yalnız senaryo; fiyat varsayımı gerçek fiyat değildir | KİLİTLİ | 15 |
| K-22 | Hero: H1 mevcut kol, H2 ilk niteliksel test; kod değiştirilmedi | MAR önerisi | 06 |
| K-23 | Kullanıcı eklediği 20 taktik havuzu 20 §2'deki gibi sınıflandı (Product Hunt, otomatik DM, Offer Codes kullanılmaz; çeviri ertelendi) | MAR önerisi | 20 |

## 2. Onay Bekleyen (kullanıcıdan istenen)
| # | Karar | Seçenekler (öneri *) | Neden şimdi |
|---|---|---|---|
| O-1 | 12 aylık planı ve K-9…K-23 önerilerini onayla | Onayla* / revize | Tüm iş akışı buna bağlı |
| O-2 | Ürün lansman/yayın tarihi ve mağaza kararı | Pilot → mağaza (tarih ver) | Takvim kaydırılır |
| O-3 | Hukuk onay sırası ve avukat | Ön bilgilendirme + aydınlatma önce* | Gönderim/ödeme kapıları |
| O-4 | Y1, Y2, Y5 kod düzeltmelerini ana oturuma iş olarak ver | Şimdi hazırla, satıştan önce uygula* | Kapı |
| O-5 | Hesapları aç (adım 1–8) ve YouTube "çocuklara yönelik" kararı | Hayır (veli kitle)* | T0 |
| O-6 | Ücretli reklam hiç mi? | İlk 6 ay hayır*; Mayıs'ta yeniden bak | 15 sonucu |
| O-7 | Pilot hane daveti (20–30, admin deneme) ve veli görüşmeleri (8) rıza metni | Evet* | Kanıt/öğrenme |
| O-8 | Plan fiyatları ve kapsam (Free/Premium/Aile) | Admin'den kayıt | 15 gerçek girdisi |
| O-9 | Hane/kaynak kaydı migration'ı | Önerilen yol (decisions 2026-10-29)* | Kanal CAC |
| O-10 | n8n iskeletini Oracle'a yüklemek | Hayır, dosya tabanlı yeter* | Gereksiz risk |
| O-11 | Üçüncü tur: rakip araştırması R-1'i kim yapar | Kullanıcı tarayıcısı / araç yetkisi | 02 boşluk |
| O-12 | Topluluk tanıtımları (veli grupları, okul-aile birlikleri) için ilk 3 hedef ve yönetici temasları | Onayla | 20 #10 |
| O-13 | Basın/blog tanıtım metinlerinin dışarı gönderimi | Onaylı metinle, tek tek | 20 #16 |
| O-14 | PROJE_GUNLUGU.md kaydı (AGENTS §9 biçimi) ana oturumca | Evet | Bu çalışma yalnız docs/marketing yazdı |

## 3. Tutarlılık denetimi (dosyalar arası)
| Alan | Değer (tüm dosyalarda) |
|---|---|
| Hedef kitle | Veli (ana P1), 4. sınıf ağırlıklı 3–7 |
| Konumlandırma | "Veli görünürlüklü günlük soru rutini"; tek CTA "Örnek soruları dene" |
| Fiyat/deneme/kota | Yok (plan kaydı); tek seferlik; ücretsiz deneme dili yok |
| Kanal | Instagram > YouTube/Shorts > LinkedIn |
| Yayın | İnsan; kapı Y1–Y5 |
Denetim yöntemi: dosyalarda yasaklı ifade taraması 00–20 üzerinde yapıldı (bkz. `_ILERLEME.md` doğrulama notu).
