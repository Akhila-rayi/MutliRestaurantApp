import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';

import 'package:FarmToHome/bloc/login/login_bloc.dart';
import 'package:FarmToHome/bloc/login/login_event.dart';
import 'package:FarmToHome/bloc/login/login_state.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/login_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/data/repository/location_repository.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:FarmToHome/ui/homepage.dart';
import 'package:FarmToHome/ui/personalinfo.dart';
import 'package:FarmToHome/ui/selectlocation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:need_resume/need_resume.dart';

class EnterMobile extends StatefulWidget {
  @override
  EnterMobileState createState() {
    return EnterMobileState();
  }
}

class EnterMobileState extends ResumableState<EnterMobile> {
  String mobileno = "", otp = "";
  bool showEnterMobileUI = true, showloading = false, enablebutton = true;
  LoginBloc _loginBloc;
  TextEditingController _editingController1 = new TextEditingController();
  TextEditingController _editingController2 = new TextEditingController();
  Apputils _apputils = new Apputils();
  UserPrefs _userPrefs = new UserPrefs();
  List<UserData> _userdatalist = [];

  LoginVerify_response_model _loginVerify_response_model;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    checkmobileEnteredAlready();
  }

  @override
  void onPause() {
    // TODO: implement onPause
    super.onPause();
    setState(() {
      /*if(!showEnterMobileUI) {
        showEnterMobileUI = true;
      }*/
      checkmobileEnteredAlready();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WillPopScope(
        onWillPop: () {
          print('Backbutton pressed (device or appbar button)');
          if (!showEnterMobileUI) {
            setState(() {
              showEnterMobileUI = true;
            });
          } else {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }

          return Future.value(false);
        },
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body:
                BlocListener<LoginBloc, LoginState>(listener: (context, state) {
              if (state is LoginErrorState) {
                setState(() {
                  showloading = false;
                  enablebutton = true;
                });
                _apputils.showtoast(context, state.message);
              } else if (state is LoginLoadedState) {
                setState(() {
                  showloading = false;
                });
                if (state.msg.toLowerCase() == "success") {
                  _apputils.showtoast(context, "OTP Sent");

                  setState(() {
                    enablebutton = true;
                    showEnterMobileUI = false;
                  });
                } else {
                  _apputils.showtoast(context, state.msg);
                }
              } else if (state is VerifyLoginLoadedState) {
                if (state.loginVerify_response_model.message.toLowerCase() ==
                    "success") {
                  _loginVerify_response_model =
                      state.loginVerify_response_model;
                  saveuserdetails();
                } else if (state.loginVerify_response_model.status == "500") {
                  setState(() {
                    showloading = false;
                    enablebutton = true;
                  });
                  _apputils.showtoast(context, "Please Enter correct OTP");
                }
              } else if (state is SendDevicetokenLoadedState) {
                setState(() {
                  showloading = false;
                  enablebutton = true;
                });
                if (state.message == "success") {
                  _apputils.showtoast(context, "login Successful");
                  if (_loginVerify_response_model != null &&
                      _loginVerify_response_model.data[0].name.isEmpty) {
                    navtoPersonalinfo();
                  } else if (_loginVerify_response_model
                          .data[0].name.isNotEmpty &&
                      _loginVerify_response_model
                          .data[0].restaurantPlace.isEmpty) {
                    navtoSelctloctn();
                  } else {
                    navtoHome();
                  }
                  /*Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => SelectLocation(
                            nav_from_home: false,
                          )));*/
                } else {
                  _apputils.showtoast(
                      context, "Cannot login. Please try again.");
                }
              }
            }, child: BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return SingleChildScrollView(
                    child: Stack(
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(color: Colors.white)),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: FractionallySizedBox(
                            widthFactor: 1.0,
                            heightFactor: 0.6,
                            alignment: Alignment.topCenter,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 50),
                                Image.asset(
                                  'assets/images/logo_green.png',
                                  width: 120,
                                  height: 150,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(height: 50),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Image.asset(
                                          'assets/images/img_login.png',
                                          fit: BoxFit.fill,
                                        ))),
                              ],
                            ))),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          heightFactor: 0.4,
                          alignment: Alignment.bottomCenter,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              showEnterMobileUI
                                  ? getEnterMobileno(state)
                                  : getVerifyUI(),
                            ],
                          ),
                        )),
                    showloading
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: _apputils.buildLoading(context))
                        : Container()
                  ],
                ));
              },
            ))));
  }

  Widget getEnterMobileno(LoginState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
            ),
            Text(
              '+91',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontFamily: 'quicksand',
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: Align(
              alignment: Alignment.center,
              child: TextFormField(
                  enabled: true,
                  controller: _editingController1,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  cursorWidth: 1.5,
                  showCursor: true,
                  cursorColor: Colors.redAccent,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontFamily: 'quicksand',
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                      hintText: AppStrings.entermobilenumber,
                      hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 14.0,
                          fontFamily: 'quicksand',
                          fontWeight: FontWeight.w500),
                      contentPadding: EdgeInsets.only(left: 8.0),
                      border: InputBorder.none)),
            )),
            SizedBox(
              width: 16,
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.only(
                  left: 30.0, top: 8.0, right: 30.0, bottom: 8.0),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  side: BorderSide(color: Colors.transparent)),
              onPressed: enablebutton
                  ? () {
                      _onloginpressed();
                    }
                  : null,
              child: Text(
                'Continue',
                style: Theme.of(context)
                    .textTheme
                    .button
                    .apply(color: Colors.white),
              ),
            ),
            SizedBox(
              width: 16,
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Or',
          style: TextStyle(
              fontSize: 16.0,
              fontFamily: 'quicksand',
              fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          color: const Color(0xFF4267B2),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/images/facebook.png',
                      fit: BoxFit.fill,
                      width: 18,
                      height: 20,
                    ),
                  )),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Continue with ',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontFamily: 'quicksand',
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Facebook',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontFamily: 'quicksand',
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
          color: Colors.white,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        'assets/images/google.png',
                        fit: BoxFit.fill,
                        width: 20,
                        height: 20,
                      ))),
              Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Continue with ',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontFamily: 'quicksand',
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Google',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontFamily: 'quicksand',
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )
                    ],
                  )),
            ],
          ),
        ),
        Container(
          color: Colors.black,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        'assets/images/apple.png',
                        fit: BoxFit.fill,
                        width: 20,
                        height: 20,
                      ))),
              Expanded(
                  flex: 3,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'Continue with ',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Apple',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )
                      ]))
            ],
          ),
        )
      ],
    );
  }

  _onloginpressed() async {
    FocusScope.of(context).requestFocus(FocusNode());

    mobileno = _editingController1.text.toString();

    if (mobileno != null && mobileno.isEmpty) {
      _apputils.showtoast(context, "Please Enter Mobile Number");
    } else if (mobileno != null && mobileno.length != 10) {
      _apputils.showtoast(context, "Please Enter valid Mobile Number");
    } else {
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        _userPrefs.setIsEnteredmobileNo(true);
        _userPrefs.setMobileNo(mobileno);
        setState(() {
          showloading = true;
          enablebutton = false;
        });
        _loginBloc.add(FetchLoginEvent(mobileno));
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }
    }
  }

  _onverifyloginpressed() async {
    FocusScope.of(context).requestFocus(FocusNode());
    otp = _editingController2.text.toString();
    if (otp != null && otp.isEmpty) {
      _apputils.showtoast(context, "Please Enter received OTP");
    } else if (otp != null && otp.length != 6) {
      _apputils.showtoast(context, "Please Enter valid OTP");
    } else {
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        setState(() {
          enablebutton = false;
          showloading = true;
        });
        _loginBloc.add(FetchVerifyLoginEvent(mobileno, otp));
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }
    }
  }

  Widget getVerifyUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Text(
          'VERIFICATION CODE',
          style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'quicksand',
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Please type the verification code sent to \n +91-' + mobileno,
                style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'quicksand',
                    fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 45, top: 8, right: 45, bottom: 0),
          child: TextFormField(
              maxLengthEnforced: false,
              maxLength: 6,
              enabled: true,
              controller: _editingController2,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              autofocus: false,
              cursorWidth: 1.5,
              showCursor: true,
              cursorColor: Colors.redAccent,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontFamily: 'quicksand',
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                  counterText: "",
                  /*hintText: "ex:123456",
                  hintStyle: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'quicksand',
                      color: Colors.black54,
                      fontWeight: FontWeight.w500),*/
                  contentPadding: EdgeInsets.only(left: 8.0),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.black38, width: 1.5)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.black38, width: 1.5)))),
        ),
        SizedBox(
          height: 20,
        ),
        Expanded(
            child: Center(
          child: RaisedButton(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.only(
                left: 50.0, top: 10.0, right: 50.0, bottom: 10.0),
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.transparent)),
            onPressed: enablebutton
                ? () {
                    _onverifyloginpressed();
                  }
                : null,
            child: Text(
              'VALIDATE',
              style:
                  Theme.of(context).textTheme.button.apply(color: Colors.white),
            ),
          ),
        ))
      ],
    );
  }

  void navtoPersonalinfo() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => PersonalInfo(nav_from_home: false)));
  }

  void navtoHome() async {
    await _userPrefs.setLoggedIn(true);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomePage()));
  }

  void navtoSelctloctn() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
            SelectLocation(nav_from_home: false)));
  }

  void saveuserdetails() async {
    if (_userdatalist.length > 0) {
      _userdatalist.clear();
    }
    _userdatalist.addAll(_loginVerify_response_model.data);
    if (_userdatalist.length > 0) {
      Map<String, dynamic> userdata = new Map<String, dynamic>();
      userdata['data'] = _userdatalist.map((v) => v.toJson()).toList();
      await _userPrefs.setUserdetls(jsonEncode(userdata['data']));

      Map<String, dynamic> locationdata = new Map<String, dynamic>();
      LocationDetls locationDetls = new LocationDetls(
          location: _userdatalist[0].restaurantPlace,
          latitude: _userdatalist[0].latitude,
          locationId: _userdatalist[0].locationId,
          longitude: _userdatalist[0].longitude,
          radius: _userdatalist[0].radius,
          OpenTime: "",
          min_order: "",
          deliveryTime: "",
          closeTime: "",
          address: "",
          deliveryCharges: "");
      List<LocationDetls> _locationdtlslist = [];
      _locationdtlslist.add(locationDetls);
      locationdata['data'] = _locationdtlslist.map((v) => v.toJson()).toList();
      await _userPrefs.setLoctndetls(jsonEncode(locationdata['data']));

      String firebasetoken = await _userPrefs.getdeviceToken();
      if (firebasetoken != null && firebasetoken.isNotEmpty) {
        _loginBloc
            .add(SendDevicetokenEvent(_userdatalist[0].userId, firebasetoken));
      } else {
        setState(() {
          showloading = false;
          enablebutton = true;
        });
        _apputils.showtoast(context, "login Successful");
        if (_userdatalist[0].name.isEmpty) {
          navtoPersonalinfo();
        } else if (_userdatalist[0].name.isNotEmpty &&
            _userdatalist[0].restaurantPlace.isEmpty) {
          navtoSelctloctn();
        } else {
          navtoHome();
        }
      }
    }
  }

  void checkmobileEnteredAlready() async {
    var status = await _userPrefs.getIsEnteredmobileNo();
    if (status != null && status) {
      setState(() {
        showEnterMobileUI = false;
      });
    } else {
      setState(() {
        showEnterMobileUI = true;
      });
    }

    var s_mobile = await _userPrefs.getMobileNo();
    if (s_mobile != null && s_mobile.isNotEmpty) {
      setState(() {
        _editingController1.text = s_mobile;
        mobileno = s_mobile;
      });
    }
  }
}
