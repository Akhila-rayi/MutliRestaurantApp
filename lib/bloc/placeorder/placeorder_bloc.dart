import 'package:FarmToHome/bloc/login/login_event.dart';
import 'package:FarmToHome/bloc/login/login_state.dart';
import 'package:FarmToHome/bloc/placeorder/placeorder_event.dart';
import 'package:FarmToHome/bloc/placeorder/placeorder_state.dart';
import 'package:FarmToHome/data/model/login_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/data/model/placeorder_response_model.dart';
import 'package:FarmToHome/data/repository/login_repository.dart';
import 'package:FarmToHome/data/repository/placeorder_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class PlaceOrderBloc extends Bloc<PlaceOrderEvent, PlaceOrderState> {

  PlaceOrderRepository repository;

  PlaceOrderBloc({@required this.repository}): super(PlaceOrderInitialState());

  @override
  // TODO: implement initialState
  PlaceOrderState get initialState => PlaceOrderInitialState();

  @override
  Stream<PlaceOrderState> mapEventToState(PlaceOrderEvent event) async* {

    if (event is SendOrderEvent) {
      yield PlaceOrderLoadingState();
      try {
        String status = await repository.placeorder(event.placeordermap);
        yield PlaceOrderLoadedState(status: status);
      } catch (e) {
        yield PlaceOrderErrorState(message: e.toString());
      }
    }

    if (event is SendPaymentstatusEvent) {
      yield PlaceOrderLoadingState();
      try {
        String status = await repository.sendpaymentstatus(event.paymentstatusmap);
        yield SendPaymentstatusLoadedState(status: status);
      } catch (e) {
        yield PlaceOrderErrorState(message: e.toString());
      }
    }
  }

}