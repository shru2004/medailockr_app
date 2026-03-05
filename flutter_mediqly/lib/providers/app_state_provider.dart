// ─── App State Provider ─────────────────────────────────────────────────────
// Central app state provider.
// Manages: API key, user profile, notifications, home data, booking flow.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/doctor.dart';
import '../models/notification_model.dart';
import '../services/gemini_service.dart';

class AppStateProvider extends ChangeNotifier {
  // ── Secure storage ──────────────────────────────────────────────────────────
  static const _storage = FlutterSecureStorage();
  static const _apiKeyStorageKey = 'gemini_api_key';

  // ── API key ─────────────────────────────────────────────────────────────────
  bool _showApiKeyModal = false;
  bool get showApiKeyModal => _showApiKeyModal;

  String _apiKey = '';
  String get apiKey => _apiKey;
  bool get hasApiKey => _apiKey.isNotEmpty;

  // ── Notifications ────────────────────────────────────────────────────────────
  List<AppNotification> _notifications = List.from(kNotifications);
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => n.unread).length;

  // ── Doctor filter / search ───────────────────────────────────────────────────
  String _specialtyFilter = 'All';
  String get specialtyFilter => _specialtyFilter;

  String _cityFilter = 'All';
  String get cityFilter => _cityFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ── Booking flow ─────────────────────────────────────────────────────────────
  Doctor? _selectedDoctor;
  Doctor? get selectedDoctor => _selectedDoctor;

  String _selectedDate = '';
  String get selectedDate => _selectedDate;

  String _selectedTime = '';
  String get selectedTime => _selectedTime;

  String _consultationType = 'Video';
  String get consultationType => _consultationType;

  // ── Symptom checker ───────────────────────────────────────────────────────────
  String _symptomInput = '';
  String get symptomInput => _symptomInput;

  // ── Home-page counts (water / mood etc) ──────────────────────────────────────
  int _waterGlasses = 0;
  int get waterGlasses => _waterGlasses;

  String _selectedMood = '';
  String get selectedMood => _selectedMood;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────
  AppStateProvider() {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    try {
      final saved = await _storage.read(key: _apiKeyStorageKey);
      if (saved != null && saved.isNotEmpty) {
        _apiKey = saved;
        GeminiService.instance.setApiKey(saved);
      }
    } catch (_) {
      // flutter_secure_storage may not be available on all web platforms;
      // ignore and let user add key when needed via an AI feature.
    }
    // Never block the UI on startup — modal is shown on-demand via requestApiKey()
    _showApiKeyModal = false;
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    _apiKey = key;
    _showApiKeyModal = false;
    GeminiService.instance.setApiKey(key);
    await _storage.write(key: _apiKeyStorageKey, value: key);
    notifyListeners();
  }

  void dismissApiKeyModal() {
    _showApiKeyModal = false;
    notifyListeners();
  }

  void requestApiKey() {
    _showApiKeyModal = true;
    notifyListeners();
  }

  // ── Notifications ─────────────────────────────────────────────────────────────
  void markAllRead() {
    _notifications = _notifications.map((n) => AppNotification(
      id: n.id,
      type: n.type,
      title: n.title,
      description: n.description,
      timestamp: n.timestamp,
      unread: false,
    )).toList();
    notifyListeners();
  }

  // ── Doctor filtering ──────────────────────────────────────────────────────────
  void setSpecialtyFilter(String s) {
    _specialtyFilter = s;
    notifyListeners();
  }

  void setCityFilter(String c) {
    _cityFilter = c;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  List<Doctor> get filteredDoctors {
    return kDoctors.where((d) {
      final matchCity      = _cityFilter      == 'All' || d.city      == _cityFilter;
      final matchSpecialty = _specialtyFilter == 'All' || d.specialty == _specialtyFilter;
      final matchSearch    = _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.specialty.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCity && matchSpecialty && matchSearch;
    }).toList();
  }

  // ── Booking ───────────────────────────────────────────────────────────────────
  void selectDoctor(Doctor d) {
    _selectedDoctor = d;
    _selectedDate  = '';
    _selectedTime  = '';
    notifyListeners();
  }

  void setBookingDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setBookingTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  void setConsultationType(String type) {
    _consultationType = type;
    notifyListeners();
  }

  // ── Symptom ───────────────────────────────────────────────────────────────────
  void setSymptomInput(String s) {
    _symptomInput = s;
    notifyListeners();
  }

  // ── Water / mood ──────────────────────────────────────────────────────────────
  void incrementWater() {
    _waterGlasses++;
    notifyListeners();
  }

  void setMood(String mood) {
    _selectedMood = mood;
    notifyListeners();
  }
}
