import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_skripsi/provider/home_provider.dart';
import 'package:frontend_skripsi/screen/home_screen.dart';
import 'package:provider/provider.dart';

class DetailPresensiScreen extends StatelessWidget {
  const DetailPresensiScreen({Key? key}) : super(key: key);
  static const detailPresensiRoute = '/detail-presensi-screen';

  @override
  Widget build(BuildContext context) {
    HomeProvider homeProvider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Absen Masuk")),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        child: Column(children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: FileImage(File(homeProvider.imagestr!)),
                    fit: BoxFit.contain)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(children: const [
              Icon(Icons.notification_add),
              Text("Absen Masuk Berhasil")
            ]),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Nama: ${homeProvider.faceResponseModel?.data?.nama}"),
              Text("Divisi: ${homeProvider.faceResponseModel?.data?.divisi}")
            ]),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, HomeScreen.homeScreenRoute, (route) => false);
              },
              child: const Text("Home"))
        ]),
      ),
    );
  }
}
