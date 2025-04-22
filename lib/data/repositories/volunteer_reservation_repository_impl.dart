import 'package:car_reservation_app/data/api/api_service.dart';
import 'package:car_reservation_app/domain/repositories/volunteer_reservation_repository.dart';

class VolunteerReservationRepositoryImpl implements VolunteerReservationRepository {
  final ApiService _apiService;

  VolunteerReservationRepositoryImpl(this._apiService);

  @override
  Future<List<dynamic>> getReservations() async {
    return await _apiService.getReservations();
  }

  @override
  Future<void> joinReservation(String reservationId) async {
    await _apiService.joinReservation(reservationId);
  }

  @override
  Future<void> processReservation(String reservationId) async {
    await _apiService.processReservation(reservationId);
  }

  @override
  Future<void> finishReservation(String reservationId, String description, List<String> photoUrls) async {
    await _apiService.finishReservation(reservationId, description, photoUrls);
  }
}
