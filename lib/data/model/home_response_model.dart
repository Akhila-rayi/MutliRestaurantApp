import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';

class Home_response_model {
  String status;
  String message;
  List<HomeData> data;

  Home_response_model({this.status, this.message, this.data});

  Home_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<HomeData>();
      json['data'].forEach((v) {
        data.add(new HomeData.fromJson(v));
      });
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

class HomeData {
  String availability;
  List<Banners> banners;
  List<Categories> categories;
  List<TodaySpecial> todaySpecial;
  List<TopSellers> topSellers;
  List<LocationDetls> branch;
  List<Coupons> coupons;

  HomeData(
      {this.availability,
        this.banners,
        this.categories,
        this.todaySpecial,
        this.topSellers,
        this.branch,
        this.coupons});

  HomeData.fromJson(Map<String, dynamic> json) {
    availability = json['availability'];
    if (json['banners'] != null) {
      banners = new List<Banners>();
      if (!jsonEncode(json['banners']).contains("[[]]")) {
        json['banners'].forEach((v) {
          banners.add(new Banners.fromJson(v));
        });
      }
    }
    if (json['categories'] != null) {
      categories = new List<Categories>();
      if (!jsonEncode(json['categories']).contains("[[]]")) {
        json['categories'].forEach((v) {
          categories.add(new Categories.fromJson(v));
        });
      }
    }
    if (json['todaySpecial'] != null) {
      todaySpecial = new List<TodaySpecial>();
      if (!jsonEncode(json['todaySpecial']).contains("[[]]")) {
        json['todaySpecial'].forEach((v) {
          todaySpecial.add(new TodaySpecial.fromJson(v));
        });
      }
    }
    if (json['topSellers'] != null) {
      topSellers = new List<TopSellers>();
      if (!jsonEncode(json['topSellers']).contains("[[]]")) {
        json['topSellers'].forEach((v) {
          topSellers.add(new TopSellers.fromJson(v));
        });
      }
    }
    if (json['branch'] != null) {
      branch = new List<LocationDetls>();
      if (!jsonEncode(json['branch']).contains("[[]]")) {
        json['branch'].forEach((v) {
          branch.add(new LocationDetls.fromJson(v));
        });
      }
    }

    if (json['coupons'] != null) {
      coupons = new List<Coupons>();
      if (!jsonEncode(json['coupons']).contains("[[]]")) {
        json['coupons'].forEach((v) {
          coupons.add(new Coupons.fromJson(v));
        });
      }
    }

   /* if (branch.length > 0) {
      new UserPrefs().setLoctndetls(jsonEncode(json['branch']));
    }*/
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['availability'] = this.availability;
    if (this.banners != null) {
      data['banners'] = this.banners.map((v) => v.toJson()).toList();
    }
    if (this.categories != null) {
      data['categories'] = this.categories.map((v) => v.toJson()).toList();
    }
    if (this.todaySpecial != null) {
      data['todaySpecial'] = this.todaySpecial.map((v) => v.toJson()).toList();
    }
    if (this.topSellers != null) {
      data['topSellers'] = this.topSellers.map((v) => v.toJson()).toList();
    }
    if (this.branch != null) {
      data['branch'] = this.branch.map((v) => v.toJson()).toList();
    }
    if (this.coupons != null) {
      data['coupons'] = this.coupons.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Banners {
  String imageUrl;
  String titleMain;
  String titleSub;
  String category;
  String siteUrl;
  String product;
  String subcategory;

  Banners(
      {this.imageUrl,
        this.titleMain,
        this.titleSub,
        this.category,
        this.siteUrl,this.product,this.subcategory});

  Banners.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl'];
    titleMain = json['title_main'];
    titleSub = json['title_sub'];
    category = json['category'];
    siteUrl = json['siteUrl'];
    product = json['product'];
    subcategory = json['subcategory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageUrl'] = this.imageUrl;
    data['title_main'] = this.titleMain;
    data['title_sub'] = this.titleSub;
    data['category'] = this.category;
    data['siteUrl'] = this.siteUrl;
    data['product']=this.product;
    data['subcategory']=this.subcategory;
    return data;
  }
}

class Categories {
  String imageUrl;
  String titleMain;
  String category;
  String siteUrl;

  Categories({this.imageUrl, this.titleMain, this.category, this.siteUrl});

  Categories.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl'];
    titleMain = json['title_main'];
    category = json['category'];
    siteUrl = json['siteUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageUrl'] = this.imageUrl;
    data['title_main'] = this.titleMain;
    data['category'] = this.category;
    data['siteUrl'] = this.siteUrl;
    return data;
  }
}

class TodaySpecial {

