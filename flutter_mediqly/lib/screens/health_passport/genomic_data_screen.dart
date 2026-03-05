// ─── Genomic Data Screen ──────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

class GenomicDataScreen extends StatelessWidget {
  const GenomicDataScreen({super.key});

  static const _traits = [
    _Trait('Lactose Tolerance', 'Likely Tolerant', Icons.check_circle_rounded, Color(0xFF10B981), 'Low risk'),
    _Trait('Caffeine Metabolism', 'Fast Metabolizer', Icons.bolt_rounded, Color(0xFFF59E0B), 'Normal coffee sensitivity'),
    _Trait('Vitamin D Deficiency Risk', 'Moderate Risk', Icons.warning_rounded, Color(0xFFF59E0B), 'Supplement recommended'),
    _Trait('Heart Disease Risk', 'Average Risk', Icons.monitor_heart_rounded, AppColors.primaryBlue, 'Maintain healthy lifestyle'),
    _Trait('Type 2 Diabetes Risk', 'Low Risk', Icons.check_circle_rounded, Color(0xFF10B981), 'Continue healthy habits'),
    _Trait('Blood Clotting Factor', 'Normal', Icons.bloodtype_rounded, Color(0xFFEF4444), 'No special precautions'),
  ];

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Genomic Insights',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2))),
            child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.biotech_rounded, color: Color(0xFF10B981), size: 22)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Report ID: GEN-2025-IN-042', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)), Text('Analyzed: 45 genetic markers', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))]))]),
          ),
          const SizedBox(height: 16),
          const Text('Genetic Traits', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ..._traits.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: t.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(t.icon, color: t.color, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(t.result, style: TextStyle(fontSize: 11, color: t.color, fontWeight: FontWeight.w500)),
                Text(t.note, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _Trait { final String name, result, note; final IconData icon; final Color color; const _Trait(this.name, this.result, this.icon, this.color, this.note); }
