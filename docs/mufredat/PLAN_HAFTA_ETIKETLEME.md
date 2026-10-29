# Müfredat Haritası ile Soru Etiketleme ve "Şimdiye Kadar İşlenenler" Pratiği — Tasarım ve İş Paketleri

Durum: PLAN (2026-10-24). Karar sahibi: kullanıcı (delege: ana oturum). Kodlama: Haiku 5.5; mimari, sözleşme ve kabul: Sonnet.
Girdi: `docs/mufredat/` (mufredat_hafta, sinav_dagilim, okul haftaları). Kanıt: README ve K-0129.

## 1. Hedef (kullanıcı görevi)
Çocuk, ders seçtiğinde **bu haftanın konularını** ya da **bugüne kadar işlenen tüm konuları** (karışık) çözebilsin; ya da haftaya/konuya göre seçebilsin. Veli ve yönetici, hangi kazanımda kaç onaylı soru olduğunu görsün.
Kabul ölçütü (ürün): 5. sınıf Matematik öğrencisi, 14 Aralık haftasında "Bugüne kadar" derse yalnız hafta ≤ 13'te işlenen kazanımlara etiketli, onaylı sorular gelir; hafta 14+ sorusu gelmez.

## 2. Kısıtlar (değişmez)
- Etiket ≠ yayın. `onay_durumu` ve yayın kapısı (iki denetçi + insan onayı) bu işte değişmez. Yeni soru yazılmaz.
- Soru başına **tek** kazanım (`docs/soru-uretim/REHBER.md` §12). Kod yalnız müfredatta görülürse yazılır; görülmezse boş kalır (`source_pending`).
- 1–4. sınıfta puan/sıra gösterilmez (GÖR-058). Öğrenme metriği XP/süre ile karıştırılmaz. Sahte sosyal kanıt, puan/sınav garantisi yok.
- Yeni RPC: `set search_path = ''`, `public.` nitelemesi, `revoke`/`grant` satırı; yeni tablo: RLS + politika (AGENTS.md §4).
- Uzak DB'ye migration yalnız Sonnet kontrolünden sonra (`db:preview` tek bekleyen migration ise).
- Hassas veri/PII yok. Çocuk uygulaması: takip ve reklam kapalı.

## 3. Mevcut durum (haritalama ajanı, 2026-10-24)
- `questions`: `ders`, `konu` serbest metin; `sinif` (RLS anahtarı: öğrenci yalnız `my_sinif()` ve onaylı soruyu görür); `kazanim_kodu` kolonu var (20261047) ama ~400–460 seed sorunun neredeyse tamamında **boş**. 12 paket JSON'unda ~707 kodlu soru var, DB'ye aktarım durumu belirsiz.
- Öğrenci soru çekimi RPC değil, istemcide PostgREST (`quiz_repository.dart:105-137`); `user_answers.sonraki_tekrar_tarihi` ile tekrar sırası; ilerleme `get_topic_progress` (serbest `konu` metnine göre, ≥6 cevap eşiği).
- Etiketleme arayüzü yok (`QuestionFormModal` kazanımsız; `PaketImport` v2 kazanımı alıyor).
- `mufredat_hafta` (10.594 satır), `mufredat_sinav_dagilim` (WP0 sonrası) FK'siz, `kazanim_kodu` metin eşleşmesiyle bağlanır.
- Canlıdaki gerçek kazanımlı soru sayısı **ölçülmedi** (WP1 ilk işi).

## 4. Tasarım

