// ─── AI Health Passport Screen ─────────────────────────────────────────────
//          + FeatureGrid.tsx + ProfileCard.tsx

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart'; // kept for other screens
import 'package:provider/provider.dart';
import '../../services/gemini_service.dart';
import '../../providers/navigation_provider.dart';
import 'emergency_qr_screen.dart' show showEmergencyIdModal;
import 'compatibility_check_screen.dart' show showDrugSafetyModal;
import 'health_credits_screen.dart' show showHealthCreditsModal;
import 'blockchain_security_screen.dart' show showBlockchainLogModal;
import 'wearable_integration_screen.dart' show showWearableSyncModal;
import 'digital_discharge_screen.dart' show showDigitalDischargeModal;

// ─── Tailwind colour constants ───────────────────────────────────────────────
const _kBg      = Color(0xFFF3F4F6); // bg-[#f3f4f6]
const _kBlue900 = Color(0xFF1E3A8A); // text-blue-900
const _kBlue950 = Color(0xFF172554); // text-blue-950
const _kBlue700 = Color(0xFF1D4ED8); // text-blue-700
const _kBlue300 = Color(0xFF93C5FD); // text-blue-300
const _kBlue100 = Color(0xFFDBEAFE); // from-blue-100
const _kBlue200 = Color(0xFFBFDBFE); // to-blue-200
const _kBlue50  = Color(0xFFEFF6FF); // border-blue-50
const _kGray100 = Color(0xFFF3F4F6); // border-gray-100

// ─── Feature data (mirrors FeatureGrid.tsx features array) ──────────────────
class _Feature {
  final String label;
  final IconData icon;
  final String route;
  const _Feature(this.label, this.icon, this.route);
}

const _features = <_Feature>[
  _Feature('Medical History Vault',     Icons.lock_outline,           'passport-vault'),
  _Feature('Emergency QR Code',         Icons.qr_code_2,              'passport-qr_code'),
  _Feature('Cross-border Data Sharing', Icons.language,               'passport-sharing'),
  _Feature('Compatibility Check',       Icons.phone_android,          'passport-compatibility'),
  _Feature('Health Credits',            Icons.share_outlined,         'passport-credits'),
  _Feature('Blockchain Security',       Icons.verified_user_outlined, 'passport-security'),
  _Feature('Voice Access',              Icons.mic_none,               'passport-voice'),
  _Feature('Wearable Integration',      Icons.watch_outlined,         'passport-wearable'),
  _Feature('Discharge Process',          Icons.assignment_outlined,    'passport-discharge_process'),
];

// ─── Main screen ─────────────────────────────────────────────────────────────
class PassportScreen extends StatefulWidget {
  const PassportScreen({super.key});

