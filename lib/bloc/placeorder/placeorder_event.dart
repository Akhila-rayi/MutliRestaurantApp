import 'package:FarmToHome/ui/manageAddress.dart';
import 'package:equatable/equatable.dart';

abstract class PlaceOrderEvent extends Equatable {}

class SendOrderEvent extends PlaceOrderEvent {

  Map<String,dynamic> placeordermap;

  SendOrderEvent(this.placeordermap);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


class SendPaymentstatusEvent extends PlaceOrderEvent {

  Map<String,dynamic> paymentstatusmap;

  SendPaymentstatusEvent(this.paymentstatusmap);

  @override
  // TODO: implement props
  List<Object> get props => null;
}
