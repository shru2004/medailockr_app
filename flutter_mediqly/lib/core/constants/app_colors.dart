// ─── App Colors ────────────────────────────────────────────────────────────
// Mirrors the CSS custom-property palette in index.css
// Tailwind slate/cyan/blue palette

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light-theme (main app)
  static const Color bgColor        = Color(0xFFF8FAFC);   // --bg-color
  static const Color cardBg         = Color(0xFFFFFFFF);   // --card-bg
  static const Color textPrimary    = Color(0xFF1E293B);   // --text-primary
  static const Color textSecondary  = Color(0xFF64748B);   // --text-secondary
  static const Color textOnDark     = Color(0xFFF1F5F9);   // --text-on-dark
  static const Color borderColor    = Color(0xFFE2E8F0);   // --border-color

  // ── Brand palette
  static const Color primaryBlue    = Color(0xFF3B82F6);   // --primary-blue
  static const Color primaryPurple  = Color(0xFF8B5CF6);   // --primary-purple
  static const Color primaryOrange  = Color(0xFFF97316);   // --primary-orange
  static const Color primaryGreen   = Color(0xFF10B981);   // --primary-green
  static const Color primaryCyan    = Color(0xFF06B6D4);   // --primary-cyan
  static const Color primaryPink    = Color(0xFFEC4899);   // --primary-pink
  static const Color dangerRed      = Color(0xFFEF4444);   // --danger-red

  // ── Home header gradient
  static const Color gradientStart  = Color(0xFF4F46E5);   // indigo-600
  static const Color gradientEnd    = Color(0xFF7C3AED);   // violet-600

  // ── Action-card colors  (quick-actions grid)
  static const Color cardBook       = Color(0xFF60A5FA);   // blue-400
  static const Color cardVideo      = Color(0xFF34D399);   // emerald-400
  static const Color cardHome       = Color(0xFFFACC15);   // yellow-400
  static const Color cardMedicos    = Color(0xFFFB923C);   // orange-400

  // ── Health-Twin (dark)
  static const Color twinBg         = Color(0xFF020617);   // slate-950
  static const Color twinSurface    = Color(0xFF0F172A);   // slate-900
  static const Color twinBorder     = Color(0xFF1E293B);   // slate-800
  static const Color twinText       = Color(0xFFCBD5E1);   // slate-300
  static const Color twinSubtext    = Color(0xFF64748B);   // slate-500
  static const Color twinAccent     = Color(0xFF22D3EE);   // cyan-400
  static const Color twinAccent2    = Color(0xFF3B82F6);   // blue-500
  static const Color twinGreen      = Color(0xFF4ADE80);   // green-400
  static const Color twinAmber      = Color(0xFFF59E0B);   // amber-500
  static const Color twinRed        = Color(0xFFEF4444);   // red-500
  static const Color twinEmerald    = Color(0xFF34D399);   // emerald-400

  // ── Triage levels
  static const Color triageEmergencyBg   = Color(0xFFFEE2E2);
  static const Color triageEmergencyText = Color(0xFFDC2626);
  static const Color triageUrgentBg      = Color(0xFFFEF3C7);
  static const Color triageUrgentText    = Color(0xFFD97706);
  static const Color triageRoutineBg     = Color(0xFFD1FAE5);
  static const Color triageRoutineText   = Color(0xFF059669);
  static const Color triageSelfCareBg    = Color(0xFFEFF6FF);
  static const Color triageSelfCareText  = Color(0xFF2563EB);

  // ── Confidence tags
  static const Color confidenceHighBg    = Color(0xFFD1FAE5);
  static const Color confidenceHighText  = Color(0xFF065F46);
  static const Color confidenceMedBg     = Color(0xFFFFF7CD);
  static const Color confidenceMedText   = Color(0xFF92400E);
  static const Color confidenceLowBg     = Color(0xFFFEE2E2);
  static const Color confidenceLowText   = Color(0xFF991B1B);

  // ── Input background
  static const Color inputBg = Color(0xFFF9FAFB);

  // ── Verified blue
  static const Color verifiedBlue = Color(0xFF2563EB);

  // ── Aliases used widely across screens
  static const Color border        = borderColor;   // shorthand alias
  static const Color errorRed      = dangerRed;     // shorthand alias
  static const Color twinMuted     = twinSubtext;   // shorthand alias
  static const Color successGreen  = primaryGreen;  // shorthand alias
  static const Color warningAmber  = Color(0xFFF59E0B); // amber-500
}
