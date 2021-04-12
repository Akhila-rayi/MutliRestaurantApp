
import 'package:equatable/equatable.dart';

abstract class PaymentgatewayEvent extends Equatable {}

class FetchPaymentgatewaysEvent extends PaymentgatewayEvent {

  String loc_ID;

  FetchPaymentgatewaysEvent(this.loc_ID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}
