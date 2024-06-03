// import 'dart:io';
// import 'dart:typed_data';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:frontend_skripsi/provider/home_provider.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:image/image.dart' as imglib;

// class CameraView extends StatefulWidget {
//   const CameraView(
//       {Key? key,
//       required this.customPaint,
//       required this.onImage,
//       this.onCameraFeedReady,
//       this.onDetectorViewModeChanged,
//       this.onCameraLensDirectionChanged,
//       this.initialCameraLensDirection = CameraLensDirection.back})
//       : super(key: key);

//   final CustomPaint? customPaint;
//   final Function(InputImage inputImage) onImage;
//   final VoidCallback? onCameraFeedReady;
//   final VoidCallback? onDetectorViewModeChanged;
//   final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
//   final CameraLensDirection initialCameraLensDirection;

//   @override
//   State<CameraView> createState() => _CameraViewState();
// }

// class _CameraViewState extends State<CameraView> {
//   static List<CameraDescription> _cameras = [];
//   CameraController? _controller;
//   int _cameraIndex = -1;
//   double _currentZoomLevel = 1.0;
//   double _minAvailableZoom = 1.0;
//   double _maxAvailableZoom = 1.0;
//   double _minAvailableExposureOffset = 0.0;
//   double _maxAvailableExposureOffset = 0.0;
//   double _currentExposureOffset = 0.0;
//   bool _changingCameraLens = false;
//   late HomeProvider homeProvider;
//   WebSocketChannel? _channel;

//   @override
//   void initState() {
//     super.initState();
//     initWebSocket();

//     _initialize();
//   }

//   void _initialize() async {
//     if (_cameras.isEmpty) {
//       _cameras = await availableCameras();
//     }
//     for (var i = 0; i < _cameras.length; i++) {
//       if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
//         _cameraIndex = i;
//         break;
//       }
//     }
//     if (_cameraIndex != -1) {
//       _startLiveFeed();
//     }
//   }

//   @override
//   void dispose() {
//     _stopLiveFeed();
//     _channel?.sink.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: _liveFeedBody());
//   }

//   Widget _liveFeedBody() {
//     if (_cameras.isEmpty) return Container();
//     if (_controller == null) return Container();
//     if (_controller?.value.isInitialized == false) return Container();
//     return ColoredBox(
//       color: Colors.black,
//       child: Stack(
//         fit: StackFit.expand,
//         children: <Widget>[
//           Center(
//             child: _changingCameraLens
//                 ? const Center(
//                     child: Text('Changing camera lens'),
//                   )
//                 : CameraPreview(
//                     _controller!,
//                     child: widget.customPaint,
//                   ),
//           ),
//           _backButton(),
//           _switchLiveCameraToggle(),
//           _detectionViewModeToggle(),
//           _zoomControl(),
//           _exposureControl(),
//         ],
//       ),
//     );
//   }

//   Widget _backButton() => Positioned(
//         top: 40,
//         left: 8,
//         child: SizedBox(
//           height: 50.0,
//           width: 50.0,
//           child: FloatingActionButton(
//             heroTag: Object(),
//             onPressed: () => Navigator.of(context).pop(),
//             backgroundColor: Colors.black54,
//             child: const Icon(
//               Icons.arrow_back_ios_outlined,
//               size: 20,
//             ),
//           ),
//         ),
//       );

//   Widget _detectionViewModeToggle() => Positioned(
//         bottom: 8,
//         left: 8,
//         child: SizedBox(
//           height: 50.0,
//           width: 50.0,
//           child: FloatingActionButton(
//             heroTag: Object(),
//             onPressed: widget.onDetectorViewModeChanged,
//             backgroundColor: Colors.black54,
//             child: const Icon(
//               Icons.photo_library_outlined,
//               size: 25,
//             ),
//           ),
//         ),
//       );

