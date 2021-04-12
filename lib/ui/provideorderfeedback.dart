import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/orderfeedback/orderfeedback_bloc.dart';
import 'package:FarmToHome/bloc/orderfeedback/orderfeedback_event.dart';
import 'package:FarmToHome/bloc/orderfeedback/orderfeedback_state.dart';
import 'package:FarmToHome/data/model/giveOrderfeedback.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/data/model/previousorders_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ProvideOrder_Feedback extends StatefulWidget {
  Previousordersdetails previousordersdetails;

  ProvideOrder_Feedback({Key key, @required this.previousordersdetails})
      : super(key: key);

  @override
  ProvideOrder_FeedbackState createState() {
    return ProvideOrder_FeedbackState(previousordersdetails);
  }
}

class ProvideOrder_FeedbackState extends State<ProvideOrder_Feedback> {
  Previousordersdetails previousordersdetails;
  var showloading = false;

  TextEditingController editingController1 = new TextEditingController();
  double ratingsval = 0.0;
  List<UserData> _userdatalist = [];
  Future saveddatafuture;
  String userID = "", locID = "";
  List<LocationDetls> _locationDetailslist = [];
  UserPrefs _userPrefs = new UserPrefs();
  Apputils _apputils = new Apputils();
  OrderfeedbackBloc orderfeedbackBloc;
  List<bool> listCheck = [];
  List<bool> listtitlecolor = [];
  String cartids = "", note = "";
  GiveOrderfeedback giveOrderfeedback;

  bool enablebutton = true;

