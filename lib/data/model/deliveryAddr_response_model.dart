import 'dart:convert';

class DeliveryAddr_response_model {
  String status;
  String message;
  List<DeliveryAdrsData> data;

  DeliveryAddr_response_model({this.status, this.message, this.data});

  DeliveryAddr_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<DeliveryAdrsData>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new DeliveryAdrsData.fromJson(v));
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

class DeliveryAdrsData {
  var addressId;
  String userId;
  String addressName;
  String addressMobile;
  String street;
  String hno;
  String city;
  String state;
  String pincode;
  String type;

  DeliveryAdrsData(
      {this.addressId,
      this.userId,
      this.addressName,
      this.addressMobile,
      this.street,
      this.hno,
      this.city,
      this.state,
      this.pincode,
      this.type});

  DeliveryAdrsData.fromJson(Map<String, dynamic> json) {
    addressId = json['addressId'];
    userId = json['user_id'];
    addressName = json['addressName'];
    addressMobile = json['addressMobile'];
    street = json['street'];
    hno = json['hno'];
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addressId'] = this.addressId;
    data['user_id'] = this.userId;
    data['addressName'] = this.addressName;
    data['addressMobile'] = this.addressMobile;
    data['street'] = this.street;
    data['hno'] = this.hno;
    data['city'] = this.city;
    data['state'] = this.state;
    data['pincode'] = this.pincode;
    data['type'] = this.type;
    return data;
  }
}
