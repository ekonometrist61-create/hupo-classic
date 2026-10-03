import fs from "fs";
import path from "path";

const filePath = path.resolve("mobile-app/lib/services/push/push_service.dart");
const content = fs.readFileSync(filePath, "utf8");

let stack = [];
for (let i = 0; i < content.length; i++) {
  const c = content[i];
  if (c === "(") {
    stack.push(i);
  } else if (c === ")") {
    stack.pop();
  }
}

for (const pos of stack) {
  const sub = content.substring(
    Math.max(0, pos - 20),
    Math.min(content.length, pos + 40),
  );
  const line = content.substring(0, pos).split("\n").length;
  console.log(`Unmatched ( at line ${line}: ...${sub}...`);
}