### 4.1 Veri modeli
1. `questions.kazanim_kodu` tek doğruluk kaynağı (köprü tablo yok). Yeni indeks: `(sinif, kazanim_kodu) where kazanim_kodu is not null`.
2. `mufredat_ders_eslesme(soru_ders, mufredat_ders)`: `questions.ders` serbest metindir; müfredattaki ad ile eşlenir (ör. "Türkçe" → "Türkçe"). Eşlenmeyen ders raporlanır, tahmin edilmez.
3. `mufredat_takvim(hafta, baslangic, bitis, tatil_mi, not)`: 2026-27 okul haftaları (`okul_haftalari_2026_2027.csv`'den, tatil haftaları işaretli). `public.mufredat_bugun_hafta(p_tarih)`: tarih hangi hafta; tatilde son işlenen hafta; dönem başından önce 1; sonrasında son hafta. Saat dilimi Europe/Istanbul.
4. `mufredat_kazanim_ozet` (görünüm): `(mufredat_ders, sinif, kazanim_kodu)` → `ilk_hafta`, `son_hafta`, `haftalar[]`, `unite_tema`, `konu`, `kaynak_yili`. Kaynak yılı 2025-2026 satırları (DKAB 4/8) **dışlanır** (2026-27 yayımı yok).
5. Hafta hesabı kazanımın **ilk** haftasından: bir kazanım ilk işlendiği haftadan itibaren "işlenmiş" sayılır (tekrar haftaları geriye yazmaz).

### 4.2 Öğrenci API (RPC, SECURITY INVOKER, yalnız `authenticated`)
Sınıf `my_sinif()` ile alınır, istemciden gelmez. Yalnız `onay_durumu='onaylandi'` ve kazanımı etiketli sorular.

`get_mufredat_haritasi(p_ders text, p_tarih date default null) returns jsonb`
```
{ "sinif": 5, "ders": "Matematik", "bugun_hafta": 13,
  "haftalar": [ { "hafta": 1, "baslangic": "2026-09-14", "bitis": "2026-09-18", "tatil": false,
      "unite_tema": "GEOMETRİK ŞEKİLLER", "konular": ["Temel Geometrik Çizimler ve İnşalar"],
      "kazanimlar": [ { "kod": "MAT.5.3.1", "metin": "…", "ilk_hafta": 1,
          "soru_sayisi": 12, "cevaplanan": 4, "dogru": 3 } ] } ] }
```
`cevaplanan/dogru` kullanıcının `user_answers` kaydından. Doğruluk oranı yalnız ≥6 cevapta hesaplanır (mevcut kural); 1–4. sınıfta oran gizlenir.

`get_mufredat_sorulari(p_ders text, p_mod text, p_hafta int default null, p_kazanim_kodlari text[] default null, p_limit int default 10) returns setof jsonb`
- `p_mod`: `'bu_hafta'` (ilk_hafta = bugun_hafta), `'bugune_kadar'` (ilk_hafta ≤ bugun_hafta), `'hafta'` (ilk_hafta ≤ p_hafta), `'kazanim'` (kodlar listesi).
- Sıra: vadesi gelen tekrar → hiç çözülmemiş → diğer; eşitlikte rastgele. Limit en çok 30.
- Dönen alanlar: `fetchQuizQuestions`'ın döndürdüğü alanların aynısı (id, ders, konu, alt_konu, zorluk, soru_metni, siklar…; `dogru_sik` dahil değil/aynı) **+** `kazanim_kodu`, `hafta`.
- Geçersiz `p_mod`, boş ders, sınıfı olmayan profil → anlamlı hata (`raise exception`), boş liste değil.

### 4.3 Yönetim API (SECURITY DEFINER, admin)
- `admin_set_question_kazanim(p_ids uuid[], p_kod text) returns int`: kod, sorunun `sinif` ve eşlenmiş dersi için `mufredat_hafta`'da yoksa **hata**; `kazanim_kodu` + `kazanim_metni` (müfredat metni) yazar; revizyon geçmişine düşer (mevcut `soru_revizyon_gecmisi` mekanizması). `p_kod = null` etiketi kaldırır.
- `admin_kazanim_kapsam(p_ders text, p_sinif int) returns table(kazanim_kodu, kazanim_metni, ilk_hafta, unite_tema, onayli_soru, bekleyen_soru, sinav1_ort, sinav2_ort)`: boş kazanımları bulmak için. `sinav*_ort` yalnız 5–8.
- `admin_kazanimsiz_sorular(p_ders, p_sinif, p_limit, p_offset)`.

### 4.4 Etiketleme hattı (mevcut sorular)
1. Salt okunur: DB'den kazanımsız, onaylı soruları çek (`supabase db query --linked`, JSON).
2. Her soru için müfredattan **aday listesi** (aynı sınıf+ders; `konu`/`alt_konu`/soru metni anahtar sözcük eşleşmesiyle ilk 8).
3. Haiku ajanı soru metnini **okuyarak** adaylardan birini seçer ya da `eslesme_yok` der; güven: `yuksek|orta|dusuk`, gerekçe 1 cümle. Çıktı: `docs/mufredat/etiket_onerileri/etiket_onerileri_<tarih>.csv` (soru_id, onerilen_kod, guven, gerekce). **DB'ye yazılmaz.**
4. İnsan onayı: `dusuk` ve `orta` hepsi, `yuksek` için %20 örnek. Onaylanan liste yönetim ekranından/`admin_set_question_kazanim` ile uygulanır.
5. Paket JSON'larındaki kodlu sorular için: kod müfredatta var mı kontrolü (rapor: `kod_mufredatta_yok`).

### 4.5 Arayüz
Flutter (öğrenci): ders ekranında **"Müfredat yolu"**: hafta şeridi (bugün vurgulu), hafta başına ünite/konu ve kazanım rozetleri; üstte üç eylem — "Bu haftanın konuları", "Bugüne kadar karışık", "Konu seç". Gelecek haftalar görünür ama "henüz işlenmedi" etiketli; varsayılan pratik yalnız işlenmişler. Soru çözümü mevcut `QuizScreen`. Soru yoksa "Bu konuda henüz soru yok" (boş durum). Yükleniyor/hata/çevrimdışı durumları; ≥48 dp dokunma alanı; 320 px uyumlu. Metinler çocuk dili, baskısız (hupo-ux-writing).
Web panel (yönetim): Sorular listesine "kazanımsız" filtresi ve toplu "kazanım ata" (ders+sınıfa göre açılır liste), `QuestionFormModal`'a kazanım seçici, yeni sayfa **Kazanım Kapsamı** (ders/sınıf seç → hafta sırasıyla kazanım × onaylı soru sayısı, boşlar kırmızı, 5–8'de sınav ağırlığı).
Veli paneli (Faz 2): çocuğun bu hafta işlenen konuları ve kazanım bazlı doğruluğu (`get_child_...` benzeri RPC, `is_parent_of`).

