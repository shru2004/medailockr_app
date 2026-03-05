// ─── Medical Records Screen ──────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  static const _categories = [
    _RecordCategory('Lab Reports', Icons.science_rounded, Color(0xFF3B82F6)),
    _RecordCategory('Prescriptions', Icons.medication_rounded, Color(0xFF10B981)),
    _RecordCategory('Imaging', Icons.image_rounded, Color(0xFF8B5CF6)),
    _RecordCategory('Vaccinations', Icons.vaccines_rounded, Color(0xFFF59E0B)),
    _RecordCategory('Doctor Notes', Icons.note_alt_rounded, Color(0xFF06B6D4)),
    _RecordCategory('Discharge Summary', Icons.description_rounded, Color(0xFFEF4444)),
  ];

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Medical Records',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Search
          const TextField(decoration: InputDecoration(hintText: 'Search records...', prefixIcon: Icon(Icons.search_rounded, size: 18))),
          const SizedBox(height: 16),
          const Text('Categories', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: _categories.map((c) => Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(c.icon, color: c.color, size: 26),
                const SizedBox(height: 6),
                Text(c.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textPrimary)),
              ]),
            )).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Recent Records', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ...List.generate(3, (i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.insert_drive_file_rounded, color: AppColors.primaryBlue, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Blood Test Report ${i + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const Text('Jul 10, 2025 • Lab Report', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondary),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _RecordCategory {
  final String name;
  final IconData icon;
  final Color color;
  const _RecordCategory(this.name, this.icon, this.color);
}
