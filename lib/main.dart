import 'dart:convert';
import 'dart:io';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_bloc.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_bloc.dart';
import 'package:FarmToHome/bloc/home/home_bloc.dart';
import 'package:FarmToHome/bloc/location/location_bloc.dart';
import 'package:FarmToHome/bloc/login/login_bloc.dart';
import 'package:FarmToHome/bloc/myfavourite/myfavourite_bloc.dart';
import 'package:FarmToHome/bloc/orderfeedback/orderfeedback_bloc.dart';
import 'package:FarmToHome/bloc/paymentgateway/paymentgateway_bloc.dart';
import 'package:FarmToHome/bloc/placeorder/placeorder_bloc.dart';
import 'package:FarmToHome/bloc/profile/profile_bloc.dart';
import 'package:FarmToHome/bloc/searchproduct/search_bloc.dart';
import 'package:FarmToHome/bloc/subcategories/subcategories_bloc.dart';
import 'package:FarmToHome/data/repository/appinfo_repository.dart';
import 'package:FarmToHome/data/repository/delvryaddress_repository.dart';
import 'package:FarmToHome/data/repository/home_repository.dart';
import 'package:FarmToHome/data/repository/login_repository.dart';
import 'package:FarmToHome/data/repository/myfav_repository.dart';
import 'package:FarmToHome/data/repository/orderfeedback_repository.dart';
import 'package:FarmToHome/data/repository/paymentgateway_repository.dart';
import 'package:FarmToHome/data/repository/placeorder_repository.dart';
import 'package:FarmToHome/data/repository/profile_repository.dart';
import 'package:FarmToHome/data/repository/searchproduct_repository.dart';
import 'package:FarmToHome/data/repository/subcategories_repository.dart';
import 'package:FarmToHome/ui/VerifyMobile.dart';
import 'package:FarmToHome/ui/addLocation.dart';
import 'package:FarmToHome/ui/contactus.dart';
import 'package:FarmToHome/ui/enter_mobile.dart';
import 'package:FarmToHome/ui/homepage.dart';
import 'package:FarmToHome/ui/selectlocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:page_transition/page_transition.dart';

import 'data/repository/location_repository.dart';

