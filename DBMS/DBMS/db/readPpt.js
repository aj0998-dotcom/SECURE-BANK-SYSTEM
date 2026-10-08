const fs = require('fs');
const zlib = require('zlib');
const path = require('path');

function extractPpt() {
  try {
    const pptxPath = path.join(__dirname, '..', '..', 'SecureBank – Bank Management System.pptx');
    if (!fs.existsSync(pptxPath)) return;
    const buf = fs.readFileSync(pptxPath);

    let eocdPos = buf.length - 22;
    while (eocdPos >= 0) {
      if (buf.readUInt32LE(eocdPos) === 0x06054b50) break;
      eocdPos--;
    }
    if (eocdPos < 0) return;

    const cdOffset = buf.readUInt32LE(eocdPos + 16);
    const cdEntries = buf.readUInt16LE(eocdPos + 10);

    let pos = cdOffset;
    const entries = [];
    for (let i = 0; i < cdEntries; i++) {
      if (buf.readUInt32LE(pos) !== 0x02014b50) break;
      const method = buf.readUInt16LE(pos + 10);
      const compSize = buf.readUInt32LE(pos + 20);
      const nameLen = buf.readUInt16LE(pos + 28);
      const extraLen = buf.readUInt16LE(pos + 30);
      const commentLen = buf.readUInt16LE(pos + 32);
      const localHeaderOffset = buf.readUInt32LE(pos + 42);

      const name = buf.toString('utf8', pos + 46, pos + 46 + nameLen);
      pos += 46 + nameLen + extraLen + commentLen;

      const localNameLen = buf.readUInt16LE(localHeaderOffset + 26);
      const localExtraLen = buf.readUInt16LE(localHeaderOffset + 28);
      const dataOffset = localHeaderOffset + 30 + localNameLen + localExtraLen;
      const rawData = buf.slice(dataOffset, dataOffset + compSize);

      let content = null;
      try {
        if (method === 8) content = zlib.inflateRawSync(rawData);
        else if (method === 0) content = rawData;
      } catch (e) {}

      entries.push({ name, content });
    }

    const slideEntries = entries.filter(e => e.name.startsWith('ppt/slides/slide') && e.name.endsWith('.xml'));
    slideEntries.sort((a, b) => {
      const numA = parseInt(a.name.replace(/[^0-9]/g, ''));
      const numB = parseInt(b.name.replace(/[^0-9]/g, ''));
      return numA - numB;
    });

    let output = `PPT SLIDE EXTRACTED CONTENT (${slideEntries.length} Slides)\n\n`;
    slideEntries.forEach((slide, idx) => {
      if (!slide.content) return;
      const xml = slide.content.toString('utf8');
      const texts = [];
      const matches = xml.match(/<a:t[^>]*>(.*?)<\/a:t>/g);
      if (matches) {
        matches.forEach(m => {
          const txt = m.replace(/<[^>]+>/g, '').trim();
          if (txt) texts.push(txt);
        });
      }
      output += `=== SLIDE ${idx + 1} (${slide.name}) ===\n${texts.join(' ')}\n\n`;
    });

    fs.writeFileSync(path.join(__dirname, '..', 'ppt_text_output.txt'), output, 'utf8');
    console.log('✅ PPT text extracted to ppt_text_output.txt');
  } catch (err) {
    console.error('PPT extract error:', err);
  }
}

extractPpt();
module.exports = extractPpt;
