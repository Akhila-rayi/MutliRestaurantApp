
import 'package:equatable/equatable.dart';

abstract class OrderfeedbackEvent extends Equatable {}

class AddOrderfeedbackEvent extends OrderfeedbackEvent {

  Map<String,String> inputmap;

  AddOrderfeedbackEvent(this.inputmap);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


