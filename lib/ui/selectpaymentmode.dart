import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/paymentgateway/paymentgateway_bloc.dart';
import 'package:FarmToHome/bloc/paymentgateway/paymentgateway_event.dart';
import 'package:FarmToHome/bloc/paymentgateway/paymentgateway_state.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/paymentgateway_response_model.dart';
import 'package:FarmToHome/ui/paymentpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectPaymentMode extends StatefulWidget {

  String addrsID = "", userID = "";
  Coupons coupondata=null;
  double couponamount=0.0;

  SelectPaymentMode({Key key, @required this.addrsID, @required this.userID,@required this.coupondata,@required this.couponamount})
      : super(key: key);

  @override
  SelectPaymentModeState createState() {
    return SelectPaymentModeState(addrsID, userID,coupondata,couponamount);
  }
}

class SelectPaymentModeState extends State<SelectPaymentMode> {

  String addrsID = "", userID = "";
  int value;
  String mode = "";
  List<String> paymenttype = ["Cash On Delivery", "Online Payment"];
  PaymentgatewayBloc _paymentgatewayBloc;
  UserPrefs _userPrefs = new UserPrefs();
  Apputils _apputils = new Apputils();
  var showloading = false;
  List<LocationDetls> _locationDetailslist = [];
  List<PaymentgatewayData> _paymentgatewayData = [];
  String secretkey="";
  Coupons coupondata=null;
  double couponamount=0.0;

  SelectPaymentModeState(this.addrsID, this.userID,this.coupondata,this.couponamount);

  Future saveddatafuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _paymentgatewayBloc = BlocProvider.of<PaymentgatewayBloc>(context);
    saveddatafuture = getsaveddata();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Payment Mode",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .apply(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            backgroundColor: Colors.white,
            body:FutureBuilder(
                future: saveddatafuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Failed To Load Data. Please try again',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            )));
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return getPage();
                  } else {
                    return Center(
                        child:Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child:_apputils.buildLoading(context)));
                  }
                })));
  }

  Widget getPage(){
    return  BlocListener<PaymentgatewayBloc, PaymentgatewayState>(
        listener: (context, state) {
          if (state is PaymentgatewayInitialState) {
            setState(() {
              showloading = true;
            });
          } else if (state is PaymentgatewayLoadingState) {
            setState(() {
              showloading = true;
            });
          } else if (state is PaymentgatewayErrorState) {
            setState(() {
              showloading = false;
            });
            _apputils.showtoast(context, "Error: ${state.message}");
          } else if (state is FetchPaymentinfoLoadedState) {
            setState(() {
              showloading = false;

              if (_paymentgatewayData.length > 0) {
                _paymentgatewayData.clear();
              }
              if (state.paymentgatewaylist != null && state.paymentgatewaylist.length > 0) {

                String sec_key=state.paymentgatewaylist[0].secret.toString();
                if(sec_key!=null && sec_key.isNotEmpty && sec_key.startsWith("rzp")){
                  secretkey=sec_key;
                }
              } else if(state.paymentgatewaylist != null && state.paymentgatewaylist.length == 0){   // online payment Inactive
                secretkey="";

                Navigator.of(this.context).push(MaterialPageRoute(
                    builder: (BuildContext context) => PaymentPage(
                      addrsID: addrsID,
                      mode: paymenttype[0],
                      sec_key: "",
                      selectedcoupon: coupondata,
                      couponamount: this.couponamount,
                    )));
              }
            });
          }
        }, child: BlocBuilder<PaymentgatewayBloc, PaymentgatewayState>(
      builder: (context, state) {
        return getScreen();
      },
    ));
  }

  Widget getScreen() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          Container(
            margin: EdgeInsets.all(16.0),
            child: Stack(
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              left: 0.0, top: 16.0, bottom: 16.0),
                          child: Text(
                            'Please Select Your Payment Mode',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .apply(color: Colors.black45),
                          )),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemExtent: 50.0,
                        padding: EdgeInsets.all(0.0),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return RadioListTile(
                            activeColor: Colors.red,
                            value: index,
                            groupValue: value,
                            onChanged: (ind) {
                              setState(() {
                                value = ind;
                                mode = paymenttype[value];
                              });
                            },
                            title: Text(
                              paymenttype[index],
                              textAlign: TextAlign.left,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .apply(color: Colors.black),
                            ),
                          );
                        },
                        itemCount: paymenttype.length,
                      )
                    ]),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    padding: EdgeInsets.only(
                        left: 50.0, top: 12.0, right: 50.0, bottom: 12.0),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.transparent)),
                    onPressed: () {
                      if (mode.isEmpty) {
                        _apputils.showtoast(
                            context, "Please select Payment Mode");
                      } else {

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => PaymentPage(
                                  addrsID: addrsID,
                                  mode: mode,
                                  sec_key: secretkey,
                              selectedcoupon: coupondata,
                              couponamount: this.couponamount,
                                )));
                      }
                    },
                    child: Text(
                      'CONTINUE',
                      style: Theme.of(context)
                          .textTheme
                          .button
                          .apply(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        ]));
  }

  Future getsaveddata() async {

    String locdetails = await _userPrefs.getLoctndetls();
    if (locdetails != null) {
      setState(() {
        if (_locationDetailslist.length > 0) {
          _locationDetailslist.clear();
        }
        debugPrint('@@@@ SAVED LOCATION DATA paymentselctn ${json.decode(locdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(locdetails)};
        _locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));
      });
      Future.delayed(const Duration(milliseconds: 100), () async {
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        _paymentgatewayBloc
            .add(FetchPaymentgatewaysEvent(_locationDetailslist[0].locationId));
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }});
    }
  }
}
