import 'dart:convert';

import 'package:FarmToHome/Utils/DatabaseHelper.dart';
import 'package:FarmToHome/data/model/CartItemsModel.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/feedbackservices_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/myfavourites_response_model.dart';
import 'package:FarmToHome/data/model/previousorders_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract class HomeRepository {

  Future<List<HomeData>> getHomedata(String userID, String locationID);
  Future<List<FavouriteData>> addFavourite(String userID, String id,String status);
  Future<List<Previousordersdetails>> getPreviousorders(String user_ID);
  Future<List<EditProfileData>> submitFeedback(Map<String, String> inputmap);
  Future<List<FeedbackservicesData>> getFeedbackservices();
  Future<List<TodaySpecial>> fetchFavouritelist(String userID);
}

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<List<HomeData>> getHomedata(String userID, String locationID) async {
    var inputmap = new Map<String, String>();
    inputmap['locationId'] = locationID;
    inputmap['user_id'] = userID;

    var response = await http.post(AppStrings.homeurl,
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
  Future<List<FavouriteData>> addFavourite(String userID, String id,String status) async {
    var inputmap = new Map<String, String>();
    inputmap['user_id'] = userID;
    inputmap['id'] = id;
    inputmap['status'] = status;

    var response = await http.post(AppStrings.addremoveFavouriteurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },body:jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<FavouriteData> list = Favourite_response_model.fromJson(data).data;
      return list;
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<Previousordersdetails>> getPreviousorders(String user_ID) async {
    debugPrint("@@@@_________Previousorders req" + user_ID);
    var inputmap = new Map<String, String>();
    inputmap['user_id'] = user_ID;
    Uri uri = Uri.http("f2hknr.in", "/api/orders", inputmap);
    var response = await get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      debugPrint("@@@@_________Previousorders response" + jsonEncode(data));
      List<Previousordersdetails> _list = Previousorders_response_model.fromJson(data).data;
      return _list;
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<EditProfileData>> submitFeedback(Map<String, String> inputmap) async {

    var response = await post(AppStrings.feedbackurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<EditProfileData> _list = EditProfile_response_model.fromJson(data).data;
      return _list;
    } else {
      throw Exception();
    }
  }



  @override
  Future<List<FeedbackservicesData>> getFeedbackservices() async {

    Uri uri = Uri.http("f2hknr.in", "/api/feedback/services");
    var response = await get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      debugPrint("@@@@_________Feedbackservices response" + jsonEncode(data));
      List<FeedbackservicesData> _list = Feedbackservices_response_model.fromJson(data).data;
      return _list;
    } else {
      throw Exception();
    }
  }

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

}
