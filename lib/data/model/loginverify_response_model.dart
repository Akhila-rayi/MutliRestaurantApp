import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';

class LoginVerify_response_model {
  String status;
  String message;
  List<UserData> data;

  LoginVerify_response_model({this.status, this.message, this.data});

  LoginVerify_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<UserData>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new UserData.fromJson(v));
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

class UserData {
  UserPrefs _userPrefs = new UserPrefs();
  String alert;
  String userId;
  String name;
  String email;
  String mobile;
  String addressId;
  String addressName;
  String addressMobile;
  String street;
  String hno;
  String city;
  String state;
  String zip;
  String type;
  int favoriteCount;
  bool isValidLocation;
  String restaurantPlace;
  String latitude;
  String longitude;
  String locationId;
  String radius;

  UserData(
      {this.alert,
      this.userId,
      this.name,
      this.email,
      this.mobile,
      this.addressId,
      this.addressName,
      this.addressMobile,
      this.street,
      this.hno,
      this.city,
      this.state,
      this.zip,
      this.type,
      this.favoriteCount,
      this.isValidLocation,
      this.restaurantPlace,
      this.latitude,
      this.longitude,
      this.locationId,
      this.radius});

  UserData.fromJson(Map<String, dynamic> json) {
    alert = json['alert'];
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    addressId = json['addressId'];
    addressName = json['addressName'];
    addressMobile = json['addressMobile'];
    street = json['street'];
    hno = json['hno'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    type = json['type'];
    favoriteCount = json['favoriteCount'];
    isValidLocation = json['isValidLocation'];
    restaurantPlace = json['restaurantPlace'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    locationId = json['locationId'];
    radius = json['radius'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alert'] = this.alert;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['addressId'] = this.addressId;
    data['addressName'] = this.addressName;
    data['addressMobile'] = this.addressMobile;
    data['street'] = this.street;
    data['hno'] = this.hno;
    data['city'] = this.city;
    data['state'] = this.state;
    data['zip'] = this.zip;
    data['type'] = this.type;
    data['favoriteCount'] = this.favoriteCount;
    data['isValidLocation'] = this.isValidLocation;
    data['restaurantPlace'] = this.restaurantPlace;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['locationId'] = this.locationId;
    data['radius'] = this.radius;

    return data;
  }
}
