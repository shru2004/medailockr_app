// ─── Emergency QR Screen + Emergency ID Modal ────────────────────────────────
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

// ─── Static QR payload ───────────────────────────────────────────────────────
const _kQrData = '''{"name":"Aarav Sharma","dob":"1990-03-15","blood":"O+","allergies":["Penicillin","NSAIDs"],"conditions":["Hypertension"],"medications":["Amlodipine 5mg"],"emergency_contact":"+91 98765 43210","medai_id":"MED-2025-0042-IN"}''';
const _kEmergencyLink = 'https://medailockr.app/emergency/MED-2025-0042-IN';

// ─── Public helper — show the modal dialog ───────────────────────────────────
void showEmergencyIdModal(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _EmergencyIdModal(),
  );
}

// ─── Full-screen fallback route (passport-qr_code) ───────────────────────────
class EmergencyQrScreen extends StatelessWidget {
  const EmergencyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-show the modal on top of a minimal scaffold page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) showEmergencyIdModal(context);
    });
    return PageWrapper(
      title: 'Emergency QR',
      child: const SizedBox.shrink(),
    );
  }
}

// ─── Emergency ID Modal ───────────────────────────────────────────────────────
class _EmergencyIdModal extends StatefulWidget {
  const _EmergencyIdModal();
  @override
  State<_EmergencyIdModal> createState() => _EmergencyIdModalState();
}

class _EmergencyIdModalState extends State<_EmergencyIdModal> {
  bool _authenticated = false;
  int _countdown = 30;
  Timer? _timer;
  bool _copied = false;

  void _authenticate() {
    setState(() => _authenticated = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_countdown <= 1) {
          _countdown = 30;
        } else {
          _countdown--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _copyLink() async {
    await Clipboard.setData(const ClipboardData(text: _kEmergencyLink));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header row ────────────────────────────────────────────────
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Emergency ID',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.close, size: 16, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 24),

              // ── Body ─────────────────────────────────────────────────────
              _authenticated ? _buildQrView() : _buildAuthView(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Auth gate ─────────────────────────────────────────────────────
  Widget _buildAuthView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lock icon with shield badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded, size: 36, color: Color(0xFF3B82F6)),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.verified_user_rounded, size: 20, color: Color(0xFF22C55E)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Protected Health ID',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 8),
        const Text(
          'This QR code contains sensitive medical data including allergies and conditions.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _authenticate,
            icon: const Icon(Icons.fingerprint, size: 22),
            label: const Text('Authenticate to Reveal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Biometric authentication simulated for demo',
          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  // ── Step 2: QR revealed ────────────────────────────────────────────────────
  Widget _buildQrView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR code card with LIVE badge
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: QrImageView(
                data: _kQrData,
                version: QrVersions.auto,
                size: 190,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            // LIVE badge
            Positioned(
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Countdown
        Text(
          '${_countdown}s',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Security token refreshes automatically',
          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 20),
        // Copy Emergency Link
        TextButton.icon(
          onPressed: _copyLink,
          icon: Icon(
            _copied ? Icons.check_circle_outline_rounded : Icons.copy_outlined,
            size: 16,
            color: const Color(0xFF3B82F6),
          ),
          label: Text(
            _copied ? 'Copied!' : 'Copy Emergency Link',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF3B82F6)),
          ),
        ),
      ],
    );
  }
}

// ─── Legacy info row (kept for potential reuse) ───────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon; final String label, val; final Color color;
  const _InfoRow(this.icon, this.label, this.val, this.color);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)), Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary))])]),
  );
}
