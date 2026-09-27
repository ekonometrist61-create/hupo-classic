// QuestionMix'in bekledigi approved/pending/rejected anahtarlarini ekler.
// Daha once Turkce karsiliklari yazilmisti, boylece bilesen Turkce metni
// gorevdi ve ceviri cozumleyemiyordu.
const fs = require("fs");
const path = require("path");

const MSG = path.join(__dirname, "..", "web-panel", "src", "messages");

const ADD = {
  tr: { approved: "Onaylı", pending: "Beklemede", rejected: "Reddedilen" },
  en: { approved: "Approved", pending: "Pending", rejected: "Rejected" },
};

for (const [loc, vals] of Object.entries(ADD)) {
  const f = path.join(MSG, "yonetim-panel." + loc + ".json");
  const j = JSON.parse(fs.readFileSync(f, "utf8"));
  j.yonetim.panel.mix = Object.assign({}, j.yonetim.panel.mix, vals);
  fs.writeFileSync(f, JSON.stringify(j, null, 2) + "\n", "utf8");
  console.log(path.basename(f) + " guncellendi");
}
