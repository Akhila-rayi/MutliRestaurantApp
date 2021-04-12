import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';

class Favourite_response_model {

  String status;
  String message;
  List<FavouriteData> data;

  Favourite_response_model({this.status, this.message, this.data});

  Favourite_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<FavouriteData>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new FavouriteData.fromJson(v));
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

class FavouriteData {
  UserPrefs _userPrefs=new UserPrefs();

  String alert;
  int favoriteCount;

  FavouriteData({this.alert, this.favoriteCount});

  FavouriteData.fromJson(Map<String, dynamic> json){
    alert = json['alert'];
    favoriteCount = json['favoriteCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alert'] = this.alert;
    data['favoriteCount'] = this.favoriteCount;
    return data;
  }
}