// ─── Digital Discharge Screen + Digital Discharge Modal ──────────────────────
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

// ─── Public helper ────────────────────────────────────────────────────────────
void showDigitalDischargeModal(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _DigitalDischargeModal(),
  );
}

// ─── Digital Discharge Modal ──────────────────────────────────────────────────
class _DigitalDischargeModal extends StatefulWidget {
  const _DigitalDischargeModal();
  @override
  State<_DigitalDischargeModal> createState() => _DigitalDischargeModalState();
}

class _DigitalDischargeModalState extends State<_DigitalDischargeModal> {
  int _tab = 0; // 0=Tracker 1=Billing 2=Documents
  late int _secondsLeft;
  Timer? _timer;

  static const _kOrange  = Color(0xFFF97316);
  static const _kGray900 = Color(0xFF111827);
  static const _kGray500 = Color(0xFF6B7280);
  static const _kGray200 = Color(0xFFE5E7EB);
  static const _kGray100 = Color(0xFFF3F4F6);
  static const _kGreen   = Color(0xFF22C55E);
  static const _kBlue    = Color(0xFF3B82F6);

  static const _tabs = ['Tracker', 'Billing', 'Documents'];

  // Checklist items: label, badge, description, status (done/pending)
  static const _checklist = [
    _CheckItem('Clinical Summary',  'Signed',      'Doctor has digitally signed the discharge summary.',      true),
    _CheckItem('Pharmacy & Labs',   'Cleared',     'All dues cleared and pending reports delivered.',         true),
    _CheckItem('Insurance Approval','Approved',    'Pre-authorization request sent digitally.',               true),
    _CheckItem('Final Billing',     'Calculating', 'System auto-calculating final payable amount.',           false),
  ];

  @override
  void initState() {
    super.initState();
    _secondsLeft = 44 * 60 + 38;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 620),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
              child: Row(children: [
                const Expanded(
                  child: Text('Digital Discharge',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kGray900)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(color: _kGray100, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: _kGray500),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // ── Status Card ─────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('DISCHARGE STATUS',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                letterSpacing: 1.2, color: Colors.white70)),
                        const SizedBox(height: 5),
                        const Text('Processing...',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.timer_outlined, size: 13, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text('Est. Time: $_timeLabel',
                              style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ]),
                      ])),
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const _SpinnerIcon(),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // ── Tab switcher ────────────────────────────────────────
                  Container(
                    height: 38,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: _kGray100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: List.generate(_tabs.length, (i) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _tab == i ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _tab == i
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4, offset: const Offset(0, 1))]
                                : null,
                          ),
                          child: Text(_tabs[i],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _tab == i ? _kGray900 : _kGray500,
                              )),
                        ),
                      ),
                    ))),
                  ),
                  const SizedBox(height: 18),

                  if (_tab == 0) _buildTracker(),
                  if (_tab == 1) _buildBilling(),
                  if (_tab == 2) _buildDocuments(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TRACKER ──────────────────────────────────────────────────────────────
  Widget _buildTracker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: const [
        Icon(Icons.show_chart_rounded, size: 16, color: _kBlue),
        SizedBox(width: 6),
        Text('Discharge Checklist',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kGray900)),
      ]),
      const SizedBox(height: 16),

      // Zigzag alternating layout
      ...List.generate(_checklist.length, (i) {
        final item = _checklist[i];
        final isRight = i.isOdd;
        final isLast  = i == _checklist.length - 1;

        final cardColor  = item.done ? _kGreen : _kOrange;
        final badgeBg    = item.done
            ? _kGreen.withValues(alpha: 0.12)
            : _kOrange.withValues(alpha: 0.12);
        final badgeText  = item.done ? _kGreen : _kOrange;

        final card = Container(
          width: 155,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kGray200),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(item.label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kGray900))),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                child: Text(item.badge,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: badgeText)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(item.description,
                style: const TextStyle(fontSize: 10, color: _kGray500, height: 1.4)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: item.done ? _kGreen : _kGray200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.done ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                  size: 13,
                  color: item.done ? Colors.white : _kGray500,
                ),
              ),
            ),
          ]),
        );

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: Row(
            mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [card],
          ),
        );
      }),
    ]);
  }

  // ── BILLING ───────────────────────────────────────────────────────────────
  Widget _buildBilling() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 44, height: 44,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: const AlwaysStoppedAnimation(_kBlue),
          backgroundColor: _kBlue.withValues(alpha: 0.12),
        ),
      ),
      const SizedBox(height: 16),
      const Text('Calculating final bill...',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kGray900)),
      const SizedBox(height: 6),
      const Text('Waiting for insurance approval and final\npharmacy clearance.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: _kGray500, height: 1.5)),
    ]),
  );

  // ── DOCUMENTS ─────────────────────────────────────────────────────────────
  Widget _buildDocuments() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.description_outlined, size: 48, color: _kGray500),
      const SizedBox(height: 14),
      const Text('Documents Locked',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kGray900)),
      const SizedBox(height: 6),
      const Text('Complete the payment process to unlock your\ndigital discharge kit.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: _kGray500, height: 1.5)),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: () => setState(() => _tab = 1),
        child: const Text('Go to Billing',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kBlue)),
      ),
    ]),
  );
}

// ─── Animated spinner icon (rotates continuously) ─────────────────────────────
class _SpinnerIcon extends StatefulWidget {
  const _SpinnerIcon();
  @override
  State<_SpinnerIcon> createState() => _SpinnerIconState();
}

class _SpinnerIconState extends State<_SpinnerIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _ctrl,
    child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
  );
}

// ─── Checklist item data class ───────────────────────────────────────────────
class _CheckItem {
  final String label, badge, description;
  final bool done;
  const _CheckItem(this.label, this.badge, this.description, this.done);
}

// ─────────────────────────────────────────────────────────────────────────────
class DigitalDischargeScreen extends StatelessWidget {
  const DigitalDischargeScreen({super.key});

  static const _discharges = [
    _Discharge('Apollo Hospital', 'Jun 10–14, 2025', 'Hypertension Management', '4 days', ['Amlodipine 5mg × 30', 'Low-sodium diet', 'BP check weekly', 'Follow-up in 2 weeks']),
    _Discharge('Max Healthcare', 'Feb 2–3, 2025', 'Viral Fever', '2 days', ['Paracetamol 500mg', 'Rest 5 days', 'Adequate hydration']),
  ];

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Digital Discharge',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2))),
            child: const Text('Smart AI-generated discharge summaries with automatic care instructions and follow-up reminders.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          ),
          const SizedBox(height: 16),
          ..._discharges.map((d) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.local_hospital_rounded, color: Color(0xFF6366F1), size: 22)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.hospital, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(d.duration, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(d.stay, style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1), fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 10),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.bgColor, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.medical_information_rounded, size: 14, color: AppColors.textSecondary), const SizedBox(width: 6), Text('Diagnosis: ${d.diagnosis}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))])),
              const SizedBox(height: 8),
              const Text('Discharge Instructions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              ...d.instructions.map((ins) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_rounded, size: 13, color: Color(0xFF10B981)), const SizedBox(width: 6), Expanded(child: Text(ins, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)))]))),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _Discharge {
  final String hospital, duration, diagnosis, stay;
  final List<String> instructions;
  const _Discharge(this.hospital, this.duration, this.diagnosis, this.stay, this.instructions);
}
