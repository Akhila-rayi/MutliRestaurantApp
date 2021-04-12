import 'dart:convert';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

abstract class LocationRepository {
  Future<List<LocationDetls>> getLocations();

  Future<List<LocationDetls>> selectedLocation(String user_id, String locationId);
}

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<List<LocationDetls>> getLocations() async {
    var response = await http.get(AppStrings.getbranchesurl,headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<LocationDetls> articles = Location_response_model.fromJson(data).data;
      return articles;
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<LocationDetls>> selectedLocation(
      String user_id, String locationId) async {
    var inputmap = new Map<String, String>();
    inputmap['locationId'] = locationId;
    inputmap['user_id'] = user_id;
    debugPrint("@@@ SELECTED LOC REQ "+jsonEncode(inputmap));
    /*var response = await http.get(
        Uri.http(AppStrings.selectedbranchurl, jsonEncode(inputmap)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });*/

    var response = await http.post(AppStrings.selectedbranchurl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(inputmap));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      debugPrint("@@@ SELECTED LOCRESPONSE "+response.body);
      List<LocationDetls> articles = Location_response_model.fromJson(data).data;
      return articles;
    } else {
      throw Exception();
    }
  }
}
