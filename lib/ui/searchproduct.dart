import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/Utils/DatabaseHelper.dart';
import 'package:FarmToHome/bloc/searchproduct/search_bloc.dart';
import 'package:FarmToHome/bloc/searchproduct/search_event.dart';
import 'package:FarmToHome/bloc/searchproduct/search_state.dart';
import 'package:FarmToHome/data/model/CartItemsModel.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:FarmToHome/ui/cartItems.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

class SearchProduct extends StatefulWidget {
  String query = "";

  SearchProduct({Key key, @required this.query}) : super(key: key);

  @override
  SearchProductState createState() {
    return SearchProductState(query);
  }
}

class SearchProductState extends State<SearchProduct>
    with TickerProviderStateMixin {
  List<UserData> _userdatalist = [];
  List<TodaySpecial> _resultlist = [];
  String query = "", userID = "";
  bool showloading = false;
  SearchBloc _searchBloc;
  UserPrefs _userPrefs = new UserPrefs();
  Apputils _apputils = new Apputils();
  AnimationController _animationController;

  String actualtext = "";
  var showCartdlg = false;

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<CartItemsModel> dbcartlist = [];
  List<CartItemsModel> _cartitemslist = [];
  var dbcartcount = 0;
  double totalcartprice = 0.0;

  List<CartItemsModel> _finalcartitemslist = [];
  var addremoveFavIndex;
  List<LocationDetls> _locationDetailslist = [];
  Future saveddatafuture;
  GlobalKey globalkey_search = GlobalKey();
  double ht = 80.0;

  SearchProductState(this.query);

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    super.initState();
    _searchBloc = BlocProvider.of<SearchBloc>(context);
    saveddatafuture = getsaveddata();
  }

  void _runAnimation() async {
    for (int i = 0; i < 3; i++) {
      await _animationController.forward();
      await _animationController.reverse();
    }
  }

  _afterLayout(_) {
    _getSize();
  }

  _getSize() {
    if (globalkey_search.currentContext != null) {
      RenderBox renderBoxRed =
          globalkey_search.currentContext.findRenderObject();
      var sizeRed = renderBoxRed.size;
      setState(() {
        ht = sizeRed.height;
      });
    }
  }

  void updatecartlist() async {
    Database futuredab = await databaseHelper.database;
    List<CartItemsModel> _list = await databaseHelper.getCartitemslist();
    double totalprice = await databaseHelper.gettotalprice();

    setState(() {
      if (dbcartlist.length > 0) {
        dbcartlist.clear();
      }
      this.dbcartlist = _list;
      this.dbcartcount = _list.length;
      debugPrint(
          "@@@@ Cartlistcount Searchproduct" + this.dbcartcount.toString());
      totalcartprice = totalprice;
    });
    Future.delayed(const Duration(milliseconds: 100), () async {
      bool isconnected = await _apputils.check();
      if (isconnected != null && isconnected) {
        _searchBloc.add(FetchSearchProductEvent(userID, query));
      } else {
        _apputils.showtoast(
            context, "Please make sure Network Connection is available");
      }
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
              "",
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
              }),
        ));
  }

  Widget getPage() {
    return BlocListener<SearchBloc, SearchState>(listener: (context, state) {
      if (state is SearchProductInitialState) {
        setState(() {
          showloading = true;
        });
      } else if (state is SearchProductLoadingState) {
        setState(() {
          showloading = true;
        });
      } else if (state is SearchProductLoadedState) {
        setState(() {
          showloading = false;

          if (_resultlist.length > 0) {
            _resultlist.clear();
          }
          if (_cartitemslist.length > 0) {
            _cartitemslist.clear();
          }
          if (state.list != null && state.list.length > 0) {
            _resultlist.addAll(state.list);
            refreshHomeData();
          } else {
            actualtext = "No Products found";
          }
        });
      } else if (state is SearchProductErrorState) {
        setState(() {
          showloading = false;
        });
        _apputils.showtoast(context, state.message);
      } else if (state is AdddelFavouriteLoadedState) {
        setState(() {
          showloading = false;
        });

        if (state.favouriteData != null && state.favouriteData.length > 0) {
          _apputils.showtoast(context, state.favouriteData[0].alert);
          updatefavouritecount(state.favouriteData[0].favoriteCount);
        }
      }
    }, child: BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return UI(_resultlist);
      },
    ));
  }

  refreshHomeData() {
    for (int i = 0; i < _resultlist.length; i++) {
      var str_isadded = "false";
      var qnty = "";

      //qnty = _resultlist[i].quantity;


      /*if (_resultlist[i].itemType.toLowerCase() == "kg") {
        qnty = "0.5";
      } else {
        qnty = _resultlist[i].quantity;
      }*/

      if (_resultlist[i].itemType.toLowerCase() == "kg" && _resultlist[i].weight.toLowerCase().contains("g")
          && !_resultlist[i].weight.toLowerCase().contains("k") ) {

        double d=double.parse(getactualweight(_resultlist[i].weight))/1000.0;
        String s=d.toString();
        s=s.replaceAll(".0", "");
        qnty= s;
      }else{
        qnty = _resultlist[i].quantity;
      }

      for (int j = 0; j < dbcartlist.length; j++) {
        if (_resultlist[i].id == dbcartlist[j].id) {
          str_isadded = "true";
          qnty = dbcartlist[j].modifiedquantity;
        }
      }

      debugPrint("@@@@@@@_________searchprdct" + qnty + "______" + str_isadded);

      _cartitemslist.add(CartItemsModel(
          id: _resultlist[i].id,
          title: _resultlist[i].title,
          imageURL: _resultlist[i].imageURL,
          weight: _resultlist[i].weight,
          priceUnit: _resultlist[i].priceUnit,
          availability: _resultlist[i].availability.toString(),
          isFavorite: _resultlist[i].isFavorite.toString(),
          quantity: _resultlist[i].quantity,
          priceTotal: _resultlist[i].priceTotal.toString(),
          itemType: _resultlist[i].itemType,
          discount: _resultlist[i].discount,
          isAdded: str_isadded,
          priceAfterdiscount: _resultlist[i].priceTotal.toString(),
          modifiedquantity: qnty));
    }
  }

  Widget UI(locations_list) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          _resultlist.length > 0
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: <Widget>[
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        padding: showCartdlg
                            ? EdgeInsets.only(bottom: ht)
                            : EdgeInsets.all(0.0),
                        itemCount: _resultlist.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              width: MediaQuery.of(context).size.width,
                              height: 270,
                              child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Card(
                                    elevation: 6.0,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                _resultlist[index].imageURL,
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
                                            _resultlist[index].discount != "0%"
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                color:
                                                                    Colors.red,
                                                                width: 1.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0.0),
                                                          ),
                                                          child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4.0),
                                                              child: Text(
                                                                '${_resultlist[index].discount} Off',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Theme.of(this
                                                                        .context)
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
                                          child: Text(_resultlist[index].title,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color:
                                                      const Color(0xFF000080),
                                                  fontSize: 14.0,
                                                  fontFamily: 'quicksand',
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 8.0, top: 4.0),
                                            child: Text(
                                              _resultlist[index].weight,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14.0,
                                                  fontFamily: 'quicksand',
                                                  fontWeight: FontWeight.w500),
                                            )),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 8.0,
                                                top: 4.0,
                                                right: 8.0,
                                                bottom: 8.0),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  _resultlist[index].discount !=
                                                          "0%"
                                                      ? Text(
                                                          "???" +
                                                              double.parse(_resultlist[
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
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 14.0,
                                                              fontFamily:
                                                                  'quicksand',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        )
                                                      : Container(),
                                                  Text(
                                                    "???" +
                                                        getdiscountprice(
                                                                double.parse(_resultlist[
                                                                        index]
                                                                    .priceTotal
                                                                    .toString()),
                                                                double.parse(_resultlist[
                                                                        index]
                                                                    .discount
                                                                    .substring(
                                                                        0,
                                                                        _resultlist[index].discount.length -
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

                                                  /*Text(
                                                "???"+_resultlist[index]
                                                    .priceTotal.toString(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 14.0,
                                                    fontFamily:
                                                    'quicksand',
                                                    fontWeight:
                                                    FontWeight.w500),
                                              ),*/
                                                  Expanded(
                                                      child: Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 4.0),
                                                      child: GestureDetector(
                                                          child: _resultlist[
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
                                                              if (_resultlist[
                                                                          index]
                                                                      .isFavorite ==
                                                                  false) {
                                                                _searchBloc.add(
                                                                    AddDelFavouriteEvent(
                                                                        userID,
                                                                        _resultlist[index]
                                                                            .id,
                                                                        "1"));
                                                              } else {
                                                                _searchBloc.add(
                                                                    AddDelFavouriteEvent(
                                                                        userID,
                                                                        _resultlist[index]
                                                                            .id,
                                                                        "0"));
                                                              }
                                                            } else {
                                                              _apputils.showtoast(
                                                                  context,
                                                                  "Please make sure Network Connection is available");
                                                            }
                                                          }),
                                                    ),
                                                  )),
                                                  _cartitemslist.length > 0 &&
                                                          _cartitemslist[
                                                                  index] !=
                                                              null &&
                                                          _cartitemslist[index]
                                                                  .isAdded ==
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
                                                                            TextAlign.center,
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
                                                                        Icons
                                                                            .add,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            15,
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
                                                                        left:
                                                                            4.0,
                                                                        right:
                                                                            4.0,
                                                                        top:
                                                                            4.0,
                                                                        bottom:
                                                                            0.0),
                                                                child: Text(
                                                                  _cartitemslist
                                                                                  .length >
                                                                              0 &&
                                                                          _cartitemslist[index] !=
                                                                              null &&
                                                                          _cartitemslist[index].isAdded ==
                                                                              "true"
                                                                      ?  showqnt(double.parse(_cartitemslist[index]
                                                                      .modifiedquantity),_cartitemslist[index]
                                                                      .weight,_cartitemslist[index]
                                                                      .itemType)

                                                                      : "",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          16.0,
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
                      showCartdlg ? displayCartItems() : Container(),
                    ],
                  ))
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
        ]));
  }

  double getdiscountprice(double totalprice, double offpercent, int index) {
    double initval = (totalprice - ((offpercent / 100) * totalprice));
    double beforeround=num.parse(initval.toStringAsFixed(1))*2;
    double price = beforeround.ceil() / 2;
    _cartitemslist[index].priceAfterdiscount = price.toString();
    return price;
  }

  void decrcountItem(int index) {

    if(_locationDetailslist[0].availability=="0" || !_apputils.allowOrder(_locationDetailslist[0])){

      _apputils.showNoticeDialog(context, AppStrings.cannotacceptorder);

    }else {

        double itemwght = double.parse(_cartitemslist[index].modifiedquantity);

        setState(() {
          if (_cartitemslist[index].itemType.toLowerCase() != "kg") {
            if (itemwght > 1) {
              itemwght -= 1;
              _cartitemslist[index].modifiedquantity = itemwght.toString();

              for (int i = 0; i < _cartitemslist.length; i++) {
                if (_cartitemslist[i].isAdded == "true") {
                  _finalcartitemslist.add(_cartitemslist[i]);
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
                _finalcartitemslist.add(_cartitemslist[i]);
                _saveorupdate(_cartitemslist[i]);
              }
            }
          } else {
            // remove from cartitemslist
            _cartitemslist[index].isAdded = "false";
            _delete(_cartitemslist[index]);
          }*/
            /* if (itemwght >= 2) {
            itemwght -= 1;
            _cartitemslist[index].modifiedquantity = itemwght.toString();

            for (int i = 0; i < _cartitemslist.length; i++) {
              if (_cartitemslist[i].isAdded == "true") {
                _finalcartitemslist.add(_cartitemslist[i]);
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
          }

          refreshdbdata();
        });

    }
  }

  void incrItemcount(int index) {

    if(_locationDetailslist[0].availability=="0" || !_apputils.allowOrder(_locationDetailslist[0])){

      _apputils.showNoticeDialog(context, AppStrings.cannotacceptorder);

    }else {

        double itemwght = double.parse(_cartitemslist[index].modifiedquantity);

        setState(() {
          if (_cartitemslist[index].itemType.toLowerCase() != "kg") {
            itemwght += 1;
            _cartitemslist[index].modifiedquantity = itemwght.toString();
          } else {
            // itemwght += 0.5;

            /*itemwght += 1;
          _cartitemslist[index].modifiedquantity = itemwght.toString();*/

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
          }

          for (int i = 0; i < _cartitemslist.length; i++) {
            if (_cartitemslist[i].isAdded == "true") {
              _finalcartitemslist.add(_cartitemslist[i]);
              _saveorupdate(_cartitemslist[i]);
            }
          }
        });

    }
  }

  void clickedaddtocart(int index) {

    if(_locationDetailslist[0].availability=="0" || !_apputils.allowOrder(_locationDetailslist[0])){

      _apputils.showNoticeDialog(context, AppStrings.cannotacceptorder);

    }else {
        setState(() {
          _cartitemslist[index].isAdded = "true";

          for (int i = 0; i < _cartitemslist.length; i++) {
            if (_cartitemslist[i].isAdded == "true") {
              _finalcartitemslist.add(_cartitemslist[i]);
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
      // Failure
      debugPrint("@@@ FAILURE DB OPERATN");
    }
  }

  void refreshdbdata() async {
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

  Widget displayCartItems() {
    Future.delayed(const Duration(milliseconds: 50), () {
      WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    });
    return Align(
      alignment: Alignment.bottomCenter,
      child: Wrap(
        children: <Widget>[
          Container(
              key: globalkey_search,
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
                              '???' + totalcartprice.toString()+"( ${dbcartcount} Items)",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500),
                            ),
                            /*Text(
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
                                  setState(() {
                                    showCartdlg = false;
                                  });
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              CartItems()))
                                      .then((value) {
                                    setState(() {
                                      updatecartlist();
                                      refreshdbdata();
                                    });
                                  });
                                },
                              )),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      showCartdlg = false;
                    });
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (BuildContext context) => CartItems()))
                        .then((value) {
                      setState(() {
                        updatecartlist();
                        refreshdbdata();
                      });
                    });
                  }))
        ],
      ),
    );
  }

  void updatefavouritecount(int favoriteCount) async {
    await _userPrefs.setFavCount(favoriteCount);

    setState(() {
      _resultlist[addremoveFavIndex].isFavorite =
          !_resultlist[addremoveFavIndex].isFavorite;

      actualtext = "No Favourites found";
    });
  }

  Future getsaveddata() async {
    String locdetails = await _userPrefs.getLoctndetls();

    if (locdetails != null) {
      setState(() {
        if (_locationDetailslist.length > 0) {
          _locationDetailslist.clear();
        }
        debugPrint(
            '@@@@ SAVED LOCATION DATA Searchproduct ${json.decode(locdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(locdetails)};

        _locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));
      });
    }

    String userdetails = await _userPrefs.getUserdetls();

    if (userdetails != null) {
      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        debugPrint(
            '@@@@ SAVED USER DATA Searchproduct ${json.decode(userdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(userdetails)};

        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
        userID = _userdatalist[0].userId;
      });
    }

    await updatecartlist();
  }



  String getactualweight(String weight) {
    String wt = weight.replaceAll(" ", "").toLowerCase();
    wt = wt.replaceAll("g", "");
    return wt;
  }

  String showqnt(double modfdqnt, String wt, String itemType) {
    if( itemType.toLowerCase() =="kg" && wt.toLowerCase().contains("g") && !wt.toLowerCase().contains("k")) {
      if (modfdqnt < 1.0) {
        double qnty=modfdqnt * 1000;
        String tostr=qnty.toString();
        tostr=tostr.replaceAll(".0", "");
        return "${tostr}gm";
      }else{
        String qnt= modfdqnt.toString().replaceAll(".0", "");
        return "${qnt}kg";
      }
    }else{
      return modfdqnt.toString().replaceAll(".0", "")+itemType.toLowerCase();
    }
  }
}
