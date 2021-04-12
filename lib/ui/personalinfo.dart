import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/profile/profile_bloc.dart';
import 'package:FarmToHome/bloc/profile/profile_event.dart';
import 'package:FarmToHome/bloc/profile/profile_state.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:FarmToHome/ui/homepage.dart';
import 'package:FarmToHome/ui/selectlocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalInfo extends StatefulWidget {
  bool nav_from_home = false;

  PersonalInfo({Key key, @required this.nav_from_home}) : super(key: key);

  @override
  PersonalInfoState createState() {
    return PersonalInfoState(nav_from_home);
  }
}

class PersonalInfoState extends State<PersonalInfo> {
  bool nav_from_home = false;
  BuildContext _buildContext;
  var actualtext = "",
      name = "",
      mobileno = "",
      emailadrs = "",
      referralcode = "";
  String userID = "";
  TextEditingController _editingController1 = new TextEditingController();
  TextEditingController _editingController2 = new TextEditingController();
  TextEditingController _editingController3 = new TextEditingController();
  TextEditingController _editingController4 = new TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Apputils _apputils = new Apputils();
  UserPrefs _userPrefs = new UserPrefs();
  ProfileBloc _profileBloc;
  List<UserData> _userdatalist = [];
  List<ProfileData> _profiledatalist = [];
  bool enablebuttn = true;
  var showloading = false;
  Future saveddatafuture;

  PersonalInfoState(this.nav_from_home);

