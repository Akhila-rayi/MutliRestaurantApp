
import 'dart:convert';

import 'package:FarmToHome/data/model/appinfo_response_model.dart';
import 'package:FarmToHome/data/model/farmersinfo_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

abstract class AppInfoRepository {
  Future<List<Appinfo_Data>> fetchaboutus_Data(String locID);
  Future<List<Appinfo_Data>> fetchcontactinfo_Data(String locID);
  Future<List<Appinfo_Data>> fetchtermsConditions();
  Future<List<Appinfo_Data>> fetchprivacypolicy();
  Future<List<FarmersinfoData>> fetchFarmersinfo();
  Future<List<Appinfo_Data>> fetchFAQs();
}

class AppInfoRepositoryImpl implements AppInfoRepository {

  @override
  Future<List<Appinfo_Data>> fetchaboutus_Data(String locID) async {

    var inputmap = new Map<String, String>();
    inputmap['locationId'] = locID;
    debugPrint("@@@@_________appinfo req"+locID);

    var response = await post(AppStrings.aboutusurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      debugPrint("@@@@_________appinfo response"+response.body);

      var data = json.decode(response.body);
      List<Appinfo_Data> appinfodatalist = Appinfo_response_model.fromJson(data).data;
      return appinfodatalist;
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<Appinfo_Data>> fetchcontactinfo_Data(String locID) async {

    var inputmap = new Map<String, String>();
    inputmap['locationId'] = locID;
    debugPrint("@@@@_________appinfo req"+locID);

    var response = await post(AppStrings.contatusurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      debugPrint("@@@@_________appinfo response"+response.body);

      var data = json.decode(response.body);

      List<Appinfo_Data> appinfodatalist = Appinfo_response_model.fromJson(data).data;
      return appinfodatalist;
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<Appinfo_Data>> fetchtermsConditions() async {

    Uri uri = Uri.http("f2hknr.in", "/api/pages/terms");
    var response = await get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      debugPrint("@@@@_________termsConditions response"+response.body);

      var data = json.decode(response.body);

      List<Appinfo_Data> appinfodatalist = Appinfo_response_model.fromJson(data).data;
      return appinfodatalist;
    } else {
      throw Exception();
    }
  }


  @override
  Future<List<Appinfo_Data>> fetchprivacypolicy() async {

    Uri uri = Uri.http("f2hknr.in", "/api/pages/privacy");
    var response = await get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      debugPrint("@@@@____________privacypolicy response"+response.body);

      var data = json.decode(response.body);
      List<Appinfo_Data> appinfodatalist = Appinfo_response_model.fromJson(data).data;
      return appinfodatalist;

    } else {
      throw Exception();
    }
  }

  @override
  Future<List<Appinfo_Data>> fetchFAQs() async {

    Uri uri = Uri.http("f2hknr.in", "/api/pages/faqs");
    var response = await get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      debugPrint("@@@@_________FAQs response"+response.body);

      var data = json.decode(response.body);
      List<Appinfo_Data> appinfodatalist = Appinfo_response_model.fromJson(data).data;
      return appinfodatalist;

    } else {
      throw Exception();
    }
  }



  @override
  Future<List<FarmersinfoData>> fetchFarmersinfo() async {

    Uri uri = Uri.http("f2hknr.in", "/api/pages/farmers");
    var response = await get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      debugPrint("@@@@_________FARMER INFO response"+response.body);

      var data = json.decode(response.body);
      List<FarmersinfoData> farmersinfoData = Farmersinfo_response_model.fromJson(data).data;
      return farmersinfoData;

    } else {
      throw Exception();
    }
  }
}