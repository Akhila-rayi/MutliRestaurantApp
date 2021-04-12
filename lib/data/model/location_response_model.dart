import 'dart:convert';
import 'package:FarmToHome/LocalStorage/userPrefs.dart';

class Location_response_model {
  String status;
  String message;
  List<LocationDetls> data;

  Location_response_model({this.status, this.message, this.data});

  Location_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<LocationDetls>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new LocationDetls.fromJson(v));
        });
      }

      /* if (data.length > 0) {
        new UserPrefs().setLoctndetls(jsonEncode(json['data']));
      }*/
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

class LocationDetls {
  String locationId;
  String location;
  String longitude;
  String latitude;
  String radius;
  String address;
  String min_order;
  String deliveryTime;
  String deliveryCharges;
  String OpenTime;
  String closeTime;
  String availability;
  String status;

  LocationDetls(
      {this.locationId,
      this.location,
      this.longitude,
      this.latitude,
      this.radius,
      this.address,
      this.deliveryTime,
      this.deliveryCharges,
      this.min_order,
      this.OpenTime,
      this.closeTime,
      this.availability,
      this.status});

  LocationDetls.fromJson(Map<String, dynamic> json) {
    locationId = json['locationId'];
    location = json['location'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    radius = json['radius'];
    address = json['address'];
    deliveryTime = json['deliveryTime'];
    deliveryCharges = json['deliveryCharges'];
    min_order = json['min_order'];
    OpenTime = json['OpenTime'];
    closeTime = json['closeTime'];
    availability = json['availability'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['locationId'] = this.locationId;
    data['location'] = this.location;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['radius'] = this.radius;
    data['address'] = this.address;
    data['deliveryTime'] = this.deliveryTime;
    data['deliveryCharges'] = this.deliveryCharges;
    data['min_order'] = this.min_order;
    data['OpenTime'] = this.OpenTime;
    data['closeTime'] = this.closeTime;
    data['availability'] = this.availability;
    data['status'] = this.status;
    return data;
  }
}
