

import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_event.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_state.dart';
import 'package:FarmToHome/bloc/myfavourite/myfavourite_state.dart';
import 'package:FarmToHome/bloc/profile/profile_event.dart';
import 'package:FarmToHome/bloc/profile/profile_state.dart';
import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/paymentgateway_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:FarmToHome/data/repository/delvryaddress_repository.dart';
import 'package:FarmToHome/data/repository/profile_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

class DeliveryAdrsBloc extends Bloc<DeliveryAdrsEvent, DeliveryAdrsState> {

  DeliveryAddressRepository repository;

  DeliveryAdrsBloc({@required this.repository}): super(DeliveryAdrsInitialState());

  @override
  // TODO: implement initialState
  DeliveryAdrsState get initialState => DeliveryAdrsInitialState();

  @override
  Stream<DeliveryAdrsState> mapEventToState(DeliveryAdrsEvent event) async* {
    if (event is FetchDeliveryAdrsEvent) {
      yield DeliveryAdrsLoadingState();
      try {
        List<DeliveryAdrsData> deliveryadrsdata = await repository.getDeliveryAdrs(event.userID);
        yield DeliveryAdrsLoadedState(deliveryAdrsdata: deliveryadrsdata);
      } catch (e) {
        yield DeliveryAdrsErrorState(message: e.toString());
      }
    }

    if (event is SubmitDeliveryAdrsEvent) {
      yield DeliveryAdrsLoadingState();
      try {
        List<DeliveryAdrsData> deliveryadrsdata = await repository.submitAddress(event.deliveryAdrsmap);
        yield SubmitDeliveryAdrsLoadedState(deliveryAdrsdata: deliveryadrsdata);
      } catch (e) {
        yield DeliveryAdrsErrorState(message: e.toString());
      }
    }

    if (event is FetchPaymentgatewaysEvent) {
      yield DeliveryAdrsLoadingState();
      try {
        List<PaymentgatewayData> paymentgatewaylist= await repository.getPaymentgatewaysinfo(event.loc_ID);
        yield FetchPaymentinfoLoadedState(paymentgatewaylist:  paymentgatewaylist);
      } catch (e) {
        yield DeliveryAdrsErrorState(message: e.toString());
      }
    }

    if (event is FetchcouponsEvent) {
      yield DeliveryAdrsLoadingState();
      try {
        List<HomeData> homedata= await repository.getcouponsdata(event.userID,event.locationID);
        yield FetchcouponsLoadedState(homedata: homedata);
      } catch (e) {
        yield DeliveryAdrsErrorState(message: e.toString());
      }
    }

  }

}