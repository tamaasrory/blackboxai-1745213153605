import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:car_reservation_app/data/api/api_service.dart';
import 'package:car_reservation_app/data/repositories/reservation_repository_impl.dart';
import 'package:car_reservation_app/domain/repositories/reservation_repository.dart';
import 'package:car_reservation_app/presentation/providers/auth_provider.dart';

final dioProvider = Provider((ref) {
  final dio = ApiService.createDio();
  return dio;
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReservationRepositoryImpl(ApiService(dio));
});

final reservationNotifierProvider = StateNotifierProvider<ReservationNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  return ReservationNotifier(repository);
});

class ReservationNotifier extends StateNotifier<AsyncValue<void>> {
  final ReservationRepository _repository;

  ReservationNotifier(this._repository) : super(const AsyncData(null));

  Future<void> submitReservation(Map<String, dynamic> reservationData) async {
    state = const AsyncLoading();
    try {
      await _repository.submitReservation(reservationData);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
