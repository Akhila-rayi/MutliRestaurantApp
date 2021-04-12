import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/Utils/DatabaseHelper.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_bloc.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_event.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_state.dart';
import 'package:FarmToHome/data/model/CartItemsModel.dart';
import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:FarmToHome/ui/addLocation.dart';
import 'package:FarmToHome/ui/homepage.dart';
import 'package:FarmToHome/ui/mycouponslist.dart';
import 'package:FarmToHome/ui/paymentpage.dart';
import 'package:FarmToHome/ui/selectpaymentmode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class CartItems extends StatefulWidget {
  @override
  CartItemsState createState() {
    return CartItemsState();
  }
}

class CartItemsState extends State<CartItems> {
  List<Coupons> _couponsdatalist = [];
  Coupons couponselct = null;
  var enableplaceorder = false;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<CartItemsModel> dbcartlist = [];
  var dbcartcount = 0;
  double totalcartprice = 0.0;
  var showloading = false;
  DeliveryAdrsBloc _deliveryAdrsBloc;
  List<double> totalitemcountlist = [];
  UserPrefs _userPrefs = new UserPrefs();
  List<UserData> _userdatalist = [];
  Apputils _apputils = new Apputils();
  String userID = "", addrsID = "";
  List<DeliveryAdrsData> deliveryAdrsdata = [];
  List<LocationDetls> _locationDetailslist = [];
  String useradrs = "";
  double mincartvalue;
  int delivercharges;
  Future saveddatafuture;
  bool onlyCOD = false,couponapplied=false;
  double couponAmount=0.0;

  @override
  void initState() {
    super.initState();
    _deliveryAdrsBloc = BlocProvider.of<DeliveryAdrsBloc>(context);
    saveddatafuture = getsaveddata();
  }

  void updatecartlist() async {

    Database futuredab = await databaseHelper.database;
    List<CartItemsModel> _list = await databaseHelper.getCartitemslist();
    double dbtotalprice = await databaseHelper.gettotalprice();

    if (dbcartlist.length > 0) {
      dbcartlist.clear();
    }

    if (_list != null) {
      setState(() {
        this.dbcartlist = _list;
        this.dbcartcount = _list.length;
        debugPrint("@@@@ Cartlistcount Cart items" + dbcartcount.toString());
      });
    }

    if (dbtotalprice != null) {
      setState(() {
        totalcartprice = dbtotalprice;
        totalcartprice += delivercharges;

        if (totalcartprice > mincartvalue) {
          setState(() {
            enableplaceorder = true;
          });
        } else {
          setState(() {
            enableplaceorder = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
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
                    child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: _apputils.buildLoading(context)));
              }
            }));
  }