  String id;
  String title;
  String imageURL;
  String itemType;
  String weight;
  String priceUnit;
  String quantity;
  var priceTotal;
  String discount;
  bool availability;
  String itemTypeURL;
  bool isFavorite;

  TodaySpecial(
      {this.id,
        this.title,
        this.imageURL,
        this.itemType,
        this.weight,
        this.priceUnit,
        this.quantity,
        this.priceTotal,
        this.discount,
        this.availability,
        this.itemTypeURL,
        this.isFavorite});

  TodaySpecial.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    imageURL = json['imageURL'];
    itemType = json['itemType'];
    weight = json['weight'];
    priceUnit = json['price_unit'];
    quantity = json['quantity'];
    priceTotal = json['price_total'];
    discount = json['discount'];
    availability = json['availability'];
    itemTypeURL = json['itemTypeURL'];
    isFavorite = json['isFavorite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['imageURL'] = this.imageURL;
    data['itemType'] = this.itemType;
    data['weight'] = this.weight;
    data['price_unit'] = this.priceUnit;
    data['quantity'] = this.quantity;
    data['price_total'] = this.priceTotal;
    data['discount'] = this.discount;
    data['availability'] = this.availability;
    data['itemTypeURL'] = this.itemTypeURL;
    data['isFavorite'] = this.isFavorite;
    return data;
  }
}

class TopSellers {
  String id;
  String title;
  String imageURL;
  String itemType;
  String weight;
  String priceUnit;
  String quantity;
  String priceTotal;
  String discount;
  bool availability;
  String itemTypeURL;
  bool isFavorite;

  TopSellers(
      {this.id,
        this.title,
        this.imageURL,
        this.itemType,
        this.weight,
        this.priceUnit,
        this.quantity,
        this.priceTotal,
        this.discount,
        this.availability,
        this.itemTypeURL,
        this.isFavorite});

  TopSellers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    imageURL = json['imageURL'];
    itemType = json['itemType'];
    weight = json['weight'];
    priceUnit = json['price_unit'];
    quantity = json['quantity'];
    priceTotal = json['price_total'];
    discount = json['discount'];
    availability = json['availability'];
    itemTypeURL = json['itemTypeURL'];
    isFavorite = json['isFavorite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['imageURL'] = this.imageURL;
    data['itemType'] = this.itemType;
    data['weight'] = this.weight;
    data['price_unit'] = this.priceUnit;
    data['quantity'] = this.quantity;
    data['price_total'] = this.priceTotal;
    data['discount'] = this.discount;
    data['availability'] = this.availability;
    data['itemTypeURL'] = this.itemTypeURL;
    data['isFavorite'] = this.isFavorite;
    return data;
  }
}


class Coupons {
  String locationId;
  String type;
  String code;
  String amountType;
  String value;
  String minAmount;
  String maxAmount;
  String count;
  String termsConditions;
  String expiredAt;
  String status;


  Coupons(
      {this.locationId,
        this.type,
        this.code,
        this.amountType,
        this.value,
        this.minAmount,
        this.maxAmount,
        this.count,
        this.termsConditions,
        this.expiredAt,
        this.status});

  Coupons.fromJson(Map<String, dynamic> json) {
    locationId = json['locationId'];
    type = json['type'];
    code = json['code'];
    amountType = json['amount_type'];
    value = json['value'];
    minAmount = json['min_amount'];
    maxAmount = json['max_amount'];
    count = json['count'];
    termsConditions = json['terms_conditions'];
    expiredAt = json['expired_at'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['locationId'] = this.locationId;
    data['type'] = this.type;
    data['code'] = this.code;
    data['amount_type'] = this.amountType;
    data['value'] = this.value;
    data['min_amount'] = this.minAmount;
    data['max_amount'] = this.maxAmount;
    data['count'] = this.count;
    data['terms_conditions'] = this.termsConditions;
    data['expired_at'] = this.expiredAt;
    data['status'] = this.status;
    return data;
  }
}