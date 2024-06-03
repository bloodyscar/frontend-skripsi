// To parse this JSON data, do
//
//     final faceResponseModel = faceResponseModelFromJson(jsonString);

import 'dart:convert';

FaceResponseModel faceResponseModelFromJson(String str) =>
    FaceResponseModel.fromJson(json.decode(str));

String faceResponseModelToJson(FaceResponseModel data) =>
    json.encode(data.toJson());

class FaceResponseModel {
  Data? data;
  DateTime? time;
  String? message;

  FaceResponseModel({
    this.data,
    this.time,
    this.message,
  });

  factory FaceResponseModel.fromJson(Map<String, dynamic> json) =>
      FaceResponseModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "time": time?.toIso8601String(),
        "message": message,
      };
}

class Data {
  int? id;
  String? npk;
  String? nama;
  String? divisi;

  Data({
    this.id,
    this.npk,
    this.nama,
    this.divisi,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        npk: json["npk"],
        nama: json["nama"],
        divisi: json["divisi"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "npk": npk,
        "nama": nama,
        "divisi": divisi,
      };
}