  @override
  State<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends State<PassportScreen> {
    bool _onboardingDone = false;
  String _name = 'John Smith';
  String _id   = '1294 5678 6012';
  String _dob  = '01/12/1995';

  void _completeOnboarding(String name, String id, String dob) {
    setState(() {
      _onboardingDone = true;
      _name = name.isNotEmpty ? name : _name;
      _id   = id.isNotEmpty   ? id   : _id;
      _dob  = dob.isNotEmpty  ? dob  : _dob;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboardingDone) {
      return _OnboardingFlow(onComplete: _completeOnboarding);
    }

    final nav = context.read<NavigationProvider>();

    return Container(
      color: _kBg,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 0,
                          child: IconButton(
                            onPressed: nav.goBack,
                            icon: const Icon(Icons.chevron_left, size: 22),
                            color: _kBlue700,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        const Text(
                          'AI Health Passport',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: _kBlue900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── ProfileCard ───────────────────────────────────────────
                  _ProfileCard(
                    name: _name,
                    id: _id,
                    dob: _dob,
                    onSave: (n, i, d) => setState(() {
                      _name = n; _id = i; _dob = d;
                    }),
                  ),

                  const SizedBox(height: 16),

                  // ── Secure ID Module ──────────────────────────────────────
                  const _SecureIDModule(),

                  const SizedBox(height: 24),

                  // ── FeatureGrid ───────────────────────────────────────────
                  _FeatureGrid(onTap: (route) {
                    if (route == 'passport-qr_code') {
                      showEmergencyIdModal(context);
                    } else if (route == 'passport-compatibility') {
                      showDrugSafetyModal(context);
                    } else if (route == 'passport-credits') {
                      showHealthCreditsModal(context);
                    } else if (route == 'passport-security') {
                      showBlockchainLogModal(context);
                    } else if (route == 'passport-wearable') {
                      showWearableSyncModal(context);
                    } else if (route == 'passport-discharge_process') {
                      showDigitalDischargeModal(context);
                    } else {
                      nav.navigateTo(route);
                    }
                  }),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── OnboardingFlow ──────────────────────────────────────────────────────────
// Mirrors OnboardingFlow.tsx — 5 steps: Welcome → Verify → Info → Voice → Done
class _OnboardingFlow extends StatefulWidget {
  final void Function(String name, String id, String dob) onComplete;
  const _OnboardingFlow({required this.onComplete});

  @override
  State<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<_OnboardingFlow> {
  int _step = 1;
  bool _isScanning = false;
  final _nameCtrl = TextEditingController();
  final _dobCtrl  = TextEditingController();
  String _scannedId     = '';
  String _language      = 'English';
  String _voiceType     = 'Female';
  Uint8List? _idImageBytes;
  bool       _isPdfSelected = false;
  String?    _scanError;
  String     _scanStatus = 'Analyzing ID with AI...';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 5) {
      setState(() => _step++);
    } else {
      widget.onComplete(_nameCtrl.text, _scannedId, _dobCtrl.text);
    }
  }

  Future<void> _pickAndScanId() async {
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
      _idImageBytes    = isPdf ? null : bytes;
      _isPdfSelected   = isPdf;
      _isScanning      = true;
      _scanStatus      = isPdf
          ? 'Reading PDF document...'
          : 'Uploading ID to verification service...';
    });

    try {
      setState(() => _scanStatus = 'Analysing document with AI...');

      final gemKey = GeminiService.instance.apiKey;
      String name = '', dob = '', idNumber = '', idType = 'ID';

      // ── Path A: backend verify-id (preferred when backend Gemini key is set) ──
      bool backendOk = false;
      try {
        const backendUrl = 'http://localhost:4000/api/passport/verify-id';
        final request = http.MultipartRequest('POST', Uri.parse(backendUrl));
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: picked.name.isNotEmpty ? picked.name : 'id_document.$ext',
          contentType: MediaType.parse(mimeType),
        ));
        request.headers['Accept'] = 'application/json';
        if (gemKey.isNotEmpty) request.headers['X-Gemini-Key'] = gemKey;

        final streamed = await request.send().timeout(const Duration(seconds: 20));
        final body     = await streamed.stream.bytesToString();
        final jsonResp = jsonDecode(body) as Map<String, dynamic>;

        if (!mounted) return;

        if (streamed.statusCode == 422) {
          final reason = jsonResp['reason'] as String? ??
              'Document not recognised as a valid government ID.';
          setState(() { _isScanning = false; _scanError = 'ID Rejected: $reason'; });
          return;
        }

        if (streamed.statusCode == 503 || (jsonResp['error'] as String? ?? '').contains('GEMINI_API_KEY')) {
          // Backend has no key — fall through to client-side path
        } else if (streamed.statusCode == 200) {
          name     = jsonResp['name']        as String? ?? '';
          dob      = jsonResp['dateOfBirth'] as String? ?? '';
          idNumber = jsonResp['idNumber']    as String? ?? '';
          final rawType = jsonResp['idType'] as String? ?? 'id';
          idType   = rawType.replaceAll('_', ' ')
              .split(' ')
              .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
              .join(' ');
          backendOk = true;
        } else {
          final err = jsonResp['error'] as String? ?? 'Server error ${streamed.statusCode}';
          setState(() { _isScanning = false; _scanError = 'Verification error: $err'; });
          return;
        }
      } catch (_) {
        // Backend unreachable — fall through to client-side path
      }

      // ── Path B: direct Gemini SDK from Flutter client ─────────────────────
      if (!backendOk) {
        if (!GeminiService.instance.hasKey) {
          setState(() {
            _isScanning = false;
            _scanError  = 'No Gemini API key set.\n'
                'Tap the key icon (⚙) in the app and enter your free API key from '
                'https://aistudio.google.com/app/apikey — then try again.';
          });
          return;
        }
        setState(() => _scanStatus = 'Reading ID with Gemini AI...');
        final result = await GeminiService.instance
            .scanGovernmentId(bytes.toList(), mimeType);
        name     = result['name']     ?? '';
        dob      = result['dob']      ?? '';
        idNumber = result['idNumber'] ?? '';
        final rawType = result['idType'] ?? 'id';
        idType   = rawType.replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
            .join(' ');
      }

      if (!mounted) return;
      setState(() => _scanStatus = 'Extracting details...');
      await Future.delayed(const Duration(milliseconds: 300));

      // For PDF, show a document icon placeholder after success
      if (isPdf && mounted) {
        setState(() => _scanStatus = '$idType verified from PDF');
      }

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
            : 'Verification failed: ${msg.split('\n').first}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // fixed inset-0 bg-white z-[100] flex flex-col
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Progress bar – h-1 bg-gray-100
          SafeArea(
            bottom: false,
            child: Container(
              height: 4,
              color: const Color(0xFFF3F4F6),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _step / 5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  color: const Color(0xFF2563EB), // bg-blue-600
                ),
              ),
            ),
          ),

          // Content – flex-1 overflow-y-auto p-6 max-w-md mx-auto w-full
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildStep(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1: return _step1();
      case 2: return _step2();
      case 3: return _step3();
      case 4: return _step4();
      case 5: return _step5();
      default: return const SizedBox();
    }
  }

  // ── Step 1: Welcome ────────────────────────────────────────────────────────
  Widget _step1() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(height: 40),
      // w-24 h-24 bg-blue-100 text-blue-600 rounded-full
      Container(
        width: 96, height: 96,
        decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
        child: const Icon(Icons.shield_outlined, size: 48, color: Color(0xFF2563EB)),
      ),
      const SizedBox(height: 24),
      const Text(
        'Welcome to AI Health Passport',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      const Text(
        "Your secure, decentralized medical identity. Let's get you set up in just a few steps.",
        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      _blueBtn('Get Started', _next),
    ],
  );

  // ── Step 2: Verify Identity ────────────────────────────────────────────────
  Widget _step2() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Verify Identity', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      const SizedBox(height: 8),
      const Text('We need to verify your government-issued ID to create your secure health profile.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      const SizedBox(height: 32),
      _isScanning ? _scanningWidget() : _scanTapWidget(),
      if (_scanError != null) ...[          
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            border: Border.all(color: const Color(0xFFFCA5A5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
              const SizedBox(width: 8),
              Expanded(child: Text(_scanError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _blueBtn('Try Again', _pickAndScanId),
      ],
    ],
  );

  Widget _scanningWidget() => Column(
    children: [
      // Show picked image on top if available
      if (_idImageBytes != null)
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12),
          ),
          child: Image.memory(_idImageBytes!, width: double.infinity, height: 160, fit: BoxFit.cover),
        )
      else if (_isPdfSelected)
        Container(
          width: double.infinity, height: 160,
          decoration: const BoxDecoration(
            color: Color(0xFF1E3A5F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12),
            ),
          ),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF60A5FA), size: 48),
            SizedBox(height: 8),
            Text('PDF Document Selected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Tap to re-scan', style: TextStyle(color: Color(0xFF93C5FD), fontSize: 12)),
          ]),
        ),
      Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF3B82F6), width: 2),
          borderRadius: _idImageBytes != null
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
            : BorderRadius.circular(12),
          color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 2),
            ),
            const SizedBox(height: 8),
            Text(_scanStatus, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w500, fontSize: 12)),
          ]),
        ),
      ),
    ],
  );

  Widget _scanTapWidget() => GestureDetector(
    onTap: _pickAndScanId,
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: _idImageBytes != null
          ? Stack(
              children: [
                Image.memory(_idImageBytes!, width: double.infinity, height: 200, fit: BoxFit.cover),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Tap to re-scan', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox(
              height: 180,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.camera_alt_outlined, size: 48, color: Color(0xFF9CA3AF)),
                SizedBox(height: 12),
                Text('Tap to scan ID document', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
                SizedBox(height: 4),
                Text('Supports Aadhaar, PAN, passport, driving licence, voter ID, national ID & more • JPEG, PNG, PDF', style: TextStyle(fontSize: 11, color: Color(0xFFD1D5DB))),
              ]),
            ),
    ),
  );

  // ── Step 3: Basic Information ──────────────────────────────────────────────
  Widget _step3() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Basic Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      const SizedBox(height: 8),
      const Text('Please confirm your details extracted from your ID.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      const SizedBox(height: 32),

      // Full Name
      const Text('FULL NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.8)),
      const SizedBox(height: 6),
      TextField(
        controller: _nameCtrl,
        decoration: _inputDec('John Doe', prefixIcon: const Icon(Icons.person_outline, size: 18, color: Color(0xFF9CA3AF))),
      ),
      const SizedBox(height: 16),

      // Date of Birth
      const Text('DATE OF BIRTH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.8)),
      const SizedBox(height: 6),
      TextField(
        controller: _dobCtrl,
        decoration: _inputDec('YYYY-MM-DD'),
        keyboardType: TextInputType.datetime,
      ),
      const SizedBox(height: 16),

      // Scanned ID (disabled)
      const Text('VERIFIED ID NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.8)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(_scannedId, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF6B7280))),
      ),
      const SizedBox(height: 24),
      _blueBtn('Continue', _next),
    ],
  );

  // ── Step 4: Voice Assistant ────────────────────────────────────────────────
  Widget _step4() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Voice Assistant', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      const SizedBox(height: 8),
      const Text('Customize how your AI Health Assistant communicates with you.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      const SizedBox(height: 32),

      // Language
      const Row(children: [
        Icon(Icons.language, size: 14, color: Color(0xFF6B7280)),
        SizedBox(width: 4),
        Text('LANGUAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.8)),
      ]),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.2,
        children: ['English', 'Spanish', 'French', 'Mandarin'].map((lang) {
          final sel = _language == lang;
          return GestureDetector(
            onTap: () => setState(() => _language = lang),
            child: Container(
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFEFF6FF) : Colors.white,
                border: Border.all(color: sel ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(lang, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: sel ? const Color(0xFF1D4ED8) : const Color(0xFF4B5563))),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 24),

      // Voice Type
      const Row(children: [
        Icon(Icons.mic_none, size: 14, color: Color(0xFF6B7280)),
        SizedBox(width: 4),
        Text('VOICE TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.8)),
      ]),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.8,
        children: ['Female', 'Male', 'Neutral'].map((v) {
          final sel = _voiceType == v;
          return GestureDetector(
            onTap: () => setState(() => _voiceType = v),
            child: Container(
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFEFF6FF) : Colors.white,
                border: Border.all(color: sel ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(v, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: sel ? const Color(0xFF1D4ED8) : const Color(0xFF4B5563))),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 24),
      _blueBtn('Continue', _next),
    ],
  );

  // ── Step 5: Setup Complete ─────────────────────────────────────────────────
  Widget _step5() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(height: 40),
      // w-24 h-24 bg-green-100 text-green-600 rounded-full
      Container(
        width: 96, height: 96,
        decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
        child: const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF16A34A)),
      ),
      const SizedBox(height: 24),
      const Text('Setup Complete!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827)), textAlign: TextAlign.center),
      const SizedBox(height: 8),
      const Text('Your AI Health Passport is ready. Your data is encrypted and secured on the blockchain.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
      const SizedBox(height: 32),
      // Next steps info box – bg-blue-50 border border-blue-100 rounded-xl p-4
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          border: Border.all(color: const Color(0xFFBFDBFE)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.monitor_heart_outlined, size: 20, color: Color(0xFF2563EB)),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Next Steps', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A), fontSize: 13)),
              SizedBox(height: 4),
              Text('Connect your wearable device to start tracking your vitals and earning Health Credits.', style: TextStyle(fontSize: 11, color: Color(0xFF1D4ED8))),
            ])),
          ],
        ),
      ),
      const SizedBox(height: 32),
      _blueBtn('Go to Dashboard', _next),
    ],
  );

  // ── Shared helpers ─────────────────────────────────────────────────────────
  Widget _blueBtn(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    ),
  );

  InputDecoration _inputDec(String hint, {Widget? prefixIcon}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
  );
}

