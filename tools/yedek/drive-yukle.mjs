// Şifreli veritabanı yedeğini Google Drive'a yükler ve eski yedekleri temizler.
// Bağımlılık yok (Node 20 yerleşik fetch). Kullanım:
//   node tools/yedek/drive-yukle.mjs <dosya.dump.enc>
//
// Gerekli ortam değişkenleri (GitHub Secrets'tan gelir):
//   GDRIVE_CLIENT_ID, GDRIVE_CLIENT_SECRET, GDRIVE_REFRESH_TOKEN, GDRIVE_FOLDER_ID
// İsteğe bağlı:
//   YEDEK_SAKLAMA_GUN  (varsayılan 30) — bu süreden eski yedekler silinir.
//
// Kapsam: drive.file → yalnızca bu uygulamanın oluşturduğu dosyalara erişir.
// Yüklenen dosya zaten şifreli olmalıdır; bu betik şifrelemez.

import { readFile, stat } from "node:fs/promises";
import { basename } from "node:path";

const SCOPE = "https://www.googleapis.com/auth/drive.file";
const ONEK = "hupo-yedek-";

function gerekli(ad) {
  const v = process.env[ad];
  if (!v) throw new Error(`Eksik ortam değişkeni: ${ad}`);
  return v;
}

async function erisimJetonu() {
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: gerekli("GDRIVE_CLIENT_ID"),
      client_secret: gerekli("GDRIVE_CLIENT_SECRET"),
      refresh_token: gerekli("GDRIVE_REFRESH_TOKEN"),
      grant_type: "refresh_token",
    }),
  });
  const data = await res.json();
  if (!res.ok || !data.access_token) {
    // Yenileme jetonu iptal/süresi dolmuşsa mesaj açık olmalı.
    throw new Error(`Google jetonu alınamadı (${res.status}): ${data.error ?? "bilinmeyen"}`);
  }
  return data.access_token;
}

async function dosyaYukle(token, yol, klasorId) {
  const boyut = (await stat(yol)).size;
  const ad = basename(yol);

  // Resumable yükleme: büyük dosyalarda ağ kesintisine karşı daha dayanıklı.
  const baslat = await fetch(
    "https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable&fields=id,name,size",
    {
      method: "POST",
      headers: {
        authorization: `Bearer ${token}`,
        "content-type": "application/json; charset=UTF-8",
        "x-upload-content-type": "application/octet-stream",
        "x-upload-content-length": String(boyut),
      },
      body: JSON.stringify({ name: ad, parents: [klasorId] }),
    },
  );
  if (!baslat.ok) throw new Error(`Yükleme başlatılamadı (${baslat.status}): ${await baslat.text()}`);
  const konum = baslat.headers.get("location");
  if (!konum) throw new Error("Yükleme adresi (Location) alınamadı");

  const icerik = await readFile(yol);
  const put = await fetch(konum, {
    method: "PUT",
    headers: { "content-length": String(boyut), "content-type": "application/octet-stream" },
    body: icerik,
  });
  if (!put.ok) throw new Error(`Dosya yüklenemedi (${put.status}): ${await put.text()}`);
  const dosya = await put.json();
  return dosya;
}

async function eskiYedekleriSil(token, klasorId, saklamaGun) {
  const esik = new Date(Date.now() - saklamaGun * 86_400_000).toISOString();
  const sorgu = new URLSearchParams({
    q: `'${klasorId}' in parents and name contains '${ONEK}' and trashed = false and createdTime < '${esik}'`,
    fields: "files(id,name,createdTime)",
    pageSize: "200",
  });
  const res = await fetch(`https://www.googleapis.com/drive/v3/files?${sorgu}`, {
    headers: { authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error(`Eski yedekler listelenemedi (${res.status})`);
  const { files = [] } = await res.json();

  let silinen = 0;
  for (const f of files) {
    const del = await fetch(`https://www.googleapis.com/drive/v3/files/${f.id}`, {
      method: "DELETE",
      headers: { authorization: `Bearer ${token}` },
    });
    if (del.ok) silinen++;
    else console.error(`Silinemedi: ${f.name} (${del.status})`);
  }
  return silinen;
}

async function main() {
  const yol = process.argv[2];
  if (!yol) throw new Error("Kullanım: node tools/yedek/drive-yukle.mjs <dosya>");
  if (!basename(yol).startsWith(ONEK)) {
    throw new Error(`Dosya adı "${ONEK}" ile başlamalı (temizlik yalnızca bu önekli dosyalara uygulanır)`);
  }
  if (!yol.endsWith(".enc")) throw new Error("Yalnızca şifreli (.enc) dosya yüklenir");

  const klasorId = gerekli("GDRIVE_FOLDER_ID");
  const saklamaGun = Number(process.env.YEDEK_SAKLAMA_GUN ?? "30");
  if (!Number.isInteger(saklamaGun) || saklamaGun < 7) {
    throw new Error("YEDEK_SAKLAMA_GUN en az 7 tam sayı olmalı");
  }

  const token = await erisimJetonu();
  const dosya = await dosyaYukle(token, yol, klasorId);
  console.log(`Yüklendi: ${dosya.name} (${dosya.size} bayt, id ${dosya.id})`);

  const silinen = await eskiYedekleriSil(token, klasorId, saklamaGun);
  console.log(`Temizlik: ${saklamaGun} günden eski ${silinen} yedek silindi.`);
}

main().catch((err) => {
  console.error(`Yedekleme hatası: ${err.message}`);
  process.exit(1);
});
