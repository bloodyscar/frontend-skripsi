import 'package:camerawesome/camerapreview.dart';
import 'package:camerawesome/models/capture_modes.dart';
import 'package:camerawesome/models/sensors.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketDemo extends StatefulWidget {
  @override
  _WebSocketDemoState createState() => _WebSocketDemoState();
}

class _WebSocketDemoState extends State<WebSocketDemo> {
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel _channel;
  final ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  final ValueNotifier<CaptureModes> _captureMode =
      ValueNotifier(CaptureModes.PHOTO);
  final ValueNotifier<Size> _photoSize = ValueNotifier(const Size(0, 0));

  @override
  void initState() {
    super.initState();
    initWebSocket();
  }

  initWebSocket() async {
    _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/ws'));
    await _channel.ready;
  }

  @override
  void dispose() {
    _controller.dispose();
    _channel.sink.close();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebSocket Demo'),
      ),
      body: CameraAwesome(
        sensor: _sensor,
        captureMode: _captureMode,
        photoSize: _photoSize,
        imagesStreamBuilder: (imageStream) {
          /// listen for images preview stream
          /// you can use it to process AI recognition or anything else...
          print('-- init CamerAwesome images stream');
        },
      ),
    );
  }
}
