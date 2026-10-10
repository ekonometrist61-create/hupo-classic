// Kelime Evreni modelleri. Alan adları Supabase RPC çıktısıyla birebir eşleşir (AGENTS.md: snake_case veritabanı, Türkçe alanlar).

/// Oyun türleri. Veritabanı değerleri sunucudaki `iliski_turu` kısıtıyla aynıdır.
enum KelimeIliskiTuru {
  esAnlamli('es_anlamli'),
  zitAnlamli('zit_anlamli'),
  esSesli('es_sesli');

  const KelimeIliskiTuru(this.veritabani);

  final String veritabani;

  static KelimeIliskiTuru fromVeritabani(String deger) {
    for (final tur in values) {
      if (tur.veritabani == deger) return tur;
    }
    throw FormatException('Bilinmeyen ilişki türü: $deger');
  }
}

/// Öğrencinin önüne gelen tek bir soru. Doğru şık ve açıklama burada YOKTUR; sunucu cevap sonrası verir.
class KelimeSoru {
  const KelimeSoru({
    required this.id,
    required this.anlamId,
    required this.soruMetni,
    required this.secenekler,
    this.ipucu,
  });

  final String id;
  final String anlamId;
  final String soruMetni;
  final List<String> secenekler;
  final String? ipucu;

  factory KelimeSoru.fromMap(Map<String, dynamic> m) {
    final ham = m['secenekler'];
    if (ham is! List) {
      throw const FormatException('Şıklar dizi değil');
    }
    final secenekler = [for (final e in ham) e as String];
    if (secenekler.length < 2 || secenekler.length > 4) {
      throw FormatException('Geçersiz şık sayısı: ${secenekler.length}');
    }
    return KelimeSoru(
      id: m['id'] as String,
      anlamId: m['anlam_id'] as String,
      soruMetni: m['soru_metni'] as String,
      secenekler: secenekler,
      ipucu: m['ipucu'] as String?,
    );
  }
}

/// `kelime_oyun_getir` çıktısı.
class KelimeOyunSorulari {
  const KelimeOyunSorulari({
    required this.sinif,
    required this.iliski,
    required this.sorular,
    required this.tekrarBekleyen,
  });

  final int sinif;
  final KelimeIliskiTuru iliski;
  final List<KelimeSoru> sorular;
  final int tekrarBekleyen;

  factory KelimeOyunSorulari.fromMap(Map<String, dynamic> m) {
    final ham = (m['sorular'] as List?) ?? const [];
    return KelimeOyunSorulari(
      sinif: (m['sinif'] as num).toInt(),
      iliski: KelimeIliskiTuru.fromVeritabani(m['iliski_turu'] as String),
      sorular: [
        for (final e in ham) KelimeSoru.fromMap(Map<String, dynamic>.from(e as Map)),
      ],
      tekrarBekleyen: (m['tekrar_bekleyen'] as num?)?.toInt() ?? 0,
    );
  }
}

/// `kelime_cevap_gonder` çıktısı. Yanlış cevapta açıklama bu sonuçla gelir.
class KelimeCevapSonucu {
  const KelimeCevapSonucu({
    required this.dogru,
    required this.dogruIndeks,
    required this.aciklama,
    required this.kazanilanXp,
    required this.tekrar,
    this.ustalikSeviyesi,
  });

  final bool dogru;
  final int dogruIndeks;
  final String aciklama;
  final int kazanilanXp;

  /// Aynı deneme anahtarı yeniden geldiyse true: sonuç önbellekten döndü, yeniden puanlanmadı.
  final bool tekrar;
  final int? ustalikSeviyesi;

  factory KelimeCevapSonucu.fromMap(Map<String, dynamic> m) {
    final ustalik = m['ustalik'] as Map?;
    return KelimeCevapSonucu(
      dogru: m['dogru'] as bool,
      dogruIndeks: (m['dogru_indeks'] as num).toInt(),
      aciklama: (m['aciklama'] as String?) ?? '',
      kazanilanXp: (m['kazanilan_xp'] as num?)?.toInt() ?? 0,
      tekrar: (m['tekrar'] as bool?) ?? false,
      ustalikSeviyesi: (ustalik?['seviye'] as num?)?.toInt(),
    );
  }
}

