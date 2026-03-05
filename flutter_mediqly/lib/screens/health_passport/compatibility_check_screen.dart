// ─── Compatibility Check Screen + Drug Safety Modal ─────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../services/gemini_service.dart';
import '../../widgets/page_wrapper.dart';

// ─── Public helper ────────────────────────────────────────────────────────────
void showDrugSafetyModal(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _DrugSafetyModal(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Drug Safety Modal
// ─────────────────────────────────────────────────────────────────────────────
class _DrugSafetyModal extends StatefulWidget {
  const _DrugSafetyModal();
  @override
  State<_DrugSafetyModal> createState() => _DrugSafetyModalState();
}

class _DrugSafetyModalState extends State<_DrugSafetyModal> {
  final _searchCtrl = TextEditingController();
  bool _loading = false;
  String? _result;
  bool? _safe;

  static const _kGray900 = Color(0xFF111827);
  static const _kGray500 = Color(0xFF6B7280);
  static const _kGray300 = Color(0xFFD1D5DB);
  static const _kGray100 = Color(0xFFF3F4F6);
  static const _kBlue   = Color(0xFF3B82F6);
  static const _kGreen  = Color(0xFF22C55E);

  static const _prescriptions = [
    ('Lisinopril',    '10mg / Daily'),
    ('Atorvastatin',  '20mg / Nightly'),
    ('Amlodipine',    '5mg / Daily'),
    ('Metformin',     '500mg / Twice Daily'),
  ];

  Future<void> _check(BuildContext ctx) async {
    final drug = _searchCtrl.text.trim();
    if (drug.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    final appState = ctx.read<AppStateProvider>();
    final gs = GeminiService.instance;
    gs.setApiKey(appState.apiKey);
    final prompt = 'Is it safe for a patient taking ${_prescriptions.map((e) => e.$1).join(', ')} to also take "$drug"? '
        'Consider drug interactions and allergies to Penicillin and NSAIDs. '
        'Respond in 2-3 sentences. Start with SAFE, CAUTION, or DANGEROUS.';
    try {
      final resp = await gs.ask(prompt);
      final lower = resp.toLowerCase();
      if (mounted) setState(() {
        _result = resp;
        _loading = false;
        _safe = lower.startsWith('safe') ? true : lower.startsWith('dangerous') ? false : null;
      });
    } catch (_) {
      if (mounted) setState(() {
        _result = 'Unable to check. Ensure your Gemini API key is set.';
        _loading = false;
        _safe = null;
      });
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 370),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(children: [
                const Expanded(
                  child: Text('Drug Safety',
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
              const SizedBox(height: 16),

              // ── Safe Profile banner ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kGreen.withValues(alpha: 0.25)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.check_circle_outline_rounded, color: _kGreen, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Safe Profile',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                              color: _kGreen.withValues(alpha: 0.85))),
                      const SizedBox(height: 2),
                      const Text(
                          'No known interactions between your active medications and allergies.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF166534), height: 1.4)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Check new medication ───────────────────────────────────────
              const Text('CHECK NEW MEDICATION',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _kGray500)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(fontSize: 14, color: _kGray900),
                    decoration: InputDecoration(
                      hintText: 'e.g. Aspirin',
                      hintStyle: const TextStyle(fontSize: 14, color: _kGray500),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kGray300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kGray300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kBlue, width: 1.5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _check(context),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _check(context),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _kBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2, color: _kBlue),
                          )
                        : const Icon(Icons.search_rounded, color: _kBlue, size: 22),
                  ),
                ),
              ]),

              // ── Search result ──────────────────────────────────────────────
              if (_result != null) ...[                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_safe == true
                            ? _kGreen
                            : _safe == false
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFF59E0B))
                        .withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (_safe == true
                              ? _kGreen
                              : _safe == false
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(
                      _safe == true
                          ? Icons.check_circle_outline_rounded
                          : _safe == false
                              ? Icons.cancel_outlined
                              : Icons.warning_amber_outlined,
                      size: 18,
                      color: _safe == true
                          ? _kGreen
                          : _safe == false
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_result!,
                          style: const TextStyle(fontSize: 12, color: _kGray900, height: 1.5)),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 20),

              // ── Active Prescriptions ───────────────────────────────────────
              const Text('ACTIVE PRESCRIPTIONS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _kGray500)),
              const SizedBox(height: 10),
              ..._prescriptions.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kGray300),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Text(p.$1,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600, color: _kGray900)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kGray100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(p.$2,
                            style: const TextStyle(fontSize: 11, color: _kGray500, fontWeight: FontWeight.w500)),
                      ),
                    ]),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class CompatibilityCheckScreen extends StatefulWidget {
  const CompatibilityCheckScreen({super.key});
  @override
  State<CompatibilityCheckScreen> createState() => _CompatibilityCheckScreenState();
}

class _CompatibilityCheckScreenState extends State<CompatibilityCheckScreen> {
  final _drug1 = TextEditingController();
  final _drug2 = TextEditingController();
  bool _loading = false;
  String? _result;
  bool? _safe;

  Future<void> _check() async {
    if (_drug1.text.isEmpty || _drug2.text.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    final appState = context.read<AppStateProvider>();
    final gs = GeminiService.instance;
    gs.setApiKey(appState.apiKey);
    final prompt = 'Check drug interaction between "${_drug1.text}" and "${_drug2.text}". Is it safe to take together? Explain briefly in 2-3 sentences. Start with SAFE or CAUTION or DANGEROUS.';
    try {
      final resp = await gs.ask(prompt);
      final lower = resp.toLowerCase();
      if (mounted) {
        setState(() {
        _result = resp;
        _loading = false;
        _safe = lower.startsWith('safe') ? true : lower.startsWith('dangerous') ? false : null;
      });
      }
    } catch (_) {
      if (mounted) setState(() { _result = 'Unable to check. Please ensure your Gemini API key is set.'; _loading = false; _safe = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Drug Compatibility',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Enter Drug Names', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _Field('Drug / Medicine 1', _drug1),
          const SizedBox(height: 2),
          const Center(child: Icon(Icons.swap_vert_rounded, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          _Field('Drug / Medicine 2', _drug2),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _loading ? null : _check,
            child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Check Compatibility', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          )),
          if (_result != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _safe == true ? const Color(0xFF10B981).withValues(alpha: 0.05) : _safe == false ? const Color(0xFFEF4444).withValues(alpha: 0.05) : const Color(0xFFF59E0B).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: _safe == true ? const Color(0xFF10B981) : _safe == false ? const Color(0xFFEF4444) : const Color(0xFFF59E0B), width: 1.5)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(_safe == true ? Icons.check_circle_rounded : _safe == false ? Icons.cancel_rounded : Icons.warning_amber_rounded, color: _safe == true ? const Color(0xFF10B981) : _safe == false ? const Color(0xFFEF4444) : const Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(_result!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5))),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String hint; final TextEditingController ctrl;
  const _Field(this.hint, this.ctrl);
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary), filled: true, fillColor: Colors.white, prefixIcon: const Icon(Icons.medication_rounded, size: 18, color: AppColors.textSecondary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
  );
}
