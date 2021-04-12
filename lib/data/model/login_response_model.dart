import 'dart:convert';

import 'package:flutter/foundation.dart';

class Login_response_model {
  String status;
  String message;
  List<LoginData> data;

  Login_response_model({this.status, this.message, this.data});

  Login_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<LoginData>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new LoginData.fromJson(v));
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

class LoginData {
  String otp;

  LoginData({this.otp});

  LoginData.fromJson(Map<String, dynamic> json) {

    debugPrint("@@@ otp_______"+json['otp']);
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['otp'] = this.otp;
    return data;
  }
}
