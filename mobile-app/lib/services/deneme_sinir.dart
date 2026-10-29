/// Deneme sınırı hatalarını çocuğa gösterilecek metne çevirir.
///
/// P0402: günlük ya da deneme penceresi sınırı. P0403: deneme sınavı ücretsiz planda yok.
/// Sunucu metni Türkçedir ("Bugünlük Kelime Evreni hakkın doldu. Yarın yeniden açılır.").
/// Sınır hatası değilse null döner; çağıran kendi genel mesajını gösterir.
String? denemeSinirMetni(Object hata) {
  final metin = hata.toString();
  if (!metin.contains('P0402') && !metin.contains('P0403')) return null;
  final eslesme = RegExp(r'(Bugünlük|Bu denemedeki|Deneme sınavları)[^.]*\.( Yarın yeniden açılır\.)?')
      .firstMatch(metin);
  return eslesme?.group(0) ?? 'Bu özellik için ücretsiz hakkın doldu.';
}
