// ─── Insurance Claim Screen ──────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

class InsuranceClaimScreen extends StatefulWidget {
  const InsuranceClaimScreen({super.key});
  @override
  State<InsuranceClaimScreen> createState() => _InsuranceClaimScreenState();
}

class _InsuranceClaimScreenState extends State<InsuranceClaimScreen> {
  final _amtCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _type;
  bool _submitted = false;

  static const _types = ['Hospitalisation', 'OPD', 'Pharmacy', 'Lab Tests', 'Emergency'];

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return PageWrapper(
      title: 'File a Claim',
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 36)),
        const SizedBox(height: 16),
        const Text('Claim Submitted!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('Claim #CLM-2025-0042\nUnder review · 3-5 business days', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), onPressed: () => setState(() => _submitted = false), child: const Text('New Claim', style: TextStyle(color: Colors.white))),
      ])),
    );
    }

    return PageWrapper(
      title: 'File a Claim',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Claim Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
            final sel = _type == t;
            return GestureDetector(
              onTap: () => setState(() => _type = t),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: sel ? AppColors.primaryBlue : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.primaryBlue : AppColors.border)), child: Text(t, style: TextStyle(fontSize: 12, color: sel ? Colors.white : AppColors.textPrimary, fontWeight: sel ? FontWeight.w600 : FontWeight.w400))),
            );
          }).toList()),
          const SizedBox(height: 16),
          _label('Claim Amount (₹)'),
          const SizedBox(height: 6),
          TextField(controller: _amtCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Enter amount')),
          const SizedBox(height: 12),
          _label('Description'),
          const SizedBox(height: 6),
          TextField(controller: _descCtrl, maxLines: 3, decoration: _inputDeco('Describe the medical expense…')),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)), child: const Row(children: [Icon(Icons.info_rounded, size: 16, color: AppColors.textSecondary), SizedBox(width: 8), Expanded(child: Text('Upload supporting documents (bills, prescriptions) within 7 days of filing.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4)))])),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _type != null && _amtCtrl.text.isNotEmpty ? () => setState(() => _submitted = true) : null,
            child: const Text('Submit Claim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          )),
        ]),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary));
  InputDecoration _inputDeco(String h) => InputDecoration(hintText: h, hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10));
}
