// â”€â”€â”€ Passport Router â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Full CRUD for all AI Health Passport features.
// All routes: /api/passport/*

const express  = require('express');
const multer   = require('multer');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const ddb      = require('../db/dynamo-db');

const router   = express.Router();

// ── multer: memory storage, 10 MB limit, images only ─────────────────────
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 20 * 1024 * 1024 }, // 20 MB – PDFs can be larger
  fileFilter: (_req, file, cb) => {
    const mime = (file.mimetype || '').toLowerCase();
    // Accept any image type OR PDF
    if (mime.startsWith('image/') || mime === 'application/pdf' || mime === 'application/octet-stream') {
      cb(null, true);
    } else {
      cb(new Error('Only image files (JPEG, PNG, WebP, HEIC, BMP, TIFF) or PDF documents are accepted'), false);
    }
  },
});

// ── Accepted government ID types (strictly enforced) ─────────────────────
const VALID_ID_TYPES = [
  'passport',           // International passport / travel document
  'driving_licence',    // Motor vehicle driving licence / driver's license
  'national_id',        // National identity card / state ID
  'aadhaar',            // India – Aadhaar card (UIDAI)
  'pan_card',           // India – Permanent Account Number card (Income Tax Dept)
  'voter_id',           // India / other – Voter ID / Election Commission ID
  'residence_permit',   // Residence permit / PR card / long-stay visa card
  'military_id',        // Military / armed forces ID card
  'government_id',      // Any other official government-issued photo ID
];

// ── Gemini Vision helper ──────────────────────────────────────────────────
async function analyzeIdWithGemini(imageBuffer, mimeType, keyOverride) {
  const apiKey = keyOverride || process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey === 'your_gemini_api_key_here') {
    throw new Error(
      'No Gemini API key available. Set GEMINI_API_KEY in backend/.env ' +
      'or ensure the Flutter app has an API key configured.'
    );
  }

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });

  const prompt = `You are a government ID document verification system.

Examine this image or PDF carefully. Your job is to determine if it is ANY type of official, government-issued identity document.

ACCEPTED document types:
- passport              – international travel passport (booklet or card)
- driving_licence       – motor vehicle driving licence / driver's license
- national_id           – national identity card, state ID, citizen card
- aadhaar               – India Aadhaar card issued by UIDAI
- pan_card              – India Permanent Account Number (PAN) card, Income Tax Dept
- voter_id              – voter ID card / election commission ID card
- residence_permit      – residence permit, permanent resident card, long-stay visa card
- military_id           – military / armed forces / defence ID card
- government_id         – any other official photo ID issued by a government authority

REJECT (return valid: false) if the image is:
- A selfie or personal photo with no document
- A credit card, debit card, or bank card
- A student ID, library card, gym membership, or private organisation card
- A health insurance card (without government photo ID elements)
- A screenshot, blank page, or non-document image
- Less than 60% confident it is a genuine government-issued document

RULES:
- Extract only what is clearly visible – do NOT invent or guess any field
- For dates use ISO 8601 format (YYYY-MM-DD) where possible
- For Aadhaar: idNumber is the 12-digit UID number (may be masked as XXXX XXXX 1234)
- For PAN card: idNumber is the 10-character alphanumeric PAN (e.g. PSMPS9296F)
- country field = issuing country (e.g. "India", "United Kingdom", "United States")

Respond with ONLY a valid JSON object, no markdown, no explanation:

If NOT a valid government ID:
{
  "valid": false,
  "reason": "<brief reason>"
}

If a valid government ID:
{
  "valid": true,
  "idType": "<one of the accepted types above>",
  "name": "<full name as printed, or null>",
  "dateOfBirth": "<YYYY-MM-DD or null>",
  "idNumber": "<document number as printed, or null>",
  "country": "<issuing country, or null>",
  "nationality": "<nationality if printed, or null>",
  "expiryDate": "<YYYY-MM-DD or null>",
  "gender": "<M|F|X or null>",
  "confidence": <0.00 to 1.00>
}`;

