import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {}

class FetchLoginEvent extends LoginEvent {

  String user_mobileNumber;

  FetchLoginEvent(this.user_mobileNumber);

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class FetchVerifyLoginEvent extends LoginEvent {

  String user_mobileNumber,otp;

  FetchVerifyLoginEvent(this.user_mobileNumber,this.otp);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


class SendDevicetokenEvent extends LoginEvent {

  String user_id,token;

  SendDevicetokenEvent(this.user_id,this.token);

  @override
  // TODO: implement props
  List<Object> get props => null;
}
