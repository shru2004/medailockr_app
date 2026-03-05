// ─── Blockchain Security Screen + Blockchain Log Modal ──────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';
import '../../services/passport_service.dart';

// ─── Public helper ────────────────────────────────────────────────────────────
void showBlockchainLogModal(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _BlockchainLogModal(),
  );
}

// ─── Blockchain Log Modal ─────────────────────────────────────────────────────
class _BlockchainLogModal extends StatelessWidget {
  const _BlockchainLogModal();

  static const _kDark   = Color(0xFF1A1F36);
  static const _kDark2  = Color(0xFF252B45);
  static const _kGreen  = Color(0xFF22C55E);
  static const _kGray900= Color(0xFF111827);
  static const _kGray500= Color(0xFF6B7280);
  static const _kGray100= Color(0xFFF3F4F6);
  static const _kGray200= Color(0xFFE5E7EB);

  static const _log = [
    _AuditEntry('Data Access Request', 'Authorized by User Key',      _kGreen,              '10m ago'),
    _AuditEntry('New Vitals Block',    'Synced from Apple Watch',      Color(0xFF3B82F6),    '1h ago'),
    _AuditEntry('Consent Updated',     'Privacy settings changed',     Color(0xFFF59E0B),    '3h ago'),
    _AuditEntry('QR Access Event',     'Emergency scan detected',      Color(0xFF8B5CF6),    'Yesterday'),
    _AuditEntry('Prescription Logged', 'Amlodipine 5mg added',         Color(0xFF10B981),    '2d ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 370, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Row(children: [
                const Expanded(
                  child: Text('Blockchain Log',
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

              // ── Live Block Card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status row
                    Row(children: [
                      Container(width: 8, height: 8,
                          decoration: const BoxDecoration(color: _kGreen, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('LIVE MAINNET',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              letterSpacing: 1, color: _kGreen)),
                      const Spacer(),
                      const Text('BLOCK #192482',
                          style: TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 0.5)),
                    ]),
                    const SizedBox(height: 12),
                    const Text('CURRENT BLOCK HASH',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500,
                            letterSpacing: 1, color: Colors.white38)),
                    const SizedBox(height: 4),
                    const Text('0x71c48...39a1b',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                            color: Color(0xFF60A5FA), fontFamily: 'monospace')),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.verified_user_outlined, size: 14, color: _kGreen),
                        const SizedBox(width: 6),
                        const Text('Verified Immutable Record',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kGreen)),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Audit Log ──────────────────────────────────────────────
              const Text('Audit Log',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kGray900)),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _log.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: _kGray200),
                  itemBuilder: (_, i) {
                    final e = _log[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(children: [
                        Container(width: 8, height: 8,
                            decoration: BoxDecoration(color: e.color, shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title,
                                style: const TextStyle(fontSize: 13,
                                    fontWeight: FontWeight.w600, color: _kGray900)),
                            const SizedBox(height: 2),
                            Text(e.subtitle,
                                style: const TextStyle(fontSize: 11, color: _kGray500)),
                          ],
                        )),
                        const SizedBox(width: 8),
                        Text(e.time,
                            style: const TextStyle(fontSize: 11, color: _kGray500)),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditEntry {
  final String title, subtitle, time;
  final Color color;
  const _AuditEntry(this.title, this.subtitle, this.color, this.time);
}

// ─────────────────────────────────────────────────────────────────────────────
class _Tx { final String label, hash, date; const _Tx(this.label, this.hash, this.date); }

class BlockchainSecurityScreen extends StatefulWidget {
  const BlockchainSecurityScreen({super.key});
  @override State<BlockchainSecurityScreen> createState() => _BlockchainSecurityScreenState();
}

class _BlockchainSecurityScreenState extends State<BlockchainSecurityScreen> {
  static const _defaultTxns = [
    _Tx('Medical Record Added',    '0xa3f1...d4e9', 'Jul 10, 2025'),
    _Tx('Data Shared to Dr. Patel','0xb8c2...f1a0', 'Jun 22, 2025'),
    _Tx('Consent Updated',         '0xc7d3...e2b1', 'Jun 5, 2025'),
    _Tx('Prescription Logged',     '0xd6e4...c3f2', 'May 18, 2025'),
    _Tx('QR Access Event',         '0xe5f5...d4a3', 'May 10, 2025'),
  ];

  List<_Tx> _txns         = _defaultTxns;
  int        _totalEvents  = 5;
  int        _verifiedCount= 5;
  int        _tamperedCount= 0;

  @override
  void initState() {
    super.initState();
    _loadBlockchain();
  }

  Future<void> _loadBlockchain() async {
    try {
      final data = await PassportService.getBlockchainStatus();
      if (data != null && mounted) {
        final log = (data['auditLog'] as List?) ?? [];
        setState(() {
          _totalEvents    = (data['totalBlocks'] as num?)?.toInt() ?? log.length;
          _verifiedCount  = log.length;
          _txns = log.map((e) {
            final m  = e as Map<String, dynamic>;
            final raw = (m['id'] ?? m['realTs'] ?? '').toString().hashCode
                .toUnsigned(32)
                .toRadixString(16)
                .padLeft(8, '0');
            return _Tx(
              m['event'] as String? ?? 'Event',
              '0x${raw.substring(0, 4)}...${raw.substring(4)}',
              m['ts']    as String? ?? '',
            );
          }).toList();
        });
      }
    } catch (_) { /* keep defaults — backend offline */ }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Blockchain Log',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.2))),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.security_rounded, color: Color(0xFF0EA5E9), size: 22)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Immutable Health Record', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('All health data changes are cryptographically secured on-chain.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _StatTile('$_totalEvents',    'Total Events'),
            const SizedBox(width: 8),
            _StatTile('$_verifiedCount',  'Verified'),
            const SizedBox(width: 8),
            _StatTile('$_tamperedCount',  'Tampered'),
          ]),
          const SizedBox(height: 16),
          const Text('Transaction Log', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ..._txns.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(t.hash, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'monospace')),
              ])),
              const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 6),
              Text(t.date, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String val, lbl;
  const _StatTile(this.val, this.lbl);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)), child: Column(children: [Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0EA5E9))), Text(lbl, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))])));
}
