
import 'package:FarmToHome/data/model/appinfo_response_model.dart';
import 'package:FarmToHome/data/model/farmersinfo_response_model.dart';
import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:meta/meta.dart';

abstract class AppInfoState extends Equatable {}

class AppInfoInitialState extends AppInfoState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AppInfoLoadingState extends AppInfoState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class FetchAppInfoLoadedState extends AppInfoState {

  List<Appinfo_Data> appinfodata;

  FetchAppInfoLoadedState({@required this.appinfodata});


  @override
  // TODO: implement props
  List<Object> get props => [appinfodata];
}

class FetchContactInfoLoadedState extends AppInfoState {

  List<Appinfo_Data> appinfodata;

  FetchContactInfoLoadedState({@required this.appinfodata});


  @override
  // TODO: implement props
  List<Object> get props => [appinfodata];
}


class FetchTermsConditionsLoadedState extends AppInfoState {

  List<Appinfo_Data> appinfodata;

  FetchTermsConditionsLoadedState({@required this.appinfodata});


  @override
  // TODO: implement props
  List<Object> get props => [appinfodata];
}


class FetchPrivacypolicyLoadedState extends AppInfoState {

  List<Appinfo_Data> appinfodata;

  FetchPrivacypolicyLoadedState({@required this.appinfodata});


  @override
  // TODO: implement props
  List<Object> get props => [appinfodata];
}



class FetchFAQsLoadedState extends AppInfoState {

  List<Appinfo_Data> appinfodata;

  FetchFAQsLoadedState({@required this.appinfodata});


  @override
  // TODO: implement props
  List<Object> get props => [appinfodata];
}


class FetchFarmersinfoState extends AppInfoState {

  List<FarmersinfoData> farmersinfodata;

  FetchFarmersinfoState({@required this.farmersinfodata});


  @override
  // TODO: implement props
  List<Object> get props => [farmersinfodata];
}

class AppInfoErrorState extends AppInfoState {

  String message;

  AppInfoErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}