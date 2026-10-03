# KARAKTER KOLEKSİYON PLANI — Öğrenci Hazırlık (Hupo)

> Oyunlaştırma / koleksiyon sistemi tasarım ve yol haritası.
> Ana kaynak: `MASTER_BRIEF.md` · Kurallar: `AGENTS.md`
> Oluşturma: 3 Ekim 2026 · Durum: **taslak — kullanıcı kararları bekliyor**

---

## 1. Vizyon (netleştirildi)

Ürün, sadece matematik değil; **ilk + ortaokul (1-8. sınıf)** için **Proje Okulu
sınavlarına hazırlık + oyunlaştırılmış öğrenme platformu**. Duolingo mantığı:
lig, yol haritası, puan, sempatik Hupo tepkileri, hata kaydı + tekrarlı öğrenme,
"öğreterek öğrenme".

Bu planın konusu: **Brawl Stars tarzı karakter koleksiyonu** —
**40 karakter = 8 tema sınıfı × 5 karakter**. Her karakter Hupo'nun farklı kostüm/
tarzdaki bir versiyonu. Çocuk ilerledikçe açar; kilitli olanlar **gölge/siluet**
görünür (silah/elbise ipucu merak uyandırır). Her sınıfın **kendi dünyası ve görsel
kimliği** olur; sınıflar birbirinin kopyası olmaz.

---

## 2. Mevcut temel (sıfırdan başlamıyoruz)

| Var olan parça | Dosya | Koleksiyon için rolü |
|---|---|---|
| Tek gelişen avatar, 5 XP evresi | `lib/widgets/evolving_avatar/avatar_models.dart` | Koleksiyonun 1/8 ölçekli prototipi; mantık devralınır |
| Kostümler (kodla vektör çizim) | `lib/widgets/evolving_avatar/evolving_avatar_widget.dart` | Ustalar/Efsaneler sınıfı için **referans sanat** (kemankeş, anka) |
| Açılış kutlaması | `evolving_avatar/tier_up_dialog.dart`, `tier_celebration_listener.dart` | Karakter açma töreni için hazır iskelet |
| Rozet kataloğu + kazanma | `supabase/migrations/20260920000500_badges.sql` | Koleksiyon tablosunun **birebir deseni** |
| Hupo pozları (20 ruh hali) | `lib/widgets/hupo/hupo_pose.dart` | Karakterlerin pozlu varyantları için temel |
| XP / seviye / seri / lig | `models/league_models.dart`, `student_stats` | Açılış ekonomisinin omurgası |

**Kritik gözlem:** Mevcut 5 evre (Çaylak Alp → Genç Kemankeş → Akıncı → Siber Yeniçeri
→ Efsanevi Anka) senin **Ustalar** ve **Efsaneler** sınıflarınla birebir örtüşüyor.
Yani eldeki sanat çöpe gitmez; en üst prestij hattının referansı olur.

---

## 3. Boşluk: 5 → 40

Bugün: **1 karakter, 5 XP evresi, kodla çizilmiş kostüm.**
Hedef: **40 karakter, 8 tema sınıfı, nadirlik dereceli, gölge-açılış mekaniği.**

İki büyük sonuç:
1. **Sanat üretimi** 8 kat artıyor → kodla vektör çizim (kostüm başına ~150 satır)
   40 karakter için **sürdürülemez**. Pipeline kararı şart (bkz. §5).
2. **Veri + açılış mantığı** rozet deseniyle ölçeklenebilir; asıl iş sanat ve balans.

---

## 4. 40 karakter kataloğu (kullanıcı metni — birebir korunacak)

> Not: Sıra (1→5) aynı zamanda **nadirlik** demektir: 1 = giriş/sıradan, 5 = zirve/efsanevi.

**1. 🦅 ÖZGÜR RUHLAR** — macera, cesaret, keşif, özgürlük
`Özgür Ruh · Kıvılcım · Ateşkanat · Gece Kartalı · Oba Muhafızı`

**2. 🌪️ FIRTINA SINIFI** — hız, enerji, hareket (hız çizgileri, uçuşan pelerin, yıldırım)
`Rüzgâr Çırağı · Rüzgâr Koşucusu · Şimşek · Fırtına Binicisi · Fırtına Ustası`

**3. 🏹 KAŞİFLER SINIFI** — merak, keşif, macera
`İz Sürücü · Yol Bulucu · Sır Avcısı · Büyük Kaşif · Dünya Kaşifi`

