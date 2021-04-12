import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_bloc.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_event.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_state.dart';
import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:FarmToHome/ui/addLocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

class ManageAddress extends StatefulWidget {
  @override
  ManageAddressState createState() {
    return ManageAddressState();
  }
}

class ManageAddressState extends State<ManageAddress> {
  Uint8List markerIcon1, markerIcon2;
  var showloading = false;
  UserPrefs _userPrefs = new UserPrefs();
  Apputils _apputils = new Apputils();
  List<UserData> _userdatalist = [];
  List<DeliveryAdrsData> deliveryAdrsdata = [];
  int _markerIdCounter = 0;

  DeliveryAdrsBloc _deliveryAdrsBloc;
  String userID = "", addrsID = "", useradrs = "";
  LatLng latlngpostn;
  Completer<GoogleMapController> _mapController = Completer();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  CameraPosition _cameraPosition;
  Future saveddatafuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _deliveryAdrsBloc = BlocProvider.of<DeliveryAdrsBloc>(context);
    saveddatafuture = getsaveddata();
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

  @override
  Widget build(BuildContext context) {
    getMarker();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Manage Address",
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
    return BlocListener<DeliveryAdrsBloc, DeliveryAdrsState>(
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

              setmarker(
                  "${deliveryAdrsdata[lastadrs].hno},${deliveryAdrsdata[lastadrs].street},"
                  "${deliveryAdrsdata[lastadrs].city},"
                  "${deliveryAdrsdata[lastadrs].state},${deliveryAdrsdata[lastadrs].pincode}, India");
            } else {
              navtoaddloc();
            }
          } else {
            navtoaddloc();
          }
        });
      }
    }, child: BlocBuilder<DeliveryAdrsBloc, DeliveryAdrsState>(
      builder: (context, state) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: getScreen(),
        );
      },
    ));
  }

  void navtoaddloc() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => Addlocation()));
  }

  void setmarker(String addrs) async {
    Coordinates coordinates = await getcoordinatesfromAddress(addrs);
    debugPrint("@@@@@@@@@@@@@ coordinates LATLNG ${coordinates}");

    if (addrs != null) {
      setState(() {
        var lat = coordinates.latitude;
        var lng = coordinates.longitude;
        latlngpostn = LatLng(lat, lng);
        _cameraPosition = CameraPosition(
          target: latlngpostn,
          zoom: 12.0,
        );
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
      });
    }
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

  Widget getScreen() {
    return latlngpostn != null
        ? Stack(
            children: [
              GoogleMap(
                markers: Set<Marker>.of(_markers.values),
                onMapCreated: _onMapCreated,
                initialCameraPosition: _cameraPosition,
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(
                              left: 16, top: 14, right: 16, bottom: 16),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          useradrs,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontFamily: 'quicksand',
                                              fontWeight: FontWeight.w500),
                                        ))),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    iconSize: 30,
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  Addlocation()))
                                          .then((value) {
                                        debugPrint(
                                            "@@@ ADRESS ID  %%%%%%%%%%%%%%___" +
                                                value);
                                        setState(() {
                                          showloading = false;
                                          if (value.toString().contains("@")) {
                                            addrsID =
                                                value.toString().split("@")[0];
                                            useradrs =
                                                value.toString().split("@")[1];
                                            var s = useradrs.replaceFirst(
                                                useradrs.split(",")[0] + ",",
                                                ""); // remove name
                                            setmarker(s);
                                          }
                                        });
                                      });
                                    })
                              ])),
                    ],
                  )),
              showloading ? _apputils.buildLoading(context) : Container()
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

  Future<Coordinates> getcoordinatesfromAddress(String query) async {
    final addresses = await Geocoder.google(AppStrings.googlemapskey)
        .findAddressesFromQuery(query);
    return addresses.first.coordinates;
  }

  Future getsaveddata() async {
    String userdetails = await _userPrefs.getUserdetls();
    if (userdetails != null) {
      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        debugPrint(
            '@@@@ SAVED USER DATA manageadrs ${json.decode(userdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(userdetails)};
        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
        userID = _userdatalist[0].userId;
        debugPrint('@@@@ USERID $userID');
      });
      Future.delayed(const Duration(milliseconds: 100), () async {
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        _deliveryAdrsBloc.add(FetchDeliveryAdrsEvent(userID));
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }});
    }
  }
}
