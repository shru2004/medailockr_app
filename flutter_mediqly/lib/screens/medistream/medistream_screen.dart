// ─── Medistream Screen ──────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';

class MedistreamScreen extends StatelessWidget {
  const MedistreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            color: Colors.white,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('MediStream', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(Icons.circle, color: Color(0xFFEF4444), size: 8),
                  SizedBox(width: 4),
                  Text('LIVE', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Featured video
              if (kMedistreamFeed.isNotEmpty) _FeaturedVideo(video: kMedistreamFeed.first),
              const SizedBox(height: 16),
              const Text('More Videos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              ...kMedistreamFeed.skip(1).map((v) => _VideoTile(video: v)),
              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
    );
  }
}

class _FeaturedVideo extends StatelessWidget {
  final MedistreamVideo video;
  const _FeaturedVideo({required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white, border: Border.all(color: AppColors.border)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          Image.network(video.thumbnailUrl, height: 180, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 180, color: const Color(0xFFF1F5F9), child: const Center(child: Icon(Icons.play_circle_outline, size: 48, color: AppColors.textSecondary)))),
          Positioned.fill(child: Center(child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow_rounded, color: AppColors.primaryBlue, size: 28),
          ))),
          Positioned(top: 8, left: 8, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(4)),
            child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
          )),
        ]),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(video.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Row(children: [
              CircleAvatar(radius: 12, backgroundImage: NetworkImage(video.doctor.image)),
              const SizedBox(width: 6),
              Text(video.doctor.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (video.doctor.verified) ...[const SizedBox(width: 4), const Icon(Icons.verified_rounded, size: 12, color: AppColors.primaryBlue)],
              const Spacer(),
              Text(video.duration, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final MedistreamVideo video;
  const _VideoTile({required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(video.thumbnailUrl, width: 80, height: 56, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 80, height: 56, color: const Color(0xFFF1F5F9), child: const Icon(Icons.play_circle_outline, color: AppColors.textSecondary))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('${video.doctor.name} • ${video.views}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
      ]),
    );
  }
}
