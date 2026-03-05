// ─── Custom Plan Screen ──────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

class CustomPlanScreen extends StatelessWidget {
  const CustomPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'My Health Plan',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Personalized Plan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('AI-generated plan based on your health profile', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 16),
          ..._planItems.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(item.icon, color: item.color, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(item.desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: item.done ? const Color(0xFF10B981).withValues(alpha: 0.1) : AppColors.border.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
                child: Text(item.done ? 'Done' : item.time, style: TextStyle(fontSize: 10, color: item.done ? const Color(0xFF10B981) : AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ),
            ]),
          )),
        ]),
      ),
    );
  }

  static const _planItems = [
    _PlanItem('Morning Walk', '30 min brisk walk in the park', Icons.directions_walk_rounded, Color(0xFF10B981), '7:00 AM', false),
    _PlanItem('Medication', 'Amlodipine 5mg with breakfast', Icons.medication_rounded, Color(0xFFEF4444), '8:00 AM', true),
    _PlanItem('Hydration', 'Drink 2 glasses of water', Icons.water_drop_rounded, AppColors.primaryBlue, '10:00 AM', true),
    _PlanItem('Lunch', 'Low-sodium meal, avoid processed foods', Icons.restaurant_rounded, Color(0xFFF59E0B), '1:00 PM', false),
    _PlanItem('BP Check', 'Record blood pressure reading', Icons.monitor_heart_rounded, Color(0xFF8B5CF6), '4:00 PM', false),
    _PlanItem('Evening Walk', '20 min walk or stretching', Icons.self_improvement_rounded, Color(0xFF06B6D4), '6:30 PM', false),
  ];
}

class _PlanItem {
  final String title, desc, time;
  final IconData icon;
  final Color color;
  final bool done;
  const _PlanItem(this.title, this.desc, this.icon, this.color, this.time, this.done);
}
