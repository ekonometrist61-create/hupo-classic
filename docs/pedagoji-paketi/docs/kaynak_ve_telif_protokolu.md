# Kaynak, telif, müfredat ve kanıt protokolü

1. Kaynak türü alanları: `authority=meb_official|tdk_official|peer_reviewed_or_evidence_guide|user_owned|secondary`, `source_url`, `access_date`, `applicable_school_year`, `grade`, `lesson`, `page`, `learning_outcome_exact_text_short`, `verified_by`, `rights`.
2. Resmî MEB portalında bir programın 8. sınıf sekmesi bulunması **2026–27'de geçerli** olduğunu göstermez. Uygulama takvimi TYMM 1/2/3/5/6/7, 4/8 eski programdır. Her yıl kontrol et.
3. MEB ders kitabı ve sorularından *özellik çıkarımı* yap: sınıf, konu, madde tipi, bilişsel eylem, çeldirici mantığı, sayfa, görsel/veri tasarımı. **Soru metni, seçenek, görsel, paragrafı çoğaltma ve çok yakın parafraz yapma.** Özellikle yayınevi telifi ve görsel lisansı.
4. MEB yarışmasında 2026 kelime bandı yalnız ilgili yarışmaya ait. Şartname AI kullanımına izin vermez. Bu projeyi yarışma için düzenlenmiş resmî eser diye sunma.
5. İçerik ilk taslakta `curriculum_verified=false`, `rights_cleared=false`, `editor_approved=false`, `published=false`. İnsan kontrolleri geçmeden true olamaz.
6. Resmî belgeye erişilemezse kazanım kodunu, soru sayısını, sınav tarihini veya yanlış 'resmî' kotasını uydurma; `source_pending` ile yeni kontrol görevi oluştur.
7. `source_registry.json` ve mevcut MEB yıl tablolarını altı ayda bir/yıl başında veya MEB güncel duyurusunda yenile; eski sürümü sakla. Araştırma metinleri güvenlik veya mevzuat yerine geçmez.
8. Hikâyede çocuğun adı, ailesi ve tercihi kişiselleştirilebilir; gerçek özel veri (ad-soyad, konum, ses, fotoğraf) yalnız gerekli izin ve veri minimizasyonuyla tutulur. Üçüncü şahıs telifli karakteri izinsiz kullanma. Alternatif özgün karakter yarat.

**Okuma kapsamı dürüstlüğü:** Bu paket önceki Library'deki seçili Hupo rehber ve hikâye partilerini, resmî TYMM program kataloglarını, MEB 2026 kılavuzlarını ve bazı resmî soru örneklerini inceleyerek oluşturulmuştur; MEB'in bütün 1–8 kitap/soruları tek tek taranmış, her kazanım tam listelenmiş, veri kümesi akademik olarak doğrulanmış **değildir**. Öğrenme çıktısı bazında üretim yapan Claude, kaynakları tekrar doğrulamalıdır.
