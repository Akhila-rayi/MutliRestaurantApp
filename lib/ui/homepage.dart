import 'dart:convert';

import 'package:FarmToHome/data/model/feedbackservices_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:FarmToHome/ui/faqsupport.dart';
import 'package:FarmToHome/ui/lifecycleEventhandler.dart';
import 'package:FarmToHome/ui/manageAddress.dart';
import 'package:FarmToHome/ui/mycouponslist.dart';
import 'package:FarmToHome/ui/ourfarmers.dart';
import 'package:FarmToHome/ui/provideorderfeedback.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:FarmToHome/LocalStorage/UserPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/Utils/DatabaseHelper.dart';
import 'package:FarmToHome/bloc/home/home_bloc.dart';
import 'package:FarmToHome/bloc/home/home_event.dart';
import 'package:FarmToHome/bloc/home/home_state.dart';
import 'package:FarmToHome/data/model/CartItemsModel.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/data/model/previousorders_response_model.dart';
import 'package:FarmToHome/ui/addLocation.dart';
import 'package:FarmToHome/ui/adddeliveryaddr.dart';
import 'package:FarmToHome/ui/cartItems.dart';
import 'package:FarmToHome/ui/aboutus.dart';
import 'package:FarmToHome/ui/contactus.dart';
import 'package:FarmToHome/ui/enter_mobile.dart';
import 'package:FarmToHome/ui/individual_category.dart';
import 'package:FarmToHome/ui/myfavouritespage.dart';
import 'package:FarmToHome/ui/searchproduct.dart';
import 'package:FarmToHome/ui/selectlocation.dart';
import 'package:FarmToHome/ui/webviewContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:need_resume/need_resume.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'personalinfo.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  var actualtext = "";
  List<HomeData> initialhomedata = [];
  List<UserData> _userdatalist = [];
  UserPrefs _userPrefs = new UserPrefs();

  List<LocationDetls> locationDetailslist = [];
  String userID = "", locationID = "", locationName = "";
  var addremoveFavIndex;
  HomeBloc homeBloc;
  Apputils _apputils = new Apputils();
  var showloading = false;
  List<Banners> bannerList = [];
  List<TodaySpecial> todaySpecialList = [];
  List<Categories> categoriesList = [];
  List<String> fdbcktype_list = ["Complaint", "Suggestion"];
  List<String> fdbcktitles_list = [];
  String helpItem = "";
  var helpid = 1;
  String _selectedfdbcktitle = "";
  TextEditingController _editingController1 = new TextEditingController();
  TextEditingController _editingController2 = new TextEditingController();
  var _selectedscreenIndex = 0;
  bool showCartdlg = false;
  List<CartItemsModel> _cartitemslist = [];
  AnimationController _animationController;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  SwiperController _swiperController;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<CartItemsModel> dbcartlist = [];
  var dbcartcount = 0;
  double totalcartprice = 0.0;
  var favcount = 0;
  List<Previousordersdetails> previousorderslist = [];
  var prevorderstext = "", feedbackservicestext = "";
  List<FeedbackservicesData> feedbackservicesData = [];
  Future saveddatafuture;
  var enabledropdwn = true;
  int updatefavcount = 0;

  /*@override
  void onResume() {
    super.onResume();
    debugPrint("@@@ ONR ESUME HOME");
    updatecartlist();
    refreshdbdata();
  }*/

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    super.initState();
    helpItem = fdbcktype_list[0];
    homeBloc = BlocProvider.of<HomeBloc>(context);
    saveddatafuture = getsaveddata();

    WidgetsBinding.instance
        .addObserver(LifecycleEventHandler(resumeCallBack: () async {
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        homeBloc.add(FetchHomeEvent(userID, locationID));
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }
    }));
  }

  void _runAnimation() async {
    for (int i = 0; i < 3; i++) {
      await _animationController.forward();
      await _animationController.reverse();
    }
  }

  void updatecartlist(String s) async {
    Database futuredab = await databaseHelper.database;
    List<CartItemsModel> _list = await databaseHelper.getCartitemslist();
    double dbtotalprice = await databaseHelper.gettotalprice();
    int dbfavcountval = await _userPrefs.getFavCount();

    if (dbcartlist.length > 0) {
      dbcartlist.clear();
    }
    if (_list != null) {
      setState(() {
        this.dbcartlist = _list;
        this.dbcartcount = _list.length;
        debugPrint("@@@@ Cartlistcount HOME" + dbcartcount.toString());
      });
    }

    if (dbtotalprice != null) {
      setState(() {
        totalcartprice = dbtotalprice;
      });
    }

    if (dbfavcountval != null) {
      debugPrint("@@@ userprefs favcount" + dbfavcountval.toString());
      setState(() {
        updatefavcount = dbfavcountval;
      });
    } else {
      setState(() {
        updatefavcount = favcount;
      });
    }

    if (s == "home") {
      Future.delayed(const Duration(milliseconds: 100), () async {
        bool isconnected = await _apputils.check();
        if (isconnected != null && isconnected) {
          homeBloc.add(FetchHomeEvent(userID, locationID));
        } else {
          _apputils.showtoast(
              context, "Please make sure Network Connection is available");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Theme.of(context).primaryColor,
    ));

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF009A00),
          buttonTheme: ButtonThemeData(buttonColor: const Color(0xFF009A00)),
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
        home: FutureBuilder(
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
                return getlistenerpage();
              } else {
                return Center(
                    child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: _apputils.buildLoading(context)));
              }
            }));
  }

  Widget getlistenerpage() {
    return WillPopScope(
        onWillPop: () {
          print('Backbutton pressed');
          if (_selectedscreenIndex != 0) {
            setState(() {
              _selectedscreenIndex = 0;
            });
            homeBloc.add(FetchHomeEvent(userID, locationID));

            /*if (_selectedscreenIndex == 1) {
              homeBloc.add(FetchPreviousordersEvent(userID));
            }
            if (_selectedscreenIndex == 2) {
              homeBloc.add(FetchfeedbackservicesEvent());
            }*/
          } else {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }

          return Future.value(false);
        },
        child: Scaffold(
            key: _key,
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    _key.currentState.openDrawer();
                  }),
              titleSpacing: 0,
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/logo2.png',
                      fit: BoxFit.fill,
                      width: 30,
                      height: 30,
                    ),
                    initialhomedata.length > 0 &&
                            initialhomedata[0].categories.length > 0
                        ? Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 12.0, top: 12.0, bottom: 12.0),
                                child: TextFormField(
                                    enabled: true,
                                    controller: _editingController1,
                                    textAlign: TextAlign.start,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    cursorWidth: 1.5,
                                    cursorColor: Colors.white,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontFamily: 'quicksand',
                                        fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                            icon: Icon(
                                              Icons.search,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              if (_editingController1.text
                                                  .toString()
                                                  .isNotEmpty) {
                                                nav_searchprdct(
                                                    context,
                                                    _editingController1.text
                                                        .toString());
                                              } else {
                                                _apputils.showtoast(context,
                                                    "Please Enter your text");
                                              }
                                            }),
                                        border: InputBorder.none,
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 2.0,
                                        )),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 2.0)),
                                        hintText: "What'd you like to eat?",
                                        hintStyle: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'quicksand',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                        contentPadding: EdgeInsets.all(0.0)))),
                          )
                        : Container()
                  ]),
              actions: <Widget>[
                updatefavcount <= 0
                    ? IconButton(
                        icon: Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 25,
                        ),
                        onPressed: () {
                          nav_Myfavourites(context);
                        },
                      )
                    : Stack(alignment: Alignment.centerRight, children: [
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 25,
                          ),
                          onPressed: () {
                            nav_Myfavourites(context);
                          },
                        ),
                        Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                                padding: EdgeInsets.only(top: 3.0, right: 5.0),
                                child: CircleAvatar(
                                    maxRadius: 10.0,
                                    backgroundColor: Colors.red,
                                    child: Center(
                                        child: Text(
                                      updatefavcount.toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          fontFamily: 'quicksand',
                                          fontWeight: FontWeight.bold),
                                    )))))
                      ]),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 3.0),
                      child: IconButton(
                          icon: Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () {
                            nav_Cartitems(context);
                          }),
                    ),
                    dbcartcount != 0
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                                padding: EdgeInsets.only(top: 3.0, right: 5.0),
                                child: CircleAvatar(
                                    maxRadius: 10.0,
                                    backgroundColor: Colors.red,
                                    child: Center(
                                        child: Text(
                                      dbcartcount.toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          fontFamily: 'quicksand',
                                          fontWeight: FontWeight.bold),
                                    )))))
                        : Container(),
                  ],
                )
              ],
            ),
            drawer: new Drawer(
                child: new ListView(
              padding: EdgeInsets.all(0.0),
              children: <Widget>[
                DrawerHeader(
                  padding: EdgeInsets.all(0.0),
                  margin: EdgeInsets.all(0.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    color: Theme.of(context).primaryColor,
                    child: Stack(
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 8.0,
                                        top: 8.0,
                                        right: 8.0,
                                        bottom: 0.0),
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        onPressed: () {
                                          _key.currentState.openEndDrawer();
                                        })),
                              ),
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Image.asset(
                                    'assets/images/logo_white.png',
                                    fit: BoxFit.fill,
                                  )),
                            ])
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.favorite_border,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    'My Favourites',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    _key.currentState.openEndDrawer();
                    nav_Myfavourites(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    'Change Location',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    _key.currentState.openEndDrawer();
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (BuildContext context) => SelectLocation(
                                  nav_from_home: true,
                                )))
                        .then((value) {
                      if (value == true) {
                        refreshlocationdetls();
                      }
                    });
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.supervisor_account,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    'Know your Farmer',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    _key.currentState.openEndDrawer();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => Ourfarmers()));
                  },
                ),
                /* ListTile(
                  leading: Icon(
                    Icons.card_giftcard,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    'Coupons',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    _key.currentState.openEndDrawer();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => MyCouponslist(nav_from_menu: true,)));
                  },
                ),*/
                ListTile(
                  leading: Icon(
                    Icons.share,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    'Share Referral Code',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    _key.currentState.openEndDrawer();
                    final RenderBox box = context.findRenderObject();
                    Share.share(shareMsg(),
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) & box.size);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    'About Us',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    _key.currentState.openEndDrawer();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => Aboutus()));
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.phone_in_talk,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    'Contact Us',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    _key.currentState.openEndDrawer();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => Contactus()));
                  },
                ),
              ],
            )),
            backgroundColor: Colors.transparent,
            body: BlocListener<HomeBloc, HomeState>(listener: (context, state) {
              if (state is HomeInitialState) {
                setState(() {
                  showloading = true;
                });
              } else if (state is HomeLoadingState) {
                setState(() {
                  showloading = true;
                });
              } else if (state is HomeErrorState) {
                setState(() {
                  showloading = false;
                });
                _apputils.showtoast(context, "Error: ${state.message}");
              } else if (state is HomeLoadedState) {
                setState(() {
                  showloading = false;

                  if (todaySpecialList.length > 0) {
                    todaySpecialList.clear();
                  }
                  if (bannerList.length > 0) {
                    bannerList.clear();
                  }
                  if (categoriesList.length > 0) {
                    categoriesList.clear();
                  }

                  if (_cartitemslist.length > 0) {
                    _cartitemslist.clear();
                  }
                  if (initialhomedata.length > 0) {
                    initialhomedata.clear();
                  }
                  if (locationDetailslist.length > 0) {
                    locationDetailslist.clear();
                  }
                  if (state.homedata != null && state.homedata.length > 0) {

                    if(state.homedata[0].branch!=null && state.homedata[0].branch.length>0 ){

                      if(state.homedata[0].branch[0].status=="0"){

                        actualtext = AppStrings.branchclosed;

                      }else{

                        initialhomedata.addAll(state.homedata);
                        updatelocationdetls();

                      }
                    }else{
                      actualtext = "No Data found";
                    }
                    /*if(state.homedata[0].availability!=null && state.homedata[0].availability=="1"){

                      initialhomedata.addAll(state.homedata);
                      updatelocationdetls();

                    }else{

                      actualtext = AppStrings.cannotacceptorder;
                    }*/

                  } else {
                    actualtext = "No Data found";
                  }
                });
              } else if (state is AddRemoveFavouriteLoadedState) {
                setState(() {
                  showloading = false;
                });

                if (state.favouriteData != null &&
                    state.favouriteData.length > 0) {
                  _apputils.showtoast(context, state.favouriteData[0].alert);

                  updatefavouritecount(state.favouriteData[0].favoriteCount);
                }
              } else if (state is PreviousordersLoadedState) {
                setState(() {
                  showloading = false;
                  if (previousorderslist.length > 0) {
                    previousorderslist.clear();
                  }
                  if (state.list != null && state.list.length > 0) {
                    previousorderslist.addAll(state.list);
                  } else {
                    prevorderstext = "You didn't make any orders yet!!";
                  }
                });
              } else if (state is SubmitFeedbackLoadedState) {
                setState(() {
                  showloading = false;
                });
                if (state.feedbckData != null && state.feedbckData.length > 0) {
                  _apputils.showtoast(context, state.feedbckData[0].alert);
                  setState(() {
                    helpItem = fdbcktype_list[0];
                    _editingController2.clear();
                  });
                }
              } else if (state is FetchFeedbackservicesLoadedState) {
                setState(() {
                  showloading = false;
                  if (feedbackservicesData.length > 0) {
                    feedbackservicesData.clear();
                  }
                  if (fdbcktitles_list.length > 0) {
                    fdbcktitles_list.clear();
                  }

                  if (state.feedbackservicesData != null &&
                      state.feedbackservicesData.length > 0) {
                    feedbackservicesData.addAll(state.feedbackservicesData);

                    if (feedbackservicesData[0].complaints.length > 0) {
                      // fdbcktitles_list.add("Select Title");
                      fdbcktitles_list
                          .addAll(feedbackservicesData[0].complaints);
                      _selectedfdbcktitle = fdbcktitles_list[0];
                      enabledropdwn = true;
                    } else {
                      enabledropdwn = false;
                      _selectedfdbcktitle = "None";
                    }
                  } else {
                    feedbackservicestext = "No Feedback Services found.";
                  }
                });
              } else if (state is FetchFavouritesLoadedState) {
                setState(() {
                  showloading = false;

                  if (state.myfavlist != null) {
                    setFavcount(state.myfavlist);
                  }
                });
              }
            }, child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return mainHome();
              },
            ))));
  }

  void nav_Cartitems(BuildContext context) {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new CartItems()),
    ).then((value) {
      updatecartlist("");
      refreshdbdata();

      if (_selectedscreenIndex != 0) {
        setState(() {
          _selectedscreenIndex = 0;
        });
        homeBloc.add(FetchHomeEvent(userID, locationID));
      }
      /*else{
        setState(() {

          for(int i=0;i<_cartitemslist.length;i++){
            if (_cartitemslist[i].isAdded=="true")
            {
              _cartitemslist[i].isAdded="false";
            }
          }
        });
      }*/
    });

    /*bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CartItems();
    }));

    if (result == true) {
      setState(() {
      updatecartlist();
      refreshdbdata();
      });
    }*/
  }

  void nav_searchprdct(BuildContext context, String query) async {
    _editingController1.text = "";
    FocusScope.of(context).requestFocus(FocusNode());
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SearchProduct(
        query: query,
      );
    }));

    //if (result == true) {
    FocusScope.of(context).requestFocus(FocusNode());
    updatecartlist("");
    refreshdbdata();
    // }
  }

  void nav_Myfavourites(BuildContext context) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MyFavouritespage();
    }));

    //if (result == true) {
    updatecartlist("");
    refreshdbdata();
    //}
    if (_selectedscreenIndex != 0) {
      setState(() {
        _selectedscreenIndex = 0;
      });
      homeBloc.add(FetchHomeEvent(userID, locationID));
    }
  }

  void nav_indvlcategory(BuildContext context, int index) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CategoryIndetail(
        title: categoriesList[index].titleMain,
        Categoryid: categoriesList[index].category,
      );
    }));

    //if (result == true) {
    updatecartlist("");
    refreshdbdata();
    //}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.stop();
    _swiperController.dispose();
    super.dispose();
  }

  refreshHomeData(List<HomeData> homedata) {
    setState(() {
      _swiperController = new SwiperController();
      //updatecartlist("home");

      debugPrint("@@@@ __________________ REFRESH WHOLE DATA");
      if (homedata != null && homedata.length > 0) {
        if (homedata[0].banners != null && homedata[0].banners.length > 0) {
          bannerList.addAll(homedata[0].banners);
        }
        if (homedata[0].todaySpecial != null &&
            homedata[0].todaySpecial.length > 0) {
          todaySpecialList.addAll(homedata[0].todaySpecial);
        }
        if (homedata[0].categories != null &&
            homedata[0].categories.length > 0) {
          categoriesList.addAll(homedata[0].categories);
        }

        if (homedata[0].branch != null && homedata[0].branch.length > 0) {
          locationDetailslist.addAll(homedata[0].branch);
          setState(() {
            locationName = locationDetailslist[0].location;
            locationID = locationDetailslist[0].locationId;
          });
        }

        for (int i = 0; i < todaySpecialList.length; i++) {
          var qnty = "";
          var str_isadded = "false";

          /*if (todaySpecialList[i].itemType.toLowerCase() == "kg") {
            qnty = "0.5";
          } else {
            qnty = todaySpecialList[i].quantity;
          }*/

          if (todaySpecialList[i].itemType.toLowerCase() == "kg" &&
              todaySpecialList[i].weight.toLowerCase().contains("g") &&
              !todaySpecialList[i].weight.toLowerCase().contains("k")) {
            double d =
                double.parse(getactualweight(todaySpecialList[i].weight)) /
                    1000.0;
            String s = d.toString();
            s = s.replaceAll(".0", "");
            qnty = s;
          } else {
            qnty = todaySpecialList[i].quantity;
          }

          if (dbcartlist.length > 0) {
            debugPrint("@@@@ __________________ REFRESH WHOLE DATA1111");

            for (int j = 0; j < dbcartlist.length; j++) {
              if (todaySpecialList[i].id == dbcartlist[j].id) {
                str_isadded = "true";
                qnty = dbcartlist[j].modifiedquantity;
                debugPrint("@@@@ __________________ REFRESH WHOLE DATA2222");
              }
            }
          }
          _cartitemslist.add(CartItemsModel(
              id: todaySpecialList[i].id,
              title: todaySpecialList[i].title,
              imageURL: todaySpecialList[i].imageURL,
              weight: todaySpecialList[i].weight,
              priceUnit: todaySpecialList[i].priceUnit,
              availability: todaySpecialList[i].availability.toString(),
              isFavorite: todaySpecialList[i].isFavorite.toString(),
              quantity: todaySpecialList[i].quantity,
              priceTotal: todaySpecialList[i].priceTotal.toString(),
              itemType: todaySpecialList[i].itemType,
              discount: todaySpecialList[i].discount,
              isAdded: str_isadded,
              priceAfterdiscount: todaySpecialList[i].priceTotal.toString(),
              modifiedquantity: qnty));
        }
      }
    });
  }

  Future<void> refreshhomedata() async {
    await homeBloc.add(FetchHomeEvent(userID, locationID));
    return null;
  }

  Widget mainHome() {

    return RefreshIndicator(
        onRefresh: refreshhomedata,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                    child: Container(
                        color: Colors.white,
                        child: Stack(
                          children: <Widget>[
                            initialhomedata.length > 0
                                ? getScreen(_selectedscreenIndex)
                                : Center(
                                    child: Text(
                                      actualtext,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 18.0,
                                          fontFamily: 'quicksand',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                            showCartdlg ? displayCartItems() : Container(),
                            showloading
                                ? _apputils.buildLoading(context)
                                : Container()
                          ],
                        ))),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomNavyBar(
                    selectedIndex: _selectedscreenIndex,
                    showElevation: true,
                    itemCornerRadius: 25,
                    curve: Curves.easeInBack,
                    onItemSelected: (index) => setState(() {
                      _selectedscreenIndex = index;

                      if (_selectedscreenIndex == 0) {
                        homeBloc.add(FetchHomeEvent(userID, locationID));
                      }
                      if (_selectedscreenIndex == 1) {
                        homeBloc.add(FetchPreviousordersEvent(userID));
                      }
                      if (_selectedscreenIndex == 2) {
                        homeBloc.add(FetchfeedbackservicesEvent());
                      }
                    }),
                    items: [
                      BottomNavyBarItem(
                        inactiveColor: Colors.black45,
                        textAlign: TextAlign.center,
                        icon: Icon(Icons.home),
                        title: Text('Home'),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      BottomNavyBarItem(
                        textAlign: TextAlign.center,
                        inactiveColor: Colors.black45,
                        icon: Icon(Icons.history),
                        title: Text('My Orders'),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      BottomNavyBarItem(
                        inactiveColor: Colors.black45,
                        textAlign: TextAlign.center,
                        icon: Icon(Icons.feedback),
                        title: Text('Support'),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      BottomNavyBarItem(
                        inactiveColor: Colors.black45,
                        textAlign: TextAlign.center,
                        icon: Icon(Icons.person),
                        title: Text('Account'),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }

  Widget getScreen(int indx) {
    switch (indx) {
      case 0:
        return homeScreen();
      case 1:
        return userOrdersScreen();
      case 2:
        return helpScreen();
      case 3:
        return userAccountScreen();
      default:
        return homeScreen();
    }
  }

  Widget homeScreen() {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
                  Widget>[
            Container(
              child: Swiperchild(
                key: UniqueKey(),
                list: bannerList,
                swiperController: _swiperController,
              ),
              height: 200,
            ),
            SizedBox(
              height: 8,
            ),
            /*Card(
              child: Row(
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0)),
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                              GestureDetector(
                                child: Text(
                                  'F2H \n ${locationName}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4
                                      .apply(color: Colors.white),
                                ),
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              SelectLocation(
                                                nav_from_home: true,
                                              )))
                                      .then((value) {
                                    if (value == true) {
                                      refreshlocationdetls();
                                    }
                                  });
                                },
                              )
                            ],
                          ))),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            child: TextFormField(
                                enabled: true,
                                controller: _editingController1,
                                textAlign: TextAlign.start,
                                textAlignVertical: TextAlignVertical.top,
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                cursorWidth: 1.5,
                                cursorColor: Colors.redAccent,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontFamily: 'quicksand',
                                    fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    */ /*suffixIcon: Icon(
                                  Icons.search,
                                  color: Colors.black54,
                                ),*/ /*
                                    hintText: "What'd you like to eat?",
                                    hintStyle: TextStyle(
                                        fontSize: 14.0,
                                        fontFamily: 'quicksand',
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500),
                                    contentPadding: EdgeInsets.all(0.0)))),
                        IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              nav_searchprdct(
                                  context, _editingController1.text.toString());
                            })
                      ],
                    ),
                  ))
                ],
              ),
              color: Colors.white,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            SizedBox(
              height: 16,
            ),*/
            todaySpecialList.length > 0
                ? Text(
                    'Today\'s Deals',
                    textAlign: TextAlign.left,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .apply(color: Colors.black),
                  )
                : Container(),
            todaySpecialList.length > 0
                ? Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.all(0.0),
                      itemCount: todaySpecialList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            width: 270,
                            height: 200,
                            child: Padding(
                                padding: EdgeInsets.only(top: 8.0, right: 8.0),
                                child: Card(
                                  elevation: 6.0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      /*side: BorderSide(
                                    color: Colors.black26, width: 1.0),*/
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Expanded(
                                          child: Stack(
                                        fit: StackFit.expand,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Image.network(
                                              todaySpecialList[index].imageURL,
                                              fit: BoxFit.fitHeight,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent
                                                          loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;

                                                return Padding(
                                                    padding:
                                                        EdgeInsets.all(24.0),
                                                    child: Image.asset(
                                                      "assets/images/logo_green.png",
                                                      fit: BoxFit.fitHeight,
                                                    ));
                                              },
                                            ),
                                          ),
                                          todaySpecialList[index].discount !=
                                                  "0%"
                                              ? Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color: Colors.red,
                                                              width: 1.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      0.0),
                                                        ),
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Text(
                                                              '${todaySpecialList[index].discount} Off',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .subtitle2
                                                                  .apply(
                                                                      color: Colors
                                                                          .red),
                                                            ))),
                                                  ))
                                              : Container()
                                        ],
                                      )),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 8.0, top: 8.0),
                                        child: Text(
                                          '${todaySpecialList[index].title}',
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2
                                              .apply(
                                                  color:
                                                      const Color(0xFF000080)),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 8.0, top: 4.0),
                                          child: Text(
                                            '${todaySpecialList[index].weight}',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Colors.black45,
                                                fontSize: 12.0,
                                                fontFamily: 'quicksand',
                                                fontWeight: FontWeight.w500),
                                          )),
                                      Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                todaySpecialList[index]
                                                            .discount !=
                                                        "0%"
                                                    ? Text(
                                                        "₹" +
                                                            double.parse(todaySpecialList[
                                                                        index]
                                                                    .priceTotal
                                                                    .toString())
                                                                .toString() +
                                                            " ",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14.0,
                                                            fontFamily:
                                                                'quicksand',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    : Container(),
                                                Text(
                                                  "₹" +
                                                      getdiscountprice(
                                                              double.parse(
                                                                  todaySpecialList[
                                                                          index]
                                                                      .priceTotal
                                                                      .toString()),
                                                              double.parse(
                                                                  todaySpecialList[
                                                                          index]
                                                                      .discount
                                                                      .substring(
                                                                          0,
                                                                          todaySpecialList[index].discount.length -
                                                                              1)),
                                                              index)
                                                          .toString(),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 14.0,
                                                      fontFamily: 'quicksand',
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Expanded(
                                                    child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 4.0),
                                                      child: GestureDetector(
                                                          child:
                                                              todaySpecialList[
                                                                          index]
                                                                      .isFavorite
                                                                  ? Icon(
                                                                      Icons
                                                                          .favorite,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 23,
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .favorite_border,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 23,
                                                                    ),
                                                          onTap: () async {
                                                            addremoveFavIndex =
                                                                index;

                                                            bool isconnected =
                                                                await _apputils
                                                                    .check();
                                                            if (isconnected !=
                                                                    null &&
                                                                isconnected) {
                                                              bool val =
                                                                  todaySpecialList[
                                                                          index]
                                                                      .isFavorite;
                                                              if (val ==
                                                                  false) {
                                                                debugPrint(
                                                                    "@@@ fav index111  on tapped $addremoveFavIndex");

                                                                homeBloc.add(
                                                                    AddRemoveFavouriteEvent(
                                                                        userID,
                                                                        todaySpecialList[index]
                                                                            .id,
                                                                        "1"));
                                                              } else {
                                                                debugPrint(
                                                                    "@@@ fav index222  on tapped $addremoveFavIndex");

                                                                homeBloc.add(
                                                                    AddRemoveFavouriteEvent(
                                                                        userID,
                                                                        todaySpecialList[index]
                                                                            .id,
                                                                        "0"));
                                                              }
                                                            } else {
                                                              _apputils.showtoast(
                                                                  context,
                                                                  "Please make sure Network Connection is available");
                                                            }
                                                          })),
                                                )),
                                                _cartitemslist[index].isAdded ==
                                                        "false"
                                                    ? GestureDetector(
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                    // border: Border.all(color: Color(0xFFDCDCDC), width: 2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6.0),
                                                                    color: Colors
                                                                        .red),
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            4.0),
                                                                child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      'Add',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              12.0,
                                                                          fontFamily:
                                                                              'quicksand',
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    Icon(
                                                                      Icons.add,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 15,
                                                                    )
                                                                  ],
                                                                ))),
                                                        onTap: () {
                                                          clickedaddtocart(
                                                              index);
                                                        },
                                                      )
                                                    : Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            onTap: () {
                                                              decrcountItem(
                                                                  index);
                                                            },
                                                            child: Icon(
                                                              Icons
                                                                  .remove_circle_outline,
                                                              color: Colors
                                                                  .black54,
                                                              size: 23,
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 4.0,
                                                                      right:
                                                                          4.0,
                                                                      top: 4.0,
                                                                      bottom:
                                                                          0.0),
                                                              child: Text(
                                                                _cartitemslist[
                                                                                index]
                                                                            .isAdded ==
                                                                        "true"
                                                                    ? showqnt(
                                                                        double.parse(_cartitemslist[index]
                                                                            .modifiedquantity),
                                                                        _cartitemslist[index]
                                                                            .weight,
                                                                        _cartitemslist[index]
                                                                            .itemType)
                                                                    : "",
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        15.0,
                                                                    fontFamily:
                                                                        'quicksand',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                              child: Icon(
                                                                Icons
                                                                    .add_circle_outline,
                                                                color: Colors
                                                                    .black54,
                                                                size: 23,
                                                              ),
                                                              onTap: () {
                                                                incrItemcount(
                                                                    index);
                                                              })
                                                        ],
                                                      )
                                              ]))
                                    ],
                                  ),
                                )));
                      },
                    ),
                  )
                : Container(),
            SizedBox(
              height: 16,
            ),
            categoriesList.length > 0
                ? Text(
                    'Categories',
                    textAlign: TextAlign.left,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .apply(color: Colors.black),
                  )
                : Container(),
            categoriesList.length > 0
                ? Column(
                    children: <Widget>[
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        crossAxisCount: 3,
                        children: List.generate(categoriesList.length, (index) {
                          return GestureDetector(
                            child: Card(
                                elevation: 0.0,
                                shape: RoundedRectangleBorder(
                                    side: new BorderSide(
                                        color: Colors.black26, width: 1.0),
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: Container(
                                  //height: 40,
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                          child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Image.network(
                                          categoriesList[index].imageUrl,
                                          fit: BoxFit.fitHeight,
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
                                      )),
                                      Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Text(
                                          categoriesList[index].titleMain,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2
                                              .apply(color: Colors.black),
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                            onTap: () {
                              nav_indvlcategory(context, index);
                            },
                          );
                        }),
                      )
                    ],
                  )
                : Container(),
          ]),
        ));
  }

  double getdiscountprice(double totalprice, double offpercent, int index) {
    double initval = (totalprice - ((offpercent / 100) * totalprice));
    double beforeround = num.parse(initval.toStringAsFixed(1)) * 2;
    double price = beforeround.ceil() / 2;
    _cartitemslist[index].priceAfterdiscount = price.toString();
    return price;
  }

  Widget getSwiper() {
    return bannerList.length > 0
        ? Swiper(
            loop: true,
            autoplay: true,
            itemCount: bannerList.length,
            viewportFraction: 0.8,
            scale: 0.85,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Card(
                            color: Colors.white,
                            elevation: 3,
                            semanticContainer: true,
                            // to cover image whole card
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                                //side: new BorderSide(color: Colors.black26, width: 1.0),
                                borderRadius: BorderRadius.circular(16.0)),
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                Image.network(
                                  bannerList[index].imageUrl,
                                  fit: BoxFit.fill,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;

                                    return Padding(
                                        padding: EdgeInsets.all(24.0),
                                        child: Image.asset(
                                          "assets/images/logo_green.png",
                                          fit: BoxFit.fitHeight,
                                        ));
                                  },
                                )
                              ],
                            )))
                  ]);
            },
            controller: _swiperController,
            control: SwiperControl(iconNext: null, iconPrevious: null),
            pagination: YourOwnPaginatipon(),
            onIndexChanged: (index) {
              //lastswipepos = index;
            },
          )
        : Container();
  }

  Widget userAccountScreen() {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: <Widget>[
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          Expanded(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Hi, ${_userdatalist[0].name}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontFamily: 'quicksand',
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '${_userdatalist[0].mobile}  *  ${_userdatalist[0].email} ',
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13.0,
                            fontFamily: 'quicksand',
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ))),
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Edit',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontFamily: 'quicksand',
                    fontWeight: FontWeight.w500),
              ),
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (BuildContext context) => PersonalInfo(
                            nav_from_home: true,
                          )))
                  .then((value) {
                if (value == true) {
                  refreshUserdetls();
                }
              });
            },
          ),
        ]),
        SizedBox(
          height: 4,
        ),
        Container(
          height: 1,
          color: Colors.black12,
        ),
        SizedBox(
          height: 24,
        ),
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.edit_location,
                  color: Colors.black38,
                  size: 23,
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Manage Address',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                )),
                Icon(
                  Icons.navigate_next,
                  color: Colors.black54,
                  size: 20,
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => ManageAddress()));
          },
        ),
        SizedBox(
          height: 8,
        ),
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.card_giftcard,
                  color: Colors.black38,
                  size: 20,
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Coupons',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                )),
                Icon(
                  Icons.navigate_next,
                  color: Colors.black54,
                  size: 20,
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => MyCouponslist(
                      nav_from_menu: true,
                    )));
          },
        ),
        SizedBox(
          height: 8,
        ),
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.help_outline,
                  color: Colors.black38,
                  size: 20,
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'FAQ\'s and Support',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                )),
                Icon(
                  Icons.navigate_next,
                  color: Colors.black54,
                  size: 20,
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => FAQSupport()));
          },
        ),
        SizedBox(
          height: 8,
        ),
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.exit_to_app,
                  color: Colors.black38,
                  size: 20,
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.w500),
                  ),
                )),
              ],
            ),
          ),
          onTap: () {
            logout();
          },
        ),
      ],
    );
  }

  Widget displayCartItems() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Wrap(
        children: <Widget>[
          Container(
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                //border: Border.all(color: Colors.blueAccent, width: 1.0),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        RotationTransition(
                            turns: Tween(begin: 0.0, end: -.1)
                                .chain(CurveTween(curve: Curves.elasticIn))
                                .animate(_animationController),
                            child: Icon(
                              Icons.shopping_basket,
                              color: Colors.white,
                              size: 30,
                            )),
                        SizedBox(
                          width: 16,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '₹' +
                                  totalcartprice.toString() +
                                  "( ${dbcartcount} Items)",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                            ),
                            /* Text(
                          '${dbcartcount} Items',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.w500),
                        )*/
                          ],
                        ),
                        Expanded(
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                child: Text(
                                  'View',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontFamily: 'quicksand',
                                      fontWeight: FontWeight.w500),
                                ),
                                onTap: () {
                                  nav_Cartitems(context);
                                },
                              )),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    nav_Cartitems(context);
                  }))
        ],
      ),
    );
  }

  Widget helpScreen() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          feedbackservicesData.length > 0
              ? SingleChildScrollView(
                  child: Container(
                  margin: EdgeInsets.all(16.0),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        "Feedback",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: const Color(0xFF000080),
                            fontSize: 16.0,
                            fontFamily: 'quicksand',
                            fontWeight: FontWeight.w500),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              width: 30,
                              child: Radio(
                                activeColor: Colors.red,
                                value: 1,
                                groupValue: helpid,
                                onChanged: (val) {
                                  /*  if(val) {
                                    setState(() {
                                      helpItem = fdbcktype_list[0];
                                      helpid = 1;
                                      if (fdbcktitles_list.length > 0) {
                                        fdbcktitles_list.clear();
                                      }
                                      //fdbcktitles_list.add("Select Title");
                                      fdbcktitles_list.addAll(
                                          feedbackservicesData[0].complaints);
                                      _selectedfdbcktitle = fdbcktitles_list[0];
                                    });
                                  }*/
                                },
                              )),
                          GestureDetector(
                              child: Text(
                                fdbcktype_list[0],
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16.0,
                                    fontFamily: 'quicksand',
                                    fontWeight: FontWeight.w500),
                              ),
                              onTap: () {
                                setState(() {
                                  helpItem = fdbcktype_list[0];
                                  helpid = 1;
                                  if (fdbcktitles_list.length > 0) {
                                    fdbcktitles_list.clear();
                                  }
                                  if (feedbackservicesData[0]
                                          .complaints
                                          .length >
                                      0) {
                                    // fdbcktitles_list.add("Select Title");
                                    fdbcktitles_list.addAll(
                                        feedbackservicesData[0].complaints);
                                    _selectedfdbcktitle = fdbcktitles_list[0];
                                    enabledropdwn = true;
                                  } else {
                                    enabledropdwn = false;
                                    _selectedfdbcktitle = "None";
                                  }
                                });
                              }),
                          SizedBox(
                            width: 16,
                          ),
                          Container(
                              width: 30,
                              child: Radio(
                                activeColor: Colors.red,
                                value: 2,
                                groupValue: helpid,
                                onChanged: (val) {
                                  /*   if(val) {
                                    setState(() {
                                      helpItem = fdbcktype_list[1];
                                      helpid = 2;
                                      if (fdbcktitles_list.length > 0) {
                                        fdbcktitles_list.clear();
                                      }
                                      //fdbcktitles_list.add("Select Title");
                                      fdbcktitles_list.addAll(
                                          feedbackservicesData[0].suggestions);
                                      _selectedfdbcktitle = fdbcktitles_list[0];
                                    });
                                  }*/
                                },
                              )),
                          GestureDetector(
                              child: Text(fdbcktype_list[1],
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16.0,
                                      fontFamily: 'quicksand',
                                      fontWeight: FontWeight.w500)),
                              onTap: () {
                                setState(() {
                                  helpItem = fdbcktype_list[1];
                                  helpid = 2;
                                  if (fdbcktitles_list.length > 0) {
                                    fdbcktitles_list.clear();
                                  }
                                  if (feedbackservicesData[0]
                                          .suggestions
                                          .length >
                                      0) {
                                    //fdbcktitles_list.add("Select Title");
                                    fdbcktitles_list.addAll(
                                        feedbackservicesData[0].suggestions);
                                    _selectedfdbcktitle = fdbcktitles_list[0];
                                    enabledropdwn = true;
                                  } else {
                                    enabledropdwn = false;
                                    _selectedfdbcktitle = "None";
                                  }
                                });
                              }),
                        ],
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      enabledropdwn
                          ? Text(
                              "Title",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: const Color(0xFF000080),
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                            )
                          : Container(),
                      SizedBox(
                        height: 4.0,
                      ),
                      enabledropdwn
                          ? Container(
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                      color: Colors.black38),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                ),
                              ),
                              child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 12.0, right: 12.0),
                                  child: DropdownButton(
                                    underline: Container(),
                                    elevation: 0,
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 15.0,
                                        fontFamily: 'quicksand',
                                        fontWeight: FontWeight.w500),
                                    isExpanded: true,
                                    hint: Text('Select Title'),
                                    value: _selectedfdbcktitle,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedfdbcktitle = newValue;
                                      });
                                    },
                                    items: fdbcktitles_list.map((fdbcktitle) {
                                      return DropdownMenuItem(
                                        child: Text(
                                          fdbcktitle,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 15.0,
                                              fontFamily: 'quicksand',
                                              fontWeight: FontWeight.w500),
                                        ),
                                        value: fdbcktitle,
                                      );
                                    }).toList(),
                                  )))
                          : Container(),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        "Message",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: const Color(0xFF000080),
                            fontSize: 16.0,
                            fontFamily: 'quicksand',
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      TextFormField(
                          enabled: true,
                          controller: _editingController2,
                          maxLength: 250,
                          maxLines: 6,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          textAlign: TextAlign.start,
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
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black38, width: 1.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black38, width: 1.0)),
                              hintText: "Enter Message",
                              hintStyle: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                              contentPadding: EdgeInsets.all(16.0))),
                      SizedBox(
                        height: 8.0,
                      ),
                      RaisedButton(
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.all(8.0),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(4.0),
                            side: BorderSide(color: Colors.transparent)),
                        onPressed: () {
                          String msg = _editingController2.text.toString();
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (_selectedfdbcktitle.contains("Select Title")) {
                            _apputils.showtoast(
                                context, "Please select feedback Title");
                          } else if (msg.isEmpty) {
                            _apputils.showtoast(
                                context, "Please describe something....");
                          } else {
                            var feedbackMap = new Map<String, String>();
                            feedbackMap['user_id'] = userID;
                            feedbackMap['locationId'] = locationID;
                            feedbackMap['type'] = helpItem;
                            feedbackMap['title'] = _selectedfdbcktitle;
                            feedbackMap['message'] = msg;
                            debugPrint("@@@  FEEDBACK EVENT HIT" +
                                jsonEncode(feedbackMap));
                            homeBloc.add(SubmitFeedbackEvent(feedbackMap));
                          }
                        },
                        child: Text(
                          'SUBMIT',
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .apply(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ))
              : Center(
                  child: Text(
                    feedbackservicestext,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 18.0,
                        fontFamily: 'quicksand',
                        fontWeight: FontWeight.bold),
                  ),
                ),
          showloading ? _apputils.buildLoading(context) : Container()
        ]));
  }

  Widget userOrdersScreen() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            previousorderslist.length > 0
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: (MediaQuery.of(context).size.height),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.all(0.0),
                      itemCount: previousorderslist.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            // height: previousorderslist[index].orderItems.length * 30 + 95.0,
                            child: Card(
                          margin: EdgeInsets.all(8.0),
                          elevation: 3.0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Order ID: ",
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            .apply(color: Colors.black),
                                      ),
                                      Text(
                                        previousorderslist[index].orderId,
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .apply(color: Colors.red),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  getOrdereditemslist(
                                      previousorderslist[index].orderItems),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                  Container(
                                    color: Colors.black26,
                                    height: 1.5,
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Total Price: ",
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .apply(color: Colors.black45),
                                      ),
                                      Expanded(
                                        child: Text(
                                          getTotalprice(index),
                                          textAlign: TextAlign.start,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .apply(color: Colors.red),
                                        ),
                                      ),
                                      Text(
                                        _apputils.reformatDate(
                                                previousorderslist[index]
                                                    .orderDate
                                                    .toString()
                                                    .split(" ")[0]) +
                                            " " +
                                            _apputils.twelvehrformat_time(
                                                previousorderslist[index]
                                                    .orderDate
                                                    .toString()
                                                    .split(" ")[1]),
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .apply(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Status: ",
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .apply(color: Colors.black45),
                                      ),
                                      Expanded(
                                          child: Text(
                                        previousorderslist[index]
                                            .orderStatus
                                            .toString(),
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .apply(
                                                color: getStatuscolor(
                                                    previousorderslist[index]
                                                        .orderStatus
                                                        .toString())),
                                      )),
                                      previousorderslist[index].feedback == 0 &&
                                              previousorderslist[index]
                                                  .orderStatus
                                                  .toLowerCase()
                                                  .contains("delivered")
                                          ? RaisedButton(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              padding: EdgeInsets.all(5.0),
                                              shape: new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          5.0),
                                                  side: BorderSide(
                                                      color:
                                                          Colors.transparent)),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            ProvideOrder_Feedback(
                                                              previousordersdetails:
                                                                  previousorderslist[
                                                                      index],
                                                            )))
                                                    .then((value) {
                                                  debugPrint(
                                                      "@@@ orderfeedback response value--> $value");
                                                  if (value == 1) {
                                                    setState(() {
                                                      previousorderslist[index]
                                                          .feedback = value;
                                                    });
                                                  }
                                                });
                                              },
                                              child: Text(
                                                'Order Complaints',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4
                                                    .apply(color: Colors.white),
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                ],
                              )),
                        ));
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      prevorderstext,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18.0,
                          fontFamily: 'quicksand',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
            showloading ? _apputils.buildLoading(context) : Container()
          ],
        ));
  }

  Widget getOrdereditemslist(List<OrderItems> orderItems) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(0.0),
      itemCount: orderItems.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 25,
                    child: Text(
                      "${index + 1}. ",
                      textAlign: TextAlign.start,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .apply(color: Colors.green),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                        orderItems[index].title +
                            " (" +
                            orderItems[index].weight +
                            " x " +
                            orderItems[index].cartCount +
                            ")",
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .apply(color: Colors.green)),
                  )),
                  Align(
                      alignment: Alignment.center,
                      child: Text(
                        "₹" +
                            getindvlorderdiscountprice(
                                    double.parse(orderItems[index].priceTotal),
                                    double.parse(orderItems[index].cartCount),
                                    double.parse(orderItems[index].discount))
                                .toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .apply(color: Colors.red),
                      ))
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void decrcountItem(int index) {

    if (locationDetailslist[0].availability == "0" || !_apputils.allowOrder(locationDetailslist[0])) {
      _apputils.showNoticeDialog(context, AppStrings.cannotacceptorder);
    } else {
        double itemwght = double.parse(_cartitemslist[index].modifiedquantity);

        setState(() {
          if (_cartitemslist[index].itemType.toLowerCase() != "kg") {
            if (itemwght > 1) {
              itemwght -= 1;
              _cartitemslist[index].modifiedquantity = itemwght.toString();

              for (int i = 0; i < _cartitemslist.length; i++) {
                if (_cartitemslist[i].isAdded == "true") {
                  _saveorupdate(_cartitemslist[i]);
                }
              }
            } else {
              // remove from cartitemslist
              _cartitemslist[index].isAdded = "false";
              _delete(_cartitemslist[index]);
            }
          } else {
            /*if (itemwght >= 1) {
            itemwght -= 0.5;
            _cartitemslist[index].modifiedquantity = itemwght.toString();

            for (int i = 0; i < _cartitemslist.length; i++) {
              if (_cartitemslist[i].isAdded == "true") {
                _saveorupdate(_cartitemslist[i]);
              }
            }
          } else {
            // remove from cartitemslist
            _cartitemslist[index].isAdded = "false";
            _delete(_cartitemslist[index]);
          }*/

            if (_cartitemslist[index].weight.toLowerCase().contains("kg")) {
              if (itemwght >= 2) {
                itemwght -= 1;
                _cartitemslist[index].modifiedquantity = itemwght.toString();

                for (int i = 0; i < _cartitemslist.length; i++) {
                  if (_cartitemslist[i].isAdded == "true") {
                    _saveorupdate(_cartitemslist[i]);
                  }
                }
              } else {
                _cartitemslist[index].isAdded = "false";
                _delete(_cartitemslist[index]);
              }
            } else {
              double actaulwt = itemwght * 1000;
              if (actaulwt >=
                  (double.parse(getactualweight(_cartitemslist[index].weight)) *
                      2)) {
                actaulwt -=
                    double.parse(getactualweight(_cartitemslist[index].weight));
                _cartitemslist[index].modifiedquantity =
                    (actaulwt / 1000.0).toString();

                for (int i = 0; i < _cartitemslist.length; i++) {
                  if (_cartitemslist[i].isAdded == "true") {
                    _saveorupdate(_cartitemslist[i]);
                  }
                }
              } else {
                _cartitemslist[index].isAdded = "false";
                _delete(_cartitemslist[index]);
              }
            }

            /* if (itemwght >= 2) {
            itemwght -= 1;
            _cartitemslist[index].modifiedquantity = itemwght.toString();

            for (int i = 0; i < _cartitemslist.length; i++) {
              if (_cartitemslist[i].isAdded == "true") {
                _saveorupdate(_cartitemslist[i]);
              }
            }
          } else {
            // remove from cartitemslist
            _cartitemslist[index].isAdded = "false";
            _delete(_cartitemslist[index]);
          }
        }*/

          }
          refreshdbdata();
        });

    }
  }

  void incrItemcount(int index) {

    if (locationDetailslist[0].availability == "0" || !_apputils.allowOrder(locationDetailslist[0])) {

      _apputils.showNoticeDialog(context, AppStrings.cannotacceptorder);

    } else {

        double itemwght = double.parse(_cartitemslist[index].modifiedquantity);

        setState(() {
          if (_cartitemslist[index].itemType.toLowerCase() != "kg") {
            itemwght += 1;
            _cartitemslist[index].modifiedquantity = itemwght.toString();
          } else {
            // itemwght += 0.5;

            if (_cartitemslist[index].weight.toLowerCase().contains("kg")) {
              itemwght += 1;
              _cartitemslist[index].modifiedquantity = itemwght.toString();
            } else {
              double actaulwt = itemwght * 1000;
              actaulwt +=
                  double.parse(getactualweight(_cartitemslist[index].weight));
              _cartitemslist[index].modifiedquantity =
                  (actaulwt / 1000.0).toString();
            }

            /*itemwght += 1;
          _cartitemslist[index].modifiedquantity = itemwght.toString();*/
          }

          for (int i = 0; i < _cartitemslist.length; i++) {
            if (_cartitemslist[i].isAdded == "true") {
              _saveorupdate(_cartitemslist[i]);
            }
          }
        });

    }
  }

  void clickedaddtocart(int index) {
    if (locationDetailslist[0].availability == "0"|| !_apputils.allowOrder(locationDetailslist[0])) {
      _apputils.showNoticeDialog(context, AppStrings.cannotacceptorder);
    } else {
        setState(() {
          _cartitemslist[index].isAdded = "true";

          for (int i = 0; i < _cartitemslist.length; i++) {
            if (_cartitemslist[i].isAdded == "true") {
              _saveorupdate(_cartitemslist[i]);
            }
          }
        });

    }
  }

  void _saveorupdate(CartItemsModel cartItemsModel) async {
    int result;
    var res = await databaseHelper.getCartitembyid(cartItemsModel.id);
    if (res == null) {
      result = await databaseHelper.insertCartitem(cartItemsModel);
    } else {
      result = await databaseHelper.updatCartItem(cartItemsModel);
    }
    if (result != 0) {
      debugPrint("@@@ SUCESS DB OPERATN");
      refreshdbdata();
    } else {
      debugPrint("@@@ FAILURE DB OPERATN");
    }
  }

  void refreshdbdata() async {
    debugPrint("@@@ home___refresh cart count");
    double totalpriceval = await databaseHelper.gettotalprice();
    int cartcountval = await databaseHelper.gettotalcartcount();

    if (totalpriceval != null) {
      setState(() {
        totalcartprice = totalpriceval;
      });
    }

    if (cartcountval != null) {
      setState(() {
        dbcartcount = cartcountval;
        if (totalcartprice > 0.0) {
          showCartdlg = true;
          _runAnimation();
        } else {
          showCartdlg = false;
        }
      });
    }
  }

  void _delete(CartItemsModel cartItemsModel) async {
    int result = await databaseHelper.deleteCartItem(cartItemsModel.id);
    if (result != 0) {
      debugPrint("@@@ SUCESS DELETE DB OPERATN");
      refreshdbdata();
    } else {
      debugPrint("@@@ FAILURE DELETE DB OPERATN");
    }
  }

  void logout() async {
    _apputils.showtoast(context, "Signing out...");
    await databaseHelper.deletetable();
    await _userPrefs.setIsEnteredmobileNo(false);
    await _userPrefs.setMobileNo("");
    await _userPrefs.setLoggedIn(false);
    _key.currentState.openEndDrawer();
    //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => EnterMobile()));
  }



  void refreshlocationdetls() async {
    String locdetails = await _userPrefs.getLoctndetls();
    if (locdetails != null) {
      debugPrint('@@@@ SAVED LOCATION DATA home ${json.decode(locdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(locdetails)};
      setState(() {
        if (locationDetailslist.length > 0) {
          locationDetailslist.clear();
        }
        locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));
        locationName = locationDetailslist[0].location;
        locationID = locationDetailslist[0].locationId;
        debugPrint('@@@@ locationName____ $locationName');
        debugPrint('@@@@ LocationID $locationID');
      });

      await databaseHelper.deletetable();

      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        homeBloc.add(FetchFavouritesEvent(userID));
        if (_selectedscreenIndex != 0) {
          setState(() {
            _selectedscreenIndex = 0;
          });
        }
        homeBloc.add(FetchHomeEvent(userID, locationID));
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }
    }
  }

  void refreshUserdetls() async {
    String userdetails = await _userPrefs.getUserdetls();
    if (userdetails != null) {
      debugPrint('@@@@ SAVED USER DATA home ${json.decode(userdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(userdetails)};
      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
        userID = _userdatalist[0].userId;
        favcount = _userdatalist[0].favoriteCount;
      });
    }
  }

  void updatelocationdetls() async {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = initialhomedata[0].branch.map((v) => v.toJson()).toList();
    bool res = await _userPrefs.setLoctndetls(jsonEncode(data['data']));
    if (res) {
      refreshHomeData(initialhomedata);
    }
  }

  void updatefavouritecount(int favoriteCount) async {
    await _userPrefs.setFavCount(favoriteCount);
    setState(() {
      debugPrint("@@@ fav index $addremoveFavIndex");
      todaySpecialList[addremoveFavIndex].isFavorite =
          !todaySpecialList[addremoveFavIndex].isFavorite;
      if (todaySpecialList[addremoveFavIndex].isFavorite) {
        updatefavcount += 1;
      } else {
        updatefavcount -= 1;
      }
    });
  }

  Future getsaveddata() async {
    String locdetails = await _userPrefs.getLoctndetls();
    if (locdetails != null) {
      debugPrint('@@@@ SAVED LOCATION DATA home ${json.decode(locdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(locdetails)};
      setState(() {
        if (locationDetailslist.length > 0) {
          locationDetailslist.clear();
        }
        locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));
        locationName = locationDetailslist[0].location;
        locationID = locationDetailslist[0].locationId;
        debugPrint('@@@@ locationName____ $locationName');
        debugPrint('@@@@ LocationID $locationID');
      });
    }

    String userdetails = await _userPrefs.getUserdetls();
    if (userdetails != null) {
      debugPrint('@@@@ SAVED USER DATA home ${json.decode(userdetails)}');
      Map<String, dynamic> mp = {"data": json.decode(userdetails)};
      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
        userID = _userdatalist[0].userId;
        favcount = _userdatalist[0].favoriteCount;
      });
    }

    updatecartlist("home");
  }

  void setFavcount(List<TodaySpecial> myfavlist) async {
    await _userPrefs.setFavCount(myfavlist.length);
  }

  double getindvlorderdiscountprice(
      double totalprice, double quantity, double offpercent) {
    double initval =
        (quantity * totalprice - ((offpercent / 100) * quantity * totalprice));
    double beforeround = num.parse(initval.toStringAsFixed(1)) * 2;
    double price = beforeround.ceil() / 2;
    return price;
  }

  String getTotalprice(int index) {
    double beforeround = num.parse(
            double.parse(previousorderslist[index].orderTotal)
                .toStringAsFixed(1)) *
        2;
    double price = beforeround.ceil() / 2;
    return "₹ $price";
  }

  Color getStatuscolor(String string) {
    if (string.toLowerCase().contains("cancelled")) {
      return Colors.red;
    } else if (string.toLowerCase().contains("pending")) {
      return Colors.orange;
    } else if (string.toLowerCase().contains("delivered")) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  String getactualweight(String weight) {
    String wt = weight.replaceAll(" ", "").toLowerCase();
    wt = wt.replaceAll("g", "");
    return wt;
  }

  String showqnt(double modfdqnt, String wt, String itemType) {
    if (itemType.toLowerCase() == "kg" &&
        wt.toLowerCase().contains("g") &&
        !wt.toLowerCase().contains("k")) {
      if (modfdqnt < 1.0) {
        double qnty = modfdqnt * 1000;
        String tostr = qnty.toString();
        tostr = tostr.replaceAll(".0", "");
        return "${tostr}gm";
      } else {
        String qnt = modfdqnt.toString().replaceAll(".0", "");
        return "${qnt}kg";
      }
    } else {
      return modfdqnt.toString().replaceAll(".0", "") + itemType.toLowerCase();
    }
  }

  String shareMsg() {
    return "Hello Friends, I\'m ordering FarmFresh Vegetables, Fruits, Meat & Milk from FarmToHome. Download at https://play.google.com/store/apps/details?id=com.f2h.consumer and use my Referral Code FTH${userID} to get great discounts.";
  }
}