/// `kelime_ogrenci_ozeti` çıktısı (ana ekran).
class KelimeOzet {
  const KelimeOzet({
    required this.tekrarBekleyen,
    required this.tanimaTamam,
    required this.calisilanKelime,
    required this.kaydedilen,
    required this.bugunCozulen,
  });

  final int tekrarBekleyen;
  final int tanimaTamam;
  final int calisilanKelime;
  final int kaydedilen;
  final int bugunCozulen;

  static const bos = KelimeOzet(
    tekrarBekleyen: 0,
    tanimaTamam: 0,
    calisilanKelime: 0,
    kaydedilen: 0,
    bugunCozulen: 0,
  );

  factory KelimeOzet.fromMap(Map<String, dynamic> m) => KelimeOzet(
        tekrarBekleyen: (m['tekrar_bekleyen'] as num?)?.toInt() ?? 0,
        tanimaTamam: (m['tanima_tamam'] as num?)?.toInt() ?? 0,
        calisilanKelime: (m['calisilan_kelime'] as num?)?.toInt() ?? 0,
        kaydedilen: (m['kaydedilen'] as num?)?.toInt() ?? 0,
        bugunCozulen: (m['bugun_cozulen'] as num?)?.toInt() ?? 0,
      );
}

/// Öğrencinin kaydettiği (zorlandığı) kelime.
class KelimeKaydi {
  const KelimeKaydi({required this.anlamId, required this.kelime, required this.anlam});

  final String anlamId;
  final String kelime;
  final String anlam;

  factory KelimeKaydi.fromMap(Map<String, dynamic> m) => KelimeKaydi(
        anlamId: m['anlam_id'] as String,
        kelime: m['kelime'] as String,
        anlam: m['anlam'] as String,
      );
}

/// Velinin gördüğü zorlanılan kelime satırı. Kişisel cevap bilgisi içermez.
class ZorlanilanKelime {
  const ZorlanilanKelime({
    required this.kelime,
    required this.anlam,
    required this.iliski,
    required this.yanlisSayisi,
  });

  final String kelime;
  final String anlam;
  final KelimeIliskiTuru iliski;
  final int yanlisSayisi;

  factory ZorlanilanKelime.fromMap(Map<String, dynamic> m) => ZorlanilanKelime(
        kelime: m['kelime'] as String,
        anlam: m['anlam'] as String,
        iliski: KelimeIliskiTuru.fromVeritabani(m['iliski_turu'] as String),
        yanlisSayisi: (m['yanlis_sayisi'] as num).toInt(),
      );
}

/// `kelime_veli_ozeti` çıktısı. Oranlar yalnızca deneme varsa dolu gelir (null = veri yok).
class KelimeVeliOzeti {
  const KelimeVeliOzeti({
    required this.denemeSayisi,
    required this.dogruOrani,
    required this.ipucusuzDogruOrani,
    required this.ipucuKullanimOrani,
    required this.tekrarBekleyen,
    required this.son7GunDeneme,
    required this.zorlanilan,
    required this.oneriler,
  });

  final int denemeSayisi;
  final int? dogruOrani;
  final int? ipucusuzDogruOrani;
  final int? ipucuKullanimOrani;
  final int tekrarBekleyen;
  final int son7GunDeneme;
  final List<ZorlanilanKelime> zorlanilan;

  /// Öneri kodları: tekrar_bekleyen, zorlanilan_tekrar, haftalik_calisma_yok, devam.
  /// Metni istemci yazar (i18n).
  final List<String> oneriler;

  factory KelimeVeliOzeti.fromMap(Map<String, dynamic> m) => KelimeVeliOzeti(
        denemeSayisi: (m['deneme_sayisi'] as num?)?.toInt() ?? 0,
        dogruOrani: (m['dogru_orani'] as num?)?.toInt(),
        ipucusuzDogruOrani: (m['ipucusuz_dogru_orani'] as num?)?.toInt(),
        ipucuKullanimOrani: (m['ipucu_kullanim_orani'] as num?)?.toInt(),
        tekrarBekleyen: (m['tekrar_bekleyen'] as num?)?.toInt() ?? 0,
        son7GunDeneme: (m['son_7_gun_deneme'] as num?)?.toInt() ?? 0,
        zorlanilan: [
          for (final e in (m['zorlanilan'] as List?) ?? const [])
            ZorlanilanKelime.fromMap(Map<String, dynamic>.from(e as Map)),
        ],
        oneriler: [for (final e in (m['oneriler'] as List?) ?? const []) e as String],
      );
}
