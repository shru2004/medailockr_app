// ─── Home Screen ─────────────────────────────────────────────────────────────
// Sections (in order):
//   1. Gradient header  → "Hello Amanda!" greeting, bell, profile avatar
//   2. Symptom AI card  → white card, light-blue icon bg (#e0f2fe / #0ea5e9)
//   3. Advanced AI Tools → 4 items (Passport, Twin, Radar, AI Passport App)
//   4. Quick Actions    → 4 items (Book, Video, Home Visit, Medicos)
//   5. Your Health Hub  → appointment card + 3-tool grid (Records/Timeline/Plan)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/app_state_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Header + Symptom card overlap (React: margin -40px) ────
          Stack(
            clipBehavior: Clip.none,
            children: [
              _HomeHeader(onNavigate: nav.navigateTo),
              Positioned(
                bottom: -40,
                left: 16,
                right: 16,
                child: _SymptomAiCard(
                  onTap: () => nav.navigateTo('symptom-checker'),
                ),
              ),
            ],
          ),

          // 40px card-below-stack + 24px gap (React: margin-bottom 24px)
          const SizedBox(height: 64),

          // ── 2. Advanced AI Tools ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _AdvancedAiToolsSection(onNavigate: nav.navigateTo),
          ),

          const SizedBox(height: 24),

          // ── 3. Quick Actions ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _QuickActionsSection(onNavigate: nav.navigateTo),
          ),

          const SizedBox(height: 24),

          // ── 4. Your Health Hub ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _HealthHubSection(onNavigate: nav.navigateTo),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Gradient Header
