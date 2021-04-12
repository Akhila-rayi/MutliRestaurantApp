import 'dart:math';

import 'package:FarmToHome/data/model/login_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class LoginRepository {
  Future<String> getLogindata(String user_mobileNumber);
  Future<LoginVerify_response_model> verifyLogindata(String user_mobileNumber,String otp);
  Future<String> senddevicetoken(String user_id,String token);
}

class LoginRepositoryImpl implements LoginRepository {
  @override
  Future<String> getLogindata(String user_mobileNumber) async {

    var inputmap = new Map<String, String>();
    inputmap['mobileNo'] = user_mobileNumber;

    var response = await http.post(AppStrings.loginurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String msg=Login_response_model.fromJson(data).message;
     // List<LoginData> articles = Login_response_model.fromJson(data).data;
      return msg;
    } else {
      throw Exception();
    }
  }

  @override
  Future<LoginVerify_response_model> verifyLogindata(String user_mobileNumber,String otp) async {

    var inputmap = new Map<String, String>();
    inputmap['mobileNo'] = user_mobileNumber;
    inputmap['otp'] = otp;

    var response = await http.post(AppStrings.verifyloginurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      LoginVerify_response_model loginVerify_response_model = LoginVerify_response_model.fromJson(data);
      return loginVerify_response_model;
    } else {
      throw Exception();
    }
  }

  @override
  Future<String> senddevicetoken(String user_id,String token) async {

    var inputmap = new Map<String, String>();
    inputmap['user_id'] = user_id;
    inputmap['token'] = token;

    debugPrint("@@@ send devicetoken request______"+token+"_________"+user_id);

    var response = await http.post(AppStrings.devicetokenurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      debugPrint("@@@ send devicetoken response______"+jsonEncode(data));

      if(data['message'].toString().toLowerCase()=="success"){

        return "success";
      }
      else{
        return "failure";
      }

    } else {
      throw Exception();
    }
  }
}