// ─── ProfileCard ─────────────────────────────────────────────────────────────
// Mirrors ProfileCard.tsx
class _ProfileCard extends StatefulWidget {
  final String name, id, dob;
  final void Function(String name, String id, String dob) onSave;
  const _ProfileCard({
    required this.name,
    required this.id,
    required this.dob,
    required this.onSave,
  });

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  bool _editing = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _idCtrl;
  late final TextEditingController _dobCtrl;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _idCtrl   = TextEditingController(text: widget.id);
    _dobCtrl  = TextEditingController(text: widget.dob);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  void _save() {
    widget.onSave(_nameCtrl.text, _idCtrl.text, _dobCtrl.text);
    setState(() => _editing = false);
  }

  void _cancel() {
    _nameCtrl.text = widget.name;
    _idCtrl.text   = widget.id;
    _dobCtrl.text  = widget.dob;
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    // bg-gradient-to-br from-blue-100 to-blue-200 rounded-[2rem] p-6
    // relative overflow-hidden shadow-sm border border-blue-50
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kBlue100, _kBlue200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32), // rounded-[2rem]
        border: Border.all(color: _kBlue50),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Watermark – absolute bottom-3 left-6
          Positioned(
            bottom: 12,
            left: 24,
            child: Text(
              'NITTEAL DECODER OV',
              style: TextStyle(
                fontSize: 7,
                fontFamily: 'monospace',
                color: _kBlue300.withValues(alpha: 0.6),
                letterSpacing: 3.2,
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(24), // p-6
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Photo – w-24 h-24 rounded-full border-[3px] border-white
                GestureDetector(
                  onTap: _editing ? _pickImage : null,
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6),
                          ],
                        ),
                        child: ClipOval(
                          child: _imageBytes != null
                              ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                              : Image.network(
                                  'https://picsum.photos/200/200',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFE5E7EB),
                                    child: const Icon(Icons.person, size: 48, color: Color(0xFF9CA3AF)),
                                  ),
                                ),
                        ),
                      ),
                      // Camera overlay when editing
                      if (_editing)
                        Positioned.fill(
                          child: ClipOval(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.4),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                      // Small edit icon at bottom-LEFT when NOT editing
                      if (!_editing)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              _nameCtrl.text = widget.name;
                              _idCtrl.text   = widget.id;
                              _dobCtrl.text  = widget.dob;
                              setState(() => _editing = true);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4),
                                ],
                              ),
                              child: const Icon(Icons.edit, size: 14, color: Color(0xFF2563EB)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 24), // gap-6

                // Text block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "MedAILockr Digital ID" inline with pencil icon
                      GestureDetector(
                        onTap: () {
                          _nameCtrl.text = widget.name;
                          _idCtrl.text   = widget.id;
                          _dobCtrl.text  = widget.dob;
                          setState(() => _editing = true);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'MedAILockr Digital ID',
                              style: TextStyle(
                                color: _kBlue900,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.edit_outlined, size: 15, color: _kBlue700),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_editing) ...[
                        _field(_nameCtrl, 'Name', bold: true, size: 20),
                        const SizedBox(height: 6),
                        _field(_idCtrl, 'ID Number'),
                        const SizedBox(height: 6),
                        _field(_dobCtrl, 'Date of Birth'),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: _btn('Save',   Icons.check, _kBlue700,     Colors.white, _save)),
                          const SizedBox(width: 8),
                          Expanded(child: _btn('Cancel', Icons.close,  Colors.white, _kBlue700,   _cancel, border: _kBlue200)),
                        ]),
                      ] else ...[
                        // text-blue-950 font-bold text-2xl
                        Text(
                          widget.name,
                          style: const TextStyle(
                            color: _kBlue950,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                        // text-blue-900 font-medium text-sm
                        Text(
                          'ID ${widget.id}',
                          style: const TextStyle(color: _kBlue900, fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                        Text(
                          'Date of Birth ${widget.dob}',
                          style: const TextStyle(color: _kBlue900, fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // (edit is now inline next to title text – no floating button needed)
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {bool bold = false, double size = 13}) =>
    TextField(
      controller: ctrl,
      style: TextStyle(
        color: _kBlue950,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        fontSize: size,
      ),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFBFDBFE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
      ),
    );

  Widget _btn(String label, IconData icon, Color bg, Color fg, VoidCallback onTap, {Color? border}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: border != null ? Border.all(color: border) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
}

// ─── SecureIDModule ───────────────────────────────────────────────────────────
// Mirrors SecureIDModule.tsx – Verified Health ID card with lock/unlock
class _SecureIDModule extends StatefulWidget {
  const _SecureIDModule();

  @override
  State<_SecureIDModule> createState() => _SecureIDModuleState();
}

class _SecureIDModuleState extends State<_SecureIDModule> {
  bool _locked = true;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _locked ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _locked ? Icons.lock_outline : Icons.lock_open_outlined,
                  size: 20,
                  color: _locked ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Secure ID Management',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF111827))),
                    Text(
                      _locked ? 'Identity locked & protected' : 'Identity unlocked for sharing',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _locked = !_locked;
                  if (_locked) _showDetails = false;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _locked ? const Color(0xFFF3F4F6) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _locked ? 'Unlock' : 'Lock',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _locked ? const Color(0xFF374151) : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Verified ID Card box
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _locked ? const Color(0xFFF9FAFB) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _locked ? const Color(0xFFF3F4F6) : const Color(0xFFDBEAFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user_outlined,
                        size: 16, color: _locked ? const Color(0xFF9CA3AF) : const Color(0xFF3B82F6)),
                    const SizedBox(width: 6),
                    const Text('Verified Health ID',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                    const Spacer(),
                    Icon(Icons.check_circle, size: 14, color: const Color(0xFF22C55E)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _showDetails && !_locked ? 'MED-8492-XXXX-1923' : '••••-••••-••••-1923',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _locked ? null : () => setState(() => _showDetails = !_showDetails),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _locked ? Colors.transparent : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _showDetails && !_locked ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 16,
                          color: _locked ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  label: 'Share ID',
                  icon: Icons.share_outlined,
                  enabled: !_locked,
                  primary: true,
                  onTap: () => showDialog(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.5),
                    builder: (_) => const _GlobalAccessModal(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  label: 'Manage Keys',
                  icon: Icons.key_outlined,
                  enabled: !_locked,
                  primary: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required bool enabled,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: !enabled
              ? const Color(0xFFF3F4F6)
              : primary
                  ? const Color(0xFF2563EB)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: !enabled
                ? const Color(0xFFF3F4F6)
                : primary
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE5E7EB),
          ),
          boxShadow: enabled && primary
              ? [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15,
                color: !enabled
                    ? const Color(0xFF9CA3AF)
                    : primary
                        ? Colors.white
                        : const Color(0xFF374151)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: !enabled
                    ? const Color(0xFF9CA3AF)
                    : primary
                        ? Colors.white
                        : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Global Access Modal ─────────────────────────────────────────────────────
// Mirrors FeatureModal.tsx data_sharing case
class _GlobalAccessModal extends StatefulWidget {
  const _GlobalAccessModal();
  @override
  State<_GlobalAccessModal> createState() => _GlobalAccessModalState();
}

class _Share {
  final int id;
  final String recipient;
  final List<String> types;
  final String duration;
  _Share({required this.id, required this.recipient, required this.types, required this.duration});
}

class _GlobalAccessModalState extends State<_GlobalAccessModal> {
  List<_Share> _shares = [
    _Share(id: 1, recipient: 'Dr. Sarah Bennett',      types: ['Medications', 'History'],            duration: 'Indefinite'),
    _Share(id: 2, recipient: 'City General Emergency', types: ['Allergies', 'Vitals', 'Medications'], duration: '24 Hours'),
  ];

  // tag colours matching screenshot
  static const _tagColors = {
    'Medications': Color(0xFFDDD6FE), // purple-200
    'History':     Color(0xFFFCE7F3), // pink-100
    'Allergies':   Color(0xFFFEF3C7), // amber-100
    'Vitals':      Color(0xFFDBEAFE), // blue-100
  };
  static const _tagTextColors = {
    'Medications': Color(0xFF6D28D9),
    'History':     Color(0xFF9D174D),
    'Allergies':   Color(0xFF92400E),
    'Vitals':      Color(0xFF1E40AF),
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title row
            Row(
              children: [
                const Expanded(
                  child: Text('Global Access',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Privacy Shield banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Color(0xFFDBEAFE), shape: BoxShape.circle),
                    child: const Icon(Icons.verified_user_outlined, size: 20, color: Color(0xFF1D4ED8)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Privacy Shield',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E3A8A))),
                        Text('You are in control.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF1D4ED8))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('New Grant',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section label
            const Text('ACTIVE PERMISSIONS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Color(0xFF9CA3AF))),

            const SizedBox(height: 10),

            // Share cards
            ..._shares.map((share) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(share.recipient,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF111827))),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 11, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 3),
                                  Text('Expires: ${share.duration}',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _shares.removeWhere((s) => s.id == share.id)),
                          child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: share.types.map((tag) {
                        final bg   = _tagColors[tag]   ?? const Color(0xFFF3F4F6);
                        final text = _tagTextColors[tag] ?? const Color(0xFF374151);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                          child: Text(tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
        ),
      ),
    );
  }
}

// ─── FeatureGrid ─────────────────────────────────────────────────────────────
// Mirrors FeatureGrid.tsx – grid-cols-3, white square cards, blue-900 icons
class _FeatureGrid extends StatelessWidget {
  final void Function(String route) onTap;
  const _FeatureGrid({required this.onTap});

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 3,            // grid-cols-3
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 12,          // gap-3
    crossAxisSpacing: 12,
    childAspectRatio: 1.0,        // aspect-square
    children: _features
        .map((f) => _FeatureTile(feature: f, onTap: () => onTap(f.route)))
        .toList(),
  );
}

class _FeatureTile extends StatefulWidget {
  final _Feature feature;
  final VoidCallback onTap;
  const _FeatureTile({required this.feature, required this.onTap});

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // bg-white rounded-2xl p-3 flex flex-col items-center justify-center
    // gap-2 aspect-square shadow-sm border border-gray-100
    // hover:border-blue-200 hover:shadow-md active:scale-95
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12), // p-3
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // rounded-2xl
            border: Border.all(
              color: _hovered ? _kBlue200 : _kGray100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.04),
                blurRadius: _hovered ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon – text-blue-900 size={32}
              Icon(widget.feature.icon, size: 28, color: _kBlue900),
              const SizedBox(height: 8), // gap-2
              // Label – text-[10px] font-semibold text-blue-900 text-center
              Text(
                widget.feature.label,
                style: const TextStyle(
                  color: _kBlue900,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

