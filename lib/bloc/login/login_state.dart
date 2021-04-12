
import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:meta/meta.dart';

abstract class LoginState extends Equatable {}

class LoginInitialState extends LoginState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LoginLoadingState extends LoginState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LoginLoadedState extends LoginState {

  String msg;

  LoginLoadedState({@required this.msg});

  @override
  // TODO: implement props
  List<Object> get props => [msg];
}


class VerifyLoginLoadedState extends LoginState {

  LoginVerify_response_model loginVerify_response_model;

  VerifyLoginLoadedState({@required this.loginVerify_response_model});

  @override
  // TODO: implement props
  List<Object> get props => [loginVerify_response_model];
}


class SendDevicetokenLoadedState extends LoginState {

  String message;

  SendDevicetokenLoadedState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}


class LoginErrorState extends LoginState {

  String message;

  LoginErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}