class YourOwnPaginatipon extends SwiperPlugin {
  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    return Align(
        alignment: Alignment.center,
        child: Container(
            height: 200,
            child:
                Container() /*Column(
              children: <Widget>[
                Text(
                  "${titles[config.activeIndex]}",
                  style: Theme.of(context).textTheme.headline,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "${subtitles[config.activeIndex]}",
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 8,
                ),
                */ /*DotSwiperPaginationBuilder(
                        color: Theme.of(context).primaryColor,
                        activeColor: Theme.of(context).accentColor,
                        size: 9.0,
                        activeSize: 15.0)
                    .build(context, config),*/ /*
              ],
            )*/
            ));
  }
}

class Swiperchild extends StatefulWidget {
  List<Banners> list = [];
  SwiperController swiperController;

  Swiperchild(
      {@required Key key, @required this.list, @required this.swiperController})
      : super(key: key);

  @override
  SwiperchildState createState() {
    return SwiperchildState(list, swiperController);
  }
}

class SwiperchildState extends State<Swiperchild> {
  List<Banners> bannerList = [];
  SwiperController swiperController;
  int lastswipepos = 0;

  SwiperchildState(this.bannerList, this.swiperController);

  @override
  Widget build(BuildContext context) {
    return bannerList.length > 0
        ? GestureDetector(
            child: Swiper(
              loop: true,
              autoplay: true,
              itemCount: bannerList.length,
              viewportFraction: 0.8,
              scale: 0.85,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                          child: Card(
                              color: Colors.white,
                              elevation: 3,
                              semanticContainer: true,
                              // to cover image whole card
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                  //side: new BorderSide(color: Colors.black26, width: 1.0),
                                  borderRadius: BorderRadius.circular(16.0)),
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  Image.network(
                                    bannerList[index].imageUrl,
                                    fit: BoxFit.fill,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;

                                      return Padding(
                                          padding: EdgeInsets.all(24.0),
                                          child: Image.asset(
                                            "assets/images/logo_green.png",
                                            fit: BoxFit.fitHeight,
                                          ));
                                    },
                                  )
                                ],
                              )))
                    ]);
              },
              controller: swiperController,
              control: SwiperControl(iconNext: null, iconPrevious: null),
              pagination: YourOwnPaginatipon(),
              onIndexChanged: (index) {
                lastswipepos = index;
              },
            ),
            onTap: () async{
              if (bannerList[lastswipepos] != null &&
                  bannerList[lastswipepos].product != null &&
                  bannerList[lastswipepos].product.isNotEmpty) {

                bool result =
                    await Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SearchProduct(
                    query: bannerList[lastswipepos].product.toString(),
                  );
                }));

              }
            },
          )
        : Container();
  }
}
