import 'dart:convert';

class Orderfeedback_response_model {
  String status;
  String message;
  List<OrderfeedbackData> data;

  Orderfeedback_response_model({this.status, this.message, this.data});

  Orderfeedback_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<OrderfeedbackData>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new OrderfeedbackData.fromJson(v));
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

class  OrderfeedbackData {
  String alert;

  OrderfeedbackData({this.alert});

  OrderfeedbackData.fromJson(Map<String, dynamic> json) {
    alert = json['alert'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alert'] = this.alert;
    return data;
  }
}