**4. 🐺 BOZKIR SINIFI** — doğa, dayanıklılık, özgüven
`Bozkır Yoldaşı · Bozkır İzci · Bozkır Kurdu · Bozkır Kartalı · Bozkır Reisi`
(Reis yerine "Bozkır Lideri" alternatifi)

**5. 🧠 ZİHİN USTALARI** — düşünme, problem çözme, strateji ("zekâ" değil, gelişen beceri dili)
`Fikir Kıvılcımı · Bilgi Avcısı · Bulmaca Ustası · Akıl Ustası · Zihin Şimşeği`

**6. 🛡️ MUHAFIZLAR SINIFI** — sorumluluk, dayanışma, yardımseverlik (değerler/eğitim yüzü)
`Genç Muhafız · Kale Bekçisi · Gök Muhafızı · Ateş Muhafızı · Baş Muhafız`

**7. 🏹 USTALAR SINIFI** — uzmanlaşma, sabır, ustalık (mevcut Kemankeş sanatıyla bağlı)
`Genç Kemankeş · Usta Kemankeş · Gök Akıncısı · Fırtına Ustası · Büyük Usta`

**8. 👑 EFSANELER SINIFI** — oyunun zirvesi (koleksiyonun son parçası hissi)
`Ay Kaşifi · Güneş Muhafızı · Göklerin Akıncısı · Şimşek Kağanı · Efsaneler Efsanesi`

### Her sınıfın görsel kimliği (illüstratör brief yönü — taslak)
| Sınıf | Palet yönü | Motif |
|---|---|---|
| Özgür Ruhlar | Şafak: turuncu-mavi | Kartal, açık kanat, tüy |
| Fırtına | Camgöbeği-mor | Yıldırım, hız çizgisi, pelerin |
| Kaşifler | Parşömen-toprak | Pusula, harita, kâşif teçhizatı |
| Bozkır | Toprak yeşil-kahve | Kurt, bozkır, Türk motifi |
| Zihin Ustaları | İndigo-teal "düşünce" parıltısı | Kıvılcım, yapboz, ışık |
| Muhafızlar | Çelik + altın | Kalkan, kale, hanedan |
| Ustalar | Kızıl + altın | Yay/ok, akıncı (mevcut sanat) |
| Efsaneler | Göksel: ay/güneş + alev | Anka, taç, maksimum efekt (mevcut sanat) |

---

## 5. Karar gereken 4 nokta (önerilerimle)

### K1 — Sanat pipeline *(en kritik; her şeyi belirler)*
- **Öneri: Karakter başına tek PNG** (`assets/characters/<slug>.png`). Gölge hali
  ayrı dosya değil; çalışma anında koyu `ColorFilter` + hafif blur ile türetilir.
  İllüstratör 40 tutarlı karakteri üretir, uygulama sadece yükler.
- Alternatif (önerilmez): kodla vektör — 40 × ~150 satır, bakımı imkânsız.
- Mevcut 5 vektör avatar: Ustalar/Efsaneler'in **referans tasarımı** olarak kalır.

### K2 — Açılış ekonomisi
- **Öneri:** Omurga = XP/seviye (her sınıfın 1-2. karakteri). Çeşitlilik = streak,
  ders başarısı %, şifre tamamlama, günlük 5 soru, "arkadaşıma anlattım" (3-5. karakterler).
  Rozet koşul motoru (`kosul_turu`) genişletilerek yeniden kullanılır.
- Nadirlik 1→5 tüm sınıflarda tutarlı renklenir (koleksiyon ızgarası okunur olur).

### K3 — Mevcut 5 evreli avatarın göçü
- **Öneri:** Mevcut `AvatarTier` emekliye ayrılır; çocuk koleksiyondan bir **aktif
  karakter** seçer. Eldeki 5 kostüm Ustalar/Efsaneler görsellerine dönüştürülür.
- Geçişte mevcut XP'si olan öğrencilere eşdeğer karakterler otomatik verilir.

### K4 — Sınıf (tema) ↔ sınıf seviyesi (grade) ilişkisi
- **Öneri:** Tema sınıfları grade'e **kilitli değil** — çocuk hepsinden toplar
  ("farklı sınıflardan toplamayı istesin" hedefiyle uyumlu). Grade yalnızca **soru
  içeriğini** sürer. İstersen çocuğun grade'ine özel bir "başlangıç karakteri" hediye edilir.

