
import 'dart:convert';

import 'package:FarmToHome/data/model/paymentgateway_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:http/http.dart';

abstract class PaymentgatewayRepository {
  Future<List<PaymentgatewayData>> getPaymentgatewaysinfo(String locationid);
}

class PaymentgatewayRepositoryImpl implements PaymentgatewayRepository {
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