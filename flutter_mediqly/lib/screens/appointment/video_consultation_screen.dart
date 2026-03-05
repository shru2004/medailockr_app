// ─── Video Consultation Screen ───────────────────────────────────────────────
//
// Layout (in order):
//   1. Secure-encrypted info banner (bg #eff6ff / text #1e40af)
//   2. Doctor cards for every videoAvailable:true doctor
//      Each card: avatar, name+verified, specialty|hospital,
//                 exp+fee/duration, rating+reviews, languages, tag chips,
//                 status footer with context-aware action buttons:
//                   Online  → "Video Call" (#10b981) + "Chat First" (#3b82f6) + "Schedule" (gray)
//                   Busy    → "Join Queue" (#f59e0b) + "Schedule" (gray)
//                   Offline → "Notify me when Online" (gray outline)

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/doctor.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/page_wrapper.dart';
import 'package:provider/provider.dart';

class VideoConsultationScreen extends StatelessWidget {
  const VideoConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter kDoctors to only videoAvailable:true
    final videoDoctors =
        kDoctors.where((d) => d.videoAvailable).toList();

    return PageWrapper(
      title: 'Video Consultation',
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── Info banner ─────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_rounded, color: Color(0xFF1E40AF), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All consultations are secure and encrypted. '
                    'Doctor will upload e-prescription after consultation.',
                    style: TextStyle(
                      color: Color(0xFF1E40AF),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Doctor list ─────────────────────────────────────────────────
          ...videoDoctors.map((d) => _VideoDoctorCard(doctor: d)),
        ],
      ),
    );
  }
}

// ── Doctor card ───────────────────────────────────────────────────────────────

class _VideoDoctorCard extends StatelessWidget {
  final Doctor doctor;
  const _VideoDoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final statusColor = doctor.onlineStatus == 'Online'
        ? const Color(0xFF22C55E)
        : doctor.onlineStatus == 'Busy'
            ? const Color(0xFFF59E0B)
            : const Color(0xFF64748B);

    final statusLabel = doctor.onlineStatus == 'Online'
        ? 'Online Now'
        : doctor.onlineStatus == 'Busy'
            ? 'In Consultation'
            : 'Offline';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Doctor info row ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 80×80 avatar
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(doctor.image),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Verified badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (doctor.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              color: Color(0xFF2563EB), size: 16),
                          const SizedBox(width: 2),
                          const Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Specialty | Hospital
                    Text(
                      '${doctor.specialty} · ${doctor.hospital}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    // Experience + fee/duration
                    Text(
                      '${doctor.experience} yrs exp  •  \$${doctor.fee.toInt()} / ${doctor.consultationDuration} min',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    // Rating + reviews
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFF59E0B), size: 14),
                        Text(
                          ' ${doctor.rating} (${doctor.reviewsCount} reviews)',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Languages
                    Text(
                      doctor.languages.join(', '),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Tag chips ─────────────────────────────────────────────────
          if (doctor.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: doctor.tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 10),

          // ── Status + Action buttons footer ────────────────────────────
          Row(
            children: [
              // Status dot + label
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ActionButtons(doctor: doctor),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Doctor doctor;
  const _ActionButtons({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();

    if (doctor.onlineStatus == 'Online') {
      return Row(
        children: [
          // Video Call → green #10b981
          Expanded(
            child: _ActionBtn(
              label: 'Video Call',
              color: const Color(0xFF10B981),
              textColor: Colors.white,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connecting via Video Call...')),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Chat First → blue #3b82f6
          Expanded(
            child: _ActionBtn(
              label: 'Chat First',
              color: const Color(0xFF3B82F6),
              textColor: Colors.white,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening chat...')),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Schedule → gray #e2e8f0
          Expanded(
            child: _ActionBtn(
              label: 'Schedule',
              color: const Color(0xFFE2E8F0),
              textColor: AppColors.textPrimary,
              onTap: () => nav.navigateTo('book'),
            ),
          ),
        ],
      );
    } else if (doctor.onlineStatus == 'Busy') {
      return Row(
        children: [
          // Join Queue → amber #f59e0b
          Expanded(
            child: _ActionBtn(
              label: 'Join Queue',
              color: const Color(0xFFF59E0B),
              textColor: Colors.white,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue...')),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Schedule → gray
          Expanded(
            child: _ActionBtn(
              label: 'Schedule',
              color: const Color(0xFFE2E8F0),
              textColor: AppColors.textPrimary,
              onTap: () => nav.navigateTo('book'),
            ),
          ),
        ],
      );
    } else {
      // Offline
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You will be notified when online.')),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.borderColor),
            foregroundColor: AppColors.textSecondary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text('Notify me when Online',
              style: TextStyle(fontSize: 12)),
        ),
      );
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

