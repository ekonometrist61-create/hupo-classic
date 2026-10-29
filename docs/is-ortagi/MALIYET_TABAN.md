# Ortaksız taban maliyet modeli (2026-10-29) — TÜM DEĞERLER VARSAYIM

Varsayımlar: 1 $ = 45 TL (kontrol et); yıllık plan 1.200 TL brüt = 1.000 KDV hariç (gerçek değer admin `plans` tablosunda); 1 hane = 1,3 öğrenci; iade %5; iyzico+taksit %4,2 (KDV dahil); ücretli hane başına net katkı ~900 TL/yıl; kullanıcı başına aylık veri trafiği ~30 MB (ölçülmedi).
Repoda kullanıcı başına çalışan yapay zekâ çağrısı bulunmadı (functions içinde yalnız e-posta/olay kutusu; yalnız functions tarandı). İçerik üretimi (Gemini) sabit maliyet sayıldı.

## Marjinal maliyet
Ücretsiz aktif kullanıcı: Supabase Pro kotaları içinde (8 GB DB, 250 GB trafik ≈ 8.000 MAU, 100 bin MAU) ~0 TL; kota üstünde ~0,3–1 TL/ay (~4–12 TL/yıl). Ücretli hane: ~10 TL/yıl değişken + ödeme komisyonu.

## Yıllık sabit maliyet (TL)
| Ölçek (aktif öğrenci) | Hane | Sabit/yıl | Kalemler |
|---|---|---|---|
| 500 | 385 | ~128 bin | Supabase Pro, Vercel Pro, Apple, alan adı, içerik üretimi, muhasebe |
| 2.000 | 1.538 | ~216 bin | + Resend, Sentry, yarı zamanlı destek |
| 10.000 | 7.692 | ~456 bin | + Supabase compute yükseltme, trafik aşımı, destek |
| 50.000 | 38.462 | ~1,3 milyon | + büyük compute, trafik (~1,5 TB), analitik, 1,5 kişilik destek |

## Net (reklam/CAC hariç, yıllık, TL) ve başabaş
| Aktif öğrenci | Ücretli %2 | %5 | %8 | Başabaş ücretli hane oranı |
|---|---|---|---|---|
| 500 | −121 bin | −111 bin | −100 bin | %37 |
| 2.000 | −188 bin | −147 bin | −105 bin | %16 |
| 10.000 | −318 bin | −110 bin | +97 bin | %6,6 |
| 50.000 | −608 bin | +430 bin | +1,47 mn | %3,8 |

Bir ücretli hane (~900 TL/yıl) tüm sabit maliyet dahil yaklaşık 8 (2.000 ölçeğinde), 20 (10.000), 35 (50.000) aktif öğrenciyi taşır; yalnız marjinal maliyetle ~90 ücretsiz kullanıcıyı.
Reklamla edinim: ücretli hane başına 200–400 TL CAC varsayımı → yıllık net katkıyla geri dönüş ~2–4 kat. Ortak komisyonu (~237 TL/alıcı + indirim 150 TL) bu CAC bandıyla karşılaştırılmalı.
