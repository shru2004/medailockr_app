// ─── Home Visit Screen ───────────────────────────────────────────────────────
// but pre-filtered to doctors where homeVisit == true

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/doctor.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/app_state_provider.dart';

class HomeVisitScreen extends StatefulWidget {
  const HomeVisitScreen({super.key});
  @override
  State<HomeVisitScreen> createState() => _HomeVisitScreenState();
}

class _HomeVisitScreenState extends State<HomeVisitScreen> {
  int _step = 0;

  static const _dates = ['Mon, Jul 14', 'Tue, Jul 15', 'Wed, Jul 16', 'Thu, Jul 17', 'Fri, Jul 18'];
  static const _times = ['9:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM', '4:00 PM'];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_step > 0) { setState(() => _step--); return; }
        context.read<NavigationProvider>().goBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
            onPressed: () {
              if (_step > 0) { setState(() => _step--); }
              else { context.read<NavigationProvider>().goBack(); }
            },
          ),
          title: Text(_stepTitle(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: AppColors.border)),
        ),
        body: _buildStep(app),
      ),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 1: return 'Doctor Details';
      case 2: return 'Confirm Booking';
      case 3: return 'Booking Confirmed';
      default: return 'Home Visit';
    }
  }

  Widget _buildStep(AppStateProvider app) {
    switch (_step) {
      case 0:
        return _HVDoctorListStep(onSelectDoctor: (d) {
          app.selectDoctor(d);
          app.setConsultationType('Home Visit');
          setState(() => _step = 1);
        });
      case 1:
        return _HVDoctorDetailsStep(
          doctor: app.selectedDoctor!,
          dates: _dates,
          times: _times,
          app: app,
          onProceed: () => setState(() => _step = 2),
        );
      case 2:
        return _HVConfirmStep(
          doctor: app.selectedDoctor!,
          date: app.selectedDate,
          time: app.selectedTime,
          type: app.consultationType,
          onConfirm: () => setState(() => _step = 3),
        );
      case 3:
        return _HVSuccessStep(doctor: app.selectedDoctor!);
      default:
        return const SizedBox();
    }
  }
}

// ── Doctor list (home-visit filtered) ────────────────────────────────────────

class _HVDoctorListStep extends StatefulWidget {
  final void Function(Doctor) onSelectDoctor;
  const _HVDoctorListStep({required this.onSelectDoctor});
  @override
  State<_HVDoctorListStep> createState() => _HVDoctorListStepState();
}

class _HVDoctorListStepState extends State<_HVDoctorListStep> {
  static const _specialties = ['All', 'Cardiologist', 'Dermatologist', 'Neurologist'];
  static const _cities = ['All', 'New York', 'Los Angeles', 'Chicago'];

  String _searchQuery = '';
  String _specialty = 'All';
  String _city = 'All';

