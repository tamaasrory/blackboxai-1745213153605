import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:car_reservation_app/presentation/providers/reservation_provider.dart';

class ReservationFormPage extends ConsumerStatefulWidget {
  const ReservationFormPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends ConsumerState<ReservationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDateTime;

  String? _errorMessage;
  String? _successMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateTime == null) {
      setState(() {
        _errorMessage = 'Please select a date and time';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final reservationNotifier = ref.read(reservationNotifierProvider.notifier);

    final reservationData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'location': _locationController.text.trim(),
      'time': _selectedDateTime!.toIso8601String(),
      'notes': _notesController.text.trim(),
    };

    try {
      await reservationNotifier.submitReservation(reservationData);
      setState(() {
        _successMessage = 'Reservation submitted successfully!';
        _errorMessage = null;
        _nameController.clear();
        _phoneController.clear();
        _locationController.clear();
        _notesController.clear();
        _selectedDateTime = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit reservation. Please try again.';
        _successMessage = null;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservationState = ref.watch(reservationNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reservasi Mobil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (reservationState is AsyncLoading)
                const LinearProgressIndicator(),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              if (_successMessage != null)
                Text(_successMessage!, style: const TextStyle(color: Colors.green)),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) => value == null || value.isEmpty ? 'Masukkan nama' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'No HP'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Masukkan nomor HP' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (value) => value == null || value.isEmpty ? 'Masukkan lokasi' : null,
              ),
              ListTile(
                title: Text(_selectedDateTime == null
                    ? 'Pilih Waktu'
                    : 'Waktu: \${_selectedDateTime!.toLocal()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Catatan'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: reservationState is AsyncLoading ? null : _submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
