// ─── Book Lab Test Screen ────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

class BookLabTestScreen extends StatefulWidget {
  const BookLabTestScreen({super.key});
  @override
  State<BookLabTestScreen> createState() => _BookLabTestScreenState();
}

class _BookLabTestScreenState extends State<BookLabTestScreen> {
  int? _selected;
  String? _slot;

  static const _slots = ['8:00 AM', '9:30 AM', '11:00 AM', '2:00 PM', '4:00 PM', '6:00 PM'];
  static const _tests = [
    _LabTest('Complete Blood Count', 'CBC', Icons.bloodtype_rounded, Color(0xFFEF4444), 299),
    _LabTest('Lipid Profile', 'Cholesterol panel', Icons.favorite_rounded, Color(0xFFF59E0B), 499),
    _LabTest('Blood Glucose', 'Fasting + PP', Icons.science_rounded, Color(0xFF10B981), 199),
    _LabTest('HbA1c', 'Diabetes marker', Icons.monitor_rounded, Color(0xFF8B5CF6), 349),
    _LabTest('Thyroid Profile', 'TSH, T3, T4', Icons.local_hospital_rounded, AppColors.primaryBlue, 599),
    _LabTest('Vitamin Panel', 'B12, D3, Iron', Icons.health_and_safety_rounded, Color(0xFF06B6D4), 899),
  ];

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Book Lab Test',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Select Test', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...List.generate(_tests.length, (i) {
            final t = _tests[i];
            final sel = _selected == i;
            return GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: sel ? AppColors.primaryBlue.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? AppColors.primaryBlue : AppColors.border, width: sel ? 1.5 : 1)),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: t.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(t.icon, color: t.color, size: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(t.desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ])),
                  Text('₹${t.price}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                ]),
              ),
            );
          }),
          if (_selected != null) ...[
            const SizedBox(height: 16),
            const Text('Pick Time Slot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _slots.map((s) {
              final active = _slot == s;
              return GestureDetector(
                onTap: () => setState(() => _slot = s),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: active ? AppColors.primaryBlue : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? AppColors.primaryBlue : AppColors.border)), child: Text(s, style: TextStyle(fontSize: 12, color: active ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500))),
              );
            }).toList()),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _slot == null ? null : () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_tests[_selected!].name} booked for $_slot'))),
              child: const Text('Confirm Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            )),
          ],
        ]),
      ),
    );
  }
}

class _LabTest {
  final String name, desc;
  final IconData icon;
  final Color color;
  final int price;
  const _LabTest(this.name, this.desc, this.icon, this.color, this.price);
}
