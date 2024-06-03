import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend_skripsi/screen/video_player_screen.dart';
import 'package:path_provider/path_provider.dart';

class VideoScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  static const cameraScreenRoute = '/video-screen';
  const VideoScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  late String _videoPath;
  bool _isRecording = false;
  int _countdown = 10;
  late Timer _timer;

  void playRecordedVideo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: _videoPath),
      ),
    );
  }

  void startRecording() async {
    try {
      await cameraValue;
      final directory = await getTemporaryDirectory();
      final videoPath = '${directory.path}/${DateTime.now()}.mp4';
      setState(() {
        _isRecording = true;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_countdown > 0) {
            setState(() {
              _countdown--;
            });
          } else {
            stopRecording();
          }
        });
      });
      await cameraController.startVideoRecording();
    } catch (e) {
      print(e);
    }
  }

  void stopRecording() async {
    _timer.cancel();
    try {
      XFile videoFile = await cameraController.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _countdown = 10; // Reset countdown
      });
      _videoPath = videoFile.path;
      print('Video recorded at ${videoFile.path}');
      print('Video recorded at $_videoPath');
      playRecordedVideo();
    } catch (e) {
      // print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    cameraController =
        CameraController(widget.cameras[1], ResolutionPreset.high);
    cameraValue = cameraController.initialize();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Wajah')),
      body: FutureBuilder<void>(
        future: cameraValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(cameraController),
                if (_isRecording)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Text(
                        '00:00:${_countdown.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRecording ? stopRecording : startRecording,
        child: _isRecording
            ? const Icon(Icons.stop)
            : const Icon(Icons.play_arrow),
      ),
    );
  }
}
