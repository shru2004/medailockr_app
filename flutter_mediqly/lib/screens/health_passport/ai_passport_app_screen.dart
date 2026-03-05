// ─── AI Passport App Screen ──────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/page_wrapper.dart';

class AiPassportAppScreen extends StatelessWidget {
  const AiPassportAppScreen({super.key});

  static const _features = [
    _Feature('Medical Vault', Icons.folder_zip_rounded, Color(0xFF4F46E5), 'All records in one secure place'),
    _Feature('Emergency QR', Icons.qr_code_rounded, Color(0xFFEF4444), 'One-scan emergency data access'),
    _Feature('Data Sharing', Icons.share_rounded, Color(0xFF10B981), 'Share health data securely'),
    _Feature('Compatibility', Icons.medication_rounded, Color(0xFFF59E0B), 'Drug interaction checks'),
    _Feature('Health Credits', Icons.stars_rounded, Color(0xFF8B5CF6), 'Earn rewards for healthy habits'),
    _Feature('Blockchain Log', Icons.security_rounded, Color(0xFF0EA5E9), 'Immutable health record'),
    _Feature('Voice Access', Icons.mic_rounded, Color(0xFF06B6D4), 'Voice-controlled passport'),
    _Feature('Genomic Data', Icons.biotech_rounded, Color(0xFF10B981), 'DNA health insights'),
    _Feature('Wearable Sync', Icons.watch_rounded, Color(0xFFEC4899), 'Connect health devices'),
    _Feature('Digital Discharge', Icons.local_hospital_rounded, Color(0xFF6366F1), 'Smart discharge summaries'),
  ];

  static const _routeMap = {
    'Medical Vault': 'medical-vault',
    'Emergency QR': 'emergency-qr',
    'Data Sharing': 'data-sharing',
    'Compatibility': 'compatibility-check',
    'Health Credits': 'health-credits',
    'Blockchain Log': 'blockchain-security',
    'Voice Access': 'voice-access',
    'Genomic Data': 'genomic-data',
    'Wearable Sync': 'wearable-integration',
    'Digital Discharge': 'digital-discharge',
  };

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    return PageWrapper(
      title: 'AI Health Passport',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Aarav Sharma', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                Text('DOB: 15 Mar 1990 · Male', style: TextStyle(color: Colors.white70, fontSize: 11)),
                SizedBox(height: 8),
                Text('MedAI ID: MED-2025-0042-IN', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 0.5)),
              ])),
              Container(width: 52, height: 52, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 28)),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Passport Features', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.5,
            children: _features.map((f) {
              final route = _routeMap[f.title];
              return GestureDetector(
                onTap: route != null ? () => nav.navigateTo(route) : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 32, height: 32, decoration: BoxDecoration(color: f.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(f.icon, color: f.color, size: 18)),
                    const SizedBox(height: 8),
                    Text(f.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(f.description, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }
}

class _Feature {
  final String title, description;
  final IconData icon;
  final Color color;
  const _Feature(this.title, this.icon, this.color, this.description);
}
