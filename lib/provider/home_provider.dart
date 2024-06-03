import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:frontend_skripsi/response/check_presensi_model.dart';
import 'package:frontend_skripsi/response/face_response_model.dart';
import 'package:frontend_skripsi/response/list_presensi_model.dart';
import 'package:frontend_skripsi/screen/detail_presensi_screen.dart';
import 'package:frontend_skripsi/services/home_service.dart';
import 'package:frontend_skripsi/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeProvider with ChangeNotifier {
  final List<Uint8List> _imageList = [];
  List<Uint8List>? get imageList => _imageList;

  File? _imageFile;
  File? get imageFile => _imageFile;

  WebSocketChannel? _channel;
  WebSocketChannel? get channel => _channel;

  String? _name;
  String? get name => _name;

  String? _npk;
  String? get npk => _npk;

  CheckPresensiModel? _checkPresensiModel;
  CheckPresensiModel? get checkPresensiModel => _checkPresensiModel;

  set setCheckPresensiModel(CheckPresensiModel checkPresensiModel) {
    _checkPresensiModel = checkPresensiModel;
    notifyListeners();
  }

  set setImageList(Uint8List imageList) {
    _imageList.add(imageList);
    notifyListeners();
  }

  PresensiModel? _presensiModel;
  PresensiModel? get presensiModel => _presensiModel;

  set setPresensiModel(PresensiModel presensiModel) {
    _presensiModel = presensiModel;
    notifyListeners();
  }

  set setName(String nama) {
    _name = nama;
    notifyListeners();
  }

  String? _divisi;
  String? get divisi => _divisi;

  set setDivisi(String divisi) {
    _divisi = divisi;
    notifyListeners();
  }

  String? _imagestr;
  String? get imagestr => _imagestr;

  FaceResponseModel? _faceResponseModel;
  FaceResponseModel? get faceResponseModel => _faceResponseModel;

  initWebSocket() async {
    _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/ws'));
    await _channel?.ready;
    notifyListeners();
  }

  login(npk, password, BuildContext context) async {
    await HomeService().loginUser(npk, password, context);
    final localStorage = await SharedPreferences.getInstance();
    _name = localStorage.getString('nama') ?? "-";
    _npk = localStorage.getString('npk') ?? "-";
    _divisi = localStorage.getString('divisi') ?? "-";
  }

  Future<dynamic> getDataCheckPresensi() async {
    final localStorage = await SharedPreferences.getInstance();
    final token = localStorage.getString("token");
    var res = await HomeService().getCheckPresensi(token!);

    _checkPresensiModel = res;
    notifyListeners();
  }

  Future<PresensiModel> getPresensiUser() async {
    try {
      var res = await HomeService().getListPresensi();

      _presensiModel = res;
      return res;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  pickImageFolder(BuildContext ctx) async {
    final localStorage = await SharedPreferences.getInstance();
    final token = localStorage.getString("token");
    final npk = localStorage.getString("npk");

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    var lat = position.latitude;
    var lng = position.longitude;

    final imageGallery = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (imageGallery == null) return;

    _imagestr = imageGallery.path;
    notifyListeners();

    if (_imagestr != null) {
      await HomeService()
          .postPresenceMasuk(token, npk, _imagestr, lat, lng)
          .then((value) {
        printMsg(value.data!.nama);
        _faceResponseModel = value;
        if (value.data == null) {
          EasyLoading.showError(value.message!);
          return;
        } else {
          EasyLoading.dismiss();
          Navigator.pushNamed(ctx, DetailPresensiScreen.detailPresensiRoute);
        }
      });
    } else {
      EasyLoading.showError('Failed, No image selected');
    }
  }

  Future<Uint8List> compressFile(String imagePath) async {
    try {
      var result = await FlutterImageCompress.compressWithFile(
        imagePath,
        quality: 85,
      );
      return result!;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void pickImageCameraStream(CameraController cameraController) async {
    XFile? image;
    final localStorage = await SharedPreferences.getInstance();
    final npk = localStorage.getString("npk");

    if (cameraController.value.isTakingPicture ||
        !cameraController.value.isInitialized) {
      return;
    }

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        image = await cameraController.takePicture();
        _imagestr = image!.path;

        if (image != null) {
          final compressImageByte = await compressFile(image!.path);
          // convert uin8list to base64
          final base64Image = base64Encode(compressImageByte);
          print("TESTING");
          _channel?.sink.add(jsonEncode({
            'image': base64Image,
            'npk': npk,
          }));
        }
      } catch (e) {
        Exception(e.toString());
      }
    });

    _channel?.stream.listen((event) {
      EasyLoading.dismiss();

      final data = jsonDecode(event);
      print(data);
      if (data['predict'] == npk) {
        EasyLoading.showSuccess('Success');

        // Navigator.pushNamed(ctx, DetailPresensiScreen.detailPresensiRoute);
      } else {
        EasyLoading.showError('Failed');
      }
    });

    notifyListeners();
  }

  pickImageCamera(BuildContext ctx, CameraController cameraController) async {
    try {
      XFile? image;
      final localStorage = await SharedPreferences.getInstance();
      final token = localStorage.getString("token");
      final npk = localStorage.getString("npk");

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      var lat = position.latitude;
      var lng = position.longitude;

      if (cameraController.value.isTakingPicture ||
          !cameraController.value.isInitialized) {
        return;
      }

      image = await cameraController.takePicture();

      _imagestr = image.path;
      await HomeService()
          .postPresenceMasuk(token, npk, image.path, lat, lng)
          .then((value) {
        if (value.data == null) {
          EasyLoading.showError(value.message!);
          return;
        }
        _faceResponseModel = value;
        EasyLoading.dismiss();
        Navigator.pushNamed(ctx, DetailPresensiScreen.detailPresensiRoute);
      });
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  presensiPulang(BuildContext ctx) async {
    final localStorage = await SharedPreferences.getInstance();
    final token = localStorage.getString("token");
    final npk = localStorage.getString("npk");
    await HomeService().postPresencePulang(token, npk).then((value) {
      EasyLoading.dismiss();
    });
  }
}
