// To parse this JSON data, do
//
//     final presensiModel = presensiModelFromJson(jsonString);

import 'dart:convert';

PresensiModel presensiModelFromJson(String str) =>
    PresensiModel.fromJson(json.decode(str));

String presensiModelToJson(PresensiModel data) => json.encode(data.toJson());

class PresensiModel {
  List<Datum>? data;

  PresensiModel({
    this.data,
  });

  factory PresensiModel.fromJson(Map<String, dynamic> json) => PresensiModel(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  DateTime? jamAbsenMasuk;
  DateTime? jamAbsenKeluar;
  DateTime? tanggal;

  Datum({
    this.jamAbsenMasuk,
    this.jamAbsenKeluar,
    this.tanggal,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        jamAbsenMasuk: json["jam_absen_masuk"] == null
            ? null
            : DateTime.parse(json["jam_absen_masuk"]),
        jamAbsenKeluar: json["jam_absen_keluar"] == null
            ? null
            : DateTime.parse(json["jam_absen_keluar"]),
        tanggal:
            json["tanggal"] == null ? null : DateTime.parse(json["tanggal"]),
      );

  Map<String, dynamic> toJson() => {
        "jam_absen_masuk": jamAbsenMasuk?.toIso8601String(),
        "jam_absen_keluar": jamAbsenKeluar?.toIso8601String(),
        "tanggal": tanggal?.toIso8601String(),
      };
}
