
import 'dart:convert';

import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/searchproduct_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

abstract class SearchProductRepository {
  Future<List<TodaySpecial>> getProducts(String user_ID,String query);
  Future<List<FavouriteData>> adddelFavourite(String userID, String id, String status);
}

class SearchProductRepositoryImpl implements SearchProductRepository {

  @override
  Future<List<TodaySpecial>> getProducts(String user_ID,String query) async {

    debugPrint("@@@@_________search response"+user_ID+"___"+query);
    var inputmap = new Map<String, String>();
    inputmap['user_id'] = user_ID;
    inputmap['q'] = query;
    Uri uri = Uri.http("f2hknr.in", "/api/search", inputmap);
    var response = await get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      debugPrint("@@@@_________search response"+jsonEncode(data));

      List<TodaySpecial> _list = Searchproduct_response_model.fromJson(data).data;

      return _list;
    } else {
      throw Exception();
    }
  }


  @override
  Future<List<FavouriteData>> adddelFavourite(
      String userID, String id, String status) async {
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