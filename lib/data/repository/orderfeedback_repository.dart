
import 'dart:convert';
import 'package:FarmToHome/data/model/orderfeedback_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

abstract class OrderfeedbackRepository{

  Future<List<OrderfeedbackData>> addorderfeedback(Map<String,String> inputmap);
}

class OrderfeedbackRepositoryImpl implements OrderfeedbackRepository {


  @override
  Future<List<OrderfeedbackData>> addorderfeedback(Map<String,String> inputmap) async {

    debugPrint("@@@ ADD ORDER FEEDBACK REQUEST"+jsonEncode(inputmap));
    var response = await http.post(AppStrings.orderFeedbackurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {

      debugPrint("@@@ ADD ORDER FEEDBACK RESPONSE"+response.body);
      var data = json.decode(response.body);
      List<OrderfeedbackData> list = Orderfeedback_response_model.fromJson(data).data;
      return list;
    } else {
      throw Exception();
    }
  }
}
