const fs = require('fs');
const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/flutter_mediqly/lib/screens/health_passport/passport_screen.dart';
let c = fs.readFileSync(f, 'utf8');

// ── 1. Swap image_picker line for file_picker ──────────────────────────────
const OLD_IMP = "import 'package:image_picker/image_picker.dart';";
const NEW_IMP  = "import 'package:file_picker/file_picker.dart';";

if (c.includes(OLD_IMP)) {
  c = c.replace(OLD_IMP, NEW_IMP + "\nimport 'package:image_picker/image_picker.dart'; // kept for other screens");
} else if (!c.includes('file_picker')) {
  // insert after http import
  c = c.replace(
    "import 'package:http/http.dart' as http;",
    "import 'package:http/http.dart' as http;\nimport 'package:file_picker/file_picker.dart';"
  );
}
console.log('file_picker import added');

// ── 2. Replace _pickAndScanId method ──────────────────────────────────────
const METHOD_START = '_pickAndScanId() async {';
const startIdx = c.indexOf(METHOD_START);
if (startIdx === -1) { console.error('Method start not found'); process.exit(1); }

let depth = 0;
let endIdx = -1;
for (let i = startIdx; i < c.length; i++) {
  if (c[i] === '{') depth++;
  else if (c[i] === '}') {
    depth--;
    if (depth === 0) { endIdx = i + 1; break; }
  }
}
if (endIdx === -1) { console.error('Method end not found'); process.exit(1); }

const NEW_METHOD = `_pickAndScanId() async {
    setState(() { _scanError = null; });

    // Use FilePicker – supports JPEG, PNG, WebP, BMP, TIFF, HEIC, and PDF
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif', 'bmp', 'tiff', 'gif', 'pdf'],
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return; // cancelled

    final picked = result.files.first;
    final bytes  = picked.bytes;
    if (bytes == null || bytes.isEmpty) {
      setState(() => _scanError = 'Could not read the selected file. Please try again.');
      return;
    }

    // Determine MIME type from extension
    final ext = (picked.extension ?? 'jpg').toLowerCase();
    final mimeMap = {
      'jpg': 'image/jpeg', 'jpeg': 'image/jpeg',
      'png': 'image/png',  'webp': 'image/webp',
      'heic': 'image/heic', 'heif': 'image/heic',
      'bmp': 'image/bmp',  'tiff': 'image/tiff', 'gif': 'image/gif',
      'pdf': 'application/pdf',
    };
    final mimeType = mimeMap[ext] ?? 'image/jpeg';
    final isPdf    = mimeType == 'application/pdf';

    setState(() {
      // Show preview for images; for PDFs show placeholder (can't render PDF natively)
      _idImageBytes = isPdf ? null : bytes;
      _isScanning   = true;
      _scanStatus   = isPdf
          ? 'Reading PDF document...'
          : 'Uploading ID to verification service...';
    });

    try {
      setState(() => _scanStatus = 'Analysing document with AI...');

      const backendUrl = 'http://localhost:4000/api/passport/verify-id';

      final request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: picked.name.isNotEmpty ? picked.name : 'id_document.$ext',
      ));
      request.headers['Accept'] = 'application/json';
      final gemKey = GeminiService.instance.apiKey;
      if (gemKey.isNotEmpty) request.headers['X-Gemini-Key'] = gemKey;

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final body     = await streamed.stream.bytesToString();
      final jsonResp = jsonDecode(body) as Map<String, dynamic>;

      if (!mounted) return;

      if (streamed.statusCode == 422) {
        final reason = jsonResp['reason'] as String? ??
            'Document not recognised as a valid government ID.';
        setState(() {
          _isScanning = false;
          _scanError  = 'ID Rejected: $reason';
        });
        return;
      }

      if (streamed.statusCode != 200) {
        final err = jsonResp['error'] as String? ?? 'Unknown server error';
        setState(() {
          _isScanning = false;
          _scanError  = 'Verification error (\${streamed.statusCode}): $err';
        });
        return;
      }

      setState(() => _scanStatus = 'Extracting details...');
      await Future.delayed(const Duration(milliseconds: 300));

      final name     = jsonResp['name']       as String? ?? '';
      final dob      = jsonResp['dateOfBirth'] as String? ?? '';
      final idNumber = jsonResp['idNumber']    as String? ?? '';
      final rawType  = jsonResp['idType']      as String? ?? 'id';
      final idType   = rawType.replaceAll('_', ' ')
          .split(' ')
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' ');

      // For PDF, show a document icon placeholder after success
      if (isPdf && mounted) {
        setState(() => _scanStatus = '\$idType verified from PDF');
      }

      setState(() {
        _isScanning    = false;
        _nameCtrl.text = name;
        _dobCtrl.text  = dob;
        _scannedId     = idNumber.isNotEmpty ? idNumber : 'MED-UNREADABLE';
        _step          = 3;
        _scanStatus    = '\$idType verified successfully';
      });

    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      setState(() {
        _isScanning = false;
        _scanError  = msg.contains('SocketException') || msg.contains('Connection refused')
            ? 'Cannot reach verification server.\\nMake sure the backend is running on port 4000.'
            : 'Verification failed: \${msg.split('\\n').first}';
      });
    }
  }`;

c = c.slice(0, startIdx) + NEW_METHOD + c.slice(endIdx);
fs.writeFileSync(f, c, 'utf8');
console.log('_pickAndScanId updated. Size:', c.length);
