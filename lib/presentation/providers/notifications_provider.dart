import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:car_reservation_app/data/api/websocket_service.dart';

final webSocketUrlProvider = Provider<String>((ref) {
  return 'wss://your-websocket-url.com/ws'; // Replace with actual WebSocket URL
});

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final url = ref.watch(webSocketUrlProvider);
  final service = WebSocketService(url);
  service.connect();
  ref.onDispose(() {
    service.disconnect();
  });
  return service;
});

final notificationsProvider = StreamProvider<String>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.stream;
});
