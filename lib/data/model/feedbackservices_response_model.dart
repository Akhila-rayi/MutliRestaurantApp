import 'dart:convert';

class Feedbackservices_response_model {
  String status;
  String message;
  List<FeedbackservicesData> data;

  Feedbackservices_response_model({this.status, this.message, this.data});

  Feedbackservices_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<FeedbackservicesData>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new FeedbackservicesData.fromJson(v));
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

class FeedbackservicesData {
  List<String> complaints;
  List<String> suggestions;

  FeedbackservicesData({this.complaints, this.suggestions});

  FeedbackservicesData.fromJson(Map<String, dynamic> json) {
    complaints = json['complaints'].cast<String>();
    suggestions = json['suggestions'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['complaints'] = this.complaints;
    data['suggestions'] = this.suggestions;
    return data;
  }
}