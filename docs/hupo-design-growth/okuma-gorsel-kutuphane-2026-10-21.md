# HupoRead görsel kütüphane (2026-10-21)

**Durum: BLOCKED (görsel üretim).** Altyapı hazır; hiçbir görsel üretilmedi.

## Engel
`mcp__nano-banana-2__generate_image` iki denemede de `400 API_KEY_INVALID` döndü (MCP süreci bayat anahtarı kullanıyor). Kural gereği durduruldu; anahtar hiçbir dosyaya yazılmadı, MCP yapılandırması değiştirilmedi. Deneme partisi (3 karakter + 8 ikon) bu yüzden çalıştırılamadı ve stil kilidi doğrulanmadı.
Gereken: MCP sürecinin anahtarını `Soru-Cevap Hazırlama Programı\.env` içindeki doğru anahtarla yenile (Claude Code yeniden başlat), sonra aşağıdaki üretim planını çalıştır.

## Üretilenler
| Varlık | Sonuç |
|---|---|
| `assets/okuma/karakter_manifest.json` | 47 karakter satırı, hepsi `uretildi:false` |
| `assets/okuma/ikon_manifest.json` | 80 ikon satırı, hepsi `uretildi:false` |
| `assets/okuma/manifest.schema.json` | ortak şema (id deseni, sınıf 2-8, dosya yolu kuralı) |
| `lib/models/okuma_varlik.dart` | saf Dart model + katalog çözümleyici (bozuk satır atlanır) |
| `lib/widgets/okuma/kahraman_gorsel.dart` | manifest yükleyici + `KahramanGorsel` (yoksa yedek ikon) |
| `kahraman_secim_ekrani.dart` | kart: `KahramanGorsel(yedek: mevcut ikon)`; işlev ve Semantics aynı |
| `test/okuma_varlik_test.dart` | 2 test; `uretildi:true` ise dosya varlığını da doğrular |
| `pubspec.yaml` | yalnız `assets/okuma/` (şimdilik sadece manifestler). `karakterler/`, `ikonlar/` klasörleri görsel gelince eklenecek |
| Promptlar | `docs/hupo-design-growth/okuma-varlik-promptlari.json` (kopya: `C:\Dev\Senin Hikayen - HupoRead\varlik_kaynak\prompts.json`) |

**ÜRETİLMEDİ:** 46 karakter (47. `hupo_kus` mevcut onaylı Hupo master'dan gelecek, yeniden çizilmeyecek) ve 80 ikon.
Karakter dağılımı: insan 18 (başörtülü: öğrenci, bilim insanı, sporcu, kâşif, gizem çözücü, anne = 6), fantastik 13, hayvan 9, araç 7. Sınıf aralıkları 2-4 / 5-6 / 7-8'i kapsar; 7-8 karakterleri "olgun genç oranlar" talimatıyla.
İkon kategorileri: navigasyon 6, hikâye oluşturma 6, okuma 20, oyunlaştırma 12, kullanıcı 6, veli 6, sistem 24.

## Stil rehberi (taslak, deneme partisiyle kilitlenecek)
- Karakter öneki: premium cel-shaded çocuk kitabı çizimi, temiz ana hat, yumuşak hacim, ışık sol üstten; palet lacivert #17324D, altın #F5C842, turkuaz #147D82, yaprak yeşili #6DA940, sıcak mercan/şeftali; büyük ifadeli göz; göğüs üstü portre (hayvan/araç: tam nesne, 3/4 görünüm); aynı ölçek; düz magenta #FF00FF zemin, yazı/çerçeve yok.
- İkon öneki: yuvarlatılmış hatlar, hafif 3B hacim, ince lacivert dış hat, aynı görsel ağırlık, 48 px'te okunur, aşırı detay yok.
- Tam metinler JSON dosyasında (`stil_karakter`, `stil_ikon`; konu satırları `karakterler`/`ikonlar` altında).

## Üretim planı (anahtar düzelince)
1. Deneme: 3 karakter (erkek çocuk, genç kız, başörtülü bilim insanı) + 8 ikon, tek tabloda; stil kilitle.
2. Tablolar halinde (6 karakter / 12 ikon) üret; magenta kromayı betikle şeffaflaştır (bağlı bileşenle ayır, kenar rengi temizle), her varlığı ayrı 1024 PNG olarak `varlik_kaynak\`a, 512 WebP (ikon 256) olarak `assets/okuma/...`a yaz.
3. Her başarılı dosya için manifestte `uretildi:true`; pubspec'e klasör ekle; `flutter test test/okuma_*`.
4. Aynı karakterin ek poz/boyutu için kaynak görüntü referans verilerek `edit_image` kullan (kimlik tutarlılığı).
5. Kart görsellerini seçmek için manifest sırası: her `kartTuru` için ilk üretilen varlık gösterilir; daha iyi seçim gerekirse `kartVarsayilan` alanı eklenebilir.

## İkon biçimi kararı
Üretim rasterdir (WebP). `flutter_svg` pubspec'te yok; yeni paket eklenmedi. Tek renk SVG seti şu an gerekmiyor (düğmelerde Material ikonları sürüyor); ihtiyaç doğarsa paketin eklenmesi gerekçesiyle ayrıca karara bağlanır.

## Telif/içerik notları
Blok-dünyası karakteri "özgün küp estetik, mevcut oyun karakteri değil" diye promptlandı; Minecraft/Roblox öğeleri yok. Büyücü karakteri `KURALLAR.json` "inceleme" listesindeki büyü/cadı çağrışımına yakın: editör onayı gerekir. Başörtülü karakter promptları farklı rol ve renkler içerir; çıktı gelince temsil dengesi gözle doğrulanacak.

## Test (gerçekten çalıştırılan)
- `flutter test test/okuma_varlik_test.dart test/okuma_kart_test.dart test/okuma_akis_test.dart test/okuma_veri_test.dart`: 61 test geçti (büyük yazı, 320x568 taşma testleri dahil).
- `flutter analyze` (yeni/değişen dosyalar): sorun yok.
- Kahraman seçim ekranı gerçek görüntüsü alınmadı; görseller olmadığından ekran bugünkü yedek ikonlarla aynı.

## Boyut
Eklenen varlık: iki manifest + şema ≈ birkaç KB; APK etkisi ihmal edilebilir. Görsel boyutu ölçülemedi (görsel yok). Tahmin: 47×~60 KB + 80×~15 KB ≈ 4 MB.

## Kabul listesi
| Madde | Durum |
|---|---|
| 24+ karakter, 80+ ikon (manifest) | Manifest tamam; görsel yok: DOĞRULANAMADI |
| 2-8. sınıf dengesi, 7-8 bebeksi değil, başörtülü çeşitliliği | Plan/prompt var; görsel doğrulama YOK |
| Özgün/telif güvenli | Prompt düzeyinde; çıktı doğrulanmadı |
| İkon tek aile, küçük ekranda anlaşılır | DOĞRULANAMADI |
| Bağımsız dosya, standart isim | Manifest yolları standart; dosya yok |
| Seçim deneyimi, Semantics, ≥48dp, mevcut işlevler | Korundu (testler geçti) |
| Şeffaf arka plan | Yapılamadı (üretim yok) |
