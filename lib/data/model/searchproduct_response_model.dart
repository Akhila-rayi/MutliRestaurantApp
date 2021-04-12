import 'dart:convert';

import 'package:FarmToHome/data/model/home_response_model.dart';

class Searchproduct_response_model {
  String status;
  String message;
  List<TodaySpecial> data;

  Searchproduct_response_model({this.status, this.message, this.data});

  Searchproduct_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<TodaySpecial>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new TodaySpecial.fromJson(v));
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