// Telefon doğrulama uçtan uca test (tek seferlik, yerel).
// Kullanım (proje klasöründe): node tools/telefon-kod-test.mjs
//
// Güvenlik: e-posta ve parolayı siz terminalde girersiniz (parola ekranda görünmez).
// Oturum anahtarı (token) bellekte kalır; ekrana, dosyaya veya sohbete yazılmaz.
// Bu betik yalnızca test veli hesabıyla kullanılmalıdır. Her SMS 100 kredilik
// paketten bir kredi harcar.

import readline from 'node:readline/promises';
import { stdin as input, stdout as output } from 'node:process';

const SUPABASE_URL = 'https://ccozfrpnvyrnktpffkwo.supabase.co';
// Publishable anahtar istemci tarafında zaten herkese açık (mobil ve web kodunda var).
const PUBLISHABLE_KEY = 'sb_publishable_Ou2vCWJsewMILZzK1PdCyQ_W9Sp5avP';

const rl = readline.createInterface({ input, output, terminal: true });
let parolaGizli = false;
rl._writeToOutput = (metin) => {
  if (!parolaGizli) output.write(metin);
};

const ortakBasliklar = { apikey: PUBLISHABLE_KEY, 'content-type': 'application/json' };

async function main() {
  const email = (await rl.question('Test veli e-postası: ')).trim();
  parolaGizli = true;
  const parola = await rl.question('Parola (ekranda görünmez): ');
  parolaGizli = false;
  output.write('\n');

  // 1) Giriş: token yalnızca bu betiğin belleğinde tutulur.
  const girisYaniti = await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
    method: 'POST',
    headers: ortakBasliklar,
    body: JSON.stringify({ email, password: parola }),
  });
  const girisVeri = await girisYaniti.json();
  if (!girisYaniti.ok || !girisVeri.access_token) {
    console.log(`Giriş başarısız (HTTP ${girisYaniti.status}): ${girisVeri.error_description ?? girisVeri.msg ?? 'bilinmeyen hata'}`);
    console.log('İpucu: hesap onaylı mı ve parola doğru mu? Test hesabını Supabase panelinden de kontrol edebilirsiniz.');
    rl.close();
    return;
  }
  const token = girisVeri.access_token;
  const kullaniciId = girisVeri.user.id;
  console.log('Giriş başarılı.');

  // 2) Kod isteği: Edge Function telefonu normalize eder, kodu üretir ve SMS gönderir.
  const telefon = (await rl.question('Kendi cep numaranız (örn. 05321234567): ')).trim();
  const kodYaniti = await fetch(`${SUPABASE_URL}/functions/v1/telefon-kod-gonder`, {
    method: 'POST',
    headers: { ...ortakBasliklar, authorization: `Bearer ${token}` },
    body: JSON.stringify({ telefon }),
  });
  console.log(`Kod isteği: HTTP ${kodYaniti.status} ${await kodYaniti.text()}`);
  if (!kodYaniti.ok) {
    rl.close();
    return;
  }

  // 3) Doğrulama: telefona gelen kodu girin.
  const kod = (await rl.question('Telefonunuza gelen 6 haneli kodu girin: ')).trim();
  const dogrulamaYaniti = await fetch(`${SUPABASE_URL}/rest/v1/rpc/telefon_kod_dogrula`, {
    method: 'POST',
    headers: { ...ortakBasliklar, authorization: `Bearer ${token}` },
    body: JSON.stringify({ p_kod: kod }),
  });
  console.log(`Doğrulama: HTTP ${dogrulamaYaniti.status} ${await dogrulamaYaniti.text()}`);

  // 4) Profilde kayıt: telefon ve doğrulama zamanı dolu olmalı.
  const profilYaniti = await fetch(
    `${SUPABASE_URL}/rest/v1/profiles?select=role,telefon,telefon_dogrulandi_at&id=eq.${kullaniciId}`,
    { headers: { apikey: PUBLISHABLE_KEY, authorization: `Bearer ${token}` } },
  );
  console.log(`Profil: ${await profilYaniti.text()}`);

  rl.close();
}

main().catch((hata) => {
  console.log(`Beklenmeyen hata: ${hata.message}`);
  rl.close();
  process.exitCode = 1;
});
