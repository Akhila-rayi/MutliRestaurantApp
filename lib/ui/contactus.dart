import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_bloc.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_event.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_state.dart';
import 'package:FarmToHome/data/model/appinfo_response_model.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:contactus/contactus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launch_review/launch_review.dart';
import 'package:html/parser.dart';

class Contactus extends StatefulWidget {
  @override
  ContactusState createState() {
    return ContactusState();
  }
}

class ContactusState extends State<Contactus> {

  GlobalKey _globalkey = GlobalKey();
  var ht = 100.0;
  List<LocationDetls> _locationDetailslist = [];
  var showloading = false;
  UserPrefs _userPrefs = new UserPrefs();
  Apputils _apputils = new Apputils();
  AppInfoBloc _appInfoBloc;
  List<Appinfo_Data> _contactuslist = [];
  Future saveddatafuture;

  String actualtext = "";

  @override
  void initState() {
    super.initState();
    _appInfoBloc = BlocProvider.of<AppInfoBloc>(context);
    saveddatafuture = getsaveddata();
  }

  _afterLayout(_) {
    _getSize();
  }

  _getSize() {
    RenderBox renderBoxRed = _globalkey.currentContext.findRenderObject();
    var sizeRed = renderBoxRed.size;
    setState(() {
      ht = sizeRed.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Contact us",
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
                        child:Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child:_apputils.buildLoading(context)));
                  }
                })));
  }

  Widget getPage(){

    return BlocListener<AppInfoBloc, AppInfoState>(
        listener: (context, state) {
          if (state is AppInfoInitialState) {
            setState(() {
              showloading = true;
            });
          } else if (state is AppInfoLoadingState) {
            setState(() {
              showloading = true;
            });
          } else if (state is FetchContactInfoLoadedState) {
            setState(() {
              showloading = false;

              if (_contactuslist.length > 0) {
                _contactuslist.clear();
              }
              if (state.appinfodata != null &&
                  state.appinfodata.length > 0) {
                _contactuslist.addAll(state.appinfodata);
                WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
              } else {
                actualtext = "No data found";
              }
            });
          } else if (state is AppInfoErrorState) {
            setState(() {
              showloading = false;
            });
            _apputils.showtoast(context, state.message);
          }
        }, child: BlocBuilder<AppInfoBloc, AppInfoState>(
      builder: (context, state) {
        return getMainUI();
      },
    ));
  }
  Widget getMainUI() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          _contactuslist.length > 0
              ? ListView(
                  padding: EdgeInsets.only(
                      left: 16.0, top: 50.0, right: 16.0, bottom: 16),
                  children: <Widget>[
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              width: 120,
                              height: ht,
                              color: Theme.of(context).primaryColor,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: ht - 40,
                                        margin: EdgeInsets.only(
                                            left: 16.0, right: 16.0),
                                        child: Image(
                                          image: AssetImage(
                                              'assets/images/logo_white.png'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      margin: EdgeInsets.only(
                                          left: 4.0,
                                          right: 4.0,
                                          top: 8.0,
                                          bottom: 8.0),
                                      color: Colors.white,
                                    )
                                  ])),
                          Expanded(
                            child: getsecondwidget(),
                          )
                        ]),
                    Theme(
                      child: ContactUs(
                        cardColor: Colors.green.shade100,
                        textColor: Colors.teal.shade900,
                        companyFontSize: 0,
                        email: 'info@vitasoft.in',
                        companyName: 'vita technologies',
                        companyColor: Colors.teal.shade900,
                        phoneNumber: '+919030662999',
                        website: 'http://vitasoft.in/',
                        linkedinURL:
                            'https://www.linkedin.com/company/vita-technologies1/',
                        taglineColor: Colors.white,
                        tagLine: '',
                        //twitterHandle: '',
                        instagram: 'vita.technologies',
                        facebookHandle: 'vitaeduanditserviceskarimnagar',
                      ),
                      data: ThemeData(
                        primaryColor: const Color(0xFF009A00),
                        buttonTheme: ButtonThemeData(
                            buttonColor: const Color(0xFF009A00)),
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
                    ),
                    Card(
                        margin: EdgeInsets.only(
                            left: 24.0, right: 24.0, bottom: 16, top: 12.0),
                        color: Colors.green.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 58,
                                    ),
                                    Text("Rate Us",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.teal.shade900,
                                            fontSize: 16.0,
                                            fontFamily: 'quicksand',
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.rate_review,
                                    color: Colors.black38,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            LaunchReview.launch(
                                androidAppId: "com.f2h.consumer",
                                iOSAppId: "com.f2h.consumer");
                          },
                        ))
                  ],
                )
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

  Widget getsecondwidget() {
    return Container(
        key: _globalkey,
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Wrap(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.email,
                    color: Colors.yellow,
                    size: 15,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        "Address",
                        style: TextStyle(
                            fontSize: 15.0,
                            fontFamily: 'quicksand',
                            fontWeight: FontWeight.w500,
                            color: Colors.yellow),
                        textAlign: TextAlign.start,
                      ),
                      _contactuslist[0].address != null
                          ? Text(
                              _apputils
                                  .parseHtmlString(_contactuslist[0].address),
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.start,
                            )
                          : Container(),
                    ],
                  )),
                ],
              ),
              Container(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.phone_in_talk,
                    color: Colors.yellow,
                    size: 15,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                        Text(
                          "Phone",
                          style: TextStyle(
                              fontSize: 15.0,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.w500,
                              color: Colors.yellow),
                          textAlign: TextAlign.start,
                        ),
                        _contactuslist[0].phone != null
                            ? _contactuslist[0].phone.contains(",")
                                ? Text(
                                    /*"9030 662 999\n8340 891 732"*/
                                    _contactuslist[0]
                                        .phone
                                        .replaceAll(",", "\n"),
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontFamily: 'quicksand',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    textAlign: TextAlign.start,
                                  )
                                : Text(
                                    _contactuslist[0].phone,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontFamily: 'quicksand',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    textAlign: TextAlign.start,
                                  )
                            : Container(),
                      ])),
                ],
              ),
            ],
          ),
        ));
  }

  Future getsaveddata() async {

    String locdetails = await _userPrefs.getLoctndetls();
    if (locdetails != null) {
      debugPrint(
          '@@@@ SAVED LOCATION DATA  contactus ${json.decode(locdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(locdetails)};

      setState(() {
        if (_locationDetailslist.length > 0) {
          _locationDetailslist.clear();
        }
        _locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));

      });
      Future.delayed(const Duration(milliseconds: 100), () async {
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        _appInfoBloc
            .add(FetchContactInfoEvent(_locationDetailslist[0].locationId));
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }});
    }
  }
}
