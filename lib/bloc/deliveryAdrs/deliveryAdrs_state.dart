
import 'package:FarmToHome/data/model/paymentgateway_response_model.dart';
import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:meta/meta.dart';

abstract class DeliveryAdrsState extends Equatable {}

class DeliveryAdrsInitialState extends DeliveryAdrsState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class DeliveryAdrsLoadingState extends DeliveryAdrsState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class DeliveryAdrsLoadedState extends DeliveryAdrsState {

  List<DeliveryAdrsData> deliveryAdrsdata;

  DeliveryAdrsLoadedState({@required this.deliveryAdrsdata});

  @override
  // TODO: implement props
  List<Object> get props => [deliveryAdrsdata];
}



class SubmitDeliveryAdrsLoadedState extends DeliveryAdrsState {

  List<DeliveryAdrsData> deliveryAdrsdata;

  SubmitDeliveryAdrsLoadedState({@required this.deliveryAdrsdata});

  @override
  // TODO: implement props
  List<Object> get props => [deliveryAdrsdata];
}


class FetchPaymentinfoLoadedState extends DeliveryAdrsState {

  List<PaymentgatewayData> paymentgatewaylist;

  FetchPaymentinfoLoadedState({@required this.paymentgatewaylist});

  @override
  // TODO: implement props
  List<Object> get props => [paymentgatewaylist];
}


class DeliveryAdrsErrorState extends DeliveryAdrsState {

  String message;

  DeliveryAdrsErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}


class FetchcouponsLoadedState extends DeliveryAdrsState {

  List<HomeData> homedata;

  FetchcouponsLoadedState({@required this.homedata});

  @override
  // TODO: implement props
  List<Object> get props => [homedata];
}