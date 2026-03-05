const fs = require('fs');

// ────────────────────────────────────────────────────────────────────────────
// 1. passport.js  — accept X-Gemini-Key header + fix analyzeIdWithGemini sig
// ────────────────────────────────────────────────────────────────────────────
{
  const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/backend/routes/passport.js';
  let c = fs.readFileSync(f, 'utf8');

  // Update function signature to accept optional keyOverride
  const OLD_FN = "async function analyzeIdWithGemini(imageBuffer, mimeType) {\n  const apiKey = process.env.GEMINI_API_KEY;\n  if (!apiKey || apiKey === 'your_gemini_api_key_here') {\n    throw new Error('GEMINI_API_KEY is not configured in backend .env');\n  }";
  const NEW_FN = `async function analyzeIdWithGemini(imageBuffer, mimeType, keyOverride) {
  const apiKey = keyOverride || process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey === 'your_gemini_api_key_here') {
    throw new Error(
      'No Gemini API key available. Set GEMINI_API_KEY in backend/.env ' +
      'or ensure the Flutter app has an API key configured.'
    );
  }`;

  if (!c.includes('async function analyzeIdWithGemini(imageBuffer, mimeType)')) {
    console.error('analyzeIdWithGemini signature not found'); process.exit(1);
  }
  // Use safer indexOf-based replacement
  const sigStart = c.indexOf('async function analyzeIdWithGemini(imageBuffer, mimeType)');
  const firstThrowEnd = c.indexOf(";\n  }", sigStart) + ";\n  }".length;
  c = c.slice(0, sigStart) + NEW_FN + c.slice(firstThrowEnd);
  console.log('passport.js: function signature updated');

  // Update the call site to pass the key from request header
  const OLD_CALL = "      const result = await analyzeIdWithGemini(req.file.buffer, req.file.mimetype);";
  const NEW_CALL = `      const geminiKey = req.headers['x-gemini-key'] || undefined;
      const result = await analyzeIdWithGemini(req.file.buffer, req.file.mimetype, geminiKey);`;

  if (!c.includes(OLD_CALL)) {
    console.error('Call site not found'); process.exit(1);
  }
  c = c.replace(OLD_CALL, NEW_CALL);
  console.log('passport.js: call site updated with header key');

  fs.writeFileSync(f, c, 'utf8');
  console.log('passport.js saved. Size:', c.length);
}

// ────────────────────────────────────────────────────────────────────────────
// 2. gemini_service.dart — add public apiKey getter
// ────────────────────────────────────────────────────────────────────────────
{
  const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/flutter_mediqly/lib/services/gemini_service.dart';
  let c = fs.readFileSync(f, 'utf8');

  const OLD_GETTER = "  void setApiKey(String key) => _apiKey = key;\r\n  bool get hasKey => _apiKey.isNotEmpty;";
  const NEW_GETTER = `  void setApiKey(String key) => _apiKey = key;
  bool get hasKey   => _apiKey.isNotEmpty;
  String get apiKey => _apiKey;`;

  if (c.includes(OLD_GETTER)) {
    c = c.replace(OLD_GETTER, NEW_GETTER);
    console.log('gemini_service.dart: apiKey getter added (CRLF match)');
  } else {
    const LF_GETTER = "  void setApiKey(String key) => _apiKey = key;\n  bool get hasKey => _apiKey.isNotEmpty;";
    if (c.includes(LF_GETTER)) {
      c = c.replace(LF_GETTER, NEW_GETTER);
      console.log('gemini_service.dart: apiKey getter added (LF match)');
    } else {
      // Find by indexOf and patch
      const idx = c.indexOf('void setApiKey(String key)');
      if (idx === -1) { console.error('setApiKey not found'); process.exit(1); }
      const lineEnd = c.indexOf('\n', c.indexOf('bool get hasKey', idx)) + 1;
      c = c.slice(0, idx) + `void setApiKey(String key) => _apiKey = key;\n  bool get hasKey   => _apiKey.isNotEmpty;\n  String get apiKey => _apiKey;\n  ` + c.slice(lineEnd);
      console.log('gemini_service.dart: apiKey getter added (indexOf method)');
    }
  }

  fs.writeFileSync(f, c, 'utf8');
  console.log('gemini_service.dart saved. Size:', c.length);
}

// ────────────────────────────────────────────────────────────────────────────
// 3. passport_screen.dart — pass Gemini key as header in the request
// ────────────────────────────────────────────────────────────────────────────
{
  const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/flutter_mediqly/lib/screens/health_passport/passport_screen.dart';
  let c = fs.readFileSync(f, 'utf8');

  // Re-add the gemini_service import (needed for the apiKey getter)
  const OLD_IMP = "import '../../providers/navigation_provider.dart';";
  const NEW_IMP = `import '../../services/gemini_service.dart';
import '../../providers/navigation_provider.dart';`;

  if (c.includes(OLD_IMP) && !c.includes("import '../../services/gemini_service.dart';")) {
    c = c.replace(OLD_IMP, NEW_IMP);
    console.log('passport_screen.dart: gemini_service import re-added');
  }

  // Add the key header to the multipart request
  const OLD_HEADERS = "      request.headers['Accept'] = 'application/json';";
  const NEW_HEADERS = `      request.headers['Accept']        = 'application/json';
      // Pass the Gemini key to the backend so it can call Gemini Vision
      final gemKey = GeminiService.instance.apiKey;
      if (gemKey.isNotEmpty) request.headers['X-Gemini-Key'] = gemKey;`;

  if (!c.includes(OLD_HEADERS)) {
    console.error('Headers line not found in passport_screen.dart'); process.exit(1);
  }
  c = c.replace(OLD_HEADERS, NEW_HEADERS);
  console.log('passport_screen.dart: Gemini key header added');

  fs.writeFileSync(f, c, 'utf8');
  console.log('passport_screen.dart saved. Size:', c.length);
}

console.log('\nAll patches applied successfully.');
