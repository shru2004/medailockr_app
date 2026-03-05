// ─── Insurance Screen ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../providers/navigation_provider.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2E5090)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Insurance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Manage your health coverage', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),
              // Summary row
              Row(children: [
                _StatChip(label: 'Active Policies', value: '${kUserPolicies.length}', icon: Icons.shield_rounded),
                const SizedBox(width: 10),
                const _StatChip(label: 'Total Coverage', value: '₹17.5L', icon: Icons.account_balance_wallet_rounded),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // My Policies
              const Text('My Policies', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              ...kUserPolicies.map((p) => _PolicyCard(policy: p)),
              const SizedBox(height: 16),

              // Quick Actions
              const Text('Quick Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _ActionTile(icon: Icons.recommend_rounded, label: 'Recommender', color: AppColors.primaryBlue, onTap: () => nav.navigateTo('insurance-recommender')),
                  _ActionTile(icon: Icons.dashboard_rounded, label: 'Dashboard', color: const Color(0xFF10B981), onTap: () => nav.navigateTo('insurance-dashboard')),
                  _ActionTile(icon: Icons.receipt_long_rounded, label: 'File Claim', color: const Color(0xFF8B5CF6), onTap: () => nav.navigateTo('insurance-claim')),
                  _ActionTile(icon: Icons.add_circle_rounded, label: 'New Policy', color: const Color(0xFFF59E0B), onTap: () {}),
                ],
              ),
              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatChip({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Icon(icon, color: Colors.white70, size: 16),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ]),
    ]),
  ));
}

class _PolicyCard extends StatelessWidget {
  final InsurancePolicy policy;
  const _PolicyCard({required this.policy});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(policy.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w700))),
      ]),
      const SizedBox(height: 6),
      Text(policy.provider, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      Row(children: [
        _KeyVal('Coverage', '₹${(policy.coverage / 100000).toStringAsFixed(1)}L'),
        const SizedBox(width: 16),
        _KeyVal('Premium', '₹${policy.premium}/mo'),
        const SizedBox(width: 16),
        _KeyVal('Renewal', policy.renewal),
      ]),
    ]),
  );
}

class _KeyVal extends StatelessWidget {
  final String k, v;
  const _KeyVal(this.k, this.v);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(k, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
  ]);
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    ]),
  ));
}
