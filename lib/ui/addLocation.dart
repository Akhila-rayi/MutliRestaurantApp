import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_bloc.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_event.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_state.dart';
import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/ui/adddeliveryaddr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;

class Addlocation extends StatefulWidget {
  @override
  AddlocationState createState() {
    // TODO: implement createState
    return AddlocationState();
  }
}

class AddlocationState extends State<Addlocation> {

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  int _markerIdCounter = 0;
  Completer<GoogleMapController> _mapController = Completer();
  LocationData _locationData;
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LatLng latlngpostn;

  Uint8List markerIcon1, markerIcon2;
  Apputils _apputils = new Apputils();
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  UserPrefs userPrefs = new UserPrefs();
  var citylat, citylong;

  GoogleMapController mapController;
  String completeadrs = "";
  Address addrsinorder;
  List<LocationDetls> _locationDetailslist = [];
  UserPrefs _userPrefs = new UserPrefs();
  double radiuss;
  List<UserData> _userdatalist = [];
  FocusNode textFocusNode = new FocusNode();
  Future saveddatafuture;

  @override
  void initState() {
    super.initState();
    saveddatafuture = getsaveddata();
  }

  void runFirst() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    String addrs = await getSetAddress(
        Coordinates(_locationData.latitude, _locationData.longitude));

