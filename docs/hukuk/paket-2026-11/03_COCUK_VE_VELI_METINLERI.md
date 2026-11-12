> TASLAK · Sürümler: `cocuk-bildirim-2026-11-v1`, `veli-onayi-2026-11-v1` · Avukat onayı bekliyor. Bu belge `docs/hukuk-taslak-2026-11/ocuk-aydinlatma-taslak.md` eksik analizini karşılar.

# Çocuk ve veli metinleri

## A. Çocuk için gizlilik bildirimi (uygulama ilk açılış, sade dil)

*Gösterim: ilk girişte tek kaydırmalı kart; "Okudum, devam" düğmesi `record_notice_read` ile sürüm kaydeder. Bu bir rıza değildir, okundu kaydıdır.*

**Merhaba! Bilgilerini nasıl koruduğumuzu anlatalım.**

**Biz kimiz?** Hupolingo'yu [ŞİRKET UNVANI] yapıyor. Bir sorun olursa velinle birlikte [KVKK E-POSTASI] adresine yazabilirsin.

**Hangi bilgilerini tutuyoruz?** Adını ya da takma adını, sınıfını, giriş e-postanı, çözdüğün soruları, okuduğun hikâyeleri, XP'ni, serini ve rozetlerini.

**Neden?** Sana uygun soruları seçmek, ne kadar ilerlediğini göstermek ve velinin gelişimini görebilmesi için.

**Kim görür?** Sen ve velin. Diğer öğrenciler adını göremez; ligde yalnızca takma adın ve sıran görünür. Uygulamayı çalıştırmamıza yardım eden şirketler de bilgilerine yalnızca bu iş için ulaşır.

**Reklam var mı?** Hayır. Uygulamada reklam yok, sana kampanya mesajı göndermiyoruz, bilgilerini kimseye satmıyoruz.

**Dikkat et:** Cevaplarına veya adına okulunun adını, adresini, telefonunu ya da fotoğrafını yazma.

**Haklarını biliyor musun?** Bilgilerini görmek, düzeltmek veya silmek istersen velinle birlikte Ayarlar bölümüne bak ya da bize yaz. Hesabını silersen bilgilerin silinir.

[Okudum, devam] · [Velime ayrıntılı metni göster →]

## B. Veli onayı (veli paneli, çocuk hesabı bağlanırken)

*Gösterim: çocuk eşleştirme kodu girildikten sonra. Zorunlu kutu yalnızca 1'dir; 2 ve 3 isteğe bağlıdır ve işaretsiz başlar. `set_parental_consent` her kutuyu ayrı kaydeder.*

**[ÇOCUK TAKMA ADI] hesabını bağlıyorsunuz**

Hupolingo, çocuğunuzun öğrenme verisini yalnızca hizmeti sunmak, öğrenmeyi kişiselleştirmek ve size gelişim raporu göstermek için işler. Çocuğunuza reklam göstermez, pazarlama iletisi göndermez ve verilerini satmaz. Ayrıntılar: [Aydınlatma Metni](02_KVKK_AYDINLATMA_METNI.md).

☐ **1. (Zorunlu)** Bu öğrencinin velisi veya yasal temsilcisi olduğumu, çocuğumun Hupolingo'yu [Kullanım Sözleşmesi](01_KULLANIM_SOZLESMESI.md) çerçevesinde kullanmasını onayladığımı beyan ederim.

☐ **2. (İsteğe bağlı) Lig ve meydan okumalar:** Çocuğumun **takma adı ve avatarıyla** haftalık lige ve diğer öğrencilerle meydan okumalara katılmasına izin veriyorum. *(Kapalıysa çocuğunuz ligde yalnız kendi sırasını görür, başkalarına görünmez.)*

☐ **3. (İsteğe bağlı) Sesli okuma kaydı:** [YALNIZCA ÖZELLİK VARSA] Sesli okuma alıştırmasında çocuğumun ses kaydının okuma akıcılığını ölçmek için işlenmesine ve [X] gün sonra silinmesine izin veriyorum. *(Ses kaydı kimlik tespiti için kullanılmaz.)*

Bu onayları istediğiniz an Veli paneli > Çocuklarım > Gizlilik bölümünden değiştirebilirsiniz. Onay 1'i geri almanız çocuk hesabının bağlantısını kaldırır.

**Hukuki not (iç):**
- Temel hizmet sözleşmenin ifasına dayanır; veli beyanı, 18 yaş altı kullanıcı için yasal temsilcinin onayıdır (TMK m.16, m.342 vd.). Lig görünürlüğü ve ses kaydı hizmetin zorunlu parçası olmadığı için ayrı açık rızadır.
- Öğrencinin kendi başına açtığı ve veliye bağlanmamış hesapta: yalnız temel hizmet çalışır; lig görünürlüğü kapalı, ses kaydı kapalı, ücretli işlem yok. Belirli süre (öneri 30 gün) veli bağlanmazsa hatırlatma çocuğa nötr dille yapılır ("Velinle birlikte hesabını bağlayabilirsin").
- Çocuk ekranlarında satın alma veya pazarlama teşviki yok (bkz. 00 §3.3).

## C. Çocuk ekranı kilitli içerik mesajları (nötr dil kütüphanesi)

| Durum | ✅ Kullan | ❌ Kullanma |
|---|---|---|
| Kilitli modül | "Bu bölüm veli planıyla açılır. Velin, veli panelinden inceleyebilir." | "Velinden iste, hemen aç!" |
| Günlük kota doldu | "Bugünkü soruların bitti, harika çalıştın! Yarın yenileri gelecek." | "Sınırsız soru için velini ikna et!" |
| Deneme bitti | "Deneme süren bitti. Ücretsiz planla her gün [N] soru çözmeye devam edebilirsin." | "Son şans! Arkadaşların devam ediyor." |
| Veliye gönderim | "Veline bilgi gönderelim mi?" → veliye **hizmet iletisi**: "[Takma ad] bugün günlük kotasını doldurdu. Planları incelemek için: …" | Çocuğun ekranında fiyat, indirim, geri sayım |

Veliye giden "kota doldu" iletisi hesap durumu bilgisidir; içinde indirim/kampanya olursa ticari iletidir ve velinin pazarlama onayı gerekir.
