// ─── Book Appointment Screen ──────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/doctor.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/app_state_provider.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});
  @override State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  // Step 0=list, 1=details, 2=confirm, 3=success
  int _step = 0;

  // Available date slots
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
      default: return 'Book Appointment';
    }
  }

  Widget _buildStep(AppStateProvider app) {
    switch (_step) {
      case 0: return _DoctorListStep(app: app, onSelectDoctor: (d) {
        app.selectDoctor(d);
        setState(() => _step = 1);
      });
      case 1: return _DoctorDetailsStep(
        doctor: app.selectedDoctor!,
        dates: _dates,
        times: _times,
        app: app,
        onProceed: () => setState(() => _step = 2),
      );
      case 2: return _ConfirmStep(
        doctor: app.selectedDoctor!,
        date: app.selectedDate,
        time: app.selectedTime,
        type: app.consultationType,
        onConfirm: () => setState(() => _step = 3),
      );
      case 3: return _SuccessStep(doctor: app.selectedDoctor!);
      default: return const SizedBox();
    }
  }
}

// ── Doctor list ───────────────────────────────────────────────────────────────

class _DoctorListStep extends StatelessWidget {
  final AppStateProvider app;
  final void Function(Doctor) onSelectDoctor;
  const _DoctorListStep({required this.app, required this.onSelectDoctor});

  static const _specialties = ['All', 'Cardiologist', 'Dermatologist', 'Ophthalmologist', 'Neurologist', 'Dentist', 'Orthodontist'];
  static const _cities = ['All', 'New York', 'Los Angeles', 'Chicago'];
  static const _hospitals = ['All', 'City Medical Center', 'Beverly Hills Clinic', 'Northwestern Hospital', 'Manhattan Eye Care', 'Chicago Neuro Center', 'LA Dental Studio'];

  @override
  Widget build(BuildContext context) {
    final doctors = app.filteredDoctors;
    return Column(
      children: [
        // AI Search Banner
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E7FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Color(0xFF6366F1), size: 16),
                  SizedBox(width: 6),
                  Text('Find the Right Doctor, Faster.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4338CA))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Describe your condition in natural language...',
                        hintStyle: TextStyle(fontSize: 12),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xFFE0E7FF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xFFE0E7FF)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Icon(Icons.search_rounded, size: 18),
                  ),
                ],
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
                onChanged: app.setSearchQuery,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _Dropdown(
                    value: app.specialtyFilter,
                    items: _specialties,
                    onChanged: app.setSpecialtyFilter,
                    hint: 'Specialty',
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _Dropdown(
                    value: app.cityFilter,
                    items: _cities,
                    onChanged: app.setCityFilter,
                    hint: 'City',
                  )),
                ],
              ),
              const SizedBox(height: 8),
              _Dropdown(
                value: _hospitals.first,
                items: _hospitals,
                onChanged: (_) {},
                hint: 'Hospital',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: doctors.length,
            itemBuilder: (_, i) => _DoctorCard(
              doctor: doctors[i],
              onTap: () => onSelectDoctor(doctors[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String) onChanged;
  final String hint;
  const _Dropdown({required this.value, required this.items, required this.onChanged, required this.hint});

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

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = doctor.onlineStatus == 'Online' ? AppColors.successGreen
        : doctor.onlineStatus == 'Busy' ? AppColors.warningAmber
        : AppColors.textSecondary;

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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.successGreen,
                        border: Border.all(color: Colors.white, width: 1.5)),
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
                      Text(doctor.onlineStatus,
                          style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500)),
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
                Text('${doctor.experience} yrs exp',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Doctor details + slot selection ──────────────────────────────────────────

class _DoctorDetailsStep extends StatelessWidget {
  final Doctor doctor;
  final List<String> dates;
  final List<String> times;
  final AppStateProvider app;
  final VoidCallback onProceed;
  const _DoctorDetailsStep({required this.doctor, required this.dates, required this.times, required this.app, required this.onProceed});

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(doctor.specialty, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('${doctor.experience} years exp • ${doctor.hospital}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Consultation type
          const Text('Consultation Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TypeChip(label: 'In-Person', selected: app.consultationType == 'In-Person', enabled: true, onTap: () => app.setConsultationType('In-Person')),
              _TypeChip(label: 'Video Call', selected: app.consultationType == 'Video Call', enabled: doctor.videoAvailable, onTap: doctor.videoAvailable ? () => app.setConsultationType('Video Call') : null),
              _TypeChip(label: 'Home Visit', selected: app.consultationType == 'Home Visit', enabled: doctor.homeVisit, onTap: doctor.homeVisit ? () => app.setConsultationType('Home Visit') : null),
            ],
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

// ── Confirm + Success ─────────────────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  final Doctor doctor;
  final String date, time, type;
  final VoidCallback onConfirm;
  const _ConfirmStep({required this.doctor, required this.date, required this.time, required this.type, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Booking Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const Divider(height: 20),
              _Row('Doctor', doctor.name),
              _Row('Specialty', doctor.specialty),
              _Row('Date', date),
              _Row('Time', time),
              _Row('Type', type),
              _Row('Fee', '\$${doctor.fee.toInt()}'),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onConfirm, child: const Text('Confirm Booking'))),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String k, v;
  const _Row(this.k, this.v);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    ]),
  );
}

class _SuccessStep extends StatelessWidget {
  final Doctor doctor;
  const _SuccessStep({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppColors.successGreen, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Booking Confirmed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Your appointment with ${doctor.name} has been booked.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
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
// ── Type chip ─────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  const _TypeChip({required this.label, required this.selected, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = enabled && selected;
    final color = active ? AppColors.primaryBlue : (enabled ? AppColors.textPrimary : AppColors.textSecondary);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? AppColors.primaryBlue : AppColors.border),
          ),
          child: Text(label, style: TextStyle(color: active ? Colors.white : color, fontSize: 13)),
        ),
      ),
    );
  }
}