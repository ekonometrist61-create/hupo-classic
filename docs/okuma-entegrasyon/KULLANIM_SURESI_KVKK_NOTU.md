# Kullanım süresi analitiği: KVKK notu (2026-10-22)

Kapsam: mobil uygulama, Flutter web, halka açık site, yönetim, veli ve öğretmen panelleri. Migration: `20261066000000_kullanim_suresi.sql`.

## Ne toplanır
- Yüzey (`mobil`, `flutter_web`, `site`, `yonetim`, `veli`, `ogretmen`).
- Ekran adı: rota adı; sorgu parametresi atılır, kimlik benzeri bölümler maskelenir, en çok 60 karakter.
- Süre (saniye): uygulama arka plana gidince oturum kapanır; boşta süre sayılmaz.
- Başlangıç zamanı.
- Rastgele oturum anahtarı: hesaba ya da çocuğa bağlı değildir.
- Kaba rol: öğrenci, veli, öğretmen, admin, ziyaretçi.

## Ne toplanmaz
Çocuk adı, e-posta, profil kimliği, IP adresi, cihaz kimliği, serbest metin, soru ya da cevap içeriği.

## Saklama
300 gün (bir eğitim-öğretim dönemi; kullanıcı kararı). Süresi dolan kayıtlar `kullanim_olaylari_temizle()` ile silinir. Toplu raporlar yalnız yöneticiye gösterilir; 5'ten az oturumlu satırlar bastırılır.

## Rıza ve şeffaflık
- Web sitede mevcut çerez tercih kuralına uyulur: analitik onayı yoksa olay gönderilmez.
- Mobilde olaylar anonimdir ve hesapla ilişkilendirilmez; gizlilik metnine eklenmesi gereken cümle (hukuk onayına açık): "Uygulamayı geliştirmek için hangi ekranlarda ne kadar süre geçirildiğini, kimliğinizle ilişkilendirmeden ve anonim olarak ölçeriz; bu veriler 300 gün saklanır."
- Çocuk verisi için hukuk görüşü (GÖR-045 kapsamı) alınmadan genel kullanıma geçilmemelidir.

## Açık
Saklama süresini otomatik çalıştıran zamanlayıcı (`pg_cron`) uzak veritabanında kontrol edilecek; yoksa temizlik elle ya da planlı bir işle çalıştırılır.