  ProvideOrder_FeedbackState(this.previousordersdetails);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < previousordersdetails.orderItems.length; i++) {
      listCheck.add(false);
      listtitlecolor.add(false);
      //cartids += previousordersdetails.orderItems[i].cart_id + ",";
    }
    orderfeedbackBloc = BlocProvider.of<OrderfeedbackBloc>(context);
    saveddatafuture = getsaveddata();
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

  Future getsaveddata() async {
    String locdetails = await _userPrefs.getLoctndetls();
    if (locdetails != null) {
      debugPrint('@@@@ SAVED LOCATION DATA   ${json.decode(locdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(locdetails)};

      setState(() {
        if (_locationDetailslist.length > 0) {
          _locationDetailslist.clear();
        }
        _locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));
        locID = _locationDetailslist[0].locationId;
      });
    }

    String userdetails = await _userPrefs.getUserdetls();
    if (userdetails != null) {
      debugPrint('@@@@ SAVED USER DATA  ${json.decode(userdetails)}');
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
  }

  Widget getPage() {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Order Feedback",
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
                Navigator.of(context).pop(0);
              }),
        ),
        backgroundColor: Colors.white,
        body: BlocListener<OrderfeedbackBloc, OrderfeedbackState>(
            listener: (context, state) {
          if (state is OrderfeedbackInitialState) {
            setState(() {
              showloading = true;
              enablebutton = false;
            });
          } else if (state is OrderfeedbackLoadingState) {
            setState(() {
              showloading = true;
              enablebutton = false;
            });
          } else if (state is OrderfeedbackErrorState) {
            setState(() {
              showloading = false;
              enablebutton = true;
            });
            _apputils.showtoast(context, "Error: ${state.message}");
          } else if (state is AddOrderfeedbackLoadedState) {
            setState(() {
              showloading = false;
              enablebutton = true;

              if (state.list != null && state.list.length > 0) {
                _apputils.showtoast(context, state.list[0].alert);
                if (state.list[0].alert
                    .toLowerCase()
                    .contains("successfully")) {
                  Navigator.of(this.context).pop(1);
                }
              } else {
                _apputils.showtoast(context, "Please try again");
              }
            });
          }
        }, child: BlocBuilder<OrderfeedbackBloc, OrderfeedbackState>(
          builder: (context, state) {
            return getScreen();
          },
        )));
  }

  Widget getScreen() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 32.0,
                    ),
                    Row(
                      children: [
                        Text(
                          "Order ID: ",
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .apply(color: Colors.black),
                        ),
                        Text(
                          previousordersdetails.orderId,
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(color: Colors.red),
                        ),
                        Expanded(
                          child: Text(
                            _apputils.reformatDate(previousordersdetails
                                    .orderDate
                                    .toString()
                                    .split(" ")[0]) +
                                " " +
                                _apputils.twelvehrformat_time(
                                    previousordersdetails.orderDate
                                        .toString()
                                        .split(" ")[1]),
                            textAlign: TextAlign.end,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .apply(color: Colors.red),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 32.0,
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Please provide your Rating for the order below",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .apply(color: Colors.black),
                        )),
                    SizedBox(
                      height: 8.0,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SmoothStarRating(
                        color: Colors.red,
                        borderColor: Colors.red,
                        isReadOnly: false,
                        size: 40,
                        filledIconData: Icons.star,
                        halfFilledIconData: Icons.star_half,
                        defaultIconData: Icons.star_border,
                        starCount: 5,
                        allowHalfRating: true,
                        spacing: 2.0,
                        onRated: (value) {
                          ratingsval = value;
                          debugPrint("@@@rating value -> $value");
                          // print("rating value dd -> ${value.truncate()}");
                        },
                      ),
                    ),
                    SizedBox(
                      height: 32.0,
                    ),
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: previousordersdetails.orderItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 2.0),
                              Row(
                                  children: [
                                  SizedBox(width:25),
                              Expanded(
                                child:
                                  Text(
                                      previousordersdetails
                                              .orderItems[index].weight +
                                          " x " +
                                          previousordersdetails
                                              .orderItems[index].cartCount,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 14.0,
                                          fontFamily: 'quicksand',
                                          fontWeight: FontWeight.w500)))]),
                                  SizedBox(height: 2.0),
                              Row(
                                children: [
                                  SizedBox(width:25),
                                  Expanded(
                                    child: Text(
                                      "₹" +
                                          getindvlorderdiscountprice(
                                              double.parse(
                                                  previousordersdetails
                                                      .orderItems[index]
                                                      .priceTotal),
                                              double.parse(
                                                  previousordersdetails
                                                      .orderItems[index]
                                                      .cartCount),
                                              double.parse(
                                                  previousordersdetails
                                                      .orderItems[index]
                                                      .discount))
                                              .toString(),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontFamily: 'quicksand',
                                          fontWeight: FontWeight.w500),
                                    )
                                  )
                                  ])

                                ],
                              ),
                              trailing: Checkbox(
                                checkColor: Colors.white,
                                activeColor: const Color(0xFF009A00),
                                value: listCheck[index],
                                onChanged: (value) {
                                  setState(() {
                                    listtitlecolor[index] =
                                        !listtitlecolor[index];
                                    listCheck[index] = !listCheck[index];
                                    if (listCheck[index]) {
                                      cartids += previousordersdetails
                                              .orderItems[index].cart_id +
                                          ",";
                                    } else {
                                      if (cartids.contains(
                                          "${previousordersdetails.orderItems[index].cart_id},")) {
                                        cartids = cartids.replaceAll(
                                            "${previousordersdetails.orderItems[index].cart_id},",
                                            "");
                                      } else {
                                        cartids = cartids.replaceAll(
                                            "${previousordersdetails.orderItems[index].cart_id}",
                                            "");
                                      }
                                    }
                                  });
                                },
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    width: 25,
                                    child: Text(
                                      "${index + 1}. ",
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .apply(color: Colors.black38),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                        previousordersdetails
                                            .orderItems[index].title,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: listtitlecolor[index]
                                                ? Colors.red
                                                : Colors.green,
                                            fontSize: 15.0,
                                            fontFamily: 'quicksand',
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ));
                        }),
                    SizedBox(
                      height: 32.0,
                    ),
                    Text(
                      "Provide your feedback below:",
                      textAlign: TextAlign.start,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .apply(color: Colors.black),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      height: 150,
                      child: TextFormField(
                          maxLines: null,
                          expands: true,
                          enabled: true,
                          controller: editingController1,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          textAlign: TextAlign.start,
                          autofocus: false,
                          cursorWidth: 1.5,
                          cursorColor: Colors.redAccent,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: "",
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black38, width: 1.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black38, width: 1.0)),
                            /* hintText: "Enter Message",
                        hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: 16.0,
                            fontFamily: 'quicksand',
                            fontWeight: FontWeight.w500),
                        contentPadding: EdgeInsets.all(16.0))*/
                          )),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.only(
                          left: 50.0, top: 10.0, right: 50.0, bottom: 10.0),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.transparent)),
                      onPressed: enablebutton
                          ? () {
                              note = editingController1.text.toString();
                              if (ratingsval == 0.0) {
                                _apputils.showtoast(
                                    context, "Please provide your ratings");
                              } else if (cartids.isNotEmpty && note.isEmpty) {
                                _apputils.showtoast(
                                    context, "Please Enter your feedback");
                              } else {
                                if (cartids.isNotEmpty) {
                                  debugPrint(
                                      "@@@ CARTIDS SELECTED -> $cartids");
                                  cartids = cartids.replaceFirst(
                                      ",", "", cartids.length - 1);
                                  debugPrint(
                                      "@@@ CARTIDS SELECTED after-> $cartids");
                                }
                                giveOrderfeedback = new GiveOrderfeedback(
                                    userId: userID,
                                    orderId: previousordersdetails.orderId,
                                    locationId: locID,
                                    cartIds: cartids,
                                    rating: ratingsval.toString(),
                                    note: this.note);
                                debugPrint(
                                    "@@@ ADD FEEDBACK-> ${jsonEncode(giveOrderfeedback.toJson())}");
                                orderfeedbackBloc.add(AddOrderfeedbackEvent(
                                    giveOrderfeedback.toJson()));
                              }
                            }
                          : null,
                      child: Text(
                        'SUBMIT',
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .apply(color: Colors.white),
                      ),
                    ),
                  ],
                )),
          ),
          showloading ? _apputils.buildLoading(context) : Container()
        ]));
  }

  double getindvlorderdiscountprice(
      double totalprice, double quantity, double offpercent) {
    double initval =
        (quantity * totalprice - ((offpercent / 100) * quantity * totalprice));
    double beforeround = num.parse(initval.toStringAsFixed(1)) * 2;
    double price = beforeround.ceil() / 2;
    return price;
  }
}
