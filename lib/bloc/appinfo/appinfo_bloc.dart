

import 'package:FarmToHome/bloc/appinfo/appinfo_event.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_state.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_event.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_state.dart';
import 'package:FarmToHome/bloc/myfavourite/myfavourite_state.dart';
import 'package:FarmToHome/bloc/profile/profile_event.dart';
import 'package:FarmToHome/bloc/profile/profile_state.dart';
import 'package:FarmToHome/data/model/appinfo_response_model.dart';
import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/farmersinfo_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:FarmToHome/data/repository/appinfo_repository.dart';
import 'package:FarmToHome/data/repository/delvryaddress_repository.dart';
import 'package:FarmToHome/data/repository/profile_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

class AppInfoBloc extends Bloc<AppInfoEvent, AppInfoState> {

  AppInfoRepository repository;

  AppInfoBloc({@required this.repository}): super(AppInfoInitialState());

  @override
  // TODO: implement initialState
  AppInfoState get initialState => AppInfoInitialState();

  @override
  Stream<AppInfoState> mapEventToState(AppInfoEvent event) async* {
    if (event is FetchAppInfoEvent) {
      yield AppInfoLoadingState();
      try {
        List<Appinfo_Data> appinfodata  = await repository.fetchaboutus_Data(event.locID);
        yield FetchAppInfoLoadedState(appinfodata: appinfodata);
      } catch (e) {
        yield AppInfoErrorState(message: e.toString());
      }
    }

    if (event is FetchContactInfoEvent) {
      yield AppInfoLoadingState();
      try {
        List<Appinfo_Data> appinfodata  = await repository.fetchcontactinfo_Data(event.locID);
        yield FetchContactInfoLoadedState(appinfodata: appinfodata);
      } catch (e) {
        yield AppInfoErrorState(message: e.toString());
      }
    }

    if (event is FetchTermsConditionsEvent) {
      yield AppInfoLoadingState();
      try {
        List<Appinfo_Data> appinfodata  = await repository.fetchtermsConditions();
        yield FetchTermsConditionsLoadedState(appinfodata: appinfodata);
      } catch (e) {
        yield AppInfoErrorState(message: e.toString());
      }
    }

    if (event is FetchPrivacypolicyEvent) {
      yield AppInfoLoadingState();
      try {
        List<Appinfo_Data> appinfodata  = await repository.fetchprivacypolicy();
        yield FetchPrivacypolicyLoadedState(appinfodata: appinfodata);
      } catch (e) {
        yield AppInfoErrorState(message: e.toString());
      }
    }

    if (event is FetchFAQsEvent) {
      yield AppInfoLoadingState();
      try {
        List<Appinfo_Data> appinfodata  = await repository.fetchFAQs();
        yield FetchFAQsLoadedState(appinfodata: appinfodata);
      } catch (e) {
        yield AppInfoErrorState(message: e.toString());
      }
    }

    if (event is FetchFarmersinfoEvent) {
      yield AppInfoLoadingState();
      try {
        List<FarmersinfoData> farmersinfodata  = await repository.fetchFarmersinfo();
        yield FetchFarmersinfoState(farmersinfodata: farmersinfodata);
      } catch (e) {
        yield AppInfoErrorState(message: e.toString());
      }
    }
  }

}