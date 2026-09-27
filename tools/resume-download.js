// Buyuk dosya indirmeleri arka planda kesiliyor (kismi icerik).
// Bu betik sunucudan Content-Length kadar devam eder ve dogrular.
//
// NOT: node:http kullaniliyor; global fetch (undici) bir Web Stream donuyor
// ve Node 24'te classic pipe zincirine baglanmiyor.
const fs = require("fs");
const http = require("http");
const https = require("https");

const url = process.argv[2];
const dest = process.argv[3];
const UA = "Mozilla/5.0";

function headSize(target) {
  return new Promise((resolve, reject) => {
    const mod = target.startsWith("https") ? https : http;
    const req = mod.request(
      target,
      { method: "HEAD", headers: { "User-Agent": UA } },
      (res) => {
        resolve(Number(res.headers["content-length"]));
        res.resume();
      }
    );
    req.on("error", reject);
    req.end();
  });
}

function get(target, headers) {
  return new Promise((resolve, reject) => {
    const mod = target.startsWith("https") ? https : http;
    const req = mod.request(target, { method: "GET", headers }, resolve);
    req.on("error", reject);
    req.setTimeout(60000, () => req.destroy(new Error("zaman asimi")));
    req.end();
  });
}

async function main() {
  const total = await headSize(url);
  console.log("beklenen boyut: " + Math.round(total / 1048576) + " MB");

  for (let attempt = 1; attempt <= 15; attempt++) {
    const have = fs.existsSync(dest) ? fs.statSync(dest).size : 0;
    if (have === total) {
      console.log("TAMAM: " + Math.round(total / 1048576) + " MB");
      return;
    }
    console.log(
      "deneme " + attempt + ": " + Math.round(have / 1048576) + " MB / " +
        Math.round(total / 1048576) + " MB"
    );

    const headers = { "User-Agent": UA };
    if (have > 0) headers.Range = "bytes=" + have + "-";

    let res;
    try {
      res = await get(url, headers);
    } catch (e) {
      console.log("  baglanti hatasi: " + e.message);
      await new Promise((r) => setTimeout(r, 3000));
      continue;
    }

    if (res.statusCode !== 200 && res.statusCode !== 206) {
      console.log("  HTTP " + res.statusCode);
      res.resume();
      await new Promise((r) => setTimeout(r, 5000));
      continue;
    }

    const out = fs.createWriteStream(dest, { flags: have > 0 ? "a" : "w" });
    await new Promise((resolve) => {
      let done = false;
      const finish = () => {
        if (done) return;
        done = true;
        out.end(resolve);
      };
      res.on("data", (c) => out.write(c));
      res.on("end", finish);
      res.on("error", () => {
        out.destroy();
        resolve();
      });
      out.on("error", () => resolve());
    });

    const now = fs.statSync(dest).size;
    console.log("  -> " + Math.round(now / 1048576) + " MB");
    if (now < total) await new Promise((r) => setTimeout(r, 2000));
  }

  const have = fs.statSync(dest).size;
  if (have !== total) {
    console.log(
      "TAMAMLANAMADI: " + Math.round(have / 1048576) + " / " +
        Math.round(total / 1048576) + " MB"
    );
    process.exit(1);
  }
}

main();
