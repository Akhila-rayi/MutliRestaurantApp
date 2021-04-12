import 'dart:convert';
import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_bloc.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_event.dart';
import 'package:FarmToHome/bloc/deliveryAdrs/deliveryAdrs_state.dart';
import 'package:FarmToHome/data/model/deliveryAddr_response_model.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart';

class AddDeliveryAddrs extends StatefulWidget {
  String navfrom = "", fuladrs = "";
  Address adrs;

  AddDeliveryAddrs({Key key, @required this.navfrom, this.fuladrs, this.adrs})
      : super(key: key);

  @override
  AddDeliveryAddrsState createState() {
    return AddDeliveryAddrsState(navfrom, fuladrs, adrs);
  }
}

class AddDeliveryAddrsState extends State<AddDeliveryAddrs> {
  final _formKey = GlobalKey<FormState>();
  String navfrom,
      userID = "",
      fuladrs = "",
      city = "";
  Apputils _apputils = new Apputils();
  TextEditingController _editingController1 = new TextEditingController();
  TextEditingController _editingController2 = new TextEditingController();
  TextEditingController _editingController3 = new TextEditingController();
  TextEditingController _editingController4 = new TextEditingController();
  TextEditingController _editingController5 = new TextEditingController();
  TextEditingController _editingController6 = new TextEditingController();
  TextEditingController _editingController7 = new TextEditingController();
  TextEditingController _editingController8 = new TextEditingController();



  UserPrefs _userPrefs = new UserPrefs();
  List<UserData> _userdatalist = [];

  List<LocationDetls> _placedatalist = [];
  DeliveryAdrsBloc _deliveryAdrsBloc;
  var showloading = false;
  Address adrs;
  String fulladrswithName = "";
  Future saveddatafuture;

  AddDeliveryAddrsState(this.navfrom, this.fuladrs, this.adrs);

