// ─── Medical Vault Screen ────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../widgets/page_wrapper.dart';
import '../../services/passport_service.dart';

// ── Data model ──────────────────────────────────────────────────────────────
enum _StatusType { verified, resultsReady, archived }

class _VaultRecord {
  final int id;
  final String diagnosis, treatment, provider, facility, date, notes, category;
  final IconData icon;
  final Color iconColor;
  final _StatusType status;

  const _VaultRecord({
    required this.id,
    required this.diagnosis,
    required this.treatment,
    required this.provider,
    required this.facility,
    required this.date,
    required this.notes,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.status,
  });

  factory _VaultRecord.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as String? ?? 'visits';
    IconData icon;
    Color iconColor;
    switch (cat) {
      case 'lab results':
        icon = Icons.monitor_heart_rounded;
        iconColor = const Color(0xFF8B5CF6);
        break;
      case 'vaccines':
        icon = Icons.shield_rounded;
        iconColor = const Color(0xFF10B981);
        break;
      default:
        icon = Icons.description_rounded;
        iconColor = const Color(0xFF3B82F6);
    }
    _StatusType status;
    switch (json['status'] as String? ?? 'verified') {
      case 'results_ready':
        status = _StatusType.resultsReady;
        break;
      case 'archived':
        status = _StatusType.archived;
        break;
      default:
        status = _StatusType.verified;
    }
    return _VaultRecord(
      id:        (json['id'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      diagnosis: json['diagnosis'] as String? ?? '',
      treatment: json['treatment'] as String? ?? '',
      provider:  json['provider']  as String? ?? '',
      facility:  json['facility']  as String? ?? '',
      date:      json['date']      as String? ?? '',
      notes:     json['notes']     as String? ?? '',
      category:  cat,
      icon:      icon,
      iconColor: iconColor,
      status:    status,
    );
  }
}

const _defaultRecords = [
  _VaultRecord(
    id: 1,
    diagnosis: 'Annual Physical',
    treatment: 'General Checkup',
    provider: 'Dr. Sarah Bennett',
    facility: 'Mass General',
    date: 'Jan 12, 2024',
    notes: 'Routine checkup. BP normal.',
    category: 'visits',
    icon: Icons.description_rounded,
    iconColor: Color(0xFF3B82F6),
    status: _StatusType.verified,
  ),
  _VaultRecord(
    id: 2,
    diagnosis: 'Blood Panel',
    treatment: 'Venipuncture',
    provider: 'Quest Diagnostics',
    facility: 'Quest Diagnostics',
    date: 'Oct 30, 2023',
    notes: 'Lipid panel and CBC.',
    category: 'lab results',
    icon: Icons.monitor_heart_rounded,
    iconColor: Color(0xFF8B5CF6),
    status: _StatusType.resultsReady,
  ),
  _VaultRecord(
    id: 3,
    diagnosis: 'Flu Vaccine',
    treatment: 'Vaccination',
    provider: 'CVS Pharmacy',
    facility: 'CVS #1234',
    date: 'Sep 15, 2023',
    notes: 'Seasonal flu shot.',
    category: 'vaccines',
    icon: Icons.shield_rounded,
    iconColor: Color(0xFF10B981),
    status: _StatusType.verified,
  ),
  _VaultRecord(
    id: 4,
    diagnosis: 'Dermatology Consult',
    treatment: 'Skin Examination',
    provider: 'Dr. Emily Chen',
    facility: 'Skin Care Center',
    date: 'Jun 05, 2023',
    notes: 'Follow up on rash.',
    category: 'visits',
    icon: Icons.description_rounded,
    iconColor: Color(0xFF3B82F6),
    status: _StatusType.archived,
  ),
];

// ── Screen ──────────────────────────────────────────────────────────────────
class MedicalVaultScreen extends StatefulWidget {
  const MedicalVaultScreen({super.key});

  @override
  State<MedicalVaultScreen> createState() => _MedicalVaultScreenState();
}

class _MedicalVaultScreenState extends State<MedicalVaultScreen> {
  // ── Backend-loaded records (falls back to static defaults offline) ──────
  List<_VaultRecord> _records = _defaultRecords.toList();
  bool _isLoading = true;
  bool _isSaving  = false;

