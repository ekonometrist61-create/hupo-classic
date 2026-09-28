import fs from 'fs';
import path from 'path';

const libDir = path.resolve('mobile-app/lib');

function getDartFiles(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  for (const file of list) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      results = results.concat(getDartFiles(fullPath));
    } else if (file.endsWith('.dart')) {
      results.push(fullPath);
    }
  }
  return results;
}

const dartFiles = getDartFiles(libDir);
console.log(`Denetlenen Dart dosyasi: ${dartFiles.length}`);

let errorCount = 0;

for (const filePath of dartFiles) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');

  // Parantez kontrolü: string ve yorumları atlayarak
  let round = 0, curly = 0, square = 0;
  let inLineComment = false;
  let inBlockComment = false;
  let inSingleQuote = false;
  let inDoubleQuote = false;

  for (let i = 0; i < content.length; i++) {
    const c = content[i];
    const next = i + 1 < content.length ? content[i + 1] : '';

    if (inLineComment) {
      if (c === '\n') inLineComment = false;
      continue;
    }
    if (inBlockComment) {
      if (c === '*' && next === '/') {
        inBlockComment = false;
        i++;
      }
      continue;
    }
    if (inSingleQuote) {
      if (c === '\\') { i++; continue; }
      if (c === "'") inSingleQuote = false;
      continue;
    }
    if (inDoubleQuote) {
      if (c === '\\') { i++; continue; }
      if (c === '"') inDoubleQuote = false;
      continue;
    }

    if (c === '/' && next === '/') {
      inLineComment = true;
      i++;
      continue;
    }
    if (c === '/' && next === '*') {
      inBlockComment = true;
      i++;
      continue;
    }
    if (c === "'") { inSingleQuote = true; continue; }
    if (c === '"') { inDoubleQuote = true; continue; }

    if (c === '(') round++;
    else if (c === ')') round--;
    else if (c === '{') curly++;
    else if (c === '}') curly--;
    else if (c === '[') square++;
    else if (c === ']') square--;
  }

  if (round !== 0 || curly !== 0 || square !== 0) {
    console.error(`HATA (Dengesiz blok): ${filePath} -> round=${round}, curly=${curly}, square=${square}`);
    errorCount++;
  }

  // Relative importlar
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line.startsWith('import ') && (line.includes("'../") || line.includes("'./") || line.includes('"../') || line.includes('"./'))) {
      const match = line.match(/import\s+['"]([^'"]+)['"]/);
      if (match) {
        const importPath = match[1];
        const resolvedPath = path.resolve(path.dirname(filePath), importPath);
        if (!fs.existsSync(resolvedPath)) {
          console.error(`HATA (Eksik Import): ${filePath}:${i + 1} -> ${importPath}`);
          errorCount++;
        }
      }
    }
  }
}

if (errorCount === 0) {
  console.log(`Tüm Dart dosyalari dengeli ve local importlar eksiksiz! (HATA: 0)`);
} else {
  console.error(`HATA: ${errorCount}`);
  process.exit(1);
}
