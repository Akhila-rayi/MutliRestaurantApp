import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_bloc.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_event.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_state.dart';
import 'package:FarmToHome/data/model/appinfo_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  PrivacyPolicyState createState() {
    return PrivacyPolicyState();
  }
}

class PrivacyPolicyState extends State<PrivacyPolicy> {
  AppInfoBloc _appInfoBloc;
  var showloading = false;
  Apputils _apputils = new Apputils();
  List<Appinfo_Data> _termslist = [];
  Future saveddatafuture;
  String actualtext = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appInfoBloc = BlocProvider.of<AppInfoBloc>(context);
    saveddatafuture = getsaveddata();

  }


  Future getsaveddata() async{

    Future.delayed(const Duration(milliseconds: 100), () async {
    bool isconnected = await _apputils.check();
    if (isconnected != null && isconnected) {
      _appInfoBloc.add(FetchPrivacypolicyEvent());

    } else {
      _apputils.showtoast(
          context, "Please make sure Network Connection is available");
    }});
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
                "Privacy Policy",
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
          } else if (state is FetchPrivacypolicyLoadedState) {
            setState(() {
              showloading = false;

              if (_termslist.length > 0) {
                _termslist.clear();
              }
              if (state.appinfodata != null &&
                  state.appinfodata.length > 0) {
                _termslist.addAll(state.appinfodata);
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
          _termslist.length > 0
              ? /*Text(
                  _apputils
                      .parseHtmlString(_termslist[0].description.toString()),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.teal.shade900,

                      fontSize: 16.0,
                      fontFamily: 'quicksand',
                      fontWeight: FontWeight.bold))
                      */
              ListView(padding: EdgeInsets.all(8.0), children: [
                  Html(data: _termslist[0].description.toString(), style: {
                    "body": Style(
                      fontSize: FontSize(14.0),fontFamily: 'quicksand'
                    ),
                  })
                ])
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
          showloading
              ? Center(child: _apputils.buildLoading(context))
              : Container()
        ]));
  }
}