  Widget getPage() {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Your Cart",
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
                Navigator.pop(context, true);
              }),
          actions: [
            dbcartcount > 0
                ? Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 3.0, right: 3.0),
                          child: CircleAvatar(
                              maxRadius: 13.0,
                              backgroundColor: Colors.red,
                              child: Center(
                                  child: Text(
                                dbcartcount.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    fontFamily: 'quicksand',
                                    fontWeight: FontWeight.bold),
                              )))),
                      Padding(
                          padding: EdgeInsets.only(top: 3.0, right: 5.0),
                          child: Text(
                            "Items",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontFamily: 'quicksand',
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  )
                : Container()
          ],
        ),
        backgroundColor: Colors.white,
        body: BlocListener<DeliveryAdrsBloc, DeliveryAdrsState>(
            listener: (context, state) {
          if (state is DeliveryAdrsInitialState) {
            setState(() {
              showloading = true;
            });
          } else if (state is DeliveryAdrsLoadingState) {
            setState(() {
              showloading = true;
            });
          } else if (state is DeliveryAdrsErrorState) {
            setState(() {
              showloading = false;
            });
            _apputils.showtoast(context, "Error: ${state.message}");
          } else if (state is DeliveryAdrsLoadedState) {
            setState(() {
              showloading = false;
              if (deliveryAdrsdata.length > 0) {
                deliveryAdrsdata.clear();
              }
              if (state.deliveryAdrsdata != null &&
                  state.deliveryAdrsdata.length > 0) {
                deliveryAdrsdata.addAll(state.deliveryAdrsdata);
                int lastadrs = deliveryAdrsdata.length - 1;
                addrsID = deliveryAdrsdata[lastadrs].addressId;
                if (deliveryAdrsdata[lastadrs].hno.isNotEmpty) {
                  useradrs =
                      "${deliveryAdrsdata[lastadrs].addressName},${deliveryAdrsdata[lastadrs].hno},${deliveryAdrsdata[lastadrs].street},"
                      "${deliveryAdrsdata[lastadrs].city},"
                      "${deliveryAdrsdata[lastadrs].state},${deliveryAdrsdata[lastadrs].pincode}, India";
                }
              }
            });
          } else if (state is FetchPaymentinfoLoadedState) {
            setState(() {
              showloading = false;

              if (state.paymentgatewaylist != null &&
                  state.paymentgatewaylist.length > 0) {
                setState(() {
                  onlyCOD = false;
                });
              } else if (state.paymentgatewaylist != null &&
                  state.paymentgatewaylist.length == 0) {
                // online payment Inactive
                setState(() {
                  onlyCOD = true;
                });
              } else {
                setState(() {
                  onlyCOD = true;
                });
              }
            });
          } else if (state is FetchcouponsLoadedState) {
            setState(() {
              showloading = false;
              if (_couponsdatalist.length > 0) {
                _couponsdatalist.clear();
              }
              if (state.homedata != null &&
                  state.homedata.length > 0 &&
                  state.homedata[0].coupons.length > 0) {
                _couponsdatalist.addAll(state.homedata[0].coupons);
              }
            });
          }
        }, child: BlocBuilder<DeliveryAdrsBloc, DeliveryAdrsState>(
          builder: (context, state) {
            return getScreen();
          },
        )));
  }

  Widget getScreen() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: dbcartlist.length > 0
            ? Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: (MediaQuery.of(context).size.height),
                    child: FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: enableplaceorder
                          ? (addrsID.isNotEmpty
                              ? _couponsdatalist.length > 0
                                  ? 0.72
                                  : 0.76
                              : _couponsdatalist.length > 0
                                  ? 0.88
                                  : 0.92)
                          : (addrsID.isNotEmpty
                              ? _couponsdatalist.length > 0
                                  ? 0.89
                                  : 0.73
                              : _couponsdatalist.length > 0
                                  ? 0.85
                                  : 0.89),
                      widthFactor: 1.0,
                      child: Container(
                        child: productTile(),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: FractionallySizedBox(
                              alignment: Alignment.bottomCenter,
                              heightFactor: enableplaceorder
                                  ? (addrsID.isNotEmpty
                                      ? _couponsdatalist.length > 0
                                          ? 0.28
                                          : 0.24
                                      : _couponsdatalist.length > 0
                                          ? 0.12
                                          : 0.08)
                                  : (addrsID.isNotEmpty
                                      ? _couponsdatalist.length > 0
                                          ? 0.31
                                          : 0.27
                                      : _couponsdatalist.length > 0
                                          ? 0.15
                                          : 0.11),
                              widthFactor: 1.0,
                              child: Container(
                                  color: Colors.red,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _couponsdatalist.length > 0
                                          ? Container(
                                              color: Colors.white,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 8.0,
                                                      left: 16.0,
                                                      top: 8.0,
                                                      bottom: 8.0),
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          MyCouponslist(
                                                                            nav_from_menu:
                                                                                false,
                                                                          )))
                                                              .then((value) {
                                                            debugPrint(
                                                                "@@@ SELECTED COUPON ${json.encode(value)}");
                                                            couponselct = value;
                                                            updateAmount(couponselct);
                                                          });
                                                        },
                                                        child: Text(
                                                          couponapplied == false
                                                              ? 'Apply Coupon'
                                                              : '${couponselct.code} applied. Got ₹${couponAmount} Off.',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent,
                                                              fontSize:  couponapplied == false
                                                                  ? 16.0: 14.0,
                                                              fontFamily:
                                                                  'quicksand',
                                                              fontWeight:  couponapplied == false
                                                                  ? FontWeight.bold :FontWeight.w600 ),
                                                        ),
                                                      ),
                                                    ],
                                                  )))
                                          : Container(),

                                      /* Container(
                                          color: Colors.white,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: 8.0,
                                                  left: 8.0,
                                                  top: 4.0,
                                                  bottom: 4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Total No. of items: ',
                                                    textAlign:
                                                    TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12.0,
                                                        fontFamily:
                                                        'quicksand',
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '${dbcartlist.length}',
                                                    textAlign:
                                                    TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                        'quicksand',
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ),
                                                ],
                                              )
                                          )),*/
                                      useradrs.isNotEmpty
                                          ? Expanded(
                                              flex: 3,
                                              child: Container(
                                                  color: Colors.white,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.location_on,
                                                            color: Colors.red,
                                                            size: 30,
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                              child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'Delivery Address',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13.0,
                                                                    fontFamily:
                                                                        'quicksand',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                useradrs,
                                                                maxLines: 2,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13.0,
                                                                    fontFamily:
                                                                        'quicksand',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300),
                                                              )
                                                            ],
                                                          )),
                                                          GestureDetector(
                                                            child: Text(
                                                              'Change',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontFamily:
                                                                      'quicksand',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          Addlocation()))
                                                                  .then(
                                                                      (value) {
                                                                debugPrint(
                                                                    "@@@ ADRESS ID  %%%%%%%%%%%%%%___" +
                                                                        value);
                                                                setState(() {
                                                                  showloading =
                                                                      false;
                                                                  if (value
                                                                      .toString()
                                                                      .contains(
                                                                          "@")) {
                                                                    addrsID = value
                                                                        .toString()
                                                                        .split(
                                                                            "@")[0];
                                                                    useradrs = value
                                                                        .toString()
                                                                        .split(
                                                                            "@")[1];
                                                                  }
                                                                });
                                                              });
                                                            },
                                                          )
                                                        ],
                                                      ))))
                                          : Container(),
                                      !enableplaceorder
                                          ? Expanded(
                                              flex: 1,
                                              child: Container(
                                                  color: Colors.white,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 8.0,
                                                        left: 8.0,
                                                        top: 4.0,
                                                        bottom: 4.0),
                                                    child: Text(
                                                      'Note: Minimum Cart value should be above ₹${mincartvalue.toString()}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 12.0,
                                                          fontFamily:
                                                              'quicksand',
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  )))
                                          : Container(),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            'Cart Value: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14.0,
                                                                fontFamily:
                                                                    'quicksand',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          Text(
                                                            '₹ $totalcartprice',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16.0,
                                                                fontFamily:
                                                                    'quicksand',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                      delivercharges > 0
                                                          ? Text(
                                                              '(including ${delivercharges.toString()}/- delivery charges)',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      11.0,
                                                                  fontFamily:
                                                                      'quicksand',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            )
                                                          : Container(),
                                                    ],
                                                  )),
                                              Container(
                                                width: 2,
                                                color: Colors.white,
                                              ),
                                              Expanded(
                                                  flex: 1,
                                                  child: enableplaceorder
                                                      ? GestureDetector(
                                                          child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                'Place Order',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16.0,
                                                                    fontFamily:
                                                                        'quicksand',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                          onTap: () {
                                                            if (addrsID
                                                                .isEmpty) {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          Addlocation()))
                                                                  .then(
                                                                      (value) {
                                                                debugPrint(
                                                                    "@@@ ADRESS ID  %%%%%%%%%%%%%%___" +
                                                                        value);
                                                                setState(() {
                                                                  showloading =
                                                                      false;
                                                                  if (value
                                                                      .toString()
                                                                      .contains(
                                                                          "@")) {
                                                                    addrsID = value
                                                                        .toString()
                                                                        .split(
                                                                            "@")[0];
                                                                    useradrs = value
                                                                        .toString()
                                                                        .split(
                                                                            "@")[1];
                                                                  }
                                                                });
                                                              });
                                                            } else {
                                                              debugPrint(
                                                                  "@@@ ADRESS ID WHILE PLACING ORDER___" +
                                                                      addrsID);

                                                              if(_locationDetailslist[0].availability=="0" || !_apputils.allowOrder(_locationDetailslist[0])){

                                                                _apputils.showNoticeDialog(context, AppStrings.cannotacceptorder);

                                                              }else {

                                                                  showAlertDialog(context);

                                                              }
                                                            }
                                                          },
                                                        )
                                                      : Container())
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ))))),
                  showloading ? _apputils.buildLoading(context) : Container()
                ],
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: (MediaQuery.of(context).size.height),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Your Cart is empty",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18.0,
                          fontFamily: 'quicksand',
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.only(
                          left: 50.0, top: 12.0, right: 50.0, bottom: 12.0),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.transparent)),
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      child: Text(
                        'Add',
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .apply(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ));
  }

  Widget productTile() {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(0.0),
      itemCount: dbcartlist.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
            child: Card(
          margin: EdgeInsets.all(8.0),
          elevation: 3.0,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: <Widget>[
                Container(
                    width: 100,
                    height: 100,
                    child: Stack(fit: StackFit.expand, children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.network(dbcartlist[index].imageURL,
                              fit: BoxFit.fill, loadingBuilder:
                                  (BuildContext context, Widget child,
                                      ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;

                            return Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Image.asset(
                                  "assets/images/logo_green.png",
                                  fit: BoxFit.fill,
                                  width: 100,
                                  height: 100,
                                ));
                          })),
                      dbcartlist[index].discount != "0%"
                          ? Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.red, width: 1.0),
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Text(
                                        '${dbcartlist[index].discount} Off',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(this.context)
                                            .textTheme
                                            .subtitle2
                                            .apply(color: Colors.red),
                                      ))),
                            )
                          : Container()
                    ])),
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  dbcartlist[index].title,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(this.context)
                                      .textTheme
                                      .subtitle2
                                      .apply(
                                        color: Colors.black,
                                      ),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.only(top: 8.0, bottom: 8.0),
                                    child: Text(
                                      dbcartlist[index].weight,
                                      textAlign: TextAlign.start,
                                      style: Theme.of(this.context)
                                          .textTheme
                                          .bodyText2
                                          .apply(color: Colors.black45),
                                    )),
                              ],
                            )),
                            Text(
                              getwholeprice(index),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.bold),
                            )
                          ]),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            dbcartlist[index].discount != "0%"
                                ? Text(
                                    "₹" +
                                        double.parse(dbcartlist[index]
                                                .priceTotal
                                                .toString())
                                            .toString() +
                                        " ",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.black54,
                                        fontSize: 14.0,
                                        fontFamily: 'quicksand',
                                        fontWeight: FontWeight.w500),
                                  )
                                : Container(),
                            Text(
                              "₹" +
                                  getdiscountprice(
                                          double.parse(dbcartlist[index]
                                              .priceTotal
                                              .toString()),
                                          double.parse(dbcartlist[index]
                                              .discount
                                              .substring(
                                                  0,
                                                  dbcartlist[index]
                                                          .discount
                                                          .length -
                                                      1)),
                                          index)
                                      .toString(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                            ),
                            Expanded(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                GestureDetector(
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.black54,
                                      size: 23,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        decrcountItem(index);
                                      });
                                    }),
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 4.0,
                                        right: 4.0,
                                        top: 0.0,
                                        bottom: 0.0),
                                    child: Text(
                                      showqnt(
                                          double.parse(dbcartlist[index]
                                              .modifiedquantity),
                                          dbcartlist[index].weight,
                                          dbcartlist[index].itemType),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16.0,
                                          fontFamily: 'quicksand',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                    child: Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.black54,
                                      size: 23,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        incrItemcount(index);
                                      });
                                    })
                              ],
                            ))
                          ])
                    ],
                  ),
                ),
              ],
            ),
            /*Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                            child: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.black54,
                              size: 23,
                            ),
                            onTap: () {
                              setState(() {
                                decrcountItem(index);
                              });
                            }),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 4.0, right: 4.0, top: 0.0, bottom: 0.0),
                            child: Text(
                              (double.parse(dbcartlist[index].modifiedquantity))
                                  .toInt()
                                  .toString(),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        GestureDetector(
                            child: Icon(
                              Icons.add_circle_outline,
                              color: Colors.black54,
                              size: 23,
                            ),
                            onTap: () {
                              setState(() {
                                incrItemcount(index);
                              });
                            })
                      ],
                    )*/
          ),
        ));
      },
    );
  }

  void decrcountItem(int index) {

    if(_locationDetailslist[0].availability=="0" || !_apputils.allowOrder(_locationDetailslist[0])){

      _apputils.showNoticeDialog(context, AppStrings.cannotacceptorder);

    }else {

        double itemwght = double.parse(dbcartlist[index].modifiedquantity);
        setState(() {
          if (dbcartlist[index].itemType.toLowerCase() != "kg") {
            if (itemwght > 1) {
              itemwght -= 1;
              dbcartlist[index].modifiedquantity = itemwght.toString();
            } else {
              _delete(dbcartlist[index]);
            }
          } else {
            /*if (itemwght >= 1) {
            itemwght -= 0.5;
            dbcartlist[index].modifiedquantity = itemwght.toString();
          } else {
            _delete(dbcartlist[index]);
          }*/

            if (dbcartlist[index].weight.toLowerCase().contains("kg")) {
              if (itemwght >= 2) {
                itemwght -= 1;
                dbcartlist[index].modifiedquantity = itemwght.toString();
              } else {
                _delete(dbcartlist[index]);
              }
            } else {
              double actaulwt = itemwght * 1000;
              if (actaulwt >=
                  (double.parse(getactualweight(dbcartlist[index].weight)) *
                      2)) {
                actaulwt -=
                    double.parse(getactualweight(dbcartlist[index].weight));
                dbcartlist[index].modifiedquantity =
                    (actaulwt / 1000.0).toString();
              } else {
                _delete(dbcartlist[index]);
              }
            }
          }
          update(dbcartlist[index]);
        });

    }
  }

  void incrItemcount(int index) {

    if(_locationDetailslist[0].availability=="0" || !_apputils.allowOrder(_locationDetailslist[0])){

      _apputils.showNoticeDialog(context, AppStrings.cannotacceptorder);

    }else {
        double itemwght = double.parse(dbcartlist[index].modifiedquantity);

        setState(() {
          if (dbcartlist[index].itemType.toLowerCase() != "kg") {
            itemwght += 1;
            dbcartlist[index].modifiedquantity = itemwght.toString();
          } else {
            //itemwght += 0.5;

            if (dbcartlist[index].weight.toLowerCase().contains("kg")) {
              itemwght += 1;
              dbcartlist[index].modifiedquantity = itemwght.toString();
            } else {
              double actaulwt = itemwght * 1000;
              actaulwt +=
                  double.parse(getactualweight(dbcartlist[index].weight));
              dbcartlist[index].modifiedquantity =
                  (actaulwt / 1000.0).toString();
            }
          }

          update(dbcartlist[index]);
        });

    }
  }

  void update(CartItemsModel cartItemsModel) async {
    int result = await databaseHelper.updatCartItem(cartItemsModel);

    if (result != 0) {
      debugPrint("@@@ SUCESS DB OPERATN");
      updatecartlist();
    } else {
      // Failure
      debugPrint("@@@ FAILURE DB OPERATN");
    }
  }

  void _delete(CartItemsModel cartItemsModel) async {
    int result = await databaseHelper.deleteCartItem(cartItemsModel.id);
    if (result != 0) {
      updatecartlist();
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel",
          style: Theme.of(context)
              .textTheme
              .headline6
              .apply(color: Theme.of(context).primaryColor)),
      onPressed: () {
        _apputils.dismissProgrsdlg(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("OK",
          style: Theme.of(context)
              .textTheme
              .headline6
              .apply(color: Theme.of(context).primaryColor)),
      onPressed: () {
        _apputils.dismissProgrsdlg(context);
        if (!onlyCOD) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => SelectPaymentMode(
                    addrsID: addrsID,
                    userID: userID,
                    coupondata: couponapplied? couponselct:null,
                    couponamount: this.couponAmount,
                  )));
        } else {
          Navigator.of(this.context).push(MaterialPageRoute(
              builder: (BuildContext context) => PaymentPage(
                    addrsID: addrsID,
                    mode: "Cash On Delivery",
                    sec_key: "",
                    selectedcoupon: couponapplied? couponselct:null,
                   couponamount: this.couponAmount,
                  )));
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "FarmToHome",
        textAlign: TextAlign.center,
      ),
      content: Text("Continue Order Checkout?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              _apputils.dismissProgrsdlg(context);
            },
            child: alert);
      },
    );
  }

  /*dismissProgrsdlg(context) {
    Navigator.of(context).pop();
  }*/

  Future getsaveddata() async {
    String locdetails = await _userPrefs.getLoctndetls();
    if (locdetails != null) {
      debugPrint(
          '@@@@ SAVED LOCATION DATA CART ITEMS ${json.decode(locdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(locdetails)};

      setState(() {
        if (_locationDetailslist.length > 0) {
          _locationDetailslist.clear();
        }
        _locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));
        mincartvalue = num.parse(
            double.parse(_locationDetailslist[0].min_order.toString())
                .toStringAsFixed(1));
        delivercharges = int.parse(
            _locationDetailslist[0].deliveryCharges.toString().split(".")[0]);
      });
    }

    String userdetails = await _userPrefs.getUserdetls();
    if (userdetails != null) {
      debugPrint(
          '@@@@ SAVED USER DATA  CART ITEMS ${json.decode(userdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(userdetails)};

      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
        userID = _userdatalist[0].userId;
        debugPrint('@@@@ USERID $userID');
      });
    }
    updatecartlist();

    Future.delayed(const Duration(milliseconds: 100), () async {
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        _deliveryAdrsBloc
            .add(FetchPaymentgatewaysEvent(_locationDetailslist[0].locationId));
        _deliveryAdrsBloc.add(FetchDeliveryAdrsEvent(userID));
        _deliveryAdrsBloc
            .add(FetchcouponsEvent(userID, _locationDetailslist[0].locationId));
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }
    });
  }

  double getdiscountprice(double totalprice, double offpercent, int index) {
    double initval = (totalprice - ((offpercent / 100) * totalprice));
    double beforeround = num.parse(initval.toStringAsFixed(1)) * 2;
    double price = beforeround.ceil() / 2;
    return price;
  }

  String getwholeprice(int index) {
    double beforeround = 0.0;
    if (dbcartlist[index].itemType.toLowerCase() == "kg" &&
        dbcartlist[index].weight.toLowerCase().contains("g") &&
        !dbcartlist[index].weight.toLowerCase().contains("k")) {
      double actualwt = double.parse(getactualweight(dbcartlist[index].weight));
      double d = double.parse(dbcartlist[index].modifiedquantity) * 1000.0;
      beforeround = num.parse(((d / actualwt) * double.parse(dbcartlist[index].priceAfterdiscount)).toStringAsFixed(1)) * 2;
    } else {
      debugPrint("@@@ ${double.parse(dbcartlist[index].modifiedquantity)}");
      beforeround = num.parse(
              (double.parse(dbcartlist[index].modifiedquantity) * double.parse(dbcartlist[index].priceAfterdiscount)).toStringAsFixed(1)) * 2;
    }
    // double beforeround = num.parse((double.parse(dbcartlist[index].modifiedquantity) * double.parse(dbcartlist[index].priceAfterdiscount)).toStringAsFixed(1)) * 2;
    double totamount = beforeround.ceil() / 2;
    return "₹ ${totamount}";
  }

  String getactualweight(String weight) {
    String wt = weight.replaceAll(" ", "").toLowerCase();
    wt = wt.replaceAll("g", "");
    return wt;
  }

  String showqnt(double modfdqnt, String wt, String itemType) {
    if (itemType.toLowerCase() == "kg" &&
        wt.toLowerCase().contains("g") &&
        !wt.toLowerCase().contains("k")) {
      if (modfdqnt < 1.0) {
        double qnty = modfdqnt * 1000;
        String tostr = qnty.toString();
        tostr = tostr.replaceAll(".0", "");
        return "${tostr}gm";
      } else {
        String qnt = modfdqnt.toString().replaceAll(".0", "");
        return "${qnt}kg";
      }
    } else {
      return modfdqnt.toString().replaceAll(".0", "") + itemType.toLowerCase();
    }
  }

  void updateAmount(Coupons couponselct) {
    String amountType = couponselct.amountType;
    String value = couponselct.value;
    if (totalcartprice < double.parse(couponselct.minAmount)) {

      setState(() {
        couponapplied=false;
      });
      _apputils. showNoticeDialog(context,"Cannot Apply Coupon. Your Cart value should be minimum ₹${couponselct.minAmount}" );

    } else {

      if (amountType.toLowerCase().contains("percentage")) {
        setState(() {

          couponAmount=num.parse(((double.parse(value) * totalcartprice / 100.0)*2).toStringAsFixed(1)).ceil()/2;
          if(couponAmount>double.parse(couponselct.maxAmount)){

            couponAmount=(num.parse((double.parse(couponselct.maxAmount)*2).toStringAsFixed(1))).ceil()/2;
          }
          totalcartprice -=couponAmount ;
          couponapplied=true;
        });
      } else {

        setState(() {
          couponAmount=num.parse(((double.parse(value))*2).toStringAsFixed(1)).ceil()/2;
          if(couponAmount>double.parse(couponselct.maxAmount)){
            couponAmount=num.parse((double.parse(couponselct.maxAmount)*2).toStringAsFixed(1)).ceil()/2;
          }
          totalcartprice -= couponAmount;
          couponapplied=true;
        });
      }
    }
  }

 /* showNoticeDialog(BuildContext context, String msg) {
    // set up the buttons

    Widget continueButton = FlatButton(
      child: Text("OK",
          style: Theme.of(context)
              .textTheme
              .headline6
              .apply(color: Theme.of(context).primaryColor)),
      onPressed: () {
        dismissProgrsdlg(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "FarmToHome",
        textAlign: TextAlign.center,
      ),
      content: Text(
          msg),
      actions: [continueButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              dismissProgrsdlg(context);
            },
            child: alert);
      },
    );
  }*/
}
