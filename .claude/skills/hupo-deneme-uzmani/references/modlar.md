# Deneme modları ve takvim

Bu dosya `hupo-deneme-uzmani` skill'inin referansıdır. Ağırlıklar ve süreler **ürün önerisidir**, MEB standardı değildir.

## Takvim (2026–27)

| Olay | Tarih | Not |
|---|---|---|
| Okul başlangıcı | 14 Eylül 2026 | Paket kaydı |
| 1. ara tatil | 16–20 Kasım 2026 | Paket kaydı; resmî MEB takvimiyle teyit edilmeli |
| 1. dönem sonu | 22 Ocak 2027 | |
| Yarıyıl tatili | 25 Ocak – 5 Şubat 2027 | |
| 2. dönem başı | 8 Şubat 2027 | |
| 2. ara tatil | 8–12 Mart 2027 | |
| Okul sonu | 25 Haziran 2027 | |

Kural: takvim tarihi bir konunun işlendiğini kanıtlamaz. İşlendiği yalnızca kapı K4'te doğrulanır.

## Modlar

| Mod | Kapsam | Ağırlık (son / önceki) | Çıktı |
|---|---|---|---|
| `sene_basi` | Önceki sınıf kazanımları (`kapsam_kaynagi=onceki_sinif` olabilir) | 0 / 1 | Seviye tespiti, güçlü ve zayıf konu raporu; 1–4. sınıfta puansız |
| `haftalik` | `as_of_date` gününe kadar doğrulanmış işlenmiş konular | 0,6 / 0,4 | Ders bazında geri bildirim, kısa telafi |
| `ara_tatil_kasim` | 16 Kasım 2026'dan önce işlenmiş konular | 0,35 / 0,65 | Kavramsal açık raporu, tatil hedefleri; gerekirse iki oturum |
| `yariyil` | 1. dönem sonuna kadar tamamlanan konular; 2. dönem hariç | 0,4 / 0,6 | 1. dönem öğrenme haritası, 2. dönem köprü çalışması |
| `ara_tatil_mart` | 8 Mart 2027'den önce işlenen 1. ve 2. dönem konuları | 0,4 / 0,6 | Önkoşul açıkları, yeniden tekrar planı |
| `yilsonu` | Tamamlandığı teyit edilen yıl konuları; geçen veya gelecek sınıftan ekleme yok | 0,3 / 0,7 | Sınıf geçiş destek planı |
| `proje_genel` | 4. sınıf müfredatı ve hedef okulun resmî kapsamı | 0,35 / 0,65 | Okul profiline uyum kanıt düzeyi |
| `proje_iho` | 4. sınıf müfredatı ve yalnız hedef okulun ilan ettiği özel alanlar | 0,35 / 0,65 | Özel alan ve akademik net ayrımı; mülakat ayrı |
| `lgs` | 8. sınıf müfredatı ve işlenmiş konular | 0,3 / 0,7 | Sözel ve sayısal ayrı, alt testler, gerekçeli çözüm |
| `ortak_yazili` | Yalnız ilgili ders ve zümrenin seçtiği senaryo | — | Açık uçlu soru, analitik rubrik, geri bildirim |

## Yapı ve süre notları

- **Proje okulları:** 2026 örnek yapıları okula özgüdür. Başka okula genellenmez. Yapılar `Hupo taslak` etiketi taşımadan okul adıyla sunulmaz.
- **LGS:** paket kaydında 2026 için 90 soru, 155 dakika, iki oturum (50/75 ve 40/80) geçer. Bu bilgi yıl kılavuzuyla teyit edilmeden kesin kabul edilmez.
- **Ortak yazılı:** Hupo okul sınavı uygulamaz. Çıktı, zümre senaryosunu provaya çevirir; sınav ve sıralama işlevi yoktur.
- **Yanlış cevap puanlaması** (ör. üç yanlış bir doğruyu götürür): yalnızca kılavuzda yazılıysa kullanılır; yoksa uygulanmaz.
