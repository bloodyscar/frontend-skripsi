import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend_skripsi/response/check_presensi_model.dart';
import 'package:frontend_skripsi/response/face_response_model.dart';
import 'package:frontend_skripsi/response/list_presensi_model.dart';
import 'package:frontend_skripsi/utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  // biznetgio
  String biznetUrl = 'http://103.127.133.38';
  String fastapiUrl = 'http://103.206.246.227';
  String avdUrl = 'http://10.0.2.2:3000';

  Future<void> sendImageToBackend(String image) async {
    try {
      String base64Image = (image);

      // Prepare the API endpoint URL
      Uri url = Uri.parse('http://10.0.2.2:8000/face-recog');
      var headers = {'Content-Type': 'application/json'};
      var body = jsonEncode({'file': base64Image, 'npk': "202010225017"});
      var response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      var jsonDecode = json.decode(response.body);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Image successfully sent to backend
        print('Image sent successfully');
      } else {
        // Error occurred while sending image
        print('Error sending image: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Exception while sending image: $e');
    }
  }

  // service login
  loginUser(String npk, String password, BuildContext context) async {
    try {
      print({"npk": npk});
      print({"password": password});
      final localStorage = await SharedPreferences.getInstance();
      var url = Uri.parse("$avdUrl/login");
      var headers = {'Content-Type': 'application/json'};
      var body = jsonEncode({'npk': npk, 'password': password});

      var response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      var jsonDecode = json.decode(response.body);

      if (response.statusCode == 200) {
        String token = jsonDecode["token"];
        String divisi = jsonDecode["user"]["divisi"];
        String nama = jsonDecode["user"]["nama"];
        print(nama);
        localStorage.setString("token", token);
        localStorage.setString("password", password);
        localStorage.setBool("isLogin", true);
        localStorage.setString("npk", npk);
        localStorage.setString("nama", nama);
        localStorage.setString("divisi", divisi);
        Navigator.pushNamedAndRemoveUntil(
            context, '/home-screen', (route) => false);
        Fluttertoast.showToast(
            msg: jsonDecode['message'],
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        var err = json.decode(response.body)['message'];
        print(err);
        Fluttertoast.showToast(
            msg: err,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print(e.toString());
    }
  }

// API absence masuk
  Future<bool> postRegisterFace(String? npk, String? photoFace) async {
    try {
      var postUri = Uri.parse("$fastapiUrl/register_face");
      http.MultipartRequest request = http.MultipartRequest("POST", postUri);

      http.MultipartFile fotoFace =
          await http.MultipartFile.fromPath('video', photoFace!);

      request.files.add(fotoFace);
      request.fields['npk'] = npk!;

      http.StreamedResponse streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 30));
      print("=========STATUS CODE ==========");

      var message = json.decode(response.body);
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        // presensi pulang
        var data = json.decode(response.body)['message'];
        EasyLoading.showSuccess(data);
        return true;
      } else {
        EasyLoading.showError("error");
        return false;
      }
    } catch (e) {
      EasyLoading.showError("error");
      throw Exception('Gagal mengambil data');
    }
  }

  // API absence masuk
  Future<FaceResponseModel> postPresenceMasuk(String? token, String? npk,
      String? photoFace, double? lat, double? lng) async {
    try {
      var postUri = Uri.parse("$avdUrl/presensi");
      http.MultipartRequest request = http.MultipartRequest("POST", postUri);

      printMsg(photoFace);

      http.MultipartFile fotoFace =
          await http.MultipartFile.fromPath('file', photoFace!);
      Map<String, String> headers = {"Authorization": "Bearer $token"};

      request.headers.addAll(headers);
      request.files.add(fotoFace);
      request.fields['npk'] = npk!;
      request.fields['lat'] = lat.toString();
      request.fields['lng'] = lng.toString();

      http.StreamedResponse streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 30));
      print("=========STATUS CODE ==========");

      var message = json.decode(response.body);

      if (response.statusCode == 201) {
        // presensi masuk
        var data = (json.decode(response.body) as Map<String, dynamic>);

        return FaceResponseModel.fromJson(data);
      } else {
        var data = (json.decode(response.body) as Map<String, dynamic>);
        EasyLoading.showError(data['message']);
        return FaceResponseModel.fromJson(data);
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
      throw Exception('Gagal mengambil data: ${e.toString()}');
    }
  }

  // API absence pulang
  Future<FaceResponseModel> postPresencePulang(
    String? token,
    String? npk,
  ) async {
    try {
      var postUri = Uri.parse("$avdUrl/presensi/pulang");
      http.MultipartRequest request = http.MultipartRequest("POST", postUri);

      Map<String, String> headers = {"Authorization": "Bearer $token"};

      request.headers.addAll(headers);
      request.fields['npk'] = npk!;

      http.StreamedResponse streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 30));
      print("=========STATUS CODE ==========");

      var message = json.decode(response.body);

      if (response.statusCode == 200) {
        // presensi masuk
        var data = (json.decode(response.body) as Map<String, dynamic>);

        return FaceResponseModel.fromJson(data);
      } else if (response.statusCode == 200) {
        // presensi pulang
        var data = (json.decode(response.body) as Map<String, dynamic>);
        return FaceResponseModel.fromJson(data);
      } else {
        var data = (json.decode(response.body) as Map<String, dynamic>);
        EasyLoading.showError(data['message']);
        return FaceResponseModel.fromJson(data);
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
      throw Exception('Gagal mengambil data');
    }
  }

  Future<CheckPresensiModel> getCheckPresensi(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$avdUrl/presensi/check_presensi"),
        headers: {
          'Authorization':
              'Bearer $token', // Add the Authorization header with the token
        },
      );

      if (response.statusCode == 200) {
        var data = (json.decode(response.body) as Map<String, dynamic>);
        return CheckPresensiModel.fromJson(data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data');
    }
  }

  // CEK REGIST FACE
  Future<bool> postCheckFace(String token) async {
    final response = await http.post(
      Uri.parse("$avdUrl/presensi/check_face"),
      headers: {
        'Authorization':
            'Bearer $token', // Add the Authorization header with the token
      },
    );

    // statusCode 200 belum ada face
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data']['message'];
      return true;
    } else if (response.statusCode == 201) {
      // statusCode 201 sudah ada face
      var data = json.decode(response.body)['data']['message'];
      return false;
    } else {
      var data = json.decode(response.body)['data']['message'];
      return false;
    }
  }

  Future<PresensiModel> getListPresensi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    final response = await http.get(
      Uri.parse("$avdUrl/presensi/presensi_user"),
      headers: {
        'Authorization':
            'Bearer $token', // Add the Authorization header with the token
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      PresensiModel presensiModel = PresensiModel.fromJson(data);

      return presensiModel;
    } else {
      throw Exception('Failed to load presensi');
    }
  }
}
