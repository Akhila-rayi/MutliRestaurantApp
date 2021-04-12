

import 'package:FarmToHome/bloc/appinfo/appinfo_event.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_state.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_event.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_state.dart';
import 'package:FarmToHome/bloc/myfavourite/myfavourite_state.dart';
import 'package:FarmToHome/bloc/orderfeedback/orderfeedback_event.dart';
import 'package:FarmToHome/bloc/orderfeedback/orderfeedback_state.dart';
import 'package:FarmToHome/bloc/profile/profile_event.dart';
import 'package:FarmToHome/bloc/profile/profile_state.dart';
import 'package:FarmToHome/data/model/appinfo_response_model.dart';
import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/farmersinfo_response_model.dart';
import 'package:FarmToHome/data/model/orderfeedback_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:FarmToHome/data/repository/appinfo_repository.dart';
import 'package:FarmToHome/data/repository/delvryaddress_repository.dart';
import 'package:FarmToHome/data/repository/orderfeedback_repository.dart';
import 'package:FarmToHome/data/repository/profile_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

class OrderfeedbackBloc extends Bloc<OrderfeedbackEvent, OrderfeedbackState> {

  OrderfeedbackRepository repository;

  OrderfeedbackBloc({@required this.repository}): super(OrderfeedbackInitialState());

  @override
  // TODO: implement initialState
  OrderfeedbackState get initialState =>  OrderfeedbackInitialState();

  @override
  Stream<OrderfeedbackState> mapEventToState( OrderfeedbackEvent event) async* {
    if (event is AddOrderfeedbackEvent) {
      yield  OrderfeedbackLoadingState();
      try {
        List<OrderfeedbackData> list  = await repository.addorderfeedback(event.inputmap);
        yield AddOrderfeedbackLoadedState(list: list);
      } catch (e) {
        yield  OrderfeedbackErrorState(message: e.toString());
      }
    }
  }

}