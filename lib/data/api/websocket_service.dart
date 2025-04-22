import 'dart:async';
import 'package:websocket/websocket.dart';

class WebSocketService {
  final String url;
  WebSocket? _socket;
  final StreamController<String> _controller = StreamController.broadcast();

  WebSocketService(this.url);

  Stream<String> get stream => _controller.stream;

  Future<void> connect() async {
    _socket = await WebSocket.connect(url);
    _socket!.listen((data) {
      _controller.add(data);
    }, onError: (error) {
      _controller.addError(error);
    }, onDone: () {
      _controller.close();
    });
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
  }

  void send(String message) {
    _socket?.add(message);
  }
}
