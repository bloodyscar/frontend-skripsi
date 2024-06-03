import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:frontend_skripsi/face/face_detector_view.dart';
import 'package:frontend_skripsi/provider/home_provider.dart';
import 'package:frontend_skripsi/screen/camera_screen.dart';
import 'package:frontend_skripsi/screen/detail_presensi_screen.dart';
import 'package:frontend_skripsi/screen/home_screen.dart';
import 'package:frontend_skripsi/screen/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
        ),
      ],
      child: MaterialApp(
        builder: EasyLoading.init(),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home-screen': (context) => const HomeScreen(),
          CameraScreen.cameraScreenRoute: (context) => const CameraScreen(),
          // VideoScreen.cameraScreenRoute: (context) => VideoScreen(
          //       cameras: cameras,
          //     ),
          DetailPresensiScreen.detailPresensiRoute: (context) =>
              const DetailPresensiScreen(),
        },
      ),
    );
  }
}
