
import 'package:equatable/equatable.dart';

abstract class AppInfoEvent extends Equatable {}

class FetchAppInfoEvent extends AppInfoEvent {

  String locID;

  FetchAppInfoEvent(this.locID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class FetchContactInfoEvent extends AppInfoEvent {

  String locID;

  FetchContactInfoEvent(this.locID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


class FetchTermsConditionsEvent extends AppInfoEvent {

  FetchTermsConditionsEvent();

  @override
  // TODO: implement props
  List<Object> get props => null;
}


class FetchPrivacypolicyEvent extends AppInfoEvent {

  FetchPrivacypolicyEvent();

  @override
  // TODO: implement props
  List<Object> get props => null;
}



class FetchFAQsEvent extends AppInfoEvent {

  FetchFAQsEvent();

  @override
  // TODO: implement props
  List<Object> get props => null;
}



class FetchFarmersinfoEvent extends AppInfoEvent {


  FetchFarmersinfoEvent();

  @override
  // TODO: implement props
  List<Object> get props => null;
}