  String _activeTab = 'all';
  bool _listMode = true;
  String _search = '';
  bool _showAddForm = false;

  // Add-form controllers
  final _diagCtrl = TextEditingController();
  final _treatCtrl = TextEditingController();
  final _provCtrl = TextEditingController();
  final _facCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _newCategory = 'visits';
  DateTime _newDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final data = await PassportService.getRecords();
      if (data.isNotEmpty && mounted) {
        setState(() {
          _records = data
              .whereType<Map<String, dynamic>>()
              .map(_VaultRecord.fromJson)
              .toList();
        });
      }
    } catch (_) {
      // keep default records — backend offline
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRecord() async {
    if (_diagCtrl.text.isEmpty || _provCtrl.text.isEmpty) return;
    setState(() => _isSaving = true);
    final payload = {
      'diagnosis': _diagCtrl.text.trim(),
      'treatment': _treatCtrl.text.trim(),
      'provider':  _provCtrl.text.trim(),
      'facility':  _facCtrl.text.trim(),
      'notes':     _notesCtrl.text.trim(),
      'category':  _newCategory,
      'date':      _newDate.toIso8601String().split('T').first,
      'status':    'verified',
    };
    final saved = await PassportService.addRecord(payload);
    if (mounted) {
      setState(() {
        _records.insert(
            0,
            saved != null
                ? _VaultRecord.fromJson(saved)
                : _VaultRecord.fromJson(payload));
        _isSaving = false;
      });
    }
    _resetForm();
  }

  @override
  void dispose() {
    _diagCtrl.dispose();
    _treatCtrl.dispose();
    _provCtrl.dispose();
    _facCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    _diagCtrl.clear();
    _treatCtrl.clear();
    _provCtrl.clear();
    _facCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      _newCategory = 'visits';
      _newDate = DateTime.now();
      _showAddForm = false;
    });
  }

  static const _tabs = ['All', 'Recent', 'Vaccines', 'Lab Results', 'Visits'];

  List<_VaultRecord> get _filtered {
    var base = _records.where((r) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        return r.diagnosis.toLowerCase().contains(q) ||
            r.provider.toLowerCase().contains(q) ||
            r.facility.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    switch (_activeTab) {
      case 'vaccines':
        return base.where((r) => r.category == 'vaccines').toList();
      case 'lab results':
        return base.where((r) => r.category == 'lab results').toList();
      case 'visits':
        return base.where((r) => r.category == 'visits').toList();
      case 'recent':
        return base.take(3).toList();
      default:
        return base;
    }
  }

  Widget _buildAddForm(BuildContext context) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr =
        '${_newDate.month.toString().padLeft(2,'0')}/${_newDate.day.toString().padLeft(2,'0')}/${_newDate.year}';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Back + title
        Row(
          children: [
            GestureDetector(
              onTap: _resetForm,
              child: const Icon(Icons.chevron_left_rounded, size: 26, color: Color(0xFF374151)),
            ),
            const SizedBox(width: 4),
            const Text('Add New Record',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          ],
        ),
        const SizedBox(height: 20),

        // DIAGNOSIS / CONDITION
        _FormLabel('DIAGNOSIS / CONDITION'),
        _FormField(controller: _diagCtrl, placeholder: 'e.g. Annual Dental Cleaning'),
        const SizedBox(height: 16),

        // TREATMENT / PROCEDURE
        _FormLabel('TREATMENT / PROCEDURE'),
        _FormField(controller: _treatCtrl, placeholder: 'e.g. Scaling & Polishing'),
        const SizedBox(height: 16),

        // PROVIDER + FACILITY
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormLabel('PROVIDER'),
                  _FormField(controller: _provCtrl, placeholder: 'Dr. Name'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormLabel('FACILITY'),
                  _FormField(controller: _facCtrl, placeholder: 'Hospital/Clinic'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // DATE
        _FormLabel('DATE'),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _newDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => _newDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 10),
                Text(dateStr,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
                const Spacer(),
                const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // NOTES
        _FormLabel('NOTES'),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _notesCtrl,
            maxLines: 4,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            decoration: const InputDecoration(
              hintText: 'Add any additional details...',
              hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // CATEGORY
        _FormLabel('CATEGORY'),
        const SizedBox(height: 8),
        Row(
          children: [
            _CatBtn(label: 'Visits', value: 'visits', active: _newCategory,
                onTap: (v) => setState(() => _newCategory = v)),
            const SizedBox(width: 8),
            _CatBtn(label: 'Vaccines', value: 'vaccines', active: _newCategory,
                onTap: (v) => setState(() => _newCategory = v)),
            const SizedBox(width: 8),
            _CatBtn(label: 'Lab Results', value: 'lab results', active: _newCategory,
                onTap: (v) => setState(() => _newCategory = v)),
          ],
        ),
        const SizedBox(height: 24),

        // Save Record
        GestureDetector(
          onTap: _isSaving ? null : _saveRecord,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _isSaving ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Color(0x332563EB), blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSaving)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                  )
                else
                  const Icon(Icons.save_alt_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(_isSaving ? 'Saving…' : 'Save Record',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return PageWrapper(
      title: 'Medical Vault',
      child: _showAddForm
          ? _buildAddForm(context)
          : Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search records...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tabs.map((tab) {
                    final key = tab.toLowerCase();
                    final active = _activeTab == key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (tab == 'Recent') ...[
                                Icon(Icons.access_time_rounded,
                                    size: 12,
                                    color: active ? Colors.white : const Color(0xFF6B7280)),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                tab,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: active ? Colors.white : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Progress bar — animated while loading from backend
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _isLoading ? null : 1.0,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isLoading
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Toolbar: view toggle + export
              Row(
                children: [
                  // Toggle buttons
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _ToggleBtn(
                          icon: Icons.view_list_rounded,
                          active: _listMode,
                          onTap: () => setState(() => _listMode = true),
                        ),
                        const SizedBox(width: 4),
                        _ToggleBtn(
                          icon: Icons.calendar_month_rounded,
                          active: !_listMode,
                          onTap: () => setState(() => _listMode = false),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Export button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download_rounded, size: 14, color: Color(0xFF2563EB)),
                          SizedBox(width: 6),
                          Text('Export',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recent label
              if (_activeTab == 'recent' && filtered.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'SHOWING LATEST 3 RECORDS',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

              // Record list
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text('No records found for this category.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  ),
                )
              else
                ...filtered.map((r) => _RecordCard(record: r)),
            ],
          ),

          // ── FAB ─────────────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: () => setState(() => _showAddForm = true),
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x442563EB),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toggle button ────────────────────────────────────────────────────────────
class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToggleBtn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))]
              : [],
        ),
        child: Icon(icon,
            size: 16,
            color: active ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF)),
      ),
    );
  }
}

// ── Record card ──────────────────────────────────────────────────────────────
class _RecordCard extends StatelessWidget {
  final _VaultRecord record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + title + status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(record.icon, color: record.iconColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.diagnosis,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827))),
                    if (record.treatment.isNotEmpty)
                      Text(record.treatment,
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: record.status),
            ],
          ),
          const SizedBox(height: 8),

          // Provider • Facility
          Text(
            '${record.provider} • ${record.facility}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),

          // Notes box
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Notes: ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    TextSpan(
                      text: record.notes,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Date right-aligned
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(record.date,
                style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
          ),
        ],
      ),
    );
  }
}

// ── Status badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final _StatusType status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      _StatusType.verified => ('VERIFIED', const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      _StatusType.resultsReady =>
        ('RESULTS READY', const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
      _StatusType.archived => ('ARCHIVED', const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

// ── Form helpers ─────────────────────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B7280),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  const _FormField({required this.controller, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

class _CatBtn extends StatelessWidget {
  final String label, value, active;
  final void Function(String) onTap;
  const _CatBtn({required this.label, required this.value, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = active == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
