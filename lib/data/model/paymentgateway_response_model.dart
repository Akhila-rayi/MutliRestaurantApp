import 'dart:convert';

class Paymentgateway_response_model {
  String status;
  String message;
  List<PaymentgatewayData> data;

  Paymentgateway_response_model({this.status, this.message, this.data});

  Paymentgateway_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<PaymentgatewayData>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new PaymentgatewayData.fromJson(v));
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

class PaymentgatewayData {
  String name;
  String id;
  String secret;

  PaymentgatewayData({this.name, this.id, this.secret});

  PaymentgatewayData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    secret = json['secret'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['secret'] = this.secret;
    return data;
  }
}