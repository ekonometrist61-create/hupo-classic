// Gelistirme sunucusundaki rotalari tek tek istek atip HTTP kodunu ve
// sunucu tarafindan uretilen metni kontrol eder.
// (curl bu makinede yok; node:http kullaniliyor.)
const http = require("http");

const base = process.argv[2] || "http://localhost:3010";
const routes = process.argv.slice(3);

function get(path) {
  return new Promise((resolve) => {
    const req = http.get(base + path, { timeout: 120000 }, (res) => {
      let body = "";
      res.setEncoding("utf8");
      res.on("data", (c) => (body += c));
      res.on("end", () => resolve({ status: res.statusCode, body }));
    });
    req.on("error", (e) => resolve({ status: 0, body: "", error: e.message }));
    req.on("timeout", () => {
      req.destroy();
      resolve({ status: 0, body: "", error: "zaman asimi" });
    });
  });
}

// Sunucunun Turkce uretigini dogrulamak icin beklenen isaretler.
const MARKERS = {
  "/yonetim": ["Yönetim Paneli", "Veli Hesabı"],
  "/yonetim/sorular": ["Sorular", "Yeni Soru"],
  "/yonetim/kullanicilar": ["Kullanıcılar", "Veli Hesabı"],
  "/yonetim/odemeler": ["Ödemeler", "Plan"],
  "/veli-paneli": ["Veli Paneli", "Çocuk"],
  "/signin": ["Giriş Yap", "E-posta"],
};

(async () => {
  for (const route of routes) {
    const r = await get(route);
    const marks = MARKERS[route] || [];
    const hits = marks.filter((m) => r.body.includes(m));
    const text = r.body.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ");
    console.log(
      route.padEnd(24) +
      String(r.status).padEnd(6) +
      String(r.body.length).padEnd(10) +
      (r.error ? "HATA: " + r.error : hits.length + "/" + marks.length + " isaret")
    );
    if (hits.length < marks.length && r.body) {
      console.log("   metin: " + text.slice(0, 110));
    }
  }
})();
