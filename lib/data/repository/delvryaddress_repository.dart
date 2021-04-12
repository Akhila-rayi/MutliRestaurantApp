
import 'dart:convert';

import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/paymentgateway_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

abstract class DeliveryAddressRepository {
  Future<List<DeliveryAdrsData>> getDeliveryAdrs(String user_ID);
  Future<List<DeliveryAdrsData>> submitAddress(Map<String, String> inputmap);
  Future<List<PaymentgatewayData>> getPaymentgatewaysinfo(String locationid);
  Future<List<HomeData>> getcouponsdata(String userID, String locationID);
}

class DeliveryAddressRepositoryImpl implements DeliveryAddressRepository {

  @override
  Future<List<HomeData>> getcouponsdata(String userID, String locationID) async {
    var inputmap = new Map<String, String>();
    inputmap['locationId'] = locationID;
    inputmap['user_id'] = userID;

    var response = await  post(AppStrings.homeurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<HomeData> homedata = Home_response_model.fromJson(data).data;
      return homedata;
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<DeliveryAdrsData>> getDeliveryAdrs(String user_ID) async {
    var inputmap = new Map<String, String>();
    inputmap['user_id'] = user_ID;
    Uri uri = Uri.http("f2hknr.in", "/api/addresses", inputmap);
    var response = await get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      debugPrint("@@@@ GET DELIVER ADRS"+jsonEncode(data));
      List<DeliveryAdrsData> _list = DeliveryAddr_response_model.fromJson(data).data;
      return _list;
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<DeliveryAdrsData>> submitAddress(Map<String, String> inputmap) async {

    var response = await post(AppStrings.submmitAddressurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<DeliveryAdrsData> _list = DeliveryAddr_response_model.fromJson(data).data;
      return _list;
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<PaymentgatewayData>> getPaymentgatewaysinfo(String locationid) async {
    var inputmap = new Map<String, String>();
    inputmap['locationId'] = locationid;

    var response = await post(AppStrings.paymentgatewaysurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<PaymentgatewayData> list = Paymentgateway_response_model.fromJson(data).data;
      return list;
    } else {
      throw Exception();
    }
  }
}