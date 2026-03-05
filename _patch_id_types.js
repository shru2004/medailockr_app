const fs = require('fs');
const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/backend/routes/passport.js';
let c = fs.readFileSync(f, 'utf8');

// ── 1. Replace multer filter: accept all images + PDF ─────────────────────
const OLD_MULTER = `const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const ok = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/gif'];
    if (ok.includes(file.mimetype)) cb(null, true);
    else cb(new Error('Only JPEG, PNG, WebP or HEIC images are accepted'), false);
  },
});`;

const NEW_MULTER = `const upload = multer({
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
});`;

if (!c.includes(OLD_MULTER)) {
  console.error('OLD_MULTER not found'); process.exit(1);
}
c = c.replace(OLD_MULTER, NEW_MULTER);
console.log('Multer filter updated');

// ── 2. Expand VALID_ID_TYPES ──────────────────────────────────────────────
const OLD_TYPES = `const VALID_ID_TYPES = ['passport', 'driving_licence', 'national_id'];`;
const NEW_TYPES = `const VALID_ID_TYPES = [
  'passport',           // International passport / travel document
  'driving_licence',    // Motor vehicle driving licence / driver's license
  'national_id',        // National identity card / state ID
  'aadhaar',            // India – Aadhaar card (UIDAI)
  'pan_card',           // India – Permanent Account Number card (Income Tax Dept)
  'voter_id',           // India / other – Voter ID / Election Commission ID
  'residence_permit',   // Residence permit / PR card / long-stay visa card
  'military_id',        // Military / armed forces ID card
  'government_id',      // Any other official government-issued photo ID
];`;

if (!c.includes(OLD_TYPES)) {
  console.error('OLD_TYPES not found'); process.exit(1);
}
c = c.replace(OLD_TYPES, NEW_TYPES);
console.log('VALID_ID_TYPES expanded');

// ── 3. Replace Gemini prompt ───────────────────────────────────────────────
const PROMPT_START = 'const prompt = `';
const PROMPT_END_MARKER = 'const imagePart = {';

const promptStart = c.indexOf(PROMPT_START);
const promptEnd   = c.indexOf(PROMPT_END_MARKER, promptStart);
if (promptStart === -1 || promptEnd === -1) {
  console.error('Prompt boundaries not found'); process.exit(1);
}

const NEW_PROMPT = `const prompt = \`You are a government ID document verification system.

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
}\`;

`;

c = c.slice(0, promptStart) + NEW_PROMPT + c.slice(promptEnd);
console.log('Gemini prompt updated');

// ── 4. Fix the confidence threshold – lower to 0.60 for broader ID types ──
c = c.replace(
  'result.confidence < 0.70',
  'result.confidence < 0.60'
);
c = c.replace(
  '(result.confidence * 100).toFixed(0)) + \'%). Please provide a clearer image.',
  '(result.confidence * 100).toFixed(0)) + \'%). Please provide a clearer, well-lit image of the document.'
);
console.log('Confidence threshold lowered to 0.60');

fs.writeFileSync(f, c, 'utf8');
console.log('passport.js saved. Size:', c.length);