### 4.6 Açık ürün soruları (Faz 2'de karar)
- Veli "çocuğum geride/ileride" hafta kaydırma (`profiles` alanı) gerekir mi?
- Hafta 37 sonrası (yaz) davranışı; okul farklı plan izlerse (yayıncı varyantı) kazanım bazlı olduğu için etkilenmez.
- 4 ve 8. sınıf DKAB: 2026-27 planı yok → harita boş kalır (kullanıcıya "plan yayımlanınca" metni).

## 5. İş paketleri (Haiku kodlar, Sonnet kabul eder)

| WP | Kapsam | Bağımlılık | Çıktı / kabul |
|---|---|---|---|
| WP1 | **Ölçüm + DB temeli**: canlıda `kazanim_kodu` dolu/boş sayısı, `distinct ders` değerleri; `mufredat_ders_eslesme`, `mufredat_takvim` (+tohum), `mufredat_bugun_hafta`, `mufredat_kazanim_ozet`, indeks. Migration `20261085…` | — | PGlite testleri: hafta fonksiyonu 6 tarih (başlangıç öncesi, tatil, son hafta sonrası dahil); özet görünümünde DKAB 4/8 yok; eşlenmeyen ders raporu |
| WP2 | Öğrenci RPC'leri `get_mufredat_haritasi`, `get_mufredat_sorulari` (+ yönetim RPC'leri §4.3). Migration `20261086…` | WP1 | PGlite testi: 5. sınıf Mat öğrencisi, tarih 2026-12-14, `bugune_kadar` yalnız ilk_hafta ≤ 13; başka sınıfın sorusu gelmez (RLS); reddedilmiş/beklemede gelmez; geçersiz mod hata; `anon` erişemez |
| WP3 | Etiketleme hattı §4.4 (aday üretici betik + Haiku sınıflandırma + öneri CSV + rapor) | WP1 (ders eşleme) | CSV, kazanımsız onaylı soruların %100'ü için satır; `eslesme_yok` payı raporlanır; DB'ye yazma yok |
| WP4 | Web panel: filtre, toplu kazanım ata, form seçici, Kazanım Kapsamı sayfası (`tr`/`en` mesajları) | WP2 sözleşmesi | `npm run lint` + `tsc` 0 hata; 390/768/1024 px; ekran kanıtı yoksa "DOĞRULANMADI" |
| WP5 | Flutter: model, repository, provider, "Müfredat yolu" ekranı, 3 eylem, boş/hata durumları; `fetchQuizQuestions` değişmeden kalır (yeni yol ayrı) | WP2 sözleşmesi | `flutter analyze` 0 hata, widget testleri (yükleniyor/boş/dolu/hata), sabit renk yok (`app_theme.dart`) |
| WP6 | Veli paneli haftalık özet (Faz 2) | WP2, WP5 | ayrı plan |
| WP7 | Uç uca: kabul ölçütü senaryosu; `PROJE_GUNLUGU.md` kaydı; README güncellemesi | WP1–5 | Kayıt K-xxxx, `DOĞRULANDI` yalnız test+ekran kanıtıyla |

Sıra: WP1→WP2 (tek ajan, migration numaraları çakışmasın); WP3 paralel; WP4 ve WP5 sözleşmeye göre paralel, WP2 sonrası entegrasyon. Uzak DB'ye uygulama ve mobil/web yayın: Sonnet kontrolü + `db:preview` sonrası.

## 6. Riskler
- Etiketli soru az: ilk açılışta "bugüne kadar" çoğu ders için boş çıkar. Önlem: WP3 + Kazanım Kapsamı; boş durum metni; admin raporu soru üretim önceliğini belirler.
- `questions.ders` yazım farkı (WP1 eşleme tablosu); `konu` serbest metin (müfredat konusuna taşınmaz, kazanım yetkilidir).
- Yerel/canlı şema farkı (`questions.sinif` canlıda NOT NULL): WP1 canlıyı sorgular.
- Haiku'nun yanlış etiketi: öneri → insan onayı → RPC doğrulaması (kod müfredatta olmalı).
- Plan taslak; MEB güncellerse migration yeniden üretilir (`scripts/`).
