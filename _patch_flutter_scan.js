const fs = require('fs');
const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/flutter_mediqly/lib/screens/health_passport/passport_screen.dart';
let c = fs.readFileSync(f, 'utf8');

// ── 1. Add http/convert imports ───────────────────────────────────────────
const OLD_IMPORTS = "import 'dart:typed_data';\r\nimport 'package:flutter/material.dart';\r\nimport 'package:image_picker/image_picker.dart';\r\nimport 'package:provider/provider.dart';\r\nimport '../../services/gemini_service.dart';";
const NEW_IMPORTS = `import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';`;

if (!c.includes(OLD_IMPORTS)) {
  console.error('Could not find imports block'); process.exit(1);
}
c = c.replace(OLD_IMPORTS, NEW_IMPORTS);
console.log('Imports updated');

// ── 2. Replace _pickAndScanId method ──────────────────────────────────────
// Find boundaries
const METHOD_START = '_pickAndScanId() async {';
const startIdx = c.indexOf(METHOD_START);
if (startIdx === -1) { console.error('Method start not found'); process.exit(1); }

// Walk to the closing brace of the method (count braces)
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

    final picker = ImagePicker();
    XFile? file;
    try {
      file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1600,
      );
    } catch (_) {
      try {
        file = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      } catch (e) {
        setState(() => _scanError = 'Could not open camera or gallery: $e');
        return;
      }
    }

    if (file == null) return; // user cancelled

    final bytes    = await file.readAsBytes();
    final mimeType = file.mimeType ?? (file.name.endsWith('.png') ? 'image/png' : 'image/jpeg');

    setState(() {
      _idImageBytes = bytes;
      _isScanning   = true;
      _scanStatus   = 'Uploading ID to verification service...';
    });

    try {
      // ── Send to backend for strict AI verification ──────────────────────
      setState(() => _scanStatus = 'Analysing document type...');

      const backendUrl = 'http://localhost:4000/api/passport/verify-id';

      final request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: file.name.isNotEmpty ? file.name : 'id_document.jpg',
      ));
      request.headers['Accept'] = 'application/json';

      final streamed  = await request.send().timeout(const Duration(seconds: 30));
      final body      = await streamed.stream.bytesToString();
      final jsonResp  = jsonDecode(body) as Map<String, dynamic>;

      if (!mounted) return;

      // ── 422 = rejected document type ───────────────────────────────────
      if (streamed.statusCode == 422) {
        final reason = jsonResp['reason'] as String? ??
            'Document not recognised as a valid government ID.';
        setState(() {
          _isScanning = false;
          _scanError =
              'ID Rejected: $reason\n\nOnly passport, driving licence, or national ID are accepted.';
        });
        return;
      }

      // ── 4xx/5xx errors ─────────────────────────────────────────────────
      if (streamed.statusCode != 200) {
        final err = jsonResp['error'] as String? ?? 'Unknown server error';
        setState(() {
          _isScanning = false;
          _scanError  = 'Verification error ($\{streamed.statusCode}): $err';
        });
        return;
      }

      // ── Success ─────────────────────────────────────────────────────────
      setState(() => _scanStatus = 'Extracting name, DOB & ID number...');
      await Future.delayed(const Duration(milliseconds: 400));

      final name     = jsonResp['name']        as String? ?? '';
      final dob      = jsonResp['dateOfBirth']  as String? ?? '';
      final idNumber = jsonResp['idNumber']     as String? ?? '';
      final idType   = (jsonResp['idType']      as String? ?? 'id')
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' ');

      setState(() {
        _isScanning    = false;
        _nameCtrl.text = name;
        _dobCtrl.text  = dob;
        _scannedId     = idNumber.isNotEmpty ? idNumber : 'MED-UNREADABLE';
        _step          = 3;
        _scanStatus    = '$idType verified successfully';
      });

    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      setState(() {
        _isScanning = false;
        _scanError  = msg.contains('SocketException') || msg.contains('Connection refused')
            ? 'Cannot reach verification server.\nMake sure the backend is running on port 4000.'
            : 'Verification failed: $\{msg.split('\\n').first}';
      });
    }
  }`;

c = c.slice(0, startIdx) + NEW_METHOD + c.slice(endIdx);
console.log('_pickAndScanId replaced. File size now:', c.length);

fs.writeFileSync(f, c, 'utf8');
console.log('passport_screen.dart saved.');
