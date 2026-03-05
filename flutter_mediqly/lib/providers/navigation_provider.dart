// ─── Navigation Provider ─────────────────────────────────────────────────────
// currentPage + history stack + modal flags.

import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  // Current page
  String _currentPage = 'home';
  String get currentPage => _currentPage;

  // Navigation history stack
  final List<String> _history = [];

  // Bottom nav tab (0=Home, 1=MediStream, 2=Pharmacy, 3=Insurance, 4=SkinZone)
  int _bottomNavIndex = 0;
  int get bottomNavIndex => _bottomNavIndex;

  // Pages that hide the bottom nav
  static const Set<String> _fullscreenPages = {
    'virtual-consultation',
    'symptom-chat',
    'twin',
    'ai-passport-app',
    'skin-zone',
    'pharmacy-lab',
    'insurance',
    'insurance-recommender',
    'insurance-dashboard',
    'insurance-claim',
    'passport-vault',
    'passport-qr_code',
    'passport-sharing',
    'passport-compatibility',
    'passport-credits',
    'passport-security',
    'passport-voice',
    'passport-genomic',
    'passport-wearable',
    'passport-discharge_process',
    'radar',
  };

  // Pages that have a back button
  static const Map<String, String> _pageParents = {
    'book':                   'home',
    'home-visit':             'home',
    'video':                  'book',
    'medicos':                'home',
    'symptom-checker':        'home',
    'symptom-chat':           'symptom-checker',
    'virtual-consultation':   'home',
    'records':                'home',
    'timeline':               'home',
    'plan':                   'home',
    'notifications':          'home',
    'profile':                'home',
    'order-medicines':        'pharmacy-lab',
    'book-lab-test':          'pharmacy-lab',
    'insurance-recommender':  'insurance',
    'insurance-dashboard':    'insurance',
    'insurance-claim':        'insurance',
    'passport':               'home',
    'ai-passport-app':        'passport',
    'passport-vault':         'passport',
    'passport-qr_code':       'passport',
    'passport-sharing':       'passport',
    'passport-compatibility': 'passport',
    'passport-credits':       'passport',
    'passport-security':      'passport',
    'passport-voice':         'passport',
    'passport-genomic':       'passport',
    'passport-wearable':      'passport',
    'passport-discharge_process': 'passport',
    'twin':                   'home',
    'radar':                  'home',
    'medistream':             'home',
    'pharmacy-lab':           'home',
    'insurance':              'home',
    'skin-zone':              'home',
  };

  bool get showBottomNav => !_fullscreenPages.contains(_currentPage);
  bool get canGoBack => _history.isNotEmpty;

  void navigateTo(String page) {
    _history.add(_currentPage);
    if (_history.length > 50) _history.removeAt(0); // prevent unbounded growth
    _currentPage = page;

    // Sync bottom nav
    if (page == 'home') {
      _bottomNavIndex = 0;
    } else if (page == 'medistream') { _bottomNavIndex = 1; }
    else if (page == 'pharmacy-lab') { _bottomNavIndex = 2; }
    else if (page == 'insurance') { _bottomNavIndex = 3; }
    else if (page == 'skin-zone') { _bottomNavIndex = 4; }

    notifyListeners();
  }

  void goBack() {
    if (_history.isNotEmpty) {
      _currentPage = _history.removeLast();
      notifyListeners();
    }
  }

  void goHome() {
    _history.clear();
    _currentPage = 'home';
    _bottomNavIndex = 0;
    notifyListeners();
  }

  void setBottomNavIndex(int index) {
    const tabPages = ['home', 'medistream', 'pharmacy-lab', 'insurance', 'skin-zone'];
    _bottomNavIndex = index;
    _history.clear();
    _currentPage = tabPages[index];
    notifyListeners();
  }

  String? parentOf(String page) => _pageParents[page];
}
