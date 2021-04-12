import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_bloc.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_event.dart';
import 'package:FarmToHome/bloc/appinfo/appinfo_state.dart';
import 'package:FarmToHome/data/model/farmersinfo_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Ourfarmers extends StatefulWidget {
  @override
  OurfarmersState createState() {
    return OurfarmersState();
  }
}

class OurfarmersState extends State<Ourfarmers> {
  AppInfoBloc _appInfoBloc;
  var showloading = false;
  Apputils _apputils = new Apputils();
  List<FarmersinfoData> _farmerslist = [];
  String actualtext = "";
  Future saveddatafuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appInfoBloc = BlocProvider.of<AppInfoBloc>(context);
    saveddatafuture = getsaveddata();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Know your Farmer",
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

  Widget getMainUI() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          _farmerslist.length > 0
              ? farmertitle()
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

  Widget farmertitle() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(0.0),
        itemCount: _farmerslist.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 270,
                  child: Card(
                      margin: EdgeInsets.all(8.0),
                      elevation: 6.0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                    child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    Image.network(
                                      _farmerslist[index].imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;

                                        return Padding(
                                            padding: EdgeInsets.all(24.0),
                                            child: Image.asset(
                                              "assets/images/logo_green.png",
                                              fit: BoxFit.fitHeight,
                                            ));
                                      },
                                    ),
                                  ],
                                )),
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(_farmerslist[index].title,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: const Color(0xFF000080),
                                          fontSize: 14.0,
                                          fontFamily: 'quicksand',
                                          fontWeight: FontWeight.w500)),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      _apputils.parseHtmlString(
                                          _farmerslist[index].description),
                                      textAlign: TextAlign.start,
                                      maxLines: 2,
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14.0,
                                          fontFamily: 'quicksand',
                                          fontWeight: FontWeight.w500),
                                    ))
                              ])))),
              onTap: () {
                showfulldescrptnDialog(context, _farmerslist[index].title,
                    _apputils.parseHtmlString(_farmerslist[index].description));
              });
        });
  }

  showfulldescrptnDialog(BuildContext context, String title, String descrptn) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              dismissProgrsdlg(context);
            },
            child: AlertDialog(
              title: Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .apply(color: Colors.red)),
              content: Text(descrptn,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .apply(color: Colors.black)),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    dismissProgrsdlg(context);
                  },
                  child: new Text('Close',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .apply(color: Theme.of(context).primaryColor)),
                ),
              ],
            ));
      },
    );
  }

  dismissProgrsdlg(context) {
    Navigator.of(context).pop();
  }

  Future getsaveddata() async {

    Future.delayed(const Duration(milliseconds: 100), () async {
    bool isconnected = await _apputils.check();
    if (isconnected != null && isconnected) {
      _appInfoBloc.add(FetchFarmersinfoEvent());
    } else {
      _apputils.showtoast(
          context, "Please make sure Network Connection is available");
    }});
  }

  Widget getPage() {

    return  BlocListener<AppInfoBloc, AppInfoState>(
        listener: (context, state) {
          if (state is AppInfoInitialState) {
            setState(() {
              showloading = true;
            });
          } else if (state is AppInfoLoadingState) {
            setState(() {
              showloading = true;
            });
          } else if (state is FetchFarmersinfoState) {
            setState(() {
              showloading = false;

              if (_farmerslist.length > 0) {
                _farmerslist.clear();
              }
              if (state.farmersinfodata != null &&
                  state.farmersinfodata.length > 0) {
                _farmerslist.addAll(state.farmersinfodata);
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
}
