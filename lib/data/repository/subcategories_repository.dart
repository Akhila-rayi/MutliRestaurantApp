
import 'dart:convert';

import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/subcategories_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

abstract class SubcategoriesRepository {
  Future<List<SubcategoriesData>> getSubcategories(String user_ID,String locationID,String category);
  Future<List<FavouriteData>> addFavourite(String userID, String id, String status);
}

class SubcategoriesRepositoryImpl implements SubcategoriesRepository {

  @override
  Future<List<SubcategoriesData>> getSubcategories(String user_ID,String locationID,String category) async {

    debugPrint("@@@@_________Subcategories input" + user_ID + "___" + locationID+ "___" + category);
    var inputmap = new Map<String, String>();
    inputmap['user_id'] = user_ID;
    inputmap['locationId'] = locationID;
    inputmap['category'] = category;

    var response = await post(AppStrings.subcategoriesurl,headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }, body: jsonEncode(inputmap));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      debugPrint("@@@@_________Subcategories response" + jsonEncode(data));
      List<SubcategoriesData> _list = Subcategories_response_model.fromJson(data).data;
      return _list;
    } else {
    throw Exception();
    }
  }


  @override
  Future<List<FavouriteData>> addFavourite(
      String userID, String id, String status) async {

    debugPrint("@@@ favourite input"+userID+"___"+id+"___"+status);
    var inputmap = {
      'user_id': userID,
      'id': id,
      'status':status
    };

    var response = await post(AppStrings.addremoveFavouriteurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<FavouriteData> list = Favourite_response_model.fromJson(data).data;
      return list;
    } else {
      throw Exception();
    }
  }


}