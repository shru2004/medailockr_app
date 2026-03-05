// ─── Data Sharing Screen ─────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public helper — show the Global Access modal
// ─────────────────────────────────────────────────────────────────────────────
void showGlobalAccessModal(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _GlobalAccessModal(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Global Access Modal
// ─────────────────────────────────────────────────────────────────────────────
class _GlobalAccessModal extends StatefulWidget {
  const _GlobalAccessModal();
  @override
  State<_GlobalAccessModal> createState() => _GlobalAccessModalState();
}

class _GlobalAccessModalState extends State<_GlobalAccessModal> {
  final _recipientCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  final _allTypes = ['Medications', 'History', 'Vitals', 'Allergies', 'Lab Results'];
  final _selectedTypes = <String>{'Medications', 'History', 'Vitals'};

  final _durations = ['1 Hour', '24 Hours', '7 Days', '30 Days', 'Indefinite'];
  String _selectedDuration = '24 Hours';

  bool _generated = false;

  static const _kBlue = Color(0xFF3B82F6);
  static const _kGray100 = Color(0xFFF3F4F6);
  static const _kGray300 = Color(0xFFD1D5DB);
  static const _kGray500 = Color(0xFF6B7280);
  static const _kGray900 = Color(0xFF111827);

  @override
  void dispose() {
    _recipientCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  final Map<String, IconData> _typeIcons = const {
    'Medications': Icons.medication_outlined,
    'History': Icons.history_outlined,
    'Vitals': Icons.monitor_heart_outlined,
    'Allergies': Icons.warning_amber_outlined,
    'Lab Results': Icons.science_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Row(children: [
                const Expanded(
                  child: Text('Global Access',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kGray900)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(color: _kGray100, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: _kGray500),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 16),

              if (_generated) ...[
                _buildSuccess()
              ] else ...[
                // ── Sub-header ────────────────────────────────────────────
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.chevron_left, size: 20, color: _kGray500),
                  ),
                  const SizedBox(width: 4),
                  const Text('New Access Grant',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _kGray900)),
                ]),
                const SizedBox(height: 20),

                // ── Recipient ──────────────────────────────────────────────
                const Text('RECIPIENT',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _kGray500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _recipientCtrl,
                  style: const TextStyle(fontSize: 14, color: _kGray900),
                  decoration: InputDecoration(
                    hintText: 'Doctor, Hospital, or Email',
                    hintStyle: const TextStyle(fontSize: 14, color: _kGray500),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kGray300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kGray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kBlue, width: 1.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Data Types ─────────────────────────────────────────────
                const Text('DATA TYPES',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _kGray500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allTypes.map((t) {
                    final selected = _selectedTypes.contains(t);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) _selectedTypes.remove(t);
                        else _selectedTypes.add(t);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? _kBlue.withValues(alpha: 0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? _kBlue.withValues(alpha: 0.4) : _kGray300,
                          ),
                        ),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(_typeIcons[t]!, size: 18,
                              color: selected ? _kBlue : _kGray500),
                          const SizedBox(height: 4),
                          Text(t,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: selected ? _kBlue : _kGray900)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ── Duration ───────────────────────────────────────────────
                const Text('DURATION',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _kGray500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _durations.map((d) {
                    final sel = _selectedDuration == d;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDuration = d),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: sel ? _kGray900 : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: sel ? _kGray900 : _kGray300),
                        ),
                        child: Text(d,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : _kGray900)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // ── Custom Date ────────────────────────────────────────────
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _dateCtrl.text =
                            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kGray300),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: _kGray500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dateCtrl.text.isEmpty ? 'mm/dd/yyyy' : _dateCtrl.text,
                          style: TextStyle(
                              fontSize: 13,
                              color: _dateCtrl.text.isEmpty ? _kGray500 : _kGray900),
                        ),
                      ),
                      const Text('CUSTOM DATE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                              color: _kGray500, letterSpacing: 0.5)),
                    ]),
                  ),
                ),
                const SizedBox(height: 22),

                // ── Generate Button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _generated = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Generate Access Key',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF22C55E), size: 36),
        ),
        const SizedBox(height: 14),
        const Text('Access Key Generated!',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _kGray900)),
        const SizedBox(height: 8),
        Text(
          'Access has been granted to the recipient for ${_selectedDuration.toLowerCase()}.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: _kGray500, height: 1.5),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_recipientCtrl.text.isNotEmpty) ...[
              const Text('RECIPIENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _kGray500)),
              const SizedBox(height: 2),
              Text(_recipientCtrl.text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kGray900)),
              const SizedBox(height: 8),
            ],
            const Text('DATA TYPES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _kGray500)),
            const SizedBox(height: 2),
            Text(_selectedTypes.join(', '), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kGray900)),
            const SizedBox(height: 8),
            const Text('DURATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _kGray500)),
            const SizedBox(height: 2),
            Text(_selectedDuration, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kGray900)),
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Done', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DataSharingScreen
// ─────────────────────────────────────────────────────────────────────────────
class DataSharingScreen extends StatefulWidget {
  const DataSharingScreen({super.key});
  @override
  State<DataSharingScreen> createState() => _DataSharingScreenState();
}

class _DataSharingScreenState extends State<DataSharingScreen> {
  final _perms = {
    'Primary Care Doctor': true,
    'Specialist (Dr. Patel)': true,
    'Insurance Provider': false,
    'Pharmacy Network': true,
    'Research Studies': false,
    'Emergency Services': true,
  };

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Data Sharing',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
            ),
            child: const Text(
              'Control exactly who can access your health data. All sharing is encrypted end-to-end.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
          const SizedBox(height: 14),

          // ── Global Access Button ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => showGlobalAccessModal(context),
              icon: const Icon(Icons.language_rounded, size: 18),
              label: const Text('Grant Global Access',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Access Permissions',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ..._perms.entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: [
                  Expanded(child: Text(e.key,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                  Switch(
                    value: e.value,
                    onChanged: (v) => setState(() => _perms[e.key] = v),
                    activeThumbColor: AppColors.primaryBlue,
                  ),
                ]),
              )),
          const SizedBox(height: 12),

          const Text('Recent Shares',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ..._shares.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: [
                  const Icon(Icons.share_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.$1, style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text(s.$2, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ]),
                  ),
                  Text(s.$3, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ]),
              )),
        ]),
      ),
    );
  }

  static const _shares = [
    ('Blood Report shared', 'Dr. Priya Patel · Cardiology', '2 hrs ago'),
    ('Prescription shared', 'MedPlus Pharmacy', 'Yesterday'),
    ('Vitals export', 'StarHealth Insurance', '3 days ago'),
  ];
}