void main() => runApp(MultiBlocProvider(providers: [
      BlocProvider<LocationBloc>(
        create: (context) => LocationBloc(repository: LocationRepositoryImpl()),
      ),
      BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(repository: LoginRepositoryImpl()),
      ),
      BlocProvider<HomeBloc>(
        create: (context) => HomeBloc(repository: HomeRepositoryImpl()),
      ),
      BlocProvider<MyFavouriteBloc>(
        create: (context) =>
            MyFavouriteBloc(repository: MyFavouriteRepositoryImpl()),
      ),
      BlocProvider<ProfileBloc>(
        create: (context) => ProfileBloc(repository: ProfileRepositoryImpl()),
      ),
      BlocProvider<DeliveryAdrsBloc>(
        create: (context) =>
            DeliveryAdrsBloc(repository: DeliveryAddressRepositoryImpl()),
      ),
      BlocProvider<SearchBloc>(
        create: (context) =>
            SearchBloc(repository: SearchProductRepositoryImpl()),
      ),
      BlocProvider<SubCategoriesBloc>(
        create: (context) =>
            SubCategoriesBloc(repository: SubcategoriesRepositoryImpl()),
      ),
      BlocProvider<AppInfoBloc>(
        create: (context) => AppInfoBloc(repository: AppInfoRepositoryImpl()),
      ),
      BlocProvider<PlaceOrderBloc>(
        create: (context) =>
            PlaceOrderBloc(repository: PlaceOrderRepositoryImpl()),
      ),
      BlocProvider<PaymentgatewayBloc>(
        create: (context) =>
            PaymentgatewayBloc(repository: PaymentgatewayRepositoryImpl()),
      ),
      BlocProvider<OrderfeedbackBloc>(
        create: (context) =>
            OrderfeedbackBloc(repository: OrderfeedbackRepositoryImpl()),
      ),
    ], child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        /*supportedLocales: [
          const Locale('en', 'US'), // American English
          const Locale('te', 'IN'),
        ],*/
        routes: {'/home': (_) => HomePage()},
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF009A00),
          buttonTheme: ButtonThemeData(buttonColor: const Color(0xFF009A00)),
          accentColor: const Color(0xFFFFFFFF),
          fontFamily: 'quicksand',
          textTheme: TextTheme(
              headline5: TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'quicksand',
                  fontWeight: FontWeight.bold),
              subtitle1: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'quicksand',
                  fontWeight: FontWeight.bold),
              headline6: TextStyle(
                  // medium
                  fontSize: 16.0,
                  fontFamily: 'quicksand',
                  fontWeight: FontWeight.w500),
              subtitle2: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'quicksand',
                  fontWeight: FontWeight.w500),
              headline4: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'quicksand',
                  fontWeight: FontWeight.w200),
              button: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontFamily: 'quicksand',
                  fontWeight: FontWeight.w500)),
        ),
        home: new SplashScreen());
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  UserPrefs _userPrefs = new UserPrefs();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.subscribeToTopic("FarmToHome");

    _firebaseMessaging.configure(
      onBackgroundMessage: myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        debugPrint("Firebase onMessage MESG: $message");
        // _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint("Firebase onLaunch MESG: $message");
        // _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        debugPrint("Firebase onResume MESG: $message");
        // _navigateToItemDetail(message);
      },
    );

    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: true, badge: true, alert: true, provisional: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }

    getfirebase();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.asset(
                'assets/images/veg2.jpg',
                fit: BoxFit.fill,
              ),
            ),
            Opacity(
              opacity: 0.9,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Theme.of(context).primaryColor),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  heightFactor: 0.5,
                  alignment: Alignment.topCenter,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/logo_white.png',
                      width: 180.0,
                      height: 180.0,
                    ),
                  ),
                )),
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: FractionallySizedBox(
                    widthFactor: 1.0,
                    heightFactor: 0.1,
                    alignment: Alignment.bottomCenter,
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Product by \n F2H Online Services Pvt. Ltd.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.bold),
                            )))))
          ],
        ));
  }

  void navigate() async {
    Future.delayed(const Duration(milliseconds: 2000), () async {
      bool islogged = await _userPrefs.getLoggedIn();
      if (islogged != null && islogged == true) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      } else {
        Navigator
            .pushReplacement(this.context,_createRoute());
        /*MaterialPageRoute(
            builder: (BuildContext context) => EnterMobile())*/
      }
    });
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => VerifyMobile(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {


        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve ));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: Duration(seconds: 1));
  }

  void getfirebase() async {
    String str_token = await _userPrefs.getdeviceToken();

    debugPrint("@@@ Push Messaging token: $str_token");

    if (str_token == null || (str_token != null && str_token.isEmpty)) {
      String s_firebasetoken = await _firebaseMessaging.getToken();
      debugPrint("@@@ Push Messaging token: $s_firebasetoken");
      if (s_firebasetoken != null) {
        await _userPrefs.setdeviceToken(s_firebasetoken);
        navigate();
      }
    } else {
      navigate();
    }
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    debugPrint("Firebase DATA MESG: $data");
  }

  if (message.containsKey('notification')) {
    // Handle notification message

    final dynamic notification = message['notification'];
    debugPrint("Firebase NOTIFICATION MESG: $notification");
  }
}
/*

final String serverToken = 'AAAA1cumghI:APA91bHY5Ig3tn4If7Zw6D5Gd3SlZ0AmNxhzcw6YnVYTBZQVUURyueXBURW57pkVdx8-Hrtjjp2HnibKiM7ECo2yQhP0gwoynFQG1gKZEVg2-tlFOWId5cLBochicYdowZHMaSrEGDof';
final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
  await firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
  );

  await  post(
    'https://fcm.googleapis.com/fcm/send',
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': 'test notification',
          'title': 'f2h app'
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done'
        },
        'to': 'dx2HcxNvQ5C-MgCcjP3kA9:APA91bEGprLTFVo47fvFsfgaPDfRLoMuHvNOACDKfpFG8Tf7KBCY_sgJpasKwCaEHISnbiY8yjgbqtNpt86eFtvfCb1hwTqEXsVEfr-SilTsTaFHHCiQwmuuqK45o0sYDQCQGZmzP_mJ',
      },
    ),
  );

  SystemNavigator.pop();

}
*/

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero
            ).animate(animation),
            child: child,
          ),
        );
}
