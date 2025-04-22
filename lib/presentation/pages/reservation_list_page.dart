import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:car_reservation_app/presentation/providers/volunteer_reservation_provider.dart';

class ReservationListPage extends ConsumerWidget {
  const ReservationListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationState = ref.watch(volunteerReservationNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Reservasi')),
      body: reservationState.when(
        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(child: Text('Tidak ada reservasi'));
          }
          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return ReservationCard(reservation: reservation);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: \$error')),
      ),
    );
  }
}

class ReservationCard extends ConsumerWidget {
  final dynamic reservation;

  const ReservationCard({Key? key, required this.reservation}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assuming reservation has fields: id, name, phone, location, time, notes, volunteers, status
    final id = reservation['id'] as String? ?? '';
    final name = reservation['name'] as String? ?? '';
    final phone = reservation['phone'] as String? ?? '';
    final location = reservation['location'] as String? ?? '';
    final time = reservation['time'] as String? ?? '';
    final notes = reservation['notes'] as String? ?? '';
    final volunteers = reservation['volunteers'] as List<dynamic>? ?? [];
    final status = reservation['status'] as String? ?? 'pending';

    final volunteerNotifier = ref.read(volunteerReservationNotifierProvider.notifier);

    bool canJoin = status == 'pending';
    bool canProcess = status == 'joined' && volunteers.length >= 1; // example condition
    bool canFinish = status == 'processing';

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: \$name', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('No HP: \$phone'),
            Text('Lokasi: \$location'),
            Text('Waktu: \$time'),
            if (notes.isNotEmpty) Text('Catatan: \$notes'),
            Text('Relawan Bergabung: \${volunteers.length}'),
            Text('Status: \$status'),
            const SizedBox(height: 10),
            Row(
              children: [
                if (canJoin)
                  ElevatedButton(
                    onPressed: () => volunteerNotifier.joinReservation(id),
                    child: const Text('Bergabung'),
                  ),
                if (canProcess)
                  ElevatedButton(
                    onPressed: () => volunteerNotifier.processReservation(id),
                    child: const Text('Proses'),
                  ),
                if (canFinish)
                  ElevatedButton(
                    onPressed: () {
                      // Show dialog to input description and upload photos
                      showDialog(
                        context: context,
                        builder: (context) => FinishReservationDialog(reservationId: id),
                      );
                    },
                    child: const Text('Selesai'),
                  ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ],
        ),
      ),
    );
  }
}

class FinishReservationDialog extends ConsumerStatefulWidget {
  final String reservationId;

  const FinishReservationDialog({Key? key, required this.reservationId}) : super(key: key);

  @override
  ConsumerState<FinishReservationDialog> createState() => _FinishReservationDialogState();
}

class _FinishReservationDialogState extends ConsumerState<FinishReservationDialog> {
  final _descriptionController = TextEditingController();
  List<String> _photoUrls = []; // For simplicity, just URLs or paths

  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (_descriptionController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Keterangan harus diisi';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(volunteerReservationNotifierProvider.notifier).finishReservation(
            widget.reservationId,
            _descriptionController.text,
            _photoUrls,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengirim bukti. Silakan coba lagi.';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // TODO: Implement multi-image upload UI and logic

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selesaikan Reservasi'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Keterangan'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement image picker and upload
              },
              child: const Text('Upload Foto'),
            ),
            // Display selected photos here
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting ? const CircularProgressIndicator() : const Text('Kirim'),
        ),
      ],
    );
  }
}
