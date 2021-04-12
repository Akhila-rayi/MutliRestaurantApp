import 'dart:convert';

class Appinfo_response_model {
  String status;
  String message;
  List<Appinfo_Data> data;

  Appinfo_response_model({this.status, this.message, this.data});

  Appinfo_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Appinfo_Data>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new Appinfo_Data.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Appinfo_Data {
  String title;
  String email;
  String phone;
  String map;
  String address;
  String description;

  Appinfo_Data({this.title, this.email, this.phone, this.map, this.address,this.description});

  Appinfo_Data.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    email = json['email'];
    phone = json['phone'];
    map = json['map'];
    address = json['address'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['map'] = this.map;
    data['address'] = this.address;
    data['description'] = this.description;
    return data;
  }
}