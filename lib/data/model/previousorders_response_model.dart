import 'dart:convert';

class Previousorders_response_model {
  String status;
  String message;
  List<Previousordersdetails> data;

  Previousorders_response_model({this.status, this.message, this.data});

  Previousorders_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Previousordersdetails>();
      if (!jsonEncode(json['data']).contains("[[]]")) {
        json['data'].forEach((v) {
          data.add(new Previousordersdetails.fromJson(v));
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

class Previousordersdetails {
  String orderId;
  String orderTotal;
  String orderDate;
  String orderType;
  String orderStatus;
  int feedback;
  List<OrderItems> orderItems;

  Previousordersdetails(
      {this.orderId,
        this.orderTotal,
        this.orderDate,
        this.orderType,
        this.orderStatus,
        this.feedback,
        this.orderItems});

  Previousordersdetails.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    orderTotal = json['order_total'].toString();
    orderDate = json['orderDate'];
    orderType = json['orderType'];
    orderStatus = json['orderStatus'];
    feedback = json['feedback'];
    if (json['orderItems'] != null) {
      orderItems = new List<OrderItems>();
      json['orderItems'].forEach((v) {
        orderItems.add(new OrderItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderId'] = this.orderId;
    data['order_total'] = this.orderTotal;
    data['orderDate'] = this.orderDate;
    data['orderType'] = this.orderType;
    data['orderStatus'] = this.orderStatus;
    data['feedback'] = this.feedback;
    if (this.orderItems != null) {
      data['orderItems'] = this.orderItems.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderItems {
  String cart_id;
  String id;
  String title;
  String weight;
  String imageURL;
  String priceTotal;
  String cartCount;
  String discount;

  OrderItems(
      {this.cart_id,
        this.id,
        this.title,
        this.weight,
        this.imageURL,
        this.priceTotal,
        this.cartCount,
        this.discount});

  OrderItems.fromJson(Map<String, dynamic> json) {
    cart_id=json["cart_id"];
    id = json['id'];
    title = json['title'];
    weight = json['Weight'];
    imageURL = json['imageURL'];
    priceTotal = json['price_total'];
    cartCount = json['cartCount'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["cart_id"]=this.cart_id;
    data['id'] = this.id;
    data['title'] = this.title;
    data['Weight'] = this.weight;
    data['imageURL'] = this.imageURL;
    data['price_total'] = this.priceTotal;
    data['cartCount'] = this.cartCount;
    data['discount'] = this.discount;
    return data;
  }
}