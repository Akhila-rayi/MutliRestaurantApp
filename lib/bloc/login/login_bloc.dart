import 'package:FarmToHome/bloc/login/login_event.dart';
import 'package:FarmToHome/bloc/login/login_state.dart';
import 'package:FarmToHome/data/model/login_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/data/repository/login_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  LoginRepository repository;

  LoginBloc({@required this.repository}): super(LoginInitialState());

  @override
  // TODO: implement initialState
  LoginState get initialState => LoginInitialState();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {

    if (event is FetchLoginEvent) {
      yield LoginLoadingState();
      try {
        String loginmsg = await repository.getLogindata(event.user_mobileNumber);
        yield LoginLoadedState(msg: loginmsg);
      } catch (e) {
        yield LoginErrorState(message: e.toString());
      }
    }

    if (event is FetchVerifyLoginEvent) {
      yield LoginLoadingState();
      try {
        LoginVerify_response_model loginVerify_response_model = await repository.verifyLogindata(event.user_mobileNumber,event.otp);
        yield
        VerifyLoginLoadedState(loginVerify_response_model: loginVerify_response_model);
      } catch (e) {
        yield LoginErrorState(message: e.toString());
      }
    }

    if (event is SendDevicetokenEvent) {
      yield LoginLoadingState();
      try {
        String s = await repository.senddevicetoken(event.user_id,event.token);
        yield SendDevicetokenLoadedState(message: s);
      } catch (e) {
        yield LoginErrorState(message: e.toString());
      }
    }
  }

}