const imagePart = {
    inlineData: {
      data: imageBuffer.toString('base64'),
      mimeType,
    },
  };

  const result  = await model.generateContent([prompt, imagePart]);
  const rawText = result.response.text().trim();

  // Strip markdown fences if present
  const cleaned = rawText.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '').trim();

  let parsed;
  try {
    parsed = JSON.parse(cleaned);
  } catch {
    throw new Error('Gemini returned non-JSON response: ' + rawText.slice(0, 200));
  }

  return parsed;
}

const stamp = () => new Date().toISOString();

// â”€â”€â”€ GET /api/passport/profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/profile', async (req, res) => {
  try {
    const profile = await ddb.getProfile();
    res.json(profile || {});
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ PUT /api/passport/profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.put('/profile', async (req, res) => {
  try {
    const current = await ddb.getProfile() || {};
    const updated = await ddb.saveProfile({ ...current, ...req.body });
    res.json(updated);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ GET /api/passport/records â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/records', async (req, res) => {
  try {
    let records = await ddb.queryMedicalRecords({ limit: 500 });
    const { category, status } = req.query;
    if (category && category !== 'all') records = records.filter(r => r.category === category);
    if (status) records = records.filter(r => r.status === status);
    res.json({ records, total: records.length });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ POST /api/passport/records â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post('/records', async (req, res) => {
  try {
    const rec = await ddb.putMedicalRecord({
      ...req.body,
      status: req.body.status || 'verified',
    });
    if (req.app.locals.broadcast) {
      req.app.locals.broadcast({ type: 'passport_record_added', data: rec });
    }
    res.status(201).json(rec);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ DELETE /api/passport/records/:id â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.delete('/records/:id', async (req, res) => {
  try {
    await ddb.deleteMedicalRecord(req.params.id);
    res.json({ deleted: req.params.id });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ GET /api/passport/emergency â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/emergency', async (req, res) => {
  try {
    const emergency = await ddb.getEmergencyQR();
    res.json(emergency || {});
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ POST /api/passport/emergency/log â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post('/emergency/log', async (req, res) => {
  try {
    const entry = await ddb.appendQRAccessLog({
      actor:  req.body.actor  || 'Unknown',
      action: req.body.action || 'Scanned',
    });
    if (req.app.locals.broadcast) {
      req.app.locals.broadcast({ type: 'passport_qr_scan', data: entry });
    }
    res.status(201).json(entry);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ GET /api/passport/sharing â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/sharing', async (req, res) => {
  try {
    res.json(await ddb.getSharing());
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ PUT /api/passport/sharing â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.put('/sharing', async (req, res) => {
  try {
    const current = await ddb.getSharing();
    const updated = await ddb.saveSharing({ ...current, ...req.body, consentUpdated: stamp() });
    // Log a blockchain audit event for consent change
    await ddb.appendBlockchainEvent({
      event:  'Consent Updated',
      detail: 'Cross-border sharing settings changed',
      color:  'amber',
      ts:     'Just now',
    });
    res.json(updated);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ GET /api/passport/compatibility â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/compatibility', async (req, res) => {
  try {
    res.json(await ddb.getCompatibility());
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ POST /api/passport/compatibility/check â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post('/compatibility/check', async (req, res) => {
  try {
    const compat = await ddb.getCompatibility();
    const meds   = compat?.currentMedications || [];
    const { drugName } = req.body;

    const knownInteractions = {
      'Warfarin': ['Albuterol PRN'],
      'Aspirin':  ['Montelukast 10mg'],
    };
    const flags = (knownInteractions[drugName] || []).filter(m => meds.some(x => x.name === m));

    res.json({
      drug:         drugName,
      safe:         flags.length === 0,
      interactions: flags,
      checkedAt:    stamp(),
    });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ GET /api/passport/credits â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/credits', async (req, res) => {
  try {
    res.json(await ddb.getCredits());
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ POST /api/passport/credits/earn â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post('/credits/earn', async (req, res) => {
  try {
    const credits  = await ddb.getCredits();
    const { desc, points } = req.body;
    const newBalance       = (credits.balance || 0) + points;
    const lifetimeEarned   = (credits.lifetimeEarned || 0) + points;

    let tier = 'Bronze';
    if      (newBalance >= 5000) tier = 'Platinum';
    else if (newBalance >= 2000) tier = 'Gold';
    else if (newBalance >= 1000) tier = 'Silver';

    const updated = await ddb.saveCredits({ ...credits, balance: newBalance, lifetimeEarned, tier });
    await ddb.appendCreditTransaction({ desc, points, type: 'earn' });
    res.status(201).json(updated);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ POST /api/passport/credits/redeem â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post('/credits/redeem', async (req, res) => {
  try {
    const credits = await ddb.getCredits();
    const { desc, points } = req.body;
    if ((credits.balance || 0) < points) {
      return res.status(400).json({ error: 'Insufficient balance' });
    }
    const newBalance    = credits.balance - points;
    const totalRedeemed = (credits.totalRedeemed || 0) + points;
    const updated = await ddb.saveCredits({ ...credits, balance: newBalance, totalRedeemed });
    await ddb.appendCreditTransaction({ desc, points: -points, type: 'redeem' });
    res.status(201).json(updated);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ GET /api/passport/blockchain â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/blockchain', async (req, res) => {
  try {
    const [bc, auditLog] = await Promise.all([
      ddb.getBlockchain(),
      ddb.queryBlockchainEvents({ limit: 100 }),
    ]);
    res.json({ ...(bc || {}), auditLog, lastSyncedAt: bc?.lastSyncedAt || stamp() });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ POST /api/passport/blockchain/event â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post('/blockchain/event', async (req, res) => {
  try {
    const entry = await ddb.appendBlockchainEvent({
      event:  req.body.event  || 'System Event',
      detail: req.body.detail || '',
      color:  req.body.color  || 'gray',
      ts:     'Just now',
    });
    const bc = await ddb.getBlockchain() || {};
    await ddb.saveBlockchain({ ...bc, totalBlocks: (bc.totalBlocks || 0) + 1, lastSyncedAt: stamp() });
    if (req.app.locals.broadcast) {
      req.app.locals.broadcast({ type: 'passport_blockchain_event', data: entry });
    }
    res.status(201).json(entry);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ GET /api/passport/wearable â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/wearable', async (req, res) => {
  try {
    const devices = await ddb.queryWearableDevices();
    res.json({ devices });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ PUT /api/passport/wearable/devices/:id â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.put('/wearable/devices/:id', async (req, res) => {
  try {
    const existing = await ddb.getWearableDevice(req.params.id);
    if (!existing) return res.status(404).json({ error: 'Device not found' });
    const updated = await ddb.putWearableDevice({ ...existing, ...req.body, deviceId: req.params.id, lastSync: stamp() });
    if (req.app.locals.broadcast) {
      req.app.locals.broadcast({ type: 'passport_wearable_update', data: updated });
    }
    res.json(updated);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ GET /api/passport/genomic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/genomic', async (req, res) => {
  try {
    res.json(await ddb.getGenomic() || {});
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ GET /api/passport/discharge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/discharge', async (req, res) => {
  try {
    const records = await ddb.queryDischarge({ limit: 100 });
    res.json({ records });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ POST /api/passport/discharge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post('/discharge', async (req, res) => {
  try {
    const rec = await ddb.putDischargeRecord({
      ...req.body,
      status: req.body.status || 'verified',
    });
    res.status(201).json(rec);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// â”€â”€â”€ GET /api/passport/summary â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/summary', async (req, res) => {
  try {
    const [profile, records, credits, bc, devices] = await Promise.all([
      ddb.getProfile(),
      ddb.queryMedicalRecords({ limit: 500 }),
      ddb.getCredits(),
      ddb.getBlockchain(),
      ddb.queryWearableDevices(),
    ]);
    res.json({
      profileName:     profile?.name        || 'Unknown',
      passportId:      profile?.id          || '',
      recordCount:     records.length,
      creditsBalance:  credits?.balance     || 0,
      creditsTier:     credits?.tier        || 'Bronze',
      blockchainTotal: bc?.totalBlocks      || 0,
      wearableCount:   devices.filter(d => d.connected).length,
      lastSynced:      bc?.lastSyncedAt     || null,
    });
  } catch (e) { res.status(500).json({ error: e.message }); }
});


// ── POST /api/passport/verify-id ─────────────────────────────────────────
// Accepts: multipart/form-data  { image: <file> }
// Strictly accepts only: passport, driving_licence, national_id
// Returns 200 with extracted data, or 422 with rejection reason.
router.post(
  '/verify-id',
  upload.single('image'),
  async (req, res) => {
    // multer file-filter errors arrive as req.fileValidationError via error handler
    // but multer itself throws for missing file:
    if (!req.file) {
      return res.status(400).json({
        error: 'No image uploaded. Send a JPEG, PNG, WebP or HEIC image in the "image" field.',
      });
    }

    try {
      const geminiKey = req.headers['x-gemini-key'] || undefined;

      // Derive MIME type from filename when client sends application/octet-stream
      let effectiveMime = req.file.mimetype;
      if (effectiveMime === 'application/octet-stream' && req.file.originalname) {
        const ext = req.file.originalname.split('.').pop().toLowerCase();
        const extMap = { jpg:'image/jpeg', jpeg:'image/jpeg', png:'image/png', webp:'image/webp', heic:'image/heic', heif:'image/heic', bmp:'image/bmp', tiff:'image/tiff', gif:'image/gif', pdf:'application/pdf' };
        effectiveMime = extMap[ext] || effectiveMime;
      }

      const result = await analyzeIdWithGemini(req.file.buffer, effectiveMime, geminiKey);

      // ── Strict type gate ───────────────────────────────────────────────
      if (!result.valid) {
        return res.status(422).json({
          verified: false,
          reason: result.reason || 'Document not recognised as a valid government ID.',
          supportedTypes: ['passport', 'driving_licence', 'national_id'],
        });
      }

      if (!VALID_ID_TYPES.includes(result.idType)) {
        return res.status(422).json({
          verified: false,
          reason: 'Document type "' + result.idType + '" is not accepted. Only passport, driving_licence, or national_id are supported.',
          supportedTypes: VALID_ID_TYPES,
        });
      }

      // ── Confidence threshold ───────────────────────────────────────────
      if (typeof result.confidence === 'number' && result.confidence < 0.60) {
        return res.status(422).json({
          verified: false,
          reason: 'Document could not be verified with sufficient confidence (' + (result.confidence * 100).toFixed(0) + '%). Please provide a clearer image.',
          supportedTypes: VALID_ID_TYPES,
        });
      }

      // ── Build verified record ──────────────────────────────────────────
      const verified = {
        verified:     true,
        idType:       result.idType,
        name:         result.name         || null,
        dateOfBirth:  result.dateOfBirth  || null,
        idNumber:     result.idNumber     || null,
        country:      result.country      || null,
        nationality:  result.nationality  || null,
        expiryDate:   result.expiryDate   || null,
        gender:       result.gender       || null,
        confidence:   result.confidence   ?? null,
        verifiedAt:   new Date().toISOString(),
      };

      // ── Persist to profile in DynamoDB ────────────────────────────────
      try {
        const profile = await ddb.getProfile() || {};
        await ddb.saveProfile({
          ...profile,
          idVerification: verified,
        });

        // Blockchain audit trail
        await ddb.appendBlockchainEvent({
          event:  'Identity Verified',
          detail: result.idType.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase()) + ' verified for ' + (verified.name || 'Unknown'),
          color:  'green',
          ts:     'Just now',
        });
      } catch (dbErr) {
        // Non-fatal – still return the verification result
        console.warn('[verify-id] DynamoDB save failed:', dbErr.message);
      }

      return res.json(verified);

    } catch (err) {
      console.error('[verify-id] Error:', err.message);

      // Surface Gemini config errors clearly
      if (err.message.includes('GEMINI_API_KEY')) {
        return res.status(503).json({ error: err.message });
      }

      return res.status(500).json({ error: 'ID verification failed: ' + err.message });
    }
  }
);

// ── multer error handler (file type / size) ────────────────────────────────
router.use((err, _req, res, _next) => {
  if (err instanceof multer.MulterError || err.message.includes('JPEG')) {
    return res.status(400).json({ error: err.message });
  }
  _next(err);
});

module.exports = router;
