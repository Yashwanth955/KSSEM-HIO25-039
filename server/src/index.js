import express from 'express';
import cors from 'cors';
import multer from 'multer';
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;
const UPLOAD_DIR = process.env.UPLOAD_DIR || path.resolve(process.cwd(), 'uploads');

// Ensure uploads directory exists
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true });
}

app.use(cors({ origin: '*'}));
app.use(express.json({ limit: '5mb' }));
app.use('/uploads', express.static(UPLOAD_DIR));

// Multer storage for files
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOAD_DIR),
  filename: (req, file, cb) => {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const base = path.parse(file.originalname).name;
    const ext = path.extname(file.originalname) || '.pdf';
    cb(null, `${base}-${timestamp}${ext}`);
  }
});
const upload = multer({ storage, limits: { fileSize: 15 * 1024 * 1024 } }); // 15MB

// Simple root landing page
app.get('/', (req, res) => {
  res.type('html').send(`
    <html>
      <head><title>Sādhak Backend</title></head>
      <body style="font-family: sans-serif; padding: 24px;">
        <h1>Sādhak Backend</h1>
        <ul>
          <li><a href="/health">/health</a> – health check</li>
          <li><a href="/results">/results</a> – list stored results</li>
          <li><a href="/uploads/">/uploads/</a> – served uploaded files (if any)</li>
        </ul>
        <p>POST endpoints:</p>
        <ul>
          <li><code>POST /upload</code> (multipart form, field: <code>file</code>)</li>
          <li><code>POST /results</code> (application/json)</li>
        </ul>
      </body>
    </html>
  `);
});

app.get('/health', (req, res) => res.json({ ok: true }));

// Upload endpoint
app.post('/upload', upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ ok: false, error: 'No file uploaded' });
  const { title, generatedAt } = req.body || {};

  res.json({
    ok: true,
    message: 'File uploaded',
    file: {
      originalName: req.file.originalname,
      filename: req.file.filename,
      size: req.file.size,
      url: `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`,
    },
    meta: { title, generatedAt }
  });
});

// Simple JSON store for test results (not for production)
const RESULTS_STORE = process.env.RESULTS_STORE || path.resolve(process.cwd(), 'data');
const RESULTS_FILE = path.join(RESULTS_STORE, 'results.json');
if (!fs.existsSync(RESULTS_STORE)) fs.mkdirSync(RESULTS_STORE, { recursive: true });
if (!fs.existsSync(RESULTS_FILE)) fs.writeFileSync(RESULTS_FILE, '[]');

app.get('/results', (req, res) => {
  try {
    const buf = fs.readFileSync(RESULTS_FILE, 'utf8');
    const data = JSON.parse(buf);
    res.json({ ok: true, count: data.length, data });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

app.post('/results', (req, res) => {
  const body = req.body;
  if (!body || !body.testTitle || !body.resultValue || !body.date) {
    return res.status(400).json({ ok: false, error: 'Missing fields: testTitle, resultValue, date' });
  }
  try {
    const buf = fs.readFileSync(RESULTS_FILE, 'utf8');
    const list = JSON.parse(buf);
    list.push({ ...body, createdAt: new Date().toISOString() });
    fs.writeFileSync(RESULTS_FILE, JSON.stringify(list, null, 2));
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

app.listen(PORT, () => {
  console.log(`Sādhak backend running on http://localhost:${PORT}`);
});
