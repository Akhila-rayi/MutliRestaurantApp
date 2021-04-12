
import 'package:FarmToHome/data/model/placeorder_response_model.dart';
import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:meta/meta.dart';

abstract class PlaceOrderState extends Equatable {}

class PlaceOrderInitialState extends PlaceOrderState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class PlaceOrderLoadingState extends PlaceOrderState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class PlaceOrderLoadedState extends PlaceOrderState {

  String status;

  PlaceOrderLoadedState({@required this.status});

  @override
  // TODO: implement props
  List<Object> get props => [status];
}


class SendPaymentstatusLoadedState extends PlaceOrderState {

  String status;

  SendPaymentstatusLoadedState({@required this.status});

  @override
  // TODO: implement props
  List<Object> get props => [status];
}

class PlaceOrderErrorState extends PlaceOrderState {

  String message;

  PlaceOrderErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}