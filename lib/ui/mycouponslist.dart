import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/home/home_bloc.dart';
import 'package:FarmToHome/bloc/home/home_event.dart';
import 'package:FarmToHome/bloc/home/home_state.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCouponslist extends StatefulWidget {
  bool nav_from_menu = false;

  MyCouponslist({Key key, @required this.nav_from_menu}) : super(key: key);

  @override
  MyCouponslistState createState() {
    return MyCouponslistState(nav_from_menu);
  }
}

class MyCouponslistState extends State<MyCouponslist> {
  Future saveddatafuture;
  List<UserData> _userdatalist = [];
  List<LocationDetls> _locationDetailslist = [];
  UserPrefs _userPrefs = new UserPrefs();
  Apputils _apputils = new Apputils();
  String query = "", userID = "", locationID = "";
  bool showloading = false;
  List<Coupons> _couponsdatalist = [];
  String actualtext = "";
  bool nav_from_menu = false;

  HomeBloc homeBloc;

  MyCouponslistState(this.nav_from_menu);

  @override
  void initState() {
    super.initState();
    homeBloc = BlocProvider.of<HomeBloc>(context);
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
              nav_from_menu ? "Coupons" : "Select Coupon",
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
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return getPage();
                } else {
                  return Center(
                      child: Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: _apputils.buildLoading(context)));
                }
              }),
        ));
  }

  Future getsaveddata() async {
    String locdetails = await _userPrefs.getLoctndetls();

    if (locdetails != null) {
      setState(() {
        if (_locationDetailslist.length > 0) {
          _locationDetailslist.clear();
        }
        debugPrint(
            '@@@@ SAVED LOCATION DATA COUPONS ${json.decode(locdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(locdetails)};

        _locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));

        locationID = _locationDetailslist[0].locationId;
      });
    }

    String userdetails = await _userPrefs.getUserdetls();

    if (userdetails != null) {
      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        debugPrint('@@@@ SAVED USER DATA COUPONS ${json.decode(userdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(userdetails)};

        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
        userID = _userdatalist[0].userId;
      });
    }

    Future.delayed(const Duration(milliseconds: 100), () async {
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        homeBloc.add(FetchHomeEvent(userID, locationID));
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }
    });
  }

  Widget getPage() {
    return BlocListener<HomeBloc, HomeState>(listener: (context, state) {
      if (state is HomeInitialState) {
        setState(() {
          showloading = true;
        });
      } else if (state is HomeLoadingState) {
        setState(() {
          showloading = true;
        });
      } else if (state is HomeErrorState) {
        setState(() {
          showloading = false;
        });
        _apputils.showtoast(context, "Error: ${state.message}");
      } else if (state is HomeLoadedState) {
        setState(() {
          showloading = false;
          if (_couponsdatalist.length > 0) {
            _couponsdatalist.clear();
          }
          if (state.homedata != null && state.homedata.length > 0 && state.homedata[0].coupons.length>0 ) {
            _couponsdatalist.addAll(state.homedata[0].coupons);
          } else {
            actualtext = "No Coupons found";
          }
        });
      }
    }, child: BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return UI();
      },
    ));
  }

  Widget UI() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          _couponsdatalist.length > 0
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: <Widget>[
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _couponsdatalist.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Card(
                                    elevation: 6.0,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text("Coupon Code: ",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14.0,
                                                          fontFamily:
                                                              'quicksand',
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  Text(
                                                      _couponsdatalist[index]
                                                          .code,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 20.0,
                                                          fontFamily:
                                                              'quicksand',
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ]),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                      _couponsdatalist[index]
                                                                  .amountType ==
                                                              "Percentage"
                                                          ? "${_couponsdatalist[index].value}% Off on Minimum Order of ₹${_couponsdatalist[index].minAmount}. You can earn a maximum discount of ₹${_couponsdatalist[index].maxAmount}."
                                                          : " ₹${_couponsdatalist[index].value} Off on Minimum Order of ₹${_couponsdatalist[index].minAmount}. You can earn a maximum discount of ₹${_couponsdatalist[index].maxAmount}.",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14.0,
                                                          fontFamily:
                                                              'quicksand',
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                )
                                              ],
                                            ),
                                            _couponsdatalist[index]
                                                    .termsConditions
                                                    .isNotEmpty
                                                ? SizedBox(
                                                    height: 8,
                                                  )
                                                : Container(),
                                            _couponsdatalist[index]
                                                    .termsConditions
                                                    .isNotEmpty
                                                ? Text(
                                                    _couponsdatalist[index]
                                                        .termsConditions,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.black38,
                                                        fontSize: 14.0,
                                                        fontFamily: 'quicksand',
                                                        fontWeight:
                                                            FontWeight.w500))
                                                : Container(),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text("Expire on: ",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12.0,
                                                        fontFamily: 'quicksand',
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                Text(
                                                    _apputils.reformatDate(
                                                            _couponsdatalist[
                                                                    index]
                                                                .expiredAt
                                                                .split(
                                                                    " ")[0]) +
                                                        " " +
                                                        _apputils.twelvehrformat_time(
                                                            _couponsdatalist[
                                                                    index]
                                                                .expiredAt
                                                                .split(" ")[1]),
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 14.0,
                                                        fontFamily: 'quicksand',
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Expanded(
                                                    child: nav_from_menu
                                                        ? Container()
                                                        : Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: RaisedButton(
                                                              color: Theme.of(this
                                                                      .context)
                                                                  .primaryColor,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5.0),
                                                              shape: new RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      new BorderRadius
                                                                              .circular(
                                                                          5.0),
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .transparent)),
                                                              onPressed: () {
                                                                if (!nav_from_menu) {
                                                                  Navigator.of(
                                                                          this.context)
                                                                      .pop(_couponsdatalist[
                                                                          index]);
                                                                } else {
                                                                  Navigator.of(
                                                                      this.context)
                                                                      .pop();
                                                                }
                                                              },
                                                              child: Text(
                                                                'Apply',
                                                                style: Theme.of(this
                                                                        .context)
                                                                    .textTheme
                                                                    .headline4
                                                                    .apply(
                                                                        color: Colors
                                                                            .white),
                                                              ),
                                                            ),
                                                          ))
                                              ],
                                            )
                                          ],
                                        )),
                                  )));
                        },
                      ),
                    ],
                  ))
              : Center(
                  child: Text(
                    actualtext,
                    textAlign: TextAlign.left,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .apply(color: Colors.red),
                  ),
                ),
          showloading ? _apputils.buildLoading(context) : Container()
        ]));
  }
}
