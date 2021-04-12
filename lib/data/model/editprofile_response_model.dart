import 'dart:convert';

class EditProfile_response_model {
  String status;
  String message;
  List<EditProfileData> data;

  EditProfile_response_model({this.status, this.message, this.data});

  EditProfile_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<EditProfileData>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new EditProfileData.fromJson(v));
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

class EditProfileData {
  String alert;

  EditProfileData({this.alert});

  EditProfileData.fromJson(Map<String, dynamic> json) {
    alert = json['alert'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alert'] = this.alert;
    return data;
  }
}