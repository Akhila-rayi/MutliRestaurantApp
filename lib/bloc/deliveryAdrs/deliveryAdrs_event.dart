
import 'package:equatable/equatable.dart';

abstract class DeliveryAdrsEvent extends Equatable {}

class FetchDeliveryAdrsEvent extends DeliveryAdrsEvent {

  String userID;

  FetchDeliveryAdrsEvent(this.userID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


class SubmitDeliveryAdrsEvent extends DeliveryAdrsEvent {

  Map<String,String> deliveryAdrsmap;

  SubmitDeliveryAdrsEvent(this.deliveryAdrsmap);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


class FetchPaymentgatewaysEvent extends DeliveryAdrsEvent {

  String loc_ID;

  FetchPaymentgatewaysEvent(this.loc_ID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class FetchcouponsEvent extends DeliveryAdrsEvent {

  String userID,locationID;

  FetchcouponsEvent(this.userID,this.locationID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}
