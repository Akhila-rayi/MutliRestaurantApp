
import 'package:FarmToHome/data/model/paymentgateway_response_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class PaymentgatewayState extends Equatable {}

class PaymentgatewayInitialState extends PaymentgatewayState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class PaymentgatewayLoadingState extends PaymentgatewayState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class FetchPaymentinfoLoadedState extends PaymentgatewayState {

  List<PaymentgatewayData> paymentgatewaylist;

  FetchPaymentinfoLoadedState({@required this.paymentgatewaylist});

  @override
  // TODO: implement props
  List<Object> get props => [paymentgatewaylist];
}



class PaymentgatewayErrorState extends PaymentgatewayState {

  String message;

  PaymentgatewayErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}