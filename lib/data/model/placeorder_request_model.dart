import 'dart:convert';

import 'package:FarmToHome/data/model/home_response_model.dart';

class Placeorder_request_model {
  String orderType;
  String userId;
  String addressId;
  List<PlaceorderItems> items;
  List<Paymentdetls> payment;
  Coupons coupon;
  String coupon_code;
  String coupon_amount;


  Placeorder_request_model({this.orderType, this.userId, this.addressId, this.items,this.payment,this.coupon,this.coupon_code,this.coupon_amount});

  Placeorder_request_model.fromJson(Map<String, dynamic> json) {

    orderType = json['orderType'];
    userId = json['user_id'];
    addressId = json['addressId'];
    coupon=json['coupons'];
    coupon_code=json['coupon_code'];
    coupon_amount=json['coupon_amount'];

    if (json['Items'] != null) {
      items = new List<PlaceorderItems>();
        json['Items'].forEach((v) {
          items.add(new PlaceorderItems.fromJson(v));
        });

    }
    if (json['payment'] != null) {
      payment = new List<Paymentdetls>();
      json['payment'].forEach((v) {
        payment.add(new Paymentdetls.fromJson(v));
      });

    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderType'] = this.orderType;
    data['user_id'] = this.userId;
    data['addressId'] = this.addressId;
    data['coupon']= this.coupon;
    data['coupon_code']= this.coupon_code;
    data['coupon_amount']= this.coupon_amount;

    if (this.items != null) {
      data['Items'] = this.items.map((v) => v.toJson()).toList();
    }
    if (this.payment != null) {
      data['payment'] = this.payment.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PlaceorderItems {
  String id;
  String title;
  String weight;
  String cartCount;
  String imageURL;
  String priceUnit;
  String discount;
  String deliveryCharges;

  PlaceorderItems(
      {this.id,
        this.title,
        this.weight,
        this.cartCount,
        this.imageURL,
        this.priceUnit,
        this.discount,
        this.deliveryCharges});

  PlaceorderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    weight = json['weight'];
    cartCount = json['cartCount'];
    imageURL = json['imageURL'];
    priceUnit = json['price_unit'];
    discount = json['discount'];
    deliveryCharges = json['deliveryCharges'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['weight'] = this.weight;
    data['cartCount'] = this.cartCount;
    data['imageURL'] = this.imageURL;
    data['price_unit'] = this.priceUnit;
    data['discount'] = this.discount;
    data['deliveryCharges'] = this.deliveryCharges;
    return data;
  }
}


class Paymentdetls {
  String paymentId;
  String orderId;
  String signature;
  int code;
  String message;


  Paymentdetls(
      {this.paymentId,
        this.orderId,
        this.signature,
        this.code,
        this.message
      });

  Paymentdetls.fromJson(Map<String, dynamic> json) {
    if(paymentId!=null) {
      paymentId = json['paymentId'];
    }
    if(orderId!=null) {
      orderId = json['orderId'];
    }
    if(signature!=null) {
      signature = json['signature'];
    }
    if(code!=null) {
      code = json['code'];
    }
    if(message!=null) {
      message = json['message'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if(this.paymentId!=null) {
      data['paymentId'] = this.paymentId;
    }
    if(this.orderId!=null) {
      data['orderId'] = this.orderId;
    }
    if(this.signature!=null) {
      data['signature'] = this.signature;
    }
    if(this.code!=null) {
      data['code'] = this.code;
    }
    if(this.message!=null) {
      data['message'] = this.message;
    }
    return data;
  }
}