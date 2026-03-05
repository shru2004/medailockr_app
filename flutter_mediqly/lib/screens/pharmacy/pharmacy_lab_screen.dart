// ─── Pharmacy Lab Screen ─────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';

class PharmacyLabScreen extends StatelessWidget {
  const PharmacyLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            color: Colors.white,
            child: const Text('Pharmacy & Lab', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Medicines & Tests', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Order medicines or book lab tests from your home', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                  Icon(Icons.local_pharmacy_rounded, color: Colors.white, size: 40),
                ]),
              ),
              const SizedBox(height: 16),

              // Tiles
              _PharmacyTile(
                icon: Icons.medication_rounded,
                color: const Color(0xFF10B981),
                title: 'Order Medicines',
                desc: 'Get medicines delivered to your doorstep',
                onTap: () => nav.navigateTo('order-medicines'),
              ),
              const SizedBox(height: 10),
              _PharmacyTile(
                icon: Icons.science_rounded,
                color: AppColors.primaryBlue,
                title: 'Book Lab Test',
                desc: 'Book diagnostic tests at certified labs near you',
                onTap: () => nav.navigateTo('book-lab-test'),
              ),
              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
    );
  }
}

class _PharmacyTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, desc;
  final VoidCallback onTap;
  const _PharmacyTile({required this.icon, required this.color, required this.title, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}
