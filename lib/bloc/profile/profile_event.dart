
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {}

class FetchProfileEvent extends ProfileEvent {

  String userID;

  FetchProfileEvent(this.userID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


class SubmitProfileEvent extends ProfileEvent {

  Map<String,String> profilemap;

  SubmitProfileEvent(this.profilemap);

  @override
  // TODO: implement props
  List<Object> get props => null;
}