    if (addrs != null) {
      debugPrint("@@@@   ADDDRESS ${addrs}");
      setState(() {
        completeadrs = addrs;
        if (completeadrs.contains(_locationDetailslist[0].location)) {
          debugPrint("@@@   USERS CURRENTLOC");
          var lat = _locationData.latitude;
          var lng = _locationData.longitude;
          latlngpostn = new LatLng(lat, lng);
        } else {
          debugPrint("@@@  SELECTED LOC");
          latlngpostn = LatLng(citylat, citylong);
        }
      });
    }
  }

  Future<String> getSetAddress(Coordinates coordinates) async {
    final addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    addrsinorder = addresses.first;
    return addresses.first.addressLine;
  }

  Future<double> getDistance(double endLatitude, double endLongitude) async {
    double distanceInMeters = await GeolocatorPlatform.instance
        .distanceBetween(citylat, citylong, endLatitude, endLongitude);
    return distanceInMeters / 1000; // in kms
  }

  @override
  Widget build(BuildContext context) {
    getMarker();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Add Address",
                style: Theme
                    .of(context)
                    .textTheme
                    .headline5
                    .apply(color: Colors.white),
              ),
              backgroundColor: Theme
                  .of(context)
                  .primaryColor,
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
                                  color: Theme
                                      .of(context)
                                      .primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            )));
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return getScreen();
                  } else {
                    return Center(
                        child: Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: _apputils.buildLoading(context)));
                  }
                })));
  }

  Widget getScreen() {
    return latlngpostn != null
        ? Stack(
      children: [
        GoogleMap(
          markers: Set<Marker>.of(_markers.values),
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: latlngpostn,
            zoom: 12.0,
          ),
          myLocationEnabled: true,
          onCameraMove: (CameraPosition position) {
            if (_markers.length > 0) {
              latlngpostn = LatLng(
                  position.target.latitude, position.target.longitude);
              MarkerId markerId = MarkerId(_markerIdVal());
              Marker marker = _markers[markerId];
              Marker updatedMarker = marker.copyWith(
                positionParam: position.target,
              );

              setState(() {
                _markers[markerId] = updatedMarker;
              });
            }
          },
          onCameraIdle: () {
            changecamera(
                Coordinates(latlngpostn.latitude, latlngpostn.longitude));
          },
        ),
        /*PlacePicker(
                apiKey: "AIzaSyBkFi6wZtIK7ywR0vjYEuQyQKit7BEQb9k",
                // Put YOUR OWN KEY here.
                onPlacePicked: (result) {
                  print(result.adrAddress);
                  debugPrint("@@@@@@@@@@@@@ CHANGED ADDRESS ${(result.adrAddress)}");

                },
                initialPosition: LatLng(_locationData.latitude, _locationData.longitude),
                useCurrentLocation: true,
              ),*/
        Align(
          alignment: Alignment.topCenter,
          child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.only(
                      left: 16, top: 14, right: 60, bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30,
                      ),
                      Expanded(
                          child: completeadrs != null
                              ? Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                completeadrs,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontFamily: 'quicksand',
                                    fontWeight: FontWeight.w500),
                              ))
                              : Container())
                    ],
                  ))),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: RaisedButton(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  padding: EdgeInsets.only(
                      left: 50.0, top: 12.0, right: 50.0, bottom: 12.0),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.transparent)),
                  onPressed: () {
                    if (completeadrs.isEmpty) {
                      _apputils.showtoast(
                          context, "Please add Delivery address");
                    } else {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              AddDeliveryAddrs(
                                navfrom: "editDeliveryadrs",
                                fuladrs: completeadrs,
                                adrs: addrsinorder,
                              )))
                          .then((value) {
                        Navigator.of(context).pop(value);
                      });
                    }
                  },
                  child: Text(
                    'CONTINUE',
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .button
                        .apply(color: Colors.white),
                  ))),
        )
      ],
    )
        : Center(
      child: CircularProgressIndicator(
        strokeWidth: 5.0,
        backgroundColor: Colors.green,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    MarkerId markerId = MarkerId(_markerIdVal());
    Marker marker = Marker(
      icon: BitmapDescriptor.fromBytes(markerIcon2),
      markerId: markerId,
      position: latlngpostn,
      draggable: false,
    );
    setState(() {
      _markers[markerId] = marker;
    });

    Future.delayed(Duration(seconds: 1), () async {
      GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latlngpostn,
            zoom: 17.0,
          ),
        ),
      );
    });
  }

  String _markerIdVal({bool increment = false}) {
    String val = 'marker_id_$_markerIdCounter';
    if (increment) _markerIdCounter++;
    return val;
  }

  void changecamera(Coordinates coordinates) async {
    String addrs = await getSetAddress(coordinates);
    if (addrs != null) {
      debugPrint("@@@@@@@@@@@@@ CHANGED ADDRESS ${addrs}");
      setState(() {
        completeadrs = addrs;
      });
    }

    var distancev = await getDistance(
        coordinates.latitude, coordinates.longitude);
    if (distancev != null && distancev > radiuss) {
      Future.delayed(const Duration(milliseconds: 100), () {
        showMesgDialog(context);
      });
    } /*else if (distancev != null && distancev < radiuss) {
      if (distancev <= 5.0) {} else if (distancev > 5 && distancev < 8) {} else
      if (distancev >= 8 && distancev <= 12) {}
    }*/
  }

  showMesgDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              dismissProgrsdlg(context);
            },
            child: AlertDialog(
              // two buttons dialog
              title: new Text(
                'F2H',
                textAlign: TextAlign.center,
              ),
              content: new Text(
                  'Cannot deliver at the specified location. Please select other location',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .apply(color: Theme
                      .of(context)
                      .primaryColor)),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    setState(() {
                      completeadrs = "";
                    });
                    dismissProgrsdlg(context);
                  },
                  child: new Text('Ok Done!'),
                ),
              ],
            ));
      },
    );
  }

  dismissProgrsdlg(context) {
    Navigator.of(context).pop();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void getMarker() async {
    markerIcon1 = await getBytesFromAsset('assets/images/marker_loc.png', 150);
    setState(() {
      markerIcon2 = markerIcon1;
    });
  }

  Future getsaveddata() async {
    String userdetails = await _userPrefs.getUserdetls();
    if (userdetails != null) {
      debugPrint(
          '@@@@ SAVED USER DATA addlocation ${json.decode(userdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(userdetails)};
      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
      });
    }
    String locdetails = await _userPrefs.getLoctndetls();
    if (locdetails != null) {
      debugPrint(
          '@@@@ SAVED LOCATION DATA addlocation ${json.decode(locdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(locdetails)};
      setState(() {
        if (_locationDetailslist.length > 0) {
          _locationDetailslist.clear();
        }
        _locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));
        citylat = double.parse(_locationDetailslist[0].latitude);
        citylong = double.parse(_locationDetailslist[0].longitude);
        radiuss = double.parse(_locationDetailslist[0].radius);
      });
    }
    runFirst();
  }
}
