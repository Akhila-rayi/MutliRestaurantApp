import 'dart:convert';

import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract class ProfileRepository {
  Future<List<ProfileData>> getprofile(String user_ID);
  Future<List<EditProfileData>> submitprofile(Map<String, String> inputmap);
}

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<List<ProfileData>> getprofile(String user_ID) async {
    var inputmap = new Map<String, String>();
    inputmap['user_id'] = user_ID;

    Uri uri = Uri.http("f2hknr.in", "/api/profile", inputmap);
    var response = await get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<ProfileData> _list = Profile_response_model.fromJson(data).data;
      return _list;
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<EditProfileData>> submitprofile(Map<String, String> inputmap) async {

    var response = await http.post(AppStrings.editProfileurl,
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
}
