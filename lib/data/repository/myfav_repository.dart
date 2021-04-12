import 'dart:convert';
import 'dart:io';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/myfavourites_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

abstract class MyFavouriteRepository {
  Future<List<TodaySpecial>> fetchFavouritelist(String userID);

  Future<List<FavouriteData>> addFavourite(String userID, String id, String status);
}

class MyFavouriteRepositoryImpl implements MyFavouriteRepository {
  @override
  Future<List<TodaySpecial>> fetchFavouritelist(String userID) async {
    var inputmap = new Map<String, String>();
    inputmap["user_id"] = userID;


    var response = await http.post(AppStrings.getFavouritesurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<TodaySpecial> list = Myfavourites_response_model.fromJson(data).data;
      return list;
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<FavouriteData>> addFavourite(
      String userID, String id, String status) async {

    debugPrint("@@@input"+userID+"___"+id+"___"+status);
    var inputmap = {
      'user_id': userID,
      'id': id,
      'status':status
    };


    var response = await http.post(AppStrings.addremoveFavouriteurl,
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