---

## 6. Veri modeli (rozet desenini genelleştirir)

```
character_definitions
  kod               text pk           -- 'firtina_3'
  sinif_kod         text not null     -- 8 tema sınıfı
  sira              int  not null     -- 1-5 (= nadirlik)
  ad                text not null     -- 'Şimşek' (birebir)
  emoji             text
  nadirlik          text              -- siradan|nadir|epik|efsanevi|...
  gorsel            text not null     -- asset slug (K1 PNG)
  ipucu             text              -- gölge halindeyken gösterilen ipucu
  unlock_kosul_turu text              -- xp|seviye|streak|ders_basari|sifre|gunluk|ogretme
  esik              int
  ders              text              -- ders_basari için
  sira_no           int               -- katalog sırası

user_characters
  student_id uuid, kod text, earned_at timestamptz, pk(student_id, kod)

profiles / student_stats
  aktif_karakter    text              -- gösterilen karakter
```

RPC'ler (hepsi `AGENTS.md` §4 kuralıyla: `security definer` + `set search_path` +
`revoke/grant`, test `supabase/tests/`):
- `get_character_collection(p_student_id)` → 40 karakter + sahip mi + ilerleme + gölge ipucu
- `set_active_character(p_kod)`
- Rozet tetikleyicisi genişletilir: cevap/stat değişince karakterler de otomatik verilir
  (sunucu-otoriter; istemci karakter açamaz).

---

## 7. Mobil mimari (AGENTS.md §6 kontrol listesiyle)

- `models/character_models.dart` — `CharacterDefinition.fromMap`, `CharacterClass`, `Rarity`
- `services/character_repository.dart` — `supabase.rpc('get_character_collection')`
- `providers/` — koleksiyon FutureProvider (AutoDispose), aktif karakter state
- `widgets/character/character_avatar.dart` — PNG + kilitli-gölge (ColorFilter) hali
- `widgets/character/character_card.dart` — ızgara kartı, nadirlik rengi, kilit + ipucu
- `widgets/character/unlock_dialog.dart` — `tier_up_dialog` iskeletini devralır
- `screens/collection_screen.dart` — 8 sınıf bölümü × 5 kart, geri tuşu tanımlı
- Metinler `const`, hata yolu her zaman kullanıcıya (`showSnack`), tema renkleri (`app_theme.dart`)

---

## 8. İçerik kuralı — din/kültür (ihlal edilmez)

Çocuklar Müslüman. **Karakter kostüm/aksesuarları başka dinlerin sembollerini
içermez** (haç, davut yıldızı vb. YOK). Güvenli tema: Türk/Osmanlı/doğa dünyası
(akıncı, yeniçeri, kemankeş, anka, bork, lale, kurt, kartal) — mevcut sanat zaten böyle.
Bu kural hem `AGENTS.md` içerik bölümüne hem illüstratör brief'ine yazılır.

---

## 9. Fazlı yol haritası

| Faz | İçerik | Bağımlılık |
|---|---|---|
| **0. Kararlar** | K1-K4 netleşir, roster + açılış koşulları tablosu kesinleşir, illüstratör brief yazılır | — |
| **1. Backend** | `character_definitions` + `user_characters` migration, 40 seed, açma motoru + RPC + testler | supabase |
| **2. Koleksiyon ekranı** | models + provider + ızgara ekranı, nadirlik, gölge/ipucu, aktif seçim (yer tutucu sanatla çalışır) | 1 |
| **3. Avatar + açılış** | karakter widget'ı, ana/profil ekranına bağlama, açma töreni | 2 |
| **4. Sanat üretimi** | 40 PNG (sınıf brief'lerine göre), QA: din/kültür + çocuk dostu | 1-3 paralel |
| **5. Balans + panel** | admin panelinden katalog/koşul düzenleme, gerçek veriyle ekonomi ayarı, veli görünürlüğü | 1-4 |

Katman sırası her fazda korunur: `supabase → mobile-app/web-panel → mesaj anahtarları`.

---

## 10. Açık sorular
- K1-K4 kararları (bu seni bekliyor).
- İllüstratör var mı, yoksa sanat da bu depoda mı üretilecek? (pipeline'ı belirler)
- "Nadirlik" çocuk diline nasıl çevrilsin? (yıldız sayısı mı, isim mi?)
- Karakter açılışı XP'yle otomatik mi, yoksa "sandık/ödül" anı olarak mı sunulsun?