//   Widget _switchLiveCameraToggle() => Positioned(
//         bottom: 8,
//         right: 8,
//         child: SizedBox(
//           height: 50.0,
//           width: 50.0,
//           child: FloatingActionButton(
//             heroTag: Object(),
//             onPressed: _switchLiveCamera,
//             backgroundColor: Colors.black54,
//             child: Icon(
//               Platform.isIOS
//                   ? Icons.flip_camera_ios_outlined
//                   : Icons.flip_camera_android_outlined,
//               size: 25,
//             ),
//           ),
//         ),
//       );

//   Widget _zoomControl() => Positioned(
//         bottom: 16,
//         left: 0,
//         right: 0,
//         child: Align(
//           alignment: Alignment.bottomCenter,
//           child: SizedBox(
//             width: 250,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: Slider(
//                     value: _currentZoomLevel,
//                     min: _minAvailableZoom,
//                     max: _maxAvailableZoom,
//                     activeColor: Colors.white,
//                     inactiveColor: Colors.white30,
//                     onChanged: (value) async {
//                       setState(() {
//                         _currentZoomLevel = value;
//                       });
//                       await _controller?.setZoomLevel(value);
//                     },
//                   ),
//                 ),
//                 Container(
//                   width: 50,
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Center(
//                       child: Text(
//                         '${_currentZoomLevel.toStringAsFixed(1)}x',
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );

