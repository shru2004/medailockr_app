const fs = require('fs');
const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/backend/routes/passport.js';
let c = fs.readFileSync(f, 'utf8');

// ── 1. Prepend new imports block right after the first require('express') require ──
const OLD_HEADER = "const express = require('express');\r\nconst ddb     = require('../db/dynamo-db');\r\n\r\nconst router  = express.Router();";
const NEW_HEADER = `const express  = require('express');
const multer   = require('multer');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const ddb      = require('../db/dynamo-db');

const router   = express.Router();

// ── multer: memory storage, 10 MB limit, images only ─────────────────────
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const ok = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/gif'];
    if (ok.includes(file.mimetype)) cb(null, true);
    else cb(new Error('Only JPEG, PNG, WebP or HEIC images are accepted'), false);
  },
});

// ── Accepted government ID types (strictly enforced) ─────────────────────
const VALID_ID_TYPES = ['passport', 'driving_licence', 'national_id'];

// ── Gemini Vision helper ──────────────────────────────────────────────────
async function analyzeIdWithGemini(imageBuffer, mimeType) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey === 'your_gemini_api_key_here') {
    throw new Error('GEMINI_API_KEY is not configured in backend .env');
  }

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });

  const prompt = \`You are a strict government ID document verification system.

Examine this image carefully and determine if it is one of these EXACT document types:
1. passport        – a travel document / international passport booklet or card
2. driving_licence – a motor vehicle driving licence / driver's license card
3. national_id     – a national identity card, state ID card, residence card, or voter ID

STRICT RULES:
- If the image is NOT one of those three types (e.g. it is a selfie, credit card, bank card, health card, student card, random photo, screenshot, or anything else), you MUST return valid: false.
- Do NOT guess or approximate. If you are less than 70% confident it is a genuine government-issued document of one of those three types, return valid: false.
- Extract only what is clearly visible. Do NOT invent or guess any field.
- For date of birth and expiry, use ISO 8601 format (YYYY-MM-DD) where possible.

Respond with ONLY a valid JSON object, no markdown, no explanation:

If NOT a valid document type:
{
  "valid": false,
  "reason": "<brief reason e.g. Not a government ID – appears to be a selfie>"
}

If a valid document type:
{
  "valid": true,
  "idType": "passport|driving_licence|national_id",
  "name": "<full name as printed, or null>",
  "dateOfBirth": "<YYYY-MM-DD or null>",
  "idNumber": "<document number as printed, or null>",
  "country": "<issuing country name, or null>",
  "nationality": "<nationality if printed, or null>",
  "expiryDate": "<YYYY-MM-DD or null>",
  "gender": "<M|F|X or null>",
  "confidence": <0.00 to 1.00>
}\`;

  const imagePart = {
    inlineData: {
      data: imageBuffer.toString('base64'),
      mimeType,
    },
  };

  const result  = await model.generateContent([prompt, imagePart]);
  const rawText = result.response.text().trim();

  // Strip markdown fences if present
  const cleaned = rawText.replace(/^\`\`\`(?:json)?\\s*/i, '').replace(/\\s*\`\`\`$/, '').trim();

  let parsed;
  try {
    parsed = JSON.parse(cleaned);
  } catch {
    throw new Error('Gemini returned non-JSON response: ' + rawText.slice(0, 200));
  }

  return parsed;
}`;

if (!c.includes(OLD_HEADER)) {
  // Try CRLF variant
  const ALT = "const express = require('express');\r\nconst ddb     = require('../db/dynamo-db');\r\n\r\nconst router  = express.Router();";
  if (c.includes(ALT)) {
    c = c.replace(ALT, NEW_HEADER);
    console.log('Replaced header (CRLF variant)');
  } else {
    // Try simple indexOf
    const idx = c.indexOf("const express = require('express');");
    if (idx === -1) { console.error('Cannot find header'); process.exit(1); }
    // find end of router declaration
    const routerEnd = c.indexOf("express.Router();", idx) + "express.Router();".length;
    c = c.slice(0, idx) + NEW_HEADER + c.slice(routerEnd);
    console.log('Replaced header (indexOf method)');
  }
} else {
  c = c.replace(OLD_HEADER, NEW_HEADER);
  console.log('Replaced header (exact match)');
}

// ── 2. Add verify-id route before module.exports ───────────────────────────────
const BEFORE_EXPORTS = '\r\nmodule.exports = router;';
const NEW_ROUTE = `

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
      const result = await analyzeIdWithGemini(req.file.buffer, req.file.mimetype);

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
      if (typeof result.confidence === 'number' && result.confidence < 0.70) {
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
          detail: result.idType.replace('_', ' ').replace(/\\b\\w/g, l => l.toUpperCase()) + ' verified for ' + (verified.name || 'Unknown'),
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

`;

if (!c.includes('\r\nmodule.exports = router;') && !c.includes('\nmodule.exports = router;')) {
  console.error('Cannot find module.exports');
  process.exit(1);
}

c = c.replace(/(\r?\n)(module\.exports = router;)/, NEW_ROUTE + '$2');
console.log('verify-id route added');

fs.writeFileSync(f, c, 'utf8');
console.log('passport.js written. Final size:', c.length);