  @override
  void initState() {
    super.initState();
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    saveddatafuture = getsaveddata();
  }

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Personal Info",
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .apply(color: Colors.white),
            ),
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
                  return getscafldscreen();
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

  Widget getscafldscreen() {
    return BlocListener<ProfileBloc, ProfileState>(listener: (context, state) {
      if (state is ProfileInitialState) {
        setState(() {
          showloading = true;
          enablebuttn = false;
        });
      } else if (state is ProfileLoadingState) {
        setState(() {
          showloading = true;
          enablebuttn = false;
        });
      } else if (state is ProfileLoadedState) {
        if (_profiledatalist.length > 0) {
          _profiledatalist.clear();
        }

        setState(() {
          showloading = false;
          enablebuttn = true;
          if (state.myprofile != null && state.myprofile.length > 0) {
            _profiledatalist.addAll(state.myprofile);
            _editingController1.text = _profiledatalist[0].name;
            _editingController2.text = _profiledatalist[0].mobile;
            _editingController3.text = _profiledatalist[0].email;
          } else {
            actualtext = "Cannot retrieve profile";
          }
        });
      } else if (state is EditProfileLoadedState) {
        setState(() {
          showloading = false;
          enablebuttn = true;
        });
        if (state.editprofilelist != null && state.editprofilelist.length > 0) {
          _apputils.showtoast(context, state.editprofilelist[0].alert);
          if (state.editprofilelist[0].alert
              .toLowerCase()
              .contains("updated")) {
            updateuserdetails();
          }
        }
      } else if (state is ProfileErrorState) {
        setState(() {
          showloading = false;
          enablebuttn = true;
        });
        _apputils.showtoast(context, state.message);
      }
    }, child: BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return getprofileScreen(_profiledatalist);
      },
    ));
  }

  Widget getprofileScreen(List<ProfileData> profiledatalist) {
    return SingleChildScrollView(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(children: <Widget>[
              (nav_from_home && _profiledatalist.length > 0) || !nav_from_home
                  ? Container(
                      margin: EdgeInsets.all(16.0),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Form(
                          key: _formKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Full Name',
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
                                    validator: (value) {
                                      return value.isEmpty
                                          ? 'Full Name is Required.'
                                          : null;
                                    },
                                    onSaved: (value) {
                                      return name = value;
                                    },
                                    cursorColor: Colors.redAccent,
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16.0,
                                        fontFamily: 'quicksand',
                                        fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                        counterText: "",
                                        contentPadding: EdgeInsets.only(
                                            top: 8.0, bottom: 8.0),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black,
                                                width: 2.0)),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black38,
                                                width: 2.0)))),
                                SizedBox(
                                  height: 16,
                                ),

                                Text(
                                  'Mobile Number',
                                  style: TextStyle(
                                      color: const Color(0xFF000080),
                                      fontSize: 14.0,
                                      fontFamily: 'quicksand',
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                TextFormField(
                                    textAlign: TextAlign.start,
                                    readOnly: true,
                                    controller: _editingController2,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.number,
                                    autofocus: false,
                                    cursorWidth: 1.5,
                                    validator: (value) {
                                      return value.isEmpty
                                          ? 'Mobile Number is Required.'
                                          : null;
                                    },
                                    onSaved: (value) {
                                      return mobileno = value;
                                    },
                                    cursorColor: Colors.redAccent,
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16.0,
                                        fontFamily: 'quicksand',
                                        fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                        filled: true,
                                        contentPadding: EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        fillColor: const Color(0x08000000),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide.none))),
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Email Address',
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
                                    controller: _editingController3,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.emailAddress,
                                    autofocus: false,
                                    cursorWidth: 1.5,
                                    cursorColor: Colors.redAccent,
                                    /* validator: (value) {
                                      return value.isEmpty
                                          ? 'Email Address is Required.'
                                          : null;
                                    },
                                    onSaved: (value) {
                                      return emailadrs = value;
                                    },*/
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16.0,
                                        fontFamily: 'quicksand',
                                        fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                        counterText: "",
                                        contentPadding: EdgeInsets.only(
                                            top: 8.0, bottom: 8.0),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black,
                                                width: 2.0)),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black38,
                                                width: 2.0)))),

                                SizedBox(
                                  height: 16,
                                ),
                                !nav_from_home
                                    ? Row(
                                        children: [
                                          Text(
                                            'Referral Code',
                                            style: TextStyle(
                                                color: const Color(0xFF000080),
                                                fontSize: 14.0,
                                                fontFamily: 'quicksand',
                                                fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.start,
                                          ),
                                          Text(
                                            '(optional)',
                                            style: TextStyle(
                                                color: const Color(0xFF000080),
                                                fontSize: 12.0,
                                                fontFamily: 'quicksand',
                                                fontWeight: FontWeight.w200),
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      )
                                    : Container(),
                                !nav_from_home
                                    ? TextFormField(
                                        enabled: true,
                                        textAlign: TextAlign.start,
                                        controller: _editingController4,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        keyboardType:
                                            TextInputType.text,
                                        autofocus: false,
                                        cursorWidth: 1.5,
                                        cursorColor: Colors.redAccent,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16.0,
                                            fontFamily: 'quicksand',
                                            fontWeight: FontWeight.w500),
                                        decoration: InputDecoration(
                                            counterText: "",
                                            contentPadding: EdgeInsets.only(
                                                top: 8.0, bottom: 8.0),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black,
                                                    width: 2.0)),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black38,
                                                    width: 2.0))))
                                    : Container(),

                                SizedBox(
                                  height: 16,
                                ),
                                RaisedButton(
                                  color: Theme.of(context).primaryColor,
                                  padding: EdgeInsets.all(12.0),
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(4.0),
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                  onPressed: enablebuttn
                                      ? () async {
                                          name = _editingController1.text
                                              .toString();
                                          mobileno = _editingController2.text
                                              .toString();
                                          emailadrs = _editingController3.text
                                              .toString();
                                          referralcode = _editingController4
                                              .text
                                              .toString();
                                          bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailadrs);

                                          /* if (name != null && name.isEmpty) {
                                            _apputils.showtoast(
                                              context, "Please Enter Name");
                                          } else if (emailadrs != null &&
                                              emailadrs.isEmpty) {
                                            _apputils.showtoast(context,
                                                "Please Enter Email address");
                                          } else if (!emailadrs.isEmpty &&
                                              !isvalidemail(emailadrs)) {
                                            _apputils.showtoast(context,
                                                "Please Enter valid Email address");
                                          }*/

                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          final form = _formKey.currentState;
                                          if (form.validate()) {
                                            form.save();

                                            if(emailadrs.isNotEmpty && !emailValid) {
                                             _apputils.showtoast(context, "Please Enter valid Email Address");
                                            }else{
                                              setState(() {
                                                showloading = true;
                                              });
                                              var inputmap =
                                              new Map<String, String>();
                                              inputmap["user_id"] = userID;
                                              inputmap["name"] = name;
                                              inputmap["mobile"] = mobileno;
                                              inputmap["email"] = emailadrs;
                                              inputmap["referralcode"] = referralcode;

                                              bool isconnected = await _apputils
                                                  .check();
                                              if (isconnected != null &&
                                                  isconnected) {
                                                _profileBloc.add(
                                                    SubmitProfileEvent(
                                                        inputmap));
                                              } else {
                                                _apputils.showtoast(context,
                                                    "Please make sure Network Connection is available");
                                              }
                                            }
                                          }
                                        }
                                      : null,
                                  child: Text(
                                    nav_from_home ? 'APPLY CHANGES' : 'SUBMIT',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        .apply(color: Colors.white),
                                  ),
                                ),
                                // Add TextFormFields and RaisedButton here.
                              ])),
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
            ])));
  }

  bool isvalidemail(String emailadrs) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailadrs);
    return emailValid;
  }

  void navtohome() {
    if (_userdatalist[0].restaurantPlace.isEmpty) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => SelectLocation(
                nav_from_home: false,
              )));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => HomePage()));
    }
  }

  void navback() {
    Navigator.of(_buildContext).pop(true);
  }

  void updateuserdetails() async {
    _userdatalist[0].name = _editingController1.text.toString();
    _userdatalist[0].mobile = _editingController2.text.toString();
    _userdatalist[0].email = _editingController3.text.toString();

    Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = _userdatalist.map((v) => v.toJson()).toList();
    await _userPrefs.setUserdetls(jsonEncode(data['data']));
    if (nav_from_home) {
      navback();
    } else {
      navtohome();
    }
  }

  Future getsaveddata() async {
    String str_userdata = await _userPrefs.getUserdetls();
    if (str_userdata != null) {
      debugPrint(
          '@@@@ SAVED USER DATA Personalinfo ${json.decode(str_userdata)}');
      Map<String, dynamic> mp = {"data": json.decode(str_userdata)};
      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
        userID = _userdatalist[0].userId;
        _editingController2.text = _userdatalist[0].mobile;
      });

      if (nav_from_home) {
        Future.delayed(const Duration(milliseconds: 100), () async {
          bool isconnected = await _apputils.check();
          if (isconnected != null && isconnected) {
            _profileBloc.add(FetchProfileEvent(userID));
          } else {
            _apputils.showtoast(
                context, "Please make sure Network Connection is available");
          }
        });
      }
    }
  }
}
