// Okuma Dünyası ("Senin Hikâyen") modelleri. Sözleşme: OKUMA_RPC_SOZLESMESI.md.
//
// Gizlilik: Kahraman ve yol arkadaşı adı bu modellerin HİÇBİRİNDE yoktur; ad yalnız cihaz
// belleğinde (OkumaKahramanSecimi) tutulur ve sunucuya, günlüğe, hata metnine girmez.

int _tam(Object? v, [int yedek = 0]) => v is num ? v.toInt() : yedek;

int? _tamOrNull(Object? v) => v is num ? v.toInt() : null;

List<String> _metinListesi(Object? v) => v is List ? [for (final e in v) e.toString()] : const [];

Map<String, dynamic> _harita(Object? v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

/// Günlük kota ya da aylık PDF hakkı. `sinirli=false` ve `kalan=null` → sınırsız.
class OkumaHak {
  const OkumaHak({required this.sinirli, this.limit, this.kullanilan = 0, this.kalan});

  final bool sinirli;
  final int? limit;
  final int kullanilan;
  final int? kalan;

  factory OkumaHak.fromMap(Map<String, dynamic> m, {String limitAnahtari = 'limit'}) => OkumaHak(
        sinirli: m['sinirli'] == true,
        limit: _tamOrNull(m[limitAnahtari]),
        kullanilan: _tam(m['kullanilan']),
        kalan: _tamOrNull(m['kalan']),
      );

  /// Hak bitti mi? Yalnız sınırlıysa ve kalan 0 ise.
  bool get bitti => sinirli && (kalan ?? 0) <= 0;
}

/// `okuma_ozellik_durumu()` yanıtı. `erisim` kapalıysa modül hiç görünmez.
class OkumaOzellikDurumu {
  const OkumaOzellikDurumu({
    required this.erisim,
    this.onizleme = false,
    this.gunlukKota = const OkumaHak(sinirli: false),
    this.pdf = const OkumaHak(sinirli: false),
  });

  final bool erisim;
  final bool onizleme;
  final OkumaHak gunlukKota;
  final OkumaHak pdf;

  /// Bayrak kapalı gibi davranan varsayılan.
  static const kapali = OkumaOzellikDurumu(erisim: false);

  factory OkumaOzellikDurumu.fromMap(Map<String, dynamic> m) => OkumaOzellikDurumu(
        erisim: m['erisim'] == true,
        onizleme: m['onizleme'] == true,
        gunlukKota: OkumaHak.fromMap(_harita(m['gunluk_kota'])),
        pdf: OkumaHak.fromMap(_harita(m['pdf']), limitAnahtari: 'aylik_limit'),
      );
}

/// Katalogdaki bir hikâye satırı (`okuma_katalog_filtre` ve `okuma_seri_ve_oneri.oneri`).
class OkumaKatalogSatiri {
  const OkumaKatalogSatiri({
    required this.hikayeId,
    required this.surumId,
    required this.surumNo,
    required this.slug,
    required this.baslik,
    required this.tur,
    required this.anaSinif,
    required this.sha256,
    this.tanitim = '',
    this.konu,
    this.okumaZorlugu,
    this.izinliTurler = const [],
    this.temalar = const [],
    this.kelimeSayisi,
    this.tahminiSureDk,
    this.soruSayisi = 0,
    this.onizleme = false,
    this.gorulmedi = false,
    this.anaDeger,
    this.yardimciDeger,
    this.degerEslesmesi = false,
  });

  final String hikayeId;
  final String surumId;
  final int surumNo;
  final String slug;
  final String baslik;
  final String tanitim;
  final String tur;
  final String? konu;
  final int anaSinif;
  final int? okumaZorlugu;
  final List<String> izinliTurler;
  final List<String> temalar;
  final int? kelimeSayisi;
  final int? tahminiSureDk;
  final int soruSayisi;

  /// Önbellek anahtarı: (hikayeId, sha256) değişince paket yeniden iner.
  final String sha256;
  final bool onizleme;
  final bool gorulmedi;

  /// Maarif değerleri (D-kodu). Sunucu `ana_deger` / `yardimci_deger` alanlarını döndürür.
  final String? anaDeger;
  final String? yardimciDeger;

  /// Veli bu çocuk için bu hikâyenin değerlerinden birini seçtiyse true (sunucu hesaplar).
  final bool degerEslesmesi;

  factory OkumaKatalogSatiri.fromMap(Map<String, dynamic> m) => OkumaKatalogSatiri(
        hikayeId: m['hikaye_id'] as String,
        surumId: (m['surum_id'] ?? '') as String,
        surumNo: _tam(m['surum_no'], 1),
        slug: (m['slug'] ?? '') as String,
        baslik: (m['baslik'] ?? '') as String,
        tanitim: ((m['tanitim'] ?? '') as String).trim(),
        tur: (m['tur'] ?? '') as String,
        konu: m['konu'] as String?,
        anaSinif: _tam(m['ana_sinif'], 4),
        okumaZorlugu: _tamOrNull(m['okuma_zorlugu']),
        izinliTurler: _metinListesi(m['izinli_turler']),
        temalar: _metinListesi(m['temalar']),
        kelimeSayisi: _tamOrNull(m['kelime_sayisi']),
        tahminiSureDk: _tamOrNull(m['tahmini_sure_dk']),
        soruSayisi: _tam(m['soru_sayisi']),
        sha256: (m['sha256'] ?? '') as String,
        onizleme: m['onizleme'] == true,
        gorulmedi: m['gorulmedi'] == true,
        anaDeger: m['ana_deger'] as String?,
        yardimciDeger: m['yardimci_deger'] as String?,
        degerEslesmesi: m['deger_eslesmesi'] == true,
      );

  /// Cihazda saklanan "Okuduklarım" kaydı için.
  Map<String, dynamic> toMap() => {
        'hikaye_id': hikayeId,
        'surum_id': surumId,
        'surum_no': surumNo,
        'slug': slug,
        'baslik': baslik,
        'tanitim': tanitim,
        'tur': tur,
        'konu': konu,
        'ana_sinif': anaSinif,
        'okuma_zorlugu': okumaZorlugu,
        'izinli_turler': izinliTurler,
        'temalar': temalar,
        'kelime_sayisi': kelimeSayisi,
        'tahmini_sure_dk': tahminiSureDk,
        'soru_sayisi': soruSayisi,
        'sha256': sha256,
        'onizleme': onizleme,
        'gorulmedi': gorulmedi,
        'ana_deger': anaDeger,
        'yardimci_deger': yardimciDeger,
        'deger_eslesmesi': degerEslesmesi,
      };
}

/// Paketteki bir soru. Doğru şık ve açıklama pakette YOKTUR; yalnız `okuma_cevap_kontrol` verir.
class OkumaSoru {
  const OkumaSoru({
    required this.id,
    required this.metin,
    required this.secenekler,
    this.beceri,
    this.dayanakSayfa,
  });

  final String id;
  final String metin;
  final List<OkumaSecenek> secenekler;
  final String? beceri;

  /// Sorunun dayandığı sayfa (1'den başlar). İpucu için kullanılır; cevabı vermez.
  final int? dayanakSayfa;

  factory OkumaSoru.fromMap(Map<String, dynamic> m) => OkumaSoru(
        id: m['id'] as String,
        metin: m['metin'] as String,
        beceri: m['beceri'] as String?,
        dayanakSayfa: _tamOrNull(m['dayanak_sayfa']),
        secenekler: [
          for (final o in (m['secenekler'] as List? ?? const []))
            OkumaSecenek(
              id: (o as Map)['id'] as String,
              metin: o['metin'] as String,
            ),
        ],
      );
}

class OkumaSecenek {
  const OkumaSecenek({required this.id, required this.metin});

  final String id;
  final String metin;
}

/// Pakette beyan edilen öğrenme hedefi (sözcük, deyim, atasözü). Dokunma kaydı için.
class OkumaHedefi {
  const OkumaHedefi({required this.id, required this.etiket, this.yuva});

  final String id;
  final String etiket;
  final String? yuva;
}

/// `okuma_hikaye_getir` yanıtı. [paket] motorun ve ekranların okuduğu ham JSON'dur.
class OkumaPaketi {
  const OkumaPaketi({
    required this.hikayeId,
    required this.surumId,
    required this.surum,
    required this.sha256,
    required this.minMotorSurumu,
    required this.paket,
    this.onizleme = false,
  });

  final String hikayeId;
  final String surumId;
  final int surum;
  final String sha256;
  final int minMotorSurumu;
  final bool onizleme;
  final Map<String, dynamic> paket;

  factory OkumaPaketi.fromMap(Map<String, dynamic> m) => OkumaPaketi(
        hikayeId: m['hikaye_id'] as String,
        surumId: (m['surum_id'] ?? '') as String,
        surum: _tam(m['surum'], 1),
        sha256: (m['sha256'] ?? '') as String,
        minMotorSurumu: _tam(m['min_motor_surumu'], 1),
        onizleme: m['onizleme'] == true,
        paket: _harita(m['paket']),
      );

  Map<String, dynamic> toMap() => {
        'hikaye_id': hikayeId,
        'surum_id': surumId,
        'surum': surum,
        'sha256': sha256,
        'min_motor_surumu': minMotorSurumu,
        'onizleme': onizleme,
        'paket': paket,
      };

  Map<String, dynamic> get _hikaye => _harita(paket['hikaye']);

  String get baslik => (_hikaye['baslik'] ?? '') as String;

  String get tanitim => ((_hikaye['tanitim'] ?? '') as String).trim();

  List<String> get izinliTurler => _metinListesi(_hikaye['izinli_turler']);

  int get anaSinif {
    final etiketler = _harita(_hikaye['etiketler']);
    return _tam(etiketler['ana_sinif'], _tam(_hikaye['sinif_alt'], 4));
  }

  List<OkumaSoru> get sorular => [
        for (final s in (paket['sorular'] as List? ?? const [])) OkumaSoru.fromMap(Map<String, dynamic>.from(s as Map)),
      ];

  List<OkumaHedefi> get hedefler {
    final etiketler = _harita(_hikaye['etiketler']);
    return [
      for (final h in (etiketler['ogrenme_hedefleri'] as List? ?? const []))
        OkumaHedefi(
          id: (h as Map)['id'] as String,
          etiket: (h['etiket'] ?? '') as String,
          yuva: h['yuva'] as String?,
        ),
    ];
  }

  /// Sözlük, paketle birlikte geliyorsa (`sozluk` anahtarı, sozluk.v1 biçimi) döner.
  /// Sözleşmede ayrı bir sözlük RPC'si olmadığı için varsa pakettekini kullanırız.
  Map<String, dynamic>? get paketSozlugu {
    final s = paket['sozluk'];
    return s is Map ? Map<String, dynamic>.from(s) : null;
  }
}

/// `okuma_oturum_baslat` yanıtı.
class OkumaOturum {
  const OkumaOturum({
    required this.oturumId,
    required this.hikayeId,
    required this.soruSayisi,
    this.tekrar = false,
    this.kotaKalan,
  });

  final String oturumId;
  final String hikayeId;
  final int soruSayisi;
  final bool tekrar;
  final int? kotaKalan;

  factory OkumaOturum.fromMap(Map<String, dynamic> m) => OkumaOturum(
        oturumId: m['oturum_id'] as String,
        hikayeId: (m['hikaye_id'] ?? '') as String,
        soruSayisi: _tam(m['soru_sayisi']),
        tekrar: m['tekrar'] == true,
        kotaKalan: _tamOrNull(m['kota_kalan']),
      );
}

/// `okuma_cevap_kontrol` yanıtı. Anahtar yalnız cevaptan sonra, o soru için gelir.
class OkumaCevapSonucu {
  const OkumaCevapSonucu({
    required this.dogru,
    required this.aciklama,
    required this.dogruSecenekId,
    this.tekrar = false,
  });

  final bool dogru;
  final String aciklama;
  final String dogruSecenekId;
  final bool tekrar;

  factory OkumaCevapSonucu.fromMap(Map<String, dynamic> m) => OkumaCevapSonucu(
        dogru: m['dogru'] == true,
        aciklama: (m['aciklama'] ?? '') as String,
        dogruSecenekId: (m['dogru_secenek_id'] ?? '') as String,
        tekrar: m['tekrar'] == true,
      );
}

class OkumaSeri {
  const OkumaSeri({
    this.seriSayisi = 0,
    this.enUzunSeri = 0,
    this.seriDevam = false,
    this.bugunOkudu = false,
  });

  final int seriSayisi;
  final int enUzunSeri;
  final bool seriDevam;
  final bool bugunOkudu;

  factory OkumaSeri.fromMap(Map<String, dynamic> m) => OkumaSeri(
        seriSayisi: _tam(m['streak_count']),
        enUzunSeri: _tam(m['en_uzun_seri']),
        seriDevam: m['seri_devam'] == true,
        bugunOkudu: m['bugun_okudu'] == true,
      );
}

/// Öğrenme hedefinin cevap sonrası durumu (`introduced` → `recognized` → …).
class OkumaHedefDurumu {
  const OkumaHedefDurumu({required this.hedefId, required this.etiket, required this.durum});

  final String hedefId;
  final String etiket;
  final String durum;

  factory OkumaHedefDurumu.fromMap(Map<String, dynamic> m) => OkumaHedefDurumu(
        hedefId: (m['hedef_id'] ?? '') as String,
        etiket: (m['etiket'] ?? '') as String,
        durum: (m['durum'] ?? '') as String,
      );
}

/// `okuma_oturum_bitir` yanıtı. XP ve seri yalnız sunucunun söylediği kadardır.
class OkumaSonuc {
  const OkumaSonuc({
    required this.soruSayisi,
    required this.dogruSayisi,
    required this.dogruOrani,
    this.kazanilanXp = 0,
    this.ilkTamamlama = false,
    this.xpTavaniDoldu = false,
    this.tekrar = false,
    this.hedefler = const [],
    this.seri,
  });

  final int soruSayisi;
  final int dogruSayisi;
  final int dogruOrani;
  final int kazanilanXp;
  final bool ilkTamamlama;
  final bool xpTavaniDoldu;
  final bool tekrar;
  final List<OkumaHedefDurumu> hedefler;
  final OkumaSeri? seri;

  factory OkumaSonuc.fromMap(Map<String, dynamic> m) {
    final seri = m['seri'];
    return OkumaSonuc(
      soruSayisi: _tam(m['soru_sayisi']),
      dogruSayisi: _tam(m['dogru_sayisi']),
      dogruOrani: _tam(m['dogru_orani']),
      kazanilanXp: _tam(m['kazanilan_xp']),
      ilkTamamlama: m['ilk_tamamlama'] == true,
      xpTavaniDoldu: m['xp_tavani_doldu'] == true,
      tekrar: m['tekrar'] == true,
      hedefler: [
        for (final h in (m['hedefler'] as List? ?? const [])) OkumaHedefDurumu.fromMap(Map<String, dynamic>.from(h as Map)),
      ],
      seri: seri is Map
          ? OkumaSeri(
              seriSayisi: _tam(seri['streak_count']),
              seriDevam: true,
              bugunOkudu: true,
            )
          : null,
    );
  }
}

/// `okuma_seri_ve_oneri()` yanıtı: Öğren sekmesi kartı için.
class OkumaSeriVeOneri {
  const OkumaSeriVeOneri({
    required this.seri,
    this.bugunTamamlanan = 0,
    this.toplamTamamlanan = 0,
    this.kotaDolu = false,
    this.oneri,
  });

  final OkumaSeri seri;
  final int bugunTamamlanan;
  final int toplamTamamlanan;
  final bool kotaDolu;
  final OkumaKatalogSatiri? oneri;

  factory OkumaSeriVeOneri.fromMap(Map<String, dynamic> m) {
    final oneri = m['oneri'];
    return OkumaSeriVeOneri(
      seri: OkumaSeri.fromMap(_harita(m['seri'])),
      bugunTamamlanan: _tam(m['bugun_tamamlanan']),
      toplamTamamlanan: _tam(m['toplam_tamamlanan']),
      kotaDolu: m['kota_dolu'] == true,
      oneri: oneri is Map ? OkumaKatalogSatiri.fromMap(Map<String, dynamic>.from(oneri)) : null,
    );
  }
}

/// `okuma_pdf_hakki_kullan` yanıtı.
class OkumaPdfHakki {
  const OkumaPdfHakki({required this.izin, this.kalan, this.tekrar = false});

  final bool izin;
  final int? kalan;
  final bool tekrar;

  factory OkumaPdfHakki.fromMap(Map<String, dynamic> m) => OkumaPdfHakki(
        izin: m['izin'] == true,
        kalan: _tamOrNull(m['kalan']),
        tekrar: m['tekrar'] == true,
      );
}

/// Anket yanıtı. Serbest metin yoktur; kodlar sözleşmedeki beyaz listedir.
class OkumaAnketYaniti {
  const OkumaAnketYaniti({
    this.yildiz,
    this.iyilestirmeKodlari = const {},
    this.baskaKahraman = false,
    this.ayniTurden = false,
  });

  final int? yildiz;
  final Set<String> iyilestirmeKodlari;
  final bool baskaKahraman;
  final bool ayniTurden;

  /// Sunucu 1–5 yıldızı zorunlu tutar; yıldızsız yanıt gönderilmez.
  bool get gonderilebilir => yildiz != null;
}

/// Cihazdaki "Okuduklarım" kaydı. Yalnız hikâye bilgisi; ad içermez.
class OkunanHikaye {
  const OkunanHikaye({required this.satir, required this.okunduAt});

  final OkumaKatalogSatiri satir;
  final DateTime okunduAt;
}
