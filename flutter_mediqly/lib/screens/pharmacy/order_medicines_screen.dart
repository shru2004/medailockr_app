// ─── Order Medicines Screen ──────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

class OrderMedicinesScreen extends StatefulWidget {
  const OrderMedicinesScreen({super.key});
  @override
  State<OrderMedicinesScreen> createState() => _OrderMedicinesScreenState();
}

class _OrderMedicinesScreenState extends State<OrderMedicinesScreen> {
  final _search = TextEditingController();
  final List<_MedItem> _cart = [];

  void _add(_MedItem m) {
    setState(() {
      final idx = _cart.indexWhere((e) => e.name == m.name);
      if (idx == -1) {
        _cart.add(_MedItem(m.name, m.price, m.type, m.rx, 1));
      } else {
        _cart[idx] = _MedItem(_cart[idx].name, _cart[idx].price, _cart[idx].type, _cart[idx].rx, _cart[idx].qty + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _cart.fold(0.0, (s, e) => s + e.price * e.qty);
    return PageWrapper(
      title: 'Order Medicines',
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: _SearchBar(controller: _search, onChanged: (_) => setState(() {})),
        ),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemCount: _kMedicines.length,
          itemBuilder: (_, i) {
            final m = _kMedicines[i];
            final query = _search.text.toLowerCase();
            if (query.isNotEmpty && !m.name.toLowerCase().contains(query)) return const SizedBox.shrink();
            final cartItem = _cart.where((c) => c.name == m.name).firstOrNull;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.medication_rounded, color: Color(0xFF10B981), size: 22)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(m.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (m.rx) ...[const SizedBox(width: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: const Text('Rx', style: TextStyle(fontSize: 9, color: Color(0xFFEF4444), fontWeight: FontWeight.w700)))],
                  ]),
                  Text(m.type, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹${m.price}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  if (cartItem == null)
                    GestureDetector(onTap: () => _add(m), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(20)), child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))))
                  else
                    Text('×${cartItem.qty}', style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                ]),
              ]),
            );
          },
        )),
        if (_cart.isNotEmpty) Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(children: [
            Expanded(child: Text('${_cart.length} items · ₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed!'))),
              child: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;
  const _SearchBar({required this.controller, required this.onChanged});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary), hintText: 'Search medicines…', hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary), filled: true, fillColor: AppColors.bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
  );
}

class _MedItem {
  final String name, type;
  final double price;
  final bool rx;
  final int qty;
  const _MedItem(this.name, this.price, this.type, this.rx, this.qty);
}

const _kMedicines = [
  _MedItem('Paracetamol 500mg', 18, 'Tablet · 10s', false, 0),
  _MedItem('Amlodipine 5mg', 42, 'Tablet · 10s', true, 0),
  _MedItem('Cetirizine 10mg', 24, 'Tablet · 10s', false, 0),
  _MedItem('Metformin 500mg', 55, 'Tablet · 15s', true, 0),
  _MedItem('Azithromycin 500mg', 88, 'Tablet · 3s', true, 0),
  _MedItem('Vitamin D3 60K', 120, 'Capsule · 4s', false, 0),
  _MedItem('Omeprazole 20mg', 35, 'Capsule · 10s', false, 0),
  _MedItem('Ibuprofen 400mg', 22, 'Tablet · 10s', false, 0),
];
