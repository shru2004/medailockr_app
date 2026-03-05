// ─── Profile Screen ───────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/page_wrapper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppStateProvider>();

    return PageWrapper(
      title: 'Profile',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar + name
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: const Row(children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32')),
              SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Rahul Singh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('rahul.singh@email.com', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Text('Patient ID: RAH-2025-001', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Health Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          const _InfoRow('Age', '34 years'),
          const _InfoRow('Gender', 'Male'),
          const _InfoRow('Blood Type', 'O+'),
          const _InfoRow('Weight', '72 kg'),
          const _InfoRow('Height', '175 cm'),
          const _InfoRow('Conditions', 'Hypertension'),
          const SizedBox(height: 16),
          const Text('Account Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _SettingTile(icon: Icons.key_rounded, label: 'Update API Key', color: AppColors.primaryBlue, onTap: app.requestApiKey),
          _SettingTile(icon: Icons.lock_rounded,     label: 'Privacy & Security', color: const Color(0xFF8B5CF6), onTap: () {}),
          _SettingTile(icon: Icons.help_rounded,     label: 'Help & Support',    color: const Color(0xFF10B981), onTap: () {}),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String k, v;
  const _InfoRow(this.k, this.v);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    margin: const EdgeInsets.only(bottom: 6),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    ]),
  );
}

class _SettingTile extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _SettingTile({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
        const Spacer(),
        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondary),
      ]),
    ),
  );
}
