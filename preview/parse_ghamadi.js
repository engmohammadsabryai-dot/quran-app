const fs = require('fs');
const html = fs.readFileSync('ghamadi_files.html', 'utf8');
const lines = html.split('\n');
const files = [];
for (const line of lines) {
  const match = line.match(/href="([^"]+\.mp3)"/i);
  if (match) files.push(match[1]);
}
console.log('Total mp3 files:', files.length);
console.log('Sample files:', files.slice(0, 15));