  List<Doctor> get _doctors {
    return kDoctors.where((d) {
      if (!d.homeVisit) return false;
      if (_specialty != 'All' && d.specialty != _specialty) return false;
      if (_city != 'All' && d.city != _city) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!d.name.toLowerCase().contains(q) && !d.specialty.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _doctors;
    return Column(
      children: [
        // Info banner
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            children: [
              Icon(Icons.home_rounded, color: Color(0xFF1E40AF), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'A certified doctor will visit your home at your preferred time.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                ),
              ),
            ],
          ),
        ),
        // Filters
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search doctor or specialty...',
                  prefixIcon: Icon(Icons.search_rounded, size: 18),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _HVDropdown(
                    value: _specialty,
                    items: _specialties,
                    hint: 'Specialty',
                    onChanged: (v) => setState(() => _specialty = v),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _HVDropdown(
                    value: _city,
                    items: _cities,
                    hint: 'City',
                    onChanged: (v) => setState(() => _city = v),
                  )),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: doctors.isEmpty
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No doctors available for home visit with these filters.',
                      style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: doctors.length,
                  itemBuilder: (_, i) => _HVDoctorCard(
                    doctor: doctors[i],
                    onTap: () => widget.onSelectDoctor(doctors[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _HVDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final String hint;
  final void Function(String) onChanged;
  const _HVDropdown({required this.value, required this.items, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}

class _HVDoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  const _HVDoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(radius: 26, backgroundImage: NetworkImage(doctor.image)),
                if (doctor.onlineStatus == 'Online')
                  Positioned(right: 0, bottom: 0, child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.successGreen,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  )),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(doctor.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      if (doctor.verified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: AppColors.primaryBlue, size: 14),
                      ],
                    ],
                  ),
                  Text(doctor.specialty,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 13),
                      Text(' ${doctor.rating} (${doctor.reviewsCount})',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.border)),
                      const SizedBox(width: 8),
                      Text(doctor.city, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${doctor.fee.toInt()}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                const Text('per visit', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Home Visit', style: TextStyle(fontSize: 9, color: Color(0xFF16A34A), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Doctor details + slot selection ──────────────────────────────────────────

class _HVDoctorDetailsStep extends StatelessWidget {
  final Doctor doctor;
  final List<String> dates;
  final List<String> times;
  final AppStateProvider app;
  final VoidCallback onProceed;
  const _HVDoctorDetailsStep({required this.doctor, required this.dates, required this.times, required this.app, required this.onProceed});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor info card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                CircleAvatar(radius: 30, backgroundImage: NetworkImage(doctor.image)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(doctor.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          if (doctor.verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, color: AppColors.primaryBlue, size: 14),
                          ],
                        ],
                      ),
                      Text(doctor.specialty, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('${doctor.experience} years exp • ${doctor.hospital}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Consultation type — locked to Home Visit
          const Text('Consultation Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home_rounded, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Home Visit', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Date slots
          const Text('Select Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: dates.map((d) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => app.setBookingDate(d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: app.selectedDate == d ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: app.selectedDate == d ? AppColors.primaryBlue : AppColors.border),
                    ),
                    child: Text(d, style: TextStyle(color: app.selectedDate == d ? Colors.white : AppColors.textPrimary, fontSize: 12)),
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Time slots
          const Text('Select Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: times.map((t) => GestureDetector(
              onTap: () => app.setBookingTime(t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: app.selectedTime == t ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: app.selectedTime == t ? AppColors.primaryBlue : AppColors.border),
                ),
                child: Text(t, style: TextStyle(color: app.selectedTime == t ? Colors.white : AppColors.textPrimary, fontSize: 12)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (app.selectedDate.isNotEmpty && app.selectedTime.isNotEmpty) ? onProceed : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confirm ───────────────────────────────────────────────────────────────────

class _HVConfirmStep extends StatelessWidget {
  final Doctor doctor;
  final String date, time, type;
  final VoidCallback onConfirm;
  const _HVConfirmStep({required this.doctor, required this.date, required this.time, required this.type, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Booking Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const Divider(height: 20),
                _HVRow('Doctor', doctor.name),
                _HVRow('Specialty', doctor.specialty),
                _HVRow('Type', type),
                _HVRow('Date', date),
                _HVRow('Time', time),
                _HVRow('Fee', '\$${doctor.fee.toInt()}'),
                const _HVRow('Location', 'Your home address'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The doctor will arrive at your registered home address. Please ensure someone is available.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFD97706)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              child: const Text('Confirm Home Visit'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HVRow extends StatelessWidget {
  final String k, v;
  const _HVRow(this.k, this.v);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    ]),
  );
}

// ── Success ───────────────────────────────────────────────────────────────────

class _HVSuccessStep extends StatelessWidget {
  final Doctor doctor;
  const _HVSuccessStep({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppColors.successGreen, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Home Visit Booked!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Your home visit with ${doctor.name} has been confirmed. The doctor will arrive at your scheduled time.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.read<NavigationProvider>().goHome(),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
