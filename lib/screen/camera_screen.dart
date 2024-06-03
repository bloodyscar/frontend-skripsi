import 'dart:io';
import 'package:frontend_skripsi/provider/home_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  static const cameraScreenRoute = '/camera-screen';
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool loading = true;
  Directory? tempDir;
  late File jsonFile;
  dynamic data = {};
  bool imageAdded = false;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  HomeProvider? _homeProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeProvider = Provider.of<HomeProvider>(context, listen: false);
    });
    initialCamera();
  }

  initialCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController?.initialize();
    _cameras = cameras;

    _homeProvider?.initWebSocket();
    _homeProvider?.pickImageCameraStream(_cameraController!);

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController?.dispose();
    _homeProvider?.channel?.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color.fromRGBO(255, 255, 255, .7),
      //   shape: const CircleBorder(),
      //   onPressed: () async {
      //     EasyLoading.show();
      //     // _homeProvider?.pickImageCamera(context, _cameraController!);
      //     // pickImageCamera(context, _cameraController!);
      //   },
      //   child: const Icon(
      //     Icons.camera_alt,
      //     size: 40,
      //     color: Colors.black87,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _cameraController != null
          ? Stack(
              children: [
                SizedBox(
                  width: size.width,
                  height: size.height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 100,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),
                StreamBuilder(
                    stream: _homeProvider?.channel?.stream,
                    builder: (context, snapshot) {
                      return Container(
                        color: Colors.black,
                        child: Text(
                          snapshot.hasData
                              ? snapshot.data.toString()
                              : 'No Data',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      );
                    }),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
