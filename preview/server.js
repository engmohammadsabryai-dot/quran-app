const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const PUBLIC_DIR = __dirname;

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.mp3': 'audio/mpeg',
  '.wav': 'audio/wav',
  '.ogg': 'audio/ogg'
};

const server = http.createServer((req, res) => {
  // Common CORS and Preflight handling for mobile devices
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Range, Content-Type, Accept-Ranges');
  res.setHeader('Access-Control-Expose-Headers', 'Content-Range, Content-Length, Accept-Ranges');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  let reqPath = req.url.split('?')[0];
  if (reqPath === '/' || reqPath === '') reqPath = '/index.html';

  let filePath;
  if (reqPath.startsWith('/assets/')) {
    filePath = path.join(__dirname, '..', reqPath);
  } else {
    filePath = path.join(PUBLIC_DIR, reqPath);
  }

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('404 Not Found');
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';
    const totalSize = stats.size;
    const isAudio = (ext === '.mp3' || ext === '.wav' || ext === '.ogg');

    // Robust HTTP Range requests for mobile streaming (iOS Safari, Android Chrome, WebView)
    const rangeHeader = req.headers.range;

    if (isAudio && rangeHeader) {
      const match = rangeHeader.match(/bytes=(\d*)-(\d*)/);
      if (!match) {
        res.writeHead(416, {
          'Content-Range': `bytes */${totalSize}`,
          'Content-Type': 'text/plain; charset=utf-8'
        });
        res.end('416 Range Not Satisfiable');
        return;
      }

      let start = match[1] ? parseInt(match[1], 10) : NaN;
      let end = match[2] ? parseInt(match[2], 10) : NaN;

      if (isNaN(start)) {
        // Suffix range (e.g. bytes=-500)
        start = totalSize - end;
        end = totalSize - 1;
      } else if (isNaN(end)) {
        // Prefix open range (e.g. bytes=0-)
        end = totalSize - 1;
      }

      if (start < 0) start = 0;
      if (end >= totalSize) end = totalSize - 1;

      if (start > end || start >= totalSize) {
        res.writeHead(416, {
          'Content-Range': `bytes */${totalSize}`,
          'Content-Type': 'text/plain; charset=utf-8'
        });
        res.end('416 Range Not Satisfiable');
        return;
      }

      const chunkSize = (end - start) + 1;

      const headers = {
        'Content-Range': `bytes ${start}-${end}/${totalSize}`,
        'Accept-Ranges': 'bytes',
        'Content-Length': chunkSize,
        'Content-Type': contentType,
        'Cache-Control': 'public, max-age=86400'
      };

      res.writeHead(206, headers);

      if (req.method === 'HEAD') {
        res.end();
        return;
      }

      const stream = fs.createReadStream(filePath, { start, end });
      stream.on('error', (streamErr) => {
        if (!res.headersSent) {
          res.writeHead(500);
        }
        res.end();
      });
      stream.pipe(res);
    } else {
      const headers = {
        'Content-Type': contentType,
        'Content-Length': totalSize,
        'Accept-Ranges': 'bytes',
        'Cache-Control': isAudio ? 'public, max-age=86400' : 'no-cache'
      };

      res.writeHead(200, headers);

      if (req.method === 'HEAD') {
        res.end();
        return;
      }

      const stream = fs.createReadStream(filePath);
      stream.on('error', (streamErr) => {
        if (!res.headersSent) {
          res.writeHead(500);
        }
        res.end();
      });
      stream.pipe(res);
    }
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Quran App Simulator running at http://0.0.0.0:${PORT} (Accessible via LAN IP on Mobile)`);
});
