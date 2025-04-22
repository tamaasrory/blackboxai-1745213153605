import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:car_reservation_app/data/api/api_service.dart';
import 'package:car_reservation_app/data/repositories/volunteer_reservation_repository_impl.dart';
import 'package:car_reservation_app/domain/repositories/volunteer_reservation_repository.dart';

final dioProvider = Provider((ref) {
  final dio = ApiService.createDio();
  return dio;
});

final volunteerReservationRepositoryProvider = Provider<VolunteerReservationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VolunteerReservationRepositoryImpl(ApiService(dio));
});

final volunteerReservationNotifierProvider = StateNotifierProvider<VolunteerReservationNotifier, AsyncValue<List<dynamic>>>((ref) {
  final repository = ref.watch(volunteerReservationRepositoryProvider);
  return VolunteerReservationNotifier(repository);
});

class VolunteerReservationNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final VolunteerReservationRepository _repository;

  VolunteerReservationNotifier(this._repository) : super(const AsyncLoading()) {
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    try {
      final reservations = await _repository.getReservations();
      state = AsyncData(reservations);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> joinReservation(String reservationId) async {
    try {
      await _repository.joinReservation(reservationId);
      await fetchReservations();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> processReservation(String reservationId) async {
    try {
      await _repository.processReservation(reservationId);
      await fetchReservations();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> finishReservation(String reservationId, String description, List<String> photoUrls) async {
    try {
      await _repository.finishReservation(reservationId, description, photoUrls);
      await fetchReservations();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
