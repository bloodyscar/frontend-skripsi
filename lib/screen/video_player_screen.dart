import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:frontend_skripsi/provider/home_provider.dart';
import 'package:frontend_skripsi/screen/home_screen.dart';
import 'package:frontend_skripsi/services/home_service.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({Key? key, required this.videoPath})
      : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  double _bufferValue = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
        _videoPlayerController.setLooping(true);
      });

    // Simulate buffer animation
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _bufferValue += 0.1;
        if (_bufferValue >= 1.0) {
          _bufferValue = 0.0;
        }
      });
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HomeProvider homeProvider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Recorded Video')),
      body: Center(
        child: _videoPlayerController.value.isInitialized
            ? Column(
                children: [
                  SizedBox(
                    height: 500,
                    width: 500 * _videoPlayerController.value.aspectRatio,
                    child: Stack(children: [
                      AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          color: Colors.red,
                          height: 5,
                          width:
                              MediaQuery.of(context).size.width * _bufferValue,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Ambil Ulang"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      EasyLoading.show();
                      await HomeService()
                          .postRegisterFace(homeProvider.npk, widget.videoPath);

                      Navigator.pushNamedAndRemoveUntil(context,
                          HomeScreen.homeScreenRoute, (route) => false);
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    child: const Text("Submit"),
                  )
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
