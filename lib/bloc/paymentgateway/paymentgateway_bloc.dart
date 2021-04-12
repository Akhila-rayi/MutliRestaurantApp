

import 'package:FarmToHome/bloc/paymentgateway/paymentgateway_event.dart';
import 'package:FarmToHome/bloc/paymentgateway/paymentgateway_state.dart';
import 'package:FarmToHome/data/model/paymentgateway_response_model.dart';
import 'package:FarmToHome/data/repository/paymentgateway_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

class PaymentgatewayBloc extends Bloc<PaymentgatewayEvent, PaymentgatewayState> {

  PaymentgatewayRepository repository;

  PaymentgatewayBloc({@required this.repository}): super(PaymentgatewayInitialState());

  @override

  PaymentgatewayState get initialState => PaymentgatewayInitialState();

  @override
  Stream<PaymentgatewayState> mapEventToState(PaymentgatewayEvent event) async* {

    if (event is FetchPaymentgatewaysEvent) {
      yield PaymentgatewayLoadingState();
      try {
        List<PaymentgatewayData> paymentgatewaylist= await repository.getPaymentgatewaysinfo(event.loc_ID);
        yield FetchPaymentinfoLoadedState(paymentgatewaylist:  paymentgatewaylist);
      } catch (e) {
        yield PaymentgatewayErrorState(message: e.toString());
      }
    }

  }

}