import 'dart:convert';
import 'dart:math';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/location/location_bloc.dart';
import 'package:FarmToHome/bloc/location/location_event.dart';
import 'package:FarmToHome/bloc/location/location_state.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';

import 'package:FarmToHome/ui/homepage.dart';
import 'package:FarmToHome/ui/personalinfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectLocation extends StatefulWidget {
  bool nav_from_home = false;

  SelectLocation({Key key, @required this.nav_from_home}) : super(key: key);

  @override
  SelectLocationState createState() {
    // TODO: implement createState
    return SelectLocationState(nav_from_home);
  }
}

class SelectLocationState extends State<SelectLocation> {
  BuildContext _buildContext;
  LocationBloc _locationBloc;
  int value;
  bool nav_from_home = false;
  String userID = "", selectedloctnID = "";
  List<LocationDetls> locations_list = [];
  List<Route> arrayRoutes = [];
  Apputils _apputils = new Apputils();
  UserPrefs _userPrefs = new UserPrefs();

  var showloading = false, enablebutton = true;
  String actualtext = "";
  List<UserData> _userdatalist = [];
  List<LocationDetls> _locationDetailslist = [];
  Future saveddatafuture;

  SelectLocationState(this.nav_from_home);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    saveddatafuture = getsaveddata();
  }

  @override
  Widget build(BuildContext context) {
    _buildContext = context;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            leading: nav_from_home
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      if (nav_from_home) {
                        Navigator.of(context).pop(false);
                      } else {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      }
                    })
                : Container(),
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

  Widget getPage() {
    return BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
      if (state is LocationInitialState) {
        setState(() {
          showloading = true;
          enablebutton = false;
        });
      } else if (state is LocationLoadingState) {
        setState(() {
          showloading = true;
          enablebutton = false;
        });
      } else if (state is LocationLoadedState) {
        setState(() {
          showloading = false;
          enablebutton = true;

          if (locations_list.length > 0) {
            locations_list.clear();
          }
          if (state.locations != null && state.locations.length > 0) {
            for (int i = 0; i < state.locations.length; i++) {
              if (state.locations[i].status == "1") {
                locations_list.add(state.locations[i]);
              }
            }

            if (nav_from_home) {
              for (int i = 0; i < locations_list.length; i++) {
                if (locations_list[i].location ==
                    _locationDetailslist[0].location) {
                  debugPrint(
                      "@@@ equate $i __________${_locationDetailslist[0].location}");
                  value = int.parse(locations_list[i].locationId);
                  selectedloctnID = locations_list[i].locationId;
                }
              }
            }
          } else {
            actualtext = "No Locations found";
          }
        });
      } else if (state is LocationErrorState) {
        setState(() {
          showloading = false;
          enablebutton = true;
        });
        _apputils.showtoast(context, state.message);
      } else if (state is SelectedLocationLoadedState) {
        setState(() {
          showloading = false;
        });
        if (state.locations != null && state.locations.length > 0) {
          nav(state.locations);
        }
      }
    }, child: BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        return buildlocationsList(locations_list);
      },
    ));
  }

  Widget buildlocationsList(List<LocationDetls> locations) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            locations_list.length > 0
                ? Container(
                    margin: EdgeInsets.all(16.0),
                    child: Stack(
                      children: <Widget>[
                        SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 0.0, top: 16.0, bottom: 16.0),
                                  child: Text(
                                    'Please Select Your Location',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        .apply(color: Colors.black45),
                                  )),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: locations_list.length,
                                itemBuilder: (context, index) {
                                  return RadioListTile(
                                    value: int.parse(
                                        locations_list[index].locationId),
                                    groupValue: value,
                                    title: Text(locations_list[index].location,
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .apply(
                                            color: locations_list[index].availability=="1"? Colors.black:Colors.black26,
                                                fontFamily: 'quicksand')),
                                    onChanged: locations_list[index].availability=="1"?(val) {
                                      setState(() {
                                        value = int.parse(
                                            locations_list[index].locationId);
                                        selectedloctnID =
                                            locations_list[index].locationId;
                                      });
                                    }:null,
                                    activeColor: Colors.red,
                                  );
                                },
                              ),
                            ])),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            padding: EdgeInsets.only(
                                left: 50.0,
                                top: 12.0,
                                right: 50.0,
                                bottom: 12.0),
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.transparent)),
                            onPressed: enablebutton
                                ? () async {
                                    if (selectedloctnID.isEmpty) {
                                      _apputils.showtoast(context,
                                          "Please Select your Location.");
                                    } else {
                                      bool isconnected =
                                          await _apputils.check();
                                      if (isconnected != null && isconnected) {
                                        setState(() {
                                          enablebutton = false;
                                          showloading = true;
                                        });
                                        _locationBloc.add(
                                            FetchSelectedLocationEvent(
                                                userID, selectedloctnID));
                                      } else {
                                        _apputils.showtoast(context,
                                            "Please make sure Network Connection is available");
                                      }
                                    }
                                  }
                                : null,
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
          ],
        ));
  }

  void nav(List<LocationDetls> locations) async {
    await _userPrefs.setLoggedIn(true);
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = locations.map((v) => v.toJson()).toList();
    await _userPrefs.setLoctndetls(jsonEncode(data['data']));
    if (nav_from_home) {
      Navigator.of(_buildContext).pop(true);
    } else {
      Navigator.of(_buildContext).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => HomePage()));
    }
  }

  Future getsaveddata() async {
    if (nav_from_home) {
      String locationdetails = await _userPrefs.getLoctndetls();
      if (locationdetails != null) {
        debugPrint(
            '@@@@ SAVED LOCATION DATA Selectlocation ${json.decode(locationdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(locationdetails)};
        setState(() {
          if (_locationDetailslist.length > 0) {
            _locationDetailslist.clear();
          }
          _locationDetailslist.addAll(List<LocationDetls>.from(
              mp['data'].map((x) => LocationDetls.fromJson(x))));
        });
      }
    }
    String userdetails = await _userPrefs.getUserdetls();
    if (userdetails != null) {
      debugPrint(
          '@@@@ SAVED USER DATA Selectlocation ${json.decode(userdetails)}');
      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        Map<String, dynamic> mp = {"data": json.decode(userdetails)};
        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
        userID = _userdatalist[0].userId;
        debugPrint('@@@@ USERID $userID');
      });
      Future.delayed(const Duration(milliseconds: 100), () async {
        bool isconnected = await _apputils.check();
        if (isconnected != null && isconnected) {
          _locationBloc.add(FetchLocationsEvent());
        } else {
          _apputils.showtoast(
              context, "Please make sure Network Connection is available");
        }
      });
    }
  }
}