//    React: gradient #4f46e5→#7c3aed (indigo→violet), "Hello Amanda!",
//           notification bell → notifications, profile avatar → profile
// ─────────────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final void Function(String) onNavigate;
  const _HomeHeader({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<AppStateProvider>().unreadCount;


    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 64), // React: padding-bottom 60px
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left — Greeting text (.home-header-text)
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello Amanda!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    color: Color(0xCCFFFFFF), // white 80% opacity
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Right — Bell + Profile avatar (.home-header-actions)
          Row(
            children: [
              // Notification bell
              GestureDetector(
                onTap: () => onNavigate('notifications'),
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle, // React: border-radius 50%
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 7,
                        top: 7,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Profile avatar — 44px with 2px white border
              GestureDetector(
                onTap: () => onNavigate('profile'),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: const Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Symptom AI card
//    React: .symptom-checker-card — white bg, icon-bg #e0f2fe, icon #0ea5e9,
//           title "Symptom AI", "Get an AI-powered analysis of your symptoms"
// ─────────────────────────────────────────────────────────────────────────────

class _SymptomAiCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SymptomAiCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon bg: #e0f2fe, icon: #0ea5e9
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(14), // React: 14px
              ),
              child: const Icon(
                Icons.manage_search_rounded,
                color: Color(0xFF0EA5E9),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Symptom AI',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Get an AI-powered analysis of your symptoms',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Advanced AI Tools section
//    React: "Advanced AI Tools" heading, exact aiTools array:
//      { id:'passport',      name:'AI Health Passport',   color:purple  #8b5cf6 }
//      { id:'twin',          name:'AI Digital Body Twin', color:orange  #f97316 }
//      { id:'radar',         name:'Outbreak Radar',       color:red     #ef4444 }
//      { id:'ai-passport-app', name:'AI Passport App',   color:cyan    #06b6d4 }
// ─────────────────────────────────────────────────────────────────────────────

class _AdvancedAiToolsSection extends StatelessWidget {
  final void Function(String) onNavigate;
  const _AdvancedAiToolsSection({required this.onNavigate});

  static const _tools = [
    _AiToolData(
      name: 'AI Health Passport',
      desc: 'Your secure, unified health history.',
      icon: Icons.badge_rounded,
      color: Color(0xFF8B5CF6),
      route: 'passport',
    ),
    _AiToolData(
      name: 'AI Digital Body Twin',
      desc: 'Simulate and predict your health.',
      icon: Icons.monitor_heart_rounded,
      color: Color(0xFFF97316),
      route: 'twin',
    ),
    _AiToolData(
      name: 'Outbreak Radar',
      desc: 'Stay informed about local health risks.',
      icon: Icons.radar_rounded,
      color: Color(0xFFEF4444),
      route: 'radar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advanced AI Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._tools.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AiToolTile(tool: t, onTap: () => onNavigate(t.route)),
            )),
      ],
    );
  }
}

class _AiToolData {
  final String name, desc, route;
  final IconData icon;
  final Color color;
  const _AiToolData({
    required this.name,
    required this.desc,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _AiToolTile extends StatelessWidget {
  final _AiToolData tool;
  final VoidCallback onTap;
  const _AiToolTile({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            // Solid colored icon bg (React: bg-ai-purple / bg-ai-orange / etc.)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tool.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tool.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tool.desc,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Quick Actions grid (4-column)
//    React: "Quick Actions" heading, services array:
//      { id:'book',    name:'Book Appointment', color:#60a5fa } → 'book'
//      { id:'video',   name:'Video Consult',    color:#34d399 } → 'video'
//      { id:'home',    name:'Home Visit',       color:#facc15 } → 'home-visit'
//      { id:'medicos', name:'Medicos',          color:#fb923c } → 'medicos'
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  final void Function(String) onNavigate;
  const _QuickActionsSection({required this.onNavigate});

  static const _actions = [
    _QuickActionData(
      'Book Appointment', Icons.calendar_today_rounded,
      AppColors.cardBook, 'book',
    ),
    _QuickActionData(
      'Video Consult', Icons.video_call_rounded,
      AppColors.cardVideo, 'video',
    ),
    _QuickActionData(
      'Home Visit', Icons.home_rounded,
      AppColors.cardHome, 'home-visit',
    ),
    _QuickActionData(
      'Medicos', Icons.groups_rounded,
      AppColors.cardMedicos, 'medicos',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 12,  // React: gap 12px
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: _actions
              .map((a) => _QuickActionTile(
                    action: a,
                    onTap: () => onNavigate(a.route),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _QuickActionData {
  final String label, route;
  final IconData icon;
  final Color color;
  const _QuickActionData(this.label, this.icon, this.color, this.route);
}

class _QuickActionTile extends StatelessWidget {
  final _QuickActionData action;
  final VoidCallback onTap;
  const _QuickActionTile({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // React .action-card: no background, no border — transparent container
      // icon uses solid color circle (.action-card-icon border-radius:50%)
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: action.color,
              shape: BoxShape.circle,
            ),
            child: Icon(action.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Your Health Hub
//    React: "Your Health Hub" (.health-hub .home-section):
//      a) Appointment card (bg #3b82f6): Dr. Sarah Collins, Today 10:30 AM,
//         "Join Video Call" button (white bg/blue text) → 'video'
//      b) 3-tool grid (.health-tools-grid):
//           My Records  (#10b981 green)  → 'records'
//           My Timeline (#ec4899 pink)   → 'timeline'
//           My Plan     (#8b5cf6 purple) → 'plan'
// ─────────────────────────────────────────────────────────────────────────────

class _HealthHubSection extends StatelessWidget {
  final void Function(String) onNavigate;
  const _HealthHubSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Health Hub',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // ── Appointment card (bg #3b82f6) ─────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor info
              Row(
                children: [
                  // Doctor avatar: 40px circle + 2px white border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Sarah Collins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Ophthalmologist',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF), // white 80%
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Date row with top+bottom border (rgba white 0.3)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Color(0x4DFFFFFF), width: 1), // rgba(255,255,255,0.3)
                    bottom: BorderSide(
                        color: Color(0x4DFFFFFF), width: 1),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Today, 10:30 AM',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Join Video Call button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => onNavigate('video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3B82F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Join Video Call',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── 3-tool grid (.health-tools-grid) ─────────────────────────
        Row(
          children: [
            _ToolCard(
              label: 'My Records',
              icon: Icons.folder_open_rounded,
              color: const Color(0xFF10B981),
              onTap: () => onNavigate('records'),
            ),
            const SizedBox(width: 12),
            _ToolCard(
              label: 'My Timeline',
              icon: Icons.timeline_rounded,
              color: const Color(0xFFEC4899),
              onTap: () => onNavigate('timeline'),
            ),
            const SizedBox(width: 12),
            _ToolCard(
              label: 'My Plan',
              icon: Icons.track_changes_rounded,
              color: const Color(0xFF8B5CF6),
              onTap: () => onNavigate('plan'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ToolCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // React: #f1f5f9 / slate-100, no border
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
