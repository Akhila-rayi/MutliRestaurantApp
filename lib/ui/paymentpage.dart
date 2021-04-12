import 'dart:convert';
import 'dart:math';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/Utils/DatabaseHelper.dart';
import 'package:FarmToHome/bloc/home/home_bloc.dart';
import 'package:FarmToHome/bloc/home/home_event.dart';
import 'package:FarmToHome/bloc/placeorder/placeorder_bloc.dart';
import 'package:FarmToHome/bloc/placeorder/placeorder_event.dart';
import 'package:FarmToHome/bloc/placeorder/placeorder_state.dart';
import 'package:FarmToHome/data/model/CartItemsModel.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/data/model/placeorder_request_model.dart';
import 'package:FarmToHome/data/model/placeorder_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:FarmToHome/ui/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sqflite/sqflite.dart';

class PaymentPage extends StatefulWidget {

  String addrsID = "", mode = "",sec_key="";
  Coupons selectedcoupon=null;
  double couponamount=0.0;

  PaymentPage({Key key, @required this.addrsID, @required this.mode,@required this.sec_key,@required this.selectedcoupon,@required this.couponamount})
      : super(key: key);

  @override
  PaymentPage_State createState() {
    return PaymentPage_State(addrsID, mode,sec_key,selectedcoupon,couponamount);
  }
}

class PaymentPage_State extends State<PaymentPage> {

  double couponamount=0.0;
  Coupons selectedcoupon=null;
  UserPrefs _userPrefs = new UserPrefs();
  List<UserData> _userdatalist = [];
  String addrsID = "", userID = "", mode = "",sec_key="";
  Razorpay _razorpay;
  var paymentUIstatus = "",
      orderid = "",
      paymentmsg = "",
      paymentId = "",
      billpaymentstatus = "";
  Apputils _apputils = new Apputils();
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<CartItemsModel> dbcartlist = [];
  int totalcartprice;
  var chars = "abcdefghijklmnopqrstuvwxyz0123456789_";
  var showloading = false;
  PlaceOrderBloc _placeOrderBloc;
  List<LocationDetls> _locationDetailslist = [];
  Future saveddatafuture;

  PaymentPage_State(this.addrsID, this.mode,this.sec_key,this.selectedcoupon,this.couponamount);

  @override
  void initState() {
    super.initState();

    _placeOrderBloc = BlocProvider.of<PlaceOrderBloc>(context);
    saveddatafuture = getsaveddata();
  }

