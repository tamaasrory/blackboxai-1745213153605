abstract class VolunteerReservationRepository {
  Future<List<dynamic>> getReservations();
  Future<void> joinReservation(String reservationId);
  Future<void> processReservation(String reservationId);
  Future<void> finishReservation(String reservationId, String description, List<String> photoUrls);
}
