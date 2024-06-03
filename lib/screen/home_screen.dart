import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:frontend_skripsi/provider/home_provider.dart';
import 'package:frontend_skripsi/response/list_presensi_model.dart';
import 'package:frontend_skripsi/screen/camera_screen.dart';
import 'package:frontend_skripsi/screen/video_screen.dart';
import 'package:frontend_skripsi/services/home_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  static const homeScreenRoute = '/home-screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = "-";
  String divisi = "-";
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
    checkFace();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeProvider = Provider.of<HomeProvider>(context, listen: false);
    });
    _determinePosition();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  String extractTime(String timeString) {
    DateTime dateTime = DateTime.parse(timeString);
    // Convert the DateTime object to local time zone
    dateTime = dateTime.toLocal();
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  String extractDate(String timeString) {
    DateTime dateTime = DateTime.parse(timeString);
    // Convert the DateTime object to local time zone
    dateTime = dateTime.toLocal();
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  Future<void> getSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Retrieve the name from SharedPreferences and update the UI
      name = prefs.getString('nama') ?? '';
      divisi = prefs.getString("divisi") ?? '';
    });
    print(prefs.getString('nama') ?? '');
  }

  checkFace() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    if (token != null) {
      if (await HomeService().postCheckFace(token)) {
        // Show alert dialog if there is no face
        showDialog(
          context: context,
          barrierDismissible:
              false, // To prevent dismissing when tapping outside
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Warning'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                      'Silahkan mendaftarkan wajah anda untuk keperluan presensi'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, VideoScreen.cameraScreenRoute);
                    },
                    child: const Text('Your Button'),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        print("sudah ada face");
      }
    } else {
      EasyLoading.showError("Token tidak ada");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selamat Pagi,",
                    ),
                    Text(name),
                    Text(
                      divisi,
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove("token");
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    icon: const Icon(Icons.logout))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.grey
                        .shade300, // Adjust the shade for lighter or darker grey
                    width: 2, // Adjust the width of the border
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  children: [
                    FutureBuilder(
                        future: homeProvider.getDataCheckPresensi(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text("Masuk"),
                                      Row(children: const <Widget>[
                                        Expanded(
                                            child: Divider(
                                          color: Colors.black,
                                        )),
                                      ]),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        homeProvider.checkPresensiModel?.data
                                                    ?.jamAbsenMasuk !=
                                                null
                                            ? extractTime(homeProvider
                                                .checkPresensiModel!
                                                .data!
                                                .jamAbsenMasuk!)
                                            : "--:--:--",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        width: 125,
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              // create showmodalbottomsheet from camera and folder
                                              showModalBottomSheet(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons.camera_enhance,
                                                          color: Colors.green,
                                                        ),
                                                        title: const Text(
                                                            'Camera'),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pushNamed(
                                                              context,
                                                              CameraScreen
                                                                  .cameraScreenRoute);
                                                        },
                                                      ),
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons.folder,
                                                          color: Colors.blue,
                                                        ),
                                                        title: const Text(
                                                            'Folder'),
                                                        onTap: () {
                                                          homeProvider
                                                              .pickImageFolder(
                                                                  context);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            // onPressed: homeProvider
                                            //             .checkPresensiModel
                                            //             ?.data
                                            //             ?.jamAbsenMasuk ==
                                            //         null
                                            //     ? () async {
                                            //         Navigator.pushNamed(
                                            //             context,
                                            //             CameraScreen
                                            //                 .cameraScreenRoute);
                                            //       }
                                            //     : null,
                                            child: const Text(
                                              "Presensi\nMasuk",
                                              textAlign: TextAlign.center,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text("Pulang"),
                                      Row(children: const <Widget>[
                                        Expanded(
                                            child: Divider(
                                          color: Colors.black,
                                        )),
                                      ]),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        homeProvider.checkPresensiModel?.data
                                                    ?.jamAbsenKeluar !=
                                                null
                                            ? extractTime(homeProvider
                                                .checkPresensiModel!
                                                .data!
                                                .jamAbsenKeluar!)
                                            : "--:--:--",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        width: 125,
                                        child: ElevatedButton(
                                            onPressed: homeProvider
                                                        .checkPresensiModel
                                                        ?.data
                                                        ?.jamAbsenKeluar ==
                                                    null
                                                ? () async {
                                                    EasyLoading.show();
                                                    await homeProvider
                                                        .presensiPulang(
                                                            context);
                                                    setState(() {});
                                                  }
                                                : null,
                                            child: const Text(
                                              "Presensi\nPulang",
                                              textAlign: TextAlign.center,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Display a loading indicator while data is loading
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            // Display the data if fetching is successful
                            return Center(
                                child: Text('Data: ${snapshot.data}'));
                          }
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
            const SizedBox(
              height: 30,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Histori Presensi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                )
              ],
            ),
            FutureBuilder<PresensiModel>(
              future: HomeService().getListPresensi(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  print(snapshot.data?.data);
                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('Tanggal')),
                      DataColumn(label: Text('Masuk')),
                      DataColumn(label: Text('Pulang')),
                    ],
                    // rows: snapshot.data?.data
                    //         ?.map((e) => DataRow(cells: [
                    //               DataCell(Text(e.tanggal != null
                    //                   ? extractDate(e.tanggal.toString())
                    //                   : "-")),
                    //               DataCell(Text(e.jamAbsenMasuk != null
                    //                   ? extractTime(e.jamAbsenMasuk.toString())
                    //                   : "--:--:--")),
                    //               DataCell(Text(e.jamAbsenKeluar != null
                    //                   ? extractTime(e.jamAbsenKeluar.toString())
                    //                   : "--:--:--")),
                    //             ]))
                    //         .toList() ??
                    //     [],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('2021-10-01')),
                        DataCell(Text('08:00:00')),
                        DataCell(Text('17:00:00')),
                      ]),
                    ],
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  // Display a loading indicator while data is loading
                  return const Center(child: CircularProgressIndicator());
                } else {
                  // Display the data if fetching is successful
                  return Center(child: Text('Data: ${snapshot.data}'));
                }
              },
            )
          ]),
        ),
      ),
    );
  }
}
