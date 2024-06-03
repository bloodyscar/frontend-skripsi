// To parse this JSON data, do
//
//     final checkPresensiModel = checkPresensiModelFromJson(jsonString);

import 'dart:convert';

CheckPresensiModel checkPresensiModelFromJson(String str) =>
    CheckPresensiModel.fromJson(json.decode(str));

String checkPresensiModelToJson(CheckPresensiModel data) =>
    json.encode(data.toJson());

class CheckPresensiModel {
  Data? data;

  CheckPresensiModel({
    this.data,
  });

  factory CheckPresensiModel.fromJson(Map<String, dynamic> json) =>
      CheckPresensiModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class Data {
  String? karyawanId;
  String? jamAbsenMasuk;
  String? jamAbsenKeluar;
  String? tanggal;
  double? lat;
  double? lng;

  Data({
    this.karyawanId,
    this.jamAbsenMasuk,
    this.jamAbsenKeluar,
    this.tanggal,
    this.lat,
    this.lng,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        karyawanId: json["karyawan_id"],
        jamAbsenMasuk: json["jam_absen_masuk"],
        jamAbsenKeluar: json["jam_absen_keluar"],
        tanggal: json["tanggal"],
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "karyawan_id": karyawanId,
        "jam_absen_masuk": jamAbsenMasuk,
        "jam_absen_keluar": jamAbsenKeluar,
        "tanggal": tanggal,
        "lat": lat,
        "lng": lng,
      };
}
