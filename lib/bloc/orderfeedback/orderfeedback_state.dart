
import 'package:FarmToHome/data/model/appinfo_response_model.dart';
import 'package:FarmToHome/data/model/farmersinfo_response_model.dart';
import 'package:FarmToHome/data/model/orderfeedback_response_model.dart';
import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:meta/meta.dart';

abstract class OrderfeedbackState extends Equatable {}

class OrderfeedbackInitialState extends OrderfeedbackState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class OrderfeedbackLoadingState extends OrderfeedbackState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AddOrderfeedbackLoadedState extends OrderfeedbackState {

  List<OrderfeedbackData> list;

  AddOrderfeedbackLoadedState({@required this.list});


  @override
  // TODO: implement props
  List<Object> get props => [list];
}
class OrderfeedbackErrorState extends OrderfeedbackState {

  String message;

  OrderfeedbackErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}