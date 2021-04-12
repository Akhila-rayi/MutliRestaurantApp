
import 'dart:convert';

import 'package:FarmToHome/data/model/placeorder_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

abstract class PlaceOrderRepository {
  Future<String> placeorder(Map<String, dynamic> inputmap);
  Future<String> sendpaymentstatus(Map<String, dynamic> inputmap);
}

class PlaceOrderRepositoryImpl implements PlaceOrderRepository {

  @override
  Future<String> placeorder(Map<String, dynamic> inputmap) async {

    debugPrint("@@@@@@@@_______________PLACE ORDER REQ"+jsonEncode(inputmap));
    var response = await post(AppStrings.placeorder,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      debugPrint("@@@@@@@@_______________PLACE ORDER RESPONSE"+jsonEncode(data));
      String status = Placeorder_response_model.fromJson(data).status;
      return status;
    } else {
      throw Exception();
    }
  }

  @override
  Future<String> sendpaymentstatus(Map<String, dynamic> inputmap) async {

    debugPrint("@@@@@@@@_______________PAYMENT STATUS REQ"+jsonEncode(inputmap));
    var response = await post(AppStrings.sendPaymentStatusurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      debugPrint("@@@@@@@@_______________PAYMENT STATUS  RESPONSE"+jsonEncode(data));
      String status = Placeorder_response_model.fromJson(data).status;
      return status;
    } else {
      throw Exception();
    }
  }


}