//   Widget _exposureControl() => Positioned(
//         top: 40,
//         right: 8,
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(
//             maxHeight: 250,
//           ),
//           child: Column(children: [
//             Container(
//               width: 55,
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Center(
//                   child: Text(
//                     '${_currentExposureOffset.toStringAsFixed(1)}x',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: RotatedBox(
//                 quarterTurns: 3,
//                 child: SizedBox(
//                   height: 30,
//                   child: Slider(
//                     value: _currentExposureOffset,
//                     min: _minAvailableExposureOffset,
//                     max: _maxAvailableExposureOffset,
//                     activeColor: Colors.white,
//                     inactiveColor: Colors.white30,
//                     onChanged: (value) async {
//                       setState(() {
//                         _currentExposureOffset = value;
//                       });
//                       await _controller?.setExposureOffset(value);
//                     },
//                   ),
//                 ),
//               ),
//             )
//           ]),
//         ),
//       );

//   Future _startLiveFeed() async {
//     final camera = _cameras[0];
//     _controller = CameraController(
//       camera,
//       // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
//       ResolutionPreset.high,
//       enableAudio: false,
//       imageFormatGroup: Platform.isAndroid
//           ? ImageFormatGroup.nv21
//           : ImageFormatGroup.bgra8888,
//     );
//     _controller?.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       _controller?.getMinZoomLevel().then((value) {
//         _currentZoomLevel = value;
//         _minAvailableZoom = value;
//       });
//       _controller?.getMaxZoomLevel().then((value) {
//         _maxAvailableZoom = value;
//       });
//       _currentExposureOffset = 0.0;
//       _controller?.getMinExposureOffset().then((value) {
//         _minAvailableExposureOffset = value;
//       });
//       _controller?.getMaxExposureOffset().then((value) {
//         _maxAvailableExposureOffset = value;
//       });
//       _controller?.startImageStream(_processCameraImage).then((value) {
//         if (widget.onCameraFeedReady != null) {
//           widget.onCameraFeedReady!();
//         }
//         if (widget.onCameraLensDirectionChanged != null) {
//           widget.onCameraLensDirectionChanged!(camera.lensDirection);
//         }
//       });
//       setState(() {});
//     });
//   }

//   Future _stopLiveFeed() async {
//     await _controller?.stopImageStream();
//     await _controller?.dispose();
//     _controller = null;
//   }

//   Future _switchLiveCamera() async {
//     setState(() => _changingCameraLens = true);
//     _cameraIndex = (_cameraIndex + 1) % _cameras.length;

//     await _stopLiveFeed();
//     await _startLiveFeed();
//     setState(() => _changingCameraLens = false);
//   }

//   void initWebSocket() async {
//     // Connect to WebSocket server
//     _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/ws'));
//     await _channel?.ready;
//   }

//   Future<Image> _convertYUV420toImageColor(CameraImage image) async {
//     final width = image.width;
//     final height = image.height;
//     final uvRowStride = image.planes[0].bytesPerRow;
//     // MEMO: null(iPhone XS Plus)
//     final uvPixelStride = image.planes[0].bytesPerPixel ?? 1;

//     // imgLib -> Image package from https://pub.dartlang.org/packages/image
//     final img = imglib.Image(width, height); // Create Image buffer

//     // Fill image buffer with plane[0] from YUV420_888
//     for (var x = 0; x < width; x++) {
//       for (var y = 0; y < height; y++) {
//         final uvIndex =
//             uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
//         final index = y * width + x;

//         final yp = image.planes[0].bytes[index];
//         final up = image.planes[0].bytes[uvIndex];
//         // MEMO: image.planes' length is 2(iPhone XS Plus)
//         final vp = image.planes.length > 2 ? image.planes[2].bytes[uvIndex] : 0;
//         // Calculate pixel color
//         final r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255).toInt();
//         final g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
//             .round()
//             .clamp(0, 255)
//             .toInt();
//         final b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255).toInt();
//         // color: 0x FF  FF  FF  FF
//         //           A   B   G   R
//         img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
//       }
//     }

//     final png = imglib.PngEncoder(level: 0, filter: 0).encodeImage(img);
//     // MEMO: What?
// //      muteYUVProcessing = false;
//     return Image.memory(png as Uint8List);
//   }

//   void _processCameraImage(CameraImage image) {
//     final inputImage = _inputImageFromCameraImage(image);

//     // _channel?.sink
//     //     .add(jsonEncode({"image": imageBytes, "npk": "202010225017"}));

//     if (inputImage == null) return;
//     widget.onImage(inputImage);
//   }

//   final _orientations = {
//     DeviceOrientation.portraitUp: 0,
//     DeviceOrientation.landscapeLeft: 90,
//     DeviceOrientation.portraitDown: 180,
//     DeviceOrientation.landscapeRight: 270,
//   };

//   InputImage? _inputImageFromCameraImage(CameraImage image) {
//     if (_controller == null) return null;

//     final camera = _cameras[_cameraIndex];
//     final sensorOrientation = camera.sensorOrientation;

//     InputImageRotation? rotation;
//     if (Platform.isIOS) {
//       rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
//     } else if (Platform.isAndroid) {
//       var rotationCompensation =
//           _orientations[_controller!.value.deviceOrientation];
//       if (rotationCompensation == null) return null;
//       if (camera.lensDirection == CameraLensDirection.front) {
//         // front-facing
//         rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
//       } else {
//         // back-facing
//         rotationCompensation =
//             (sensorOrientation - rotationCompensation + 360) % 360;
//       }
//       rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
//       // print('rotationCompensation: $rotationCompensation');
//     }
//     if (rotation == null) return null;
//     // print('final rotation: $rotation');

//     // get image format
//     final format = InputImageFormatValue.fromRawValue(image.format.raw);
//     if (format == null ||
//         (Platform.isAndroid && format != InputImageFormat.nv21) ||
//         (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

//     // since format is constraint to nv21 or bgra8888, both only have one plane
//     if (image.planes.length != 1) return null;
//     final plane = image.planes.first;

//     // compose InputImage using bytes
//     return InputImage.fromBytes(
//       bytes: plane.bytes,
//       metadata: InputImageMetadata(
//         size: Size(image.width.toDouble(), image.height.toDouble()),
//         rotation: rotation, // used only in Android
//         format: format, // used only in iOS
//         bytesPerRow: plane.bytesPerRow, // used only in iOS
//       ),
//     );
//   }
// }
