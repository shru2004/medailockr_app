// ─── Timeline Screen ──────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  static const _events = [
    _TimelineEvt('Jul 10, 2025', 'Blood Test', 'All markers normal. Cholesterol slightly elevated.', Icons.science_rounded, AppColors.primaryBlue),
    _TimelineEvt('Jun 22, 2025', 'Dr. Collins Visit', 'Routine check-up. BP: 118/76. Weight: 72kg.', Icons.person_rounded, Color(0xFF10B981)),
    _TimelineEvt('Jun 5, 2025', 'Vaccination', 'Influenza vaccine administered.', Icons.vaccines_rounded, Color(0xFFF59E0B)),
    _TimelineEvt('May 18, 2025', 'Prescription', 'Amlodipine 5mg prescribed for BP management.', Icons.medication_rounded, Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Health Timeline',
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _events.length,
        itemBuilder: (_, i) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: _events[i].color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(_events[i].icon, color: _events[i].color, size: 18)),
            if (i < _events.length - 1) Container(width: 2, height: 48, color: AppColors.border),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_events[i].date, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(_events[i].title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(_events[i].desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _TimelineEvt {
  final String date, title, desc;
  final IconData icon;
  final Color color;
  const _TimelineEvt(this.date, this.title, this.desc, this.icon, this.color);
}
