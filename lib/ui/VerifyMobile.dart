import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:FarmToHome/ui/personalinfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyMobile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VerifyMobileState();
  }
}

class VerifyMobileState extends State<VerifyMobile> {
  Future saveddatafuture;
  Apputils _apputils;
  var showloading = false;

  @override
  void initState() {
    super.initState();
    _apputils = new Apputils();
    saveddatafuture = getsaveddata();
  }

  Future getsaveddata() async {
    Future.delayed(const Duration(milliseconds: 100), () async {
      bool isconnected = await _apputils.check();
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
                "Verification",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(color: Colors.white,fontWeight: FontWeight.w500),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop');
                  })
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
    return AnimatedContainer(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        child: Stack(children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    margin: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '00',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(color: Colors.black),
                        ),
                        Text(
                          ':',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(color: Colors.black),
                        ),
                        Text(
                          '00',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(color: Colors.black),
                        ),
                        Text(
                          ' min',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(color: Colors.black),
                        ),
                        Expanded(
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Resend',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1.copyWith( color: Colors.green,fontWeight: FontWeight.w500 )
                              )),
                        )
                      ],
                    )),
                FlatButton(
                  height: 60,
                  color: Theme.of(context).primaryColor,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(0),
                      side: BorderSide(color: Colors.transparent)),
                  onPressed: () {


                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PersonalInfo(nav_from_home: true)));
                  },
                  child: Text(
                    'Continue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .apply(color: Colors.white),
                  ),
                ),
              ]),
          Container(
              margin: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    AppStrings.enterverification,
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    AppStrings.enterverificationcode,
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.start,
                  ),
                  Container(
                      height: 40,
                      child: TextFormField(
                          enabled: true,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.number,
                          autofocus: false,
                          cursorWidth: 1.5,
                          showCursor: true,
                          maxLength: 6,
                          cursorColor: Colors.redAccent,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              letterSpacing: 2.0,
                              color: Colors.black,
                              fontSize: 18.0,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                              counterText: "",
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black12, width: 1.5)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black12, width: 1.5))))),
                ],
              )),
          showloading ? _apputils.buildLoading(context) : Container()
        ]));
  }

}
