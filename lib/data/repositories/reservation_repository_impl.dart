import 'package:car_reservation_app/data/api/api_service.dart';
import 'package:car_reservation_app/domain/repositories/reservation_repository.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ApiService _apiService;

  ReservationRepositoryImpl(this._apiService);

  @override
  Future<void> submitReservation(Map<String, dynamic> reservationData) async {
    await _apiService.submitReservation(reservationData);
  }
}
