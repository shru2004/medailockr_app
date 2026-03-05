// ─── Page Wrapper Widget ─────────────────────────────────────────────────────
// Mirrors the full-screen page container with optional back button header.
// Used by all pages that need a title bar + optional back navigation.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/navigation_provider.dart';

class PageWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool safeTop;
  final bool safeBottom;
  final PreferredSizeWidget? customAppBar;

  const PageWrapper({
    super.key,
    required this.title,
    required this.child,
    this.showBack = true,
    this.actions,
    this.backgroundColor,
    this.safeTop = true,
    this.safeBottom = false,
    this.customAppBar,
  });

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.bgColor,
      appBar: customAppBar ??
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: showBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppColors.textPrimary),
                    onPressed: nav.goBack,
                  )
                : null,
            automaticallyImplyLeading: false,
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            actions: actions,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: AppColors.border),
            ),
          ),
      body: SafeArea(
        top: safeTop,
        bottom: safeBottom,
        child: child,
      ),
    );
  }
}