  void updatecartlist() async {
    Database futuredab = await databaseHelper.database;
    List<CartItemsModel> _list = await databaseHelper.getCartitemslist();
    double totalprice = await databaseHelper.gettotalprice();
    setState(() {
      if (dbcartlist.length > 0) {
        dbcartlist.clear();
      }
      this.dbcartlist = _list;
      debugPrint(
          "@@@@ Cartlistcount PAYMENT PAGE" + dbcartlist.length.toString());
      totalcartprice = totalprice.round() * 100;
    });

    if (mode != "Cash On Delivery") {
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        openCheckout();
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }
    } else {
      prepareOrdermap_success(null);
    }
  }

  void prepareOrdermap_success(PaymentSuccessResponse response) async {
    Placeorder_request_model _placeorder_request_model;

    List<PlaceorderItems> placeorderItemslist = [];
    List<Paymentdetls> paymentdetlslist = [];

    for (int i = 0; i < dbcartlist.length; i++) {

      String cartcount="";
      if( dbcartlist[i].itemType.toLowerCase() =="kg" && dbcartlist[i].weight.toLowerCase().contains("g")
          && !dbcartlist[i].weight.toLowerCase().contains("k")) {

        double actualwt=double.parse(getactualweight(dbcartlist[i].weight));
        double d=double.parse(dbcartlist[i].modifiedquantity)*1000.0;
        cartcount=(d/actualwt).toString();

      }else{

        cartcount= dbcartlist[i].modifiedquantity;

      }

      PlaceorderItems placeorderItems = new PlaceorderItems(
        id: dbcartlist[i].id,
        title: dbcartlist[i].title,
        deliveryCharges: _locationDetailslist[0].deliveryCharges,
        weight: dbcartlist[i].weight,
        cartCount: cartcount.replaceAll(".0", ""),
        imageURL: dbcartlist[i].imageURL,
        priceUnit: dbcartlist[i].priceUnit,
        discount: dbcartlist[i].discount,
      );
      placeorderItemslist.add(placeorderItems);
    }

    if (response != null) {
      Paymentdetls paymentdetls = new Paymentdetls(
          paymentId: response.paymentId,
          orderId: response.orderId,
          signature: response.signature);
      paymentdetlslist.add(paymentdetls);

      if(selectedcoupon!=null) {
        _placeorder_request_model = new Placeorder_request_model(
            userId: userID,
            addressId: addrsID,
            orderType: "2",
            items: placeorderItemslist,
            payment: paymentdetlslist,
            coupon: selectedcoupon,
            coupon_amount: couponamount.toString(),
            coupon_code: selectedcoupon.code);
      }else{
        _placeorder_request_model = new Placeorder_request_model(
            userId: userID,
            addressId: addrsID,
            orderType: "2",
            items: placeorderItemslist,
            payment: paymentdetlslist);
      }
      debugPrint("@@@@ TOTAL ITEMS READY TO ORDER MAP" + jsonEncode(_placeorder_request_model));
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        _placeOrderBloc.add(SendPaymentstatusEvent(_placeorder_request_model.toJson()));
      } else {
        _apputils.showtoast(context, "Please make sure Network Connection is available");
      }
    } else {

      if(selectedcoupon!=null) {
        _placeorder_request_model = new Placeorder_request_model(
            userId: userID,
            addressId: addrsID,
            orderType: "2",
            items: placeorderItemslist,
            coupon: selectedcoupon,
            coupon_amount: couponamount.toString(),
            coupon_code: selectedcoupon.code);
      }else{
        _placeorder_request_model = new Placeorder_request_model(
            userId: userID,
            addressId: addrsID,
            orderType: "2",
            items: placeorderItemslist );
      }
      debugPrint("@@@@ TOTAL ITEMS READY TO ORDER MAP" + jsonEncode(_placeorder_request_model));
      Future.delayed(const Duration(milliseconds: 100), () async {
        bool isconnected = await _apputils.check();
        if (isconnected != null && isconnected) {
          _placeOrderBloc.add(SendOrderEvent(_placeorder_request_model.toJson()));
        } else {
          _apputils.showtoast(
              context, "Please make sure Network Connection is available");
        }
      });
    }
  }

  String getactualweight(String weight) {
    String wt = weight.replaceAll(" ", "").toLowerCase();
    wt = wt.replaceAll("g", "");
    return wt;
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WillPopScope(
            onWillPop: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Scaffold(
                backgroundColor: Colors.white,
                body: FutureBuilder(
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
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return getPage();
                      } else {
                        return Center(
                            child: Container(
                                color: Colors.white,
                                alignment: Alignment.center,
                                child: _apputils.buildLoading(context)));
                      }
                    }))));
  }

  Widget getPage() {
    return BlocListener<PlaceOrderBloc, PlaceOrderState>(
        listener: (context, state) {
      if (state is PlaceOrderInitialState) {
        setState(() {
          showloading = true;
        });
      } else if (state is PlaceOrderLoadingState) {
        setState(() {
          showloading = true;
        });
      } else if (state is PlaceOrderErrorState) {
        setState(() {
          showloading = false;
        });
        _apputils.showtoast(context, "Error: ${state.message}");
      } else if (state is PlaceOrderLoadedState) {
        setState(() {
          showloading = false;
          if (state.status.toString() == "200") {
            paymentUIstatus = "Success";
            removecartitems();
          } else {
            paymentUIstatus = "Failed";
            paymentmsg = "ERROR: " + state.status;
          }
        });
      } else if (state is SendPaymentstatusLoadedState) {
        setState(() {
          showloading = false;
          if (state.status.toString() == "200") {
            paymentUIstatus = "Success";
            removecartitems();
          } else {
            paymentUIstatus = "Failed";
            paymentmsg = "ERROR: " + state.status;
          }
        });
      }
    }, child: BlocBuilder<PlaceOrderBloc, PlaceOrderState>(
      builder: (context, state) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: getScreen(),
        );
      },
    ));
  }

  void removecartitems() async {
    await databaseHelper.deletetable();
  }

  Widget getScreen() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Stack(
          children: [
            paymentUIstatus.isNotEmpty &&
                    (billpaymentstatus.isEmpty ||
                        billpaymentstatus == "Success")
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        paymentUIstatus == "Success"
                            ? Icons.check_circle
                            : Icons.error,
                        size: 100,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Center(
                        child: Text(
                          paymentUIstatus == "Success"
                              ? "Successfully Placed your Order."
                              : "Couldn\'t Place your Order",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Text(
                          paymentUIstatus == "Success"
                              ? (paymentId.isNotEmpty
                                  ? ("Payment Id: " + paymentId)
                                  : "")
                              : paymentmsg,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : Container(),
            billpaymentstatus.isNotEmpty && billpaymentstatus == "Failed"
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        billpaymentstatus == "Success"
                            ? Icons.check_circle
                            : Icons.error,
                        size: 100,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Center(
                        child: Text(
                          billpaymentstatus == "Success"
                              ? "Payment received Successfully"
                              : "Failed to receive Payment\n $paymentmsg",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Text(
                          billpaymentstatus == "Success"
                              ? "Payment Id: $paymentId"
                              : paymentmsg,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : Container(),
            paymentUIstatus.isNotEmpty? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    margin: EdgeInsets.only(bottom: 50.0),
                    child: RaisedButton(
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.only(
                            left: 50.0, top: 12.0, right: 50.0, bottom: 12.0),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.transparent)),
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          //Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                        },
                        child: Text(
                          'CONTINUE',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .apply(color: Colors.white),
                        )))):Container(),
            showloading ? _apputils.buildLoading(context) : Container()
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {

    var options = {
      'key': sec_key,
      'amount': totalcartprice,
      'currency': 'INR',
      'name': 'FarmToHome',
      'description': 'F2H Products',
      'prefill': {
        'contact': _userdatalist[0].mobile,
        'email': _userdatalist[0].email.isNotEmpty ? _userdatalist[0].email : "",
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }



  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Map<String, dynamic> successresponsedata = new Map<String, dynamic>();
    successresponsedata['paymentId'] = response.paymentId;
    successresponsedata['orderId'] = response.orderId;
    successresponsedata['signature'] = response.signature;
    var map = jsonEncode(successresponsedata);
    debugPrint("@@@@____ SUCCESS json: " + map);

    setState(() {
      billpaymentstatus = "Success";
    });
    paymentId = response.paymentId;
    debugPrint("@@@@ SUCCESS: " +
        response.paymentId); // Ex:: SUCCESS: pay_Fe3s9zCJSl1s3g
    prepareOrdermap_success(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      paymentUIstatus = "";
      billpaymentstatus = "Failed";
      paymentmsg =
          "ERROR: " + response.code.toString() + "-" + response.message;
    });
    debugPrint("@@@@  ERROR: " + response.code.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      billpaymentstatus = "EXTERNAL_WALLET: " + response.walletName;
    });
    debugPrint("@@@@  EXTERNAL_WALLET: " + response.walletName);
    _apputils.showtoast(context, "EXTERNAL_WALLET: " + response.walletName);
  }

  Future getsaveddata() async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    String locdetails = await _userPrefs.getLoctndetls();
    if (locdetails != null) {
      setState(() {
        if (_locationDetailslist.length > 0) {
          _locationDetailslist.clear();
        }
        debugPrint(
            '@@@@ SAVED LOCATION DATA  paymentpage ${json.decode(locdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(locdetails)};
        _locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));
      });
    }
    String userdetails = await _userPrefs.getUserdetls();
    if (userdetails != null) {
      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        debugPrint(
            '@@@@ SAVED USER DATA paymentpage ${json.decode(userdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(userdetails)};
        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
        userID = _userdatalist[0].userId;
      });
    }
    await updatecartlist();
  }
}
