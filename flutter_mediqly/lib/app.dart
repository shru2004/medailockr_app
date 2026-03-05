// ─── Root App Widget ─────────────────────────────────────────────────────────
// Single-page navigator driven by NavigationProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'providers/navigation_provider.dart';
import 'providers/app_state_provider.dart';

// ─── Screen imports ───────────────────────────────────────────────────────────
import 'screens/home/home_screen.dart';
import 'screens/appointment/book_appointment_screen.dart';
import 'screens/appointment/video_consultation_screen.dart';
import 'screens/appointment/home_visit_screen.dart';
import 'screens/medicos/medicos_screen.dart';
import 'screens/symptom/symptom_checker_screen.dart';
import 'screens/symptom/symptom_chat_screen.dart';
import 'screens/symptom/virtual_consultation_screen.dart';
import 'screens/records/records_screen.dart';
import 'screens/records/timeline_screen.dart';
import 'screens/plan/custom_plan_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/medistream/medistream_screen.dart';
import 'screens/pharmacy/pharmacy_lab_screen.dart';
import 'screens/pharmacy/order_medicines_screen.dart';
import 'screens/pharmacy/book_lab_test_screen.dart';
import 'screens/skin_zone/skin_zone_screen.dart';
import 'screens/insurance/insurance_screen.dart';
import 'screens/insurance/insurance_recommender_screen.dart';
import 'screens/insurance/insurance_dashboard_screen.dart';
import 'screens/insurance/insurance_claim_screen.dart';
import 'screens/health_passport/passport_screen.dart';
import 'screens/health_passport/ai_passport_app_screen.dart';
import 'screens/health_passport/medical_vault_screen.dart';
import 'screens/health_passport/emergency_qr_screen.dart';
import 'screens/health_passport/data_sharing_screen.dart';
import 'screens/health_passport/compatibility_check_screen.dart';
import 'screens/health_passport/health_credits_screen.dart';
import 'screens/health_passport/blockchain_security_screen.dart';
import 'screens/health_passport/voice_access_screen.dart';
import 'screens/health_passport/genomic_data_screen.dart';
import 'screens/health_passport/wearable_integration_screen.dart';
import 'screens/health_passport/digital_discharge_screen.dart';
import 'screens/health_twin/health_twin_screen.dart';
import 'screens/outbreak_radar/outbreak_radar_screen.dart';
import 'widgets/api_key_modal.dart';

class MediqlyApp extends StatelessWidget {
  const MediqlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mediqly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AppShell(),
    );
  }
}

// ── App shell: centered mobile frame + page routing ──────────────────────────

class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final app = context.watch<AppStateProvider>();

    // On large screens (web/desktop) the app renders as a centred 430 px
    // phone frame with a subtle grey surround — exactly like the React app's
    // max-width: 480px; margin: 0 auto pattern.
    return Scaffold(
      backgroundColor: const Color(0xFFD1D5DB), // gray-300 "desktop surround"
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bgColor,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── Scrollable page content ─────────────────────────────
                  Expanded(
                    child: app.showApiKeyModal
                        ? Stack(
                            children: [
                              _buildPage(nav.currentPage, context),
                              const ApiKeyModal(),
                            ],
                          )
                        : _buildPage(nav.currentPage, context),
                  ),

                  // ── Bottom navigation ────────────────────────────────────
                  if (nav.showBottomNav)
                    _BottomNavBar(currentIndex: nav.bottomNavIndex),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(String page, BuildContext context) {
    switch (page) {
      case 'home':                   return const HomeScreen();
      case 'book':                   return const BookAppointmentScreen();
      case 'video':                  return const VideoConsultationScreen();
      case 'home-visit':             return const HomeVisitScreen();
      case 'medicos':                return const MedicosScreen();
      case 'symptom-checker':        return const SymptomCheckerScreen();
      case 'symptom-chat':           return const SymptomChatScreen();
      case 'virtual-consultation':   return const VirtualConsultationScreen();
      case 'records':                return const RecordsScreen();
      case 'timeline':               return const TimelineScreen();
      case 'plan':                   return const CustomPlanScreen();
      case 'notifications':          return const NotificationsScreen();
      case 'profile':                return const ProfileScreen();
      case 'medistream':             return const MedistreamScreen();
      case 'pharmacy-lab':           return const PharmacyLabScreen();
      case 'order-medicines':        return const OrderMedicinesScreen();
      case 'book-lab-test':          return const BookLabTestScreen();
      case 'skin-zone':              return const SkinZoneScreen();
      case 'insurance':              return const InsuranceScreen();
      case 'insurance-recommender':  return const InsuranceRecommenderScreen();
      case 'insurance-dashboard':    return const InsuranceDashboardScreen();
      case 'insurance-claim':        return const InsuranceClaimScreen();
      case 'passport':               return const PassportScreen();
      case 'ai-passport-app':        return const AiPassportAppScreen();
      case 'passport-vault':         return const MedicalVaultScreen();
      case 'passport-qr_code':       return const EmergencyQrScreen();
      case 'passport-sharing':       return const DataSharingScreen();
      case 'passport-compatibility': return const CompatibilityCheckScreen();
      case 'passport-credits':       return const HealthCreditsScreen();
      case 'passport-security':      return const BlockchainSecurityScreen();
      case 'passport-voice':         return const VoiceAccessScreen();
      case 'passport-genomic':       return const GenomicDataScreen();
      case 'passport-wearable':      return const WearableIntegrationScreen();
      case 'passport-discharge_process': return const DigitalDischargeScreen();
      case 'twin':                   return const HealthTwinScreen();
      case 'radar':                  return const OutbreakRadarScreen();
      default:                       return const HomeScreen();
    }
  }
}

// ── Bottom navigation bar ─────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const _BottomNavBar({required this.currentIndex});

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded),           label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill),       label: 'MediStream'),
    BottomNavigationBarItem(icon: Icon(Icons.local_pharmacy_outlined), label: 'Pharmacy'),
    BottomNavigationBarItem(icon: Icon(Icons.shield_outlined),        label: 'Insurance'),
    BottomNavigationBarItem(icon: Icon(Icons.face_retouching_natural), label: 'Skin Zone'),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = currentIndex == i;
              final item = _items[i];
              return Expanded(
                child: InkWell(
                  onTap: () => nav.setBottomNavIndex(i),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconTheme(
                        data: IconThemeData(
                          size: 22,
                          color: selected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF6B7280),
                        ),
                        child: item.icon,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF6B7280),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
