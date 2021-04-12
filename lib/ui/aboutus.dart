import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_bloc.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_event.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_state.dart';
import 'package:FarmToHome/data/model/appinfo_response_model.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';

class Aboutus extends StatefulWidget {
  @override
  AboutusState createState() {
    return AboutusState();
  }
}

class AboutusState extends State<Aboutus> {
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "About us",
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
                })));
  }

  Widget getPage() {
    return BlocListener<AppInfoBloc, AppInfoState>(listener: (context, state) {
      if (state is AppInfoInitialState) {
        setState(() {
          showloading = true;
        });
      } else if (state is AppInfoLoadingState) {
        setState(() {
          showloading = true;
        });
      } else if (state is FetchAppInfoLoadedState) {
        setState(() {
          showloading = false;

          if (_contactuslist.length > 0) {
            _contactuslist.clear();
          }
          if (state.appinfodata != null && state.appinfodata.length > 0) {
            _contactuslist.addAll(state.appinfodata);
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
        return getDescription();
      },
    ));
  }

  Widget getDescription() {
    return SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.all(16.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(children: <Widget>[
              _contactuslist.length > 0
                  ? Text(
                      _apputils.parseHtmlString(
                          _contactuslist[0].description.toString()),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.teal.shade900,
                          // medium
                          fontSize: 16.0,
                          fontFamily: 'quicksand',
                          fontWeight: FontWeight.bold))
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
            ])));
  }

  Future getsaveddata() async {

    String locdetails = await _userPrefs.getLoctndetls();
    if (locdetails != null) {
      debugPrint(
          '@@@@ SAVED LOCATION DATA  aboutus ${json.decode(locdetails)}');
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
          _appInfoBloc.add(
              FetchAppInfoEvent(_locationDetailslist[0].locationId));
        } else {
          _apputils.showtoast(
              context, "Please make sure Network Connection is available");
        }
      });
    }
  }
}