  @override
  void initState() {
    super.initState();
    _deliveryAdrsBloc = BlocProvider.of<DeliveryAdrsBloc>(context);
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
                "Address Info",
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

    return  BlocListener<DeliveryAdrsBloc, DeliveryAdrsState>(
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
          } else if (state is SubmitDeliveryAdrsLoadedState) {
            setState(() {
              showloading = false;
            });

            if (state.deliveryAdrsdata != null && state.deliveryAdrsdata.length > 0) {
              if (state.deliveryAdrsdata[0].addressId != null) {
                _apputils.showtoast(
                    context, "Address Added Successfully");
                nav(state.deliveryAdrsdata[0].addressId.toString() + "@" + fulladrswithName);
              } else {
                _apputils.showtoast(
                    context, "Cannot add Address. Please try again.");
              }
            }
          }
        }, child: BlocBuilder<DeliveryAdrsBloc, DeliveryAdrsState>(
      builder: (context, state) {
        return getchildScreen();
      },
    ));
  }
  void nav(String s) {
    Navigator.of(context).pop(s);
  }

  Widget getchildScreen() {
    return SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.all(16.0),
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: Stack(
              children: [
                Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Name',
                            style: TextStyle(
                                color: const Color(0xFF000080),
                                fontSize: 14.0,
                                fontFamily: 'quicksand',
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.start,
                          ),
                          TextFormField(
                              enabled: true,
                              textAlign: TextAlign.start,
                              controller: _editingController1,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              cursorWidth: 1.5,
                              cursorColor: Colors.redAccent,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                              validator: (value) {
                                return value.isEmpty
                                    ? 'Name is Required.'
                                    : null;
                              },
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)))),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            'Mobile',
                            style: TextStyle(
                                color: const Color(0xFF000080),
                                fontSize: 14.0,
                                fontFamily: 'quicksand',
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.start,
                          ),
                          TextFormField(
                              enabled: true,
                              textAlign: TextAlign.start,
                              controller: _editingController2,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              autofocus: false,
                              cursorWidth: 1.5,
                              cursorColor: Colors.redAccent,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                              validator: (value) {
                                return value.isEmpty
                                    ? 'Mobile Number is Required.'
                                    : null;
                              },
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)))),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            'House No./Flat No.',
                            style: TextStyle(
                                color: const Color(0xFF000080),
                                fontSize: 14.0,
                                fontFamily: 'quicksand',
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.start,
                          ),
                          TextFormField(

                              textAlign: TextAlign.start,
                              controller: _editingController3,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              cursorWidth: 1.5,
                              cursorColor: Colors.redAccent,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                              validator: (value) {
                                return value.isEmpty
                                    ? 'House No./Flat No. is Required.'
                                    : null;
                              },
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)))),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            'Street',
                            style: TextStyle(
                                color: const Color(0xFF000080),
                                fontSize: 14.0,
                                fontFamily: 'quicksand',
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.start,
                          ),
                          TextFormField(

                              textAlign: TextAlign.start,
                              controller: _editingController4,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              cursorWidth: 1.5,
                              cursorColor: Colors.redAccent,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                              validator: (value) {
                                return value.isEmpty
                                    ? 'Street is Required.'
                                    : null;
                              },
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)))),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            'City',
                            style: TextStyle(
                                color: const Color(0xFF000080),
                                fontSize: 14.0,
                                fontFamily: 'quicksand',
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.start,
                          ),
                          TextFormField(
                              readOnly: true,
                              textAlign: TextAlign.start,
                              controller: _editingController5,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              cursorWidth: 1.5,
                              cursorColor: Colors.redAccent,
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                              validator: (value) {
                                return value.isEmpty
                                    ? 'City is Required.'
                                    : null;
                              },
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)))),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            'State',
                            style: TextStyle(
                                color: const Color(0xFF000080),
                                fontSize: 14.0,
                                fontFamily: 'quicksand',
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.start,
                          ),
                          TextFormField(
                              readOnly: true,
                              textAlign: TextAlign.start,
                              controller: _editingController6,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              cursorWidth: 1.5,
                              cursorColor: Colors.redAccent,
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                              validator: (value) {
                                return value.isEmpty
                                    ? 'State is Required.'
                                    : null;
                              },
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)))),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            'Postal Code',
                            style: TextStyle(
                                color: const Color(0xFF000080),
                                fontSize: 14.0,
                                fontFamily: 'quicksand',
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.start,
                          ),
                          TextFormField(

                              readOnly: true,
                              textAlign: TextAlign.start,
                              controller: _editingController7,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              cursorWidth: 1.5,
                              cursorColor: Colors.redAccent,
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                              validator: (value) {
                                return value.isEmpty
                                    ? 'Postal Code is Required.'
                                    : null;
                              },
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)))),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            'Country',
                            style: TextStyle(
                                color: const Color(0xFF000080),
                                fontSize: 14.0,
                                fontFamily: 'quicksand',
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.start,
                          ),
                          TextFormField(
                              readOnly: true,
                              textAlign: TextAlign.start,
                              controller: _editingController8,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              cursorWidth: 1.5,
                              cursorColor: Colors.redAccent,
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                              validator: (value) {
                                return value.isEmpty
                                    ? 'Country is Required.'
                                    : null;
                              },
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38, width: 1.0)))),
                          SizedBox(
                            height: 16,
                          ),
                          RaisedButton(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            padding: EdgeInsets.all(12.0),
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(4.0),
                                side: BorderSide(color: Colors.transparent)),
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              final form = _formKey.currentState;
                              if (form.validate()) {
                                form.save();
                                var str_name = _editingController1.text
                                    .toString();
                                var str_mobile = _editingController2.text
                                    .toString();
                                var str_houseno = _editingController3.text
                                    .toString();
                                var str_street = _editingController4.text
                                    .toString();
                                var str_city = _editingController5.text
                                    .toString();
                                var str_state = _editingController6.text
                                    .toString();
                                var str_pincode = _editingController7.text
                                    .toString();
                                var str_country = _editingController8.text
                                    .toString();

                                var inputmap = new Map<String, String>();
                                inputmap["user_id"] = userID;
                                inputmap["name"] = str_name;
                                inputmap["mobile"] = str_mobile;
                                inputmap["street"] = str_street;
                                inputmap["hno"] = str_houseno;
                                inputmap["city"] = str_city;
                                inputmap["state"] = str_state;
                                inputmap["pincode"] = str_pincode;
                                debugPrint("@@@________" + jsonEncode(inputmap));
                                fulladrswithName = " $str_name, ${str_houseno}, ${str_street}, ${str_city}, $str_state, $str_pincode, $str_country";

                                /*
                                if (fulladrswithName == _editingController3.text.toString()) {
                                  var list = adrs.addressLine.split(",");
                                  inputmap["street"] = list[1] + "," + list[2];
                                  inputmap["hno"] = list[0];
                                  inputmap["city"] = city;
                                  inputmap["state"] = "Telangana";
                                  inputmap["pincode"] = adrs.postalCode;
                                  debugPrint("@@@________" + jsonEncode(
                                      inputmap));
                                  fulladrswithName =
                                  " $str_name, ${list[0]}, ${list[1]}, ${list[2]}, $city, Telangana, ${adrs
                                      .postalCode}, India";
                                } */

                                bool isconnected = await _apputils.check();
                                if (isconnected != null && isconnected) {
                                    _deliveryAdrsBloc
                                        .add(SubmitDeliveryAdrsEvent(inputmap));
                                  } else {
                                    _apputils.showtoast(context,
                                        "Please make sure Network Connection is available");
                                  }
                              }
                            },
                            child: Text(
                              'SUBMIT',
                              textAlign: TextAlign.center,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .button
                                  .apply(color: Colors.white),
                            ),
                          ),
                        ])),
                showloading ? _apputils.buildLoading(context) : Container()
              ],
            )));
  }

  Future getsaveddata() async {

    String userdetails = await _userPrefs.getUserdetls();
    if (userdetails != null) {
      debugPrint('@@@@ SAVED USER DATA adddelvryadrs ${json.decode(userdetails)}');
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
      if (_placedatalist.length > 0) {
        _placedatalist.clear();
      }
      debugPrint('@@@@ SAVED Selected place DATA ${json.decode(locdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(locdetails)};
      setState(() {
        _placedatalist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));
        setState(() {
          city = _placedatalist[0].location;
          userID = _userdatalist[0].userId;
          _editingController1.text = _userdatalist[0].name;
          _editingController2.text = _userdatalist[0].mobile;
          _editingController3.text =adrs.addressLine.split(",")[0];
          _editingController4.text = adrs.addressLine.split(",")[1]+","+adrs.addressLine.split(",")[2];
          _editingController5.text = city;
          _editingController6.text = adrs.adminArea;
          _editingController7.text = adrs.postalCode;
          _editingController8.text = adrs.countryName;

        });
      });

    }
  }
}
