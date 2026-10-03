#!/usr/bin/env node
// =====================================================================
//  SQL SOZDIZIM DENETIMI (yerel PostgreSQL yoksa statik dogrulama)
//
//  Amac: migration/test dosyalarinda YAPISAL bozuklugu yakalamak:
//    * kapanmayan / fazla parantez (hicbir noktada eksiye dusmemeli)
//    * kapanmayan dolar-tirnak blogu ($function$ ... $function$ / $$ ... $$)
//    * kapanmayan tek tirnak ('...' ve '' kacisi, E'...' ters bolu)
//    * kapanmayan cift tirnak ("...") ve blok yorum (/* ... */, ic ice olabilir)
//    * noktali virgulle bitmeyen son ifade (dosya sonu)
//
//  Kullanim:
//    node tools/sql-sozdizim-denetimi.mjs
//    node tools/sql-sozdizim-denetimi.mjs supabase/migrations/x.sql
//
//  Cikti: her dosya icin TAMAM/HATA satiri + HATA varsa satir:kolon bilgisi.
//  Cikis kodu: hata sayisi (0 = temiz).
// =====================================================================

import { readFileSync, readdirSync } from 'node:fs';
import { join, basename, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const kok = join(dirname(fileURLToPath(import.meta.url)), '..');

function sqlDosyalari(dizin) {
  try {
    return readdirSync(dizin)
      .filter((f) => f.endsWith('.sql'))
      .sort()
      .map((f) => join(dizin, f));
  } catch {
    return [];
  }
}

/** Karakter akisini tarar; yapisal denge durumunu dondurur.
 *  baslangicSatiri: metnin 1. karakterinin dosyadaki satir numarasi (dolar blogu icin)
 *  ic: ic (dolar-tirnak) govde icinde miyiz — dosya sonu noktali virgul kurali uygulanmaz
 */
function denetle(metin, baslangicSatiri = 1, ic = false) {
  const hatalar = [];
  let satir = baslangicSatiri;
  let kolon = 1;
  let i = 0;
  const ilerle = (n = 1) => {
    for (let k = 0; k < n; k++) {
      if (metin[i] === '\n') {
        satir++;
        kolon = 1;
      } else {
        kolon++;
      }
      i++;
    }
  };

  let parantez = 0;
  let minParantez = 0;
  let minYer = null;
  let ifadeVar = false; // noktali virgul oncesi anlamli karakter var mi

  while (i < metin.length) {
    const c = metin[i];
    const c2 = metin[i + 1];

    // Yorumlar (blok yorumlar ic ice olabilir — PostgreSQL kurali)
    if (c === '-' && c2 === '-') {
      while (i < metin.length && metin[i] !== '\n') ilerle(1);
      continue;
    }
    if (c === '/' && c2 === '*') {
      const basSatir = satir;
      const basKolon = kolon;
      ilerle(2);
      let derinlik = 1;
      while (i < metin.length && derinlik > 0) {
        if (metin[i] === '/' && metin[i + 1] === '*') {
          derinlik++;
          ilerle(2);
        } else if (metin[i] === '*' && metin[i + 1] === '/') {
          derinlik--;
          ilerle(2);
        } else {
          ilerle(1);
        }
      }
      if (derinlik > 0) {
        hatalar.push({ satir: basSatir, kolon: basKolon, mesaj: 'Kapanmayan blok yorum (/*)' });
      }
      continue;
    }

    // Metin sabitleri
    if (c === "'" || ((c === 'E' || c === 'e') && c2 === "'")) {
      const basSatir = satir;
      const basKolon = kolon;
      const kacisli = c !== "'";
      ilerle(kacisli ? 2 : 1);
      let kapandi = false;
      while (i < metin.length) {
        if (kacisli && metin[i] === '\\') {
          ilerle(2);
          continue;
        }
        if (metin[i] === "'") {
          if (metin[i + 1] === "'") {
            ilerle(2);
            continue;
          }
          ilerle(1);
          kapandi = true;
          break;
        }
        ilerle(1);
      }
      if (!kapandi) {
        hatalar.push({ satir: basSatir, kolon: basKolon, mesaj: 'Kapanmayan metin sabiti' });
      }
      ifadeVar = true;
      continue;
    }

    // Tirnakli tanimlayici
    if (c === '"') {
      const basSatir = satir;
      const basKolon = kolon;
      ilerle(1);
      let kapandi = false;
      while (i < metin.length) {
        if (metin[i] === '"') {
          if (metin[i + 1] === '"') {
            ilerle(2);
            continue;
          }
          ilerle(1);
          kapandi = true;
          break;
        }
        ilerle(1);
      }
      if (!kapandi) {
        hatalar.push({ satir: basSatir, kolon: basKolon, mesaj: 'Kapanmayan tirnakli tanimlayici' });
      }
      ifadeVar = true;
      continue;
    }

    // Dolar-tirnakli metin ($function$ ... $function$, $$ ... $$)
    if (c === '$') {
      const esle = /^\$(?:[A-Za-z_][A-Za-z0-9_]*)?\$/.exec(metin.slice(i));
      if (esle) {
        const etiket = esle[0];
        const basSatir = satir;
        const basKolon = kolon;
        ilerle(etiket.length);
        const govdeSatiri = satir;
        const son = metin.indexOf(etiket, i);
        if (son < 0) {
          hatalar.push({ satir: basSatir, kolon: basKolon, mesaj: 'Kapanmayan dolar-tirnak blogu ' + etiket });
        } else {
          // Etiketli dolar-tirnak ($function$...) fonksiyon govdesidir — icerik denetlenir.
          // Etiketsiz dolar-tirnak ($$...) veri dizmesi olabilir; tek tirnak ve parantez
          // PostgreSQL'de serbestce gecilebilir, yanlis pozitif uretmemek icin denetlenmez.
          if (etiket !== '$$') {
            hatalar.push(...denetle(metin.slice(i, son), govdeSatiri, true));
          }
          ilerle(son - i + etiket.length);
        }
        ifadeVar = true;
        continue;
      }
    }

    if (c === '(') {
      parantez++;
      ifadeVar = true;
    } else if (c === ')') {
      parantez--;
      ifadeVar = true;
      if (parantez < minParantez) {
        minParantez = parantez;
        minYer = { satir, kolon };
      }
    } else if (c === ';') {
      ifadeVar = false;
    } else if (!/\s/.test(c)) {
      ifadeVar = true;
    }

    ilerle(1);
  }

  if (parantez !== 0) {
    hatalar.push({
      satir: minYer ? minYer.satir : satir,
      kolon: minYer ? minYer.kolon : kolon,
      mesaj:
        'Parantez dengesiz: fark ' + parantez + (minParantez < 0 ? ' (en dusuk: ' + minParantez + ')' : ''),
    });
  }
  if (ifadeVar && !ic) {
    hatalar.push({ satir, kolon, mesaj: 'Dosya noktali virgul ile bitmiyor' });
  }
  return hatalar;
}

const argumanlar = process.argv.slice(2);
const dosyalar = argumanlar.length
  ? argumanlar.map((p) => join(kok, p))
  : [
      ...sqlDosyalari(join(kok, 'supabase', 'migrations')),
      ...sqlDosyalari(join(kok, 'supabase', 'tests')),
    ];

let hataSayisi = 0;
const satirlar = [];

for (const dosya of dosyalar) {
  const metin = readFileSync(dosya, 'utf8');
  const hatalar = denetle(metin);
  if (hatalar.length === 0) {
    satirlar.push('TAMAM  ' + basename(dosya));
  } else {
    hataSayisi += hatalar.length;
    satirlar.push('HATA   ' + basename(dosya));
    for (const h of hatalar) {
      satirlar.push('        -> ' + h.satir + ':' + h.kolon + ' ' + h.mesaj);
    }
  }
}

satirlar.push('');
satirlar.push('Denetlenen dosya: ' + dosyalar.length + ' | HATA: ' + hataSayisi);
process.stdout.write(satirlar.join('\n') + '\n');
process.exit(hataSayisi);