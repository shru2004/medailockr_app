// ─── Insurance Dashboard Screen ──────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../widgets/page_wrapper.dart';

class InsuranceDashboardScreen extends StatelessWidget {
  const InsuranceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Insurance Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Coverage', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('₹15,00,000', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Row(children: [
                _StatBadge('2 Active Policies', Icons.shield_rounded),
                SizedBox(width: 12),
                _StatBadge('₹0 Pending Claims', Icons.receipt_long_rounded),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Active Policies', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...kUserPolicies.map((p) => _PolicyCard(policy: p)),
          const SizedBox(height: 12),
          const Text('Quick Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Row(children: [
            Expanded(child: _ActionTile(Icons.add_circle_rounded, 'Add Member', Color(0xFF10B981))),
            SizedBox(width: 8),
            Expanded(child: _ActionTile(Icons.upload_file_rounded, 'Upload Doc', AppColors.primaryBlue)),
            SizedBox(width: 8),
            Expanded(child: _ActionTile(Icons.history_rounded, 'Claim History', Color(0xFFF59E0B))),
          ]),
        ]),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label; final IconData icon;
  const _StatBadge(this.label, this.icon);
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: Colors.white70, size: 12), const SizedBox(width: 4), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))]);
}

class _PolicyCard extends StatelessWidget {
  final InsurancePolicy policy;
  const _PolicyCard({required this.policy});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(policy.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Text('Active', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 4),
      Text(policy.provider, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      Row(children: [
        _PolicyStat('Coverage', '₹${policy.coverage}'),
        const SizedBox(width: 16),
        _PolicyStat('Premium', '₹${policy.premium}/mo'),
        const SizedBox(width: 16),
        _PolicyStat('Renewal', policy.renewal),
      ]),
    ]),
  );
}

class _PolicyStat extends StatelessWidget {
  final String label, val;
  const _PolicyStat(this.label, this.val);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
  ]);
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _ActionTile(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500), textAlign: TextAlign.center)]),
  );
}
