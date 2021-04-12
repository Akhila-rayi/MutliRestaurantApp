import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/Utils/Apputils.dart';
import 'package:FarmToHome/Utils/DatabaseHelper.dart';
import 'package:FarmToHome/bloc/subcategories/subcategories_bloc.dart';
import 'package:FarmToHome/bloc/subcategories/subcategories_event.dart';
import 'package:FarmToHome/bloc/subcategories/subcategories_state.dart';
import 'package:FarmToHome/data/model/CartItemsModel.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:FarmToHome/data/model/loginverify_response_model.dart';
import 'package:FarmToHome/data/model/subcategories_response_model.dart';
import 'package:FarmToHome/res/strings.dart';
import 'package:FarmToHome/ui/cartItems.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

class CategoryIndetail extends StatefulWidget {
  String title = "", Categoryid = "";

  CategoryIndetail({Key key, @required this.title, @required this.Categoryid})
      : super(key: key);

  @override
  CategoryIndetail_State createState() {
    return CategoryIndetail_State(this.title, this.Categoryid);
  }
}

class CategoryIndetail_State extends State<CategoryIndetail>
    with TickerProviderStateMixin {
  List<UserData> _userdatalist = [];
  List<SubcategoriesData> _subcategorieslist = [];
  String locationID = "", userID = "";
  bool showloading = false, productsshowloading = true;
  SubCategoriesBloc _subCategoriesBloc;
  UserPrefs _userPrefs = new UserPrefs();
  Apputils _apputils = new Apputils();
  AnimationController _animationController;
  List<LocationDetls> _locationDetailslist = [];

  String actualtext = "", prodcutstxt = "";
  var showCartdlg = false;

  DatabaseHelper databaseHelper = DatabaseHelper();

  String title = "", Categoryid = "";
  GlobalKey<ScaffoldState> _key2 = GlobalKey();
  TabController tabController;
  List<CartItemsModel> dbcartlist = [];
  List<List<CartItemsModel>> _nestedcartlist = [];
  var tabpostn = 0;
  List<List<Products>> nestedprodcutslist = [];
  var dbcartcount = 0;
  double totalcartprice = 0.0;
  int addremoveFavIndex;
  Future saveddatafuture;
  GlobalKey globalkey_categry= GlobalKey();
  double ht = 80.0;

  CategoryIndetail_State(this.title, this.Categoryid);

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    tabController = TabController(
        length: _subcategorieslist.length, vsync: this, initialIndex: 0);
    _subCategoriesBloc = BlocProvider.of<SubCategoriesBloc>(context);

    super.initState();
    saveddatafuture = getsaveddata();
  }

  _afterLayout(_) {
    _getSize();
  }

  _getSize() {
    if(globalkey_categry.currentContext!=null) {
      RenderBox renderBoxRed = globalkey_categry.currentContext.findRenderObject();
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
      debugPrint("@@@@ Cartlistcount  INDV CATG" + this.dbcartcount.toString());
      totalcartprice = totalprice;
    });

    Future.delayed(const Duration(milliseconds: 100), () async {
    bool isconnected = await _apputils.check();
    if (isconnected != null && isconnected) {
      _subCategoriesBloc
          .add(FetchSubCategoriesEvent(userID, locationID, Categoryid));
    } else {
      _apputils.showtoast(
          context, "Please make sure Network Connection is available");
    }});
  }

  void _runAnimation() async {
    for (int i = 0; i < 3; i++) {
      await _animationController.forward();
      await _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            key: _key2,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                this.title,
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
                }) ));
  }

  Widget getPage(){

    return BlocListener<SubCategoriesBloc, SubCategoriesState>(
        listener: (context, state) {
          if (state is SubCategoriesInitialState) {
            setState(() {
              showloading = true;
            });
          } else if (state is SubCategoriesLoadingState) {
            setState(() {
              showloading = true;
            });
          } else if (state is SubCategoriesLoadedState) {
            setState(() {
              showloading = false;

              if (_subcategorieslist.length > 0) {
                _subcategorieslist.clear();
              }

              if (_nestedcartlist.length > 0) {
                _nestedcartlist.clear();
              }
              if (nestedprodcutslist.length > 0) {
                nestedprodcutslist.clear();
              }
              if (state.list != null && state.list.length > 0) {
                if (state.list[0].titleMain != null) {
                  _subcategorieslist.addAll(state.list);
                  setState(() {
                    tabController = TabController(
                        length: _subcategorieslist.length,
                        vsync: this,
                        initialIndex: 0);
                  });
                  tabController.addListener(() {
                    setState(() {
                      prodcutstxt = "";
                      tabpostn = tabController.index;
                      productsshowloading = true;
                    });
                    refreshData(nestedprodcutslist[tabController.index]);
                  });

                  for (int i = 0; i < _subcategorieslist.length; i++) {
                    List<CartItemsModel> _cartitemslist = [];
                    _nestedcartlist.add(_cartitemslist);
                  }
                  for (int i = 0; i < _subcategorieslist.length; i++) {
                    nestedprodcutslist.add(_subcategorieslist[i].items);
                  }
                  refreshData(nestedprodcutslist[tabpostn]);
                } else {
                  actualtext = "No Categories found";
                }
              } else {
                actualtext = "No Categories found";
              }
            });
          } else if (state is SubCategoriesErrorState) {
            setState(() {
              showloading = false;
            });
            _apputils.showtoast(context, state.message);
          } else if (state is AddRemoveFavouriteLoadedState) {
            setState(() {
              showloading = false;
            });
            if (state.favouriteData != null &&
                state.favouriteData.length > 0) {
              _apputils.showtoast(context, state.favouriteData[0].alert);
              updatefavouritecount(state.favouriteData[0].favoriteCount);
            }
          }
        }, child: BlocBuilder<SubCategoriesBloc, SubCategoriesState>(
      builder: (context, state) {
        return getUI();
      },
    ));
  }

  Widget getUI() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          _subcategorieslist.length > 0 &&
                  _subcategorieslist[0].titleMain != null
              ? Column(children: <Widget>[
                  TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.black54,
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    /* onTap: (index) {
                      setState(() {
                        tabpostn = index;
                        showloading = true;
                      });
                      refreshData(nestedprodcutslist[index]);

                    },*/
                    tabs: List<Widget>.generate(_subcategorieslist.length,
                        (int index) {
                      return Tab(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3.0,
                          child: Text(_subcategorieslist[index].titleMain,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'quicksand',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.0)),
                        ),
                      );
                    }),
                  ),
                  Expanded(
                    child: TabBarView(
                        controller: tabController,
                        children: List<Widget>.generate(
                            _subcategorieslist.length, (int index) {
                          return Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Stack(children: <Widget>[
                                nestedprodcutslist[index].length > 0 &&
                                    _nestedcartlist[index].length > 0
                                    ? productTile()
                                    : Center(
                                        child: Text(
                                          prodcutstxt,
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .apply(color: Colors.red),
                                        ),
                                      ),
                                productsshowloading
                                    ? _apputils.buildLoading(context)
                                    : Container()
                              ]));
                        })),
                  )
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
          showloading ? _apputils.buildLoading(context) : Container(),
          showCartdlg ? displayCartItems() : Container()
        ]));
  }

  void refreshData(List<Products> prodcutslist) {

    setState(() {
      if (prodcutslist.length > 0) {
        prodcutstxt = "";
        List<CartItemsModel> _cartitemslist = [];

        for (int i = 0; i < prodcutslist.length; i++) {
          var str_isadded = "false";
          var qnty = "";

          /*if (prodcutslist[i].itemType.toLowerCase() == "kg") {
            qnty = "0.5";
          } else {
            qnty = prodcutslist[i].quantity;
          }*/

          //qnty = prodcutslist[i].quantity;

          if (prodcutslist[i].itemType.toLowerCase() == "kg" && prodcutslist[i].weight.toLowerCase().contains("g")
              && !prodcutslist[i].weight.toLowerCase().contains("k") ) {

            double d=double.parse(getactualweight(prodcutslist[i].weight))/1000.0;
            String s=d.toString();
            s=s.replaceAll(".0", "");
            qnty= s;
          }else{
            qnty = prodcutslist[i].quantity;
          }

          for (int j = 0; j < dbcartlist.length; j++) {
            if (prodcutslist[i].id == dbcartlist[j].id) {
              str_isadded = "true";
              qnty = dbcartlist[j].modifiedquantity;
            }
          }

          _cartitemslist.add(CartItemsModel(
              id: prodcutslist[i].id,
              title: prodcutslist[i].title,
              imageURL: prodcutslist[i].imageURL,
              weight: prodcutslist[i].weight,
              priceUnit: prodcutslist[i].priceUnit,
              availability: prodcutslist[i].availability.toString(),
              isFavorite: prodcutslist[i].isFavorite.toString(),
              quantity: prodcutslist[i].quantity,
              priceTotal: prodcutslist[i].priceTotal.toString(),
              itemType: prodcutslist[i].itemType,
              discount: prodcutslist[i].discount,
              isAdded: str_isadded,
              priceAfterdiscount: prodcutslist[i].priceTotal.toString(),
              modifiedquantity: qnty));
        }
        debugPrint("@@@@@@@@@ CART MODEL LENGTH______" +
            _cartitemslist.length.toString());
        if (_nestedcartlist[tabpostn].length == 0) {
          debugPrint("@@@@@@@@@ CART MODEL LENGTH______" +
              _cartitemslist.length.toString());

          _nestedcartlist[tabpostn].addAll(_cartitemslist);
        }
      } else {
        prodcutstxt = "No Products found";
      }

      productsshowloading = false;
    });
  }

  Widget productTile() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        padding: showCartdlg? EdgeInsets.only(bottom: ht): EdgeInsets.all(0.0),
        scrollDirection: Axis.vertical,
        itemCount: nestedprodcutslist[tabpostn].length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              height: 270,
              child: Padding(
                  padding: EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                  child: Card(
                    elevation: 6.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                            child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Image.network(
                                nestedprodcutslist[tabpostn][index].imageURL,
                                fit: BoxFit.fitHeight,
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
                              ),
                            ),
                            nestedprodcutslist[tabpostn][index].discount != "0%"
                                ? Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.red, width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                          child: Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Text(
                                                '${nestedprodcutslist[tabpostn][index].discount} Off',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(this.context)
                                                    .textTheme
                                                    .subtitle2
                                                    .apply(color: Colors.red),
                                              ))),
                                    ))
                                : Container()
                          ],
                        )),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 8.0),
                          child: Text(
                            '${nestedprodcutslist[tabpostn][index].title}',
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            style: Theme.of(this.context)
                                .textTheme
                                .subtitle2
                                .apply(color: const Color(0xFF000080)),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Text(
                              '${nestedprodcutslist[tabpostn][index].weight}',
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
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  nestedprodcutslist[tabpostn][index].discount != "0%"
                                      ? Text(
                                          "₹" +
                                              double.parse(nestedprodcutslist[tabpostn][index]
                                                      .priceTotal
                                                      .toString())
                                                  .toString() +
                                              " ",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.black54,
                                              fontSize: 14.0,
                                              fontFamily: 'quicksand',
                                              fontWeight: FontWeight.w500),
                                        )
                                      : Container(),
                                  Text(
                                    "₹" +
                                        getdiscountprice(
                                                double.parse(nestedprodcutslist[tabpostn][index]
                                                    .priceTotal
                                                    .toString()),
                                                double.parse(nestedprodcutslist[tabpostn][index]
                                                    .discount
                                                    .substring(
                                                        0,
                                                    nestedprodcutslist[tabpostn][index]
                                                                .discount
                                                                .length -
                                                            1)),
                                                index)
                                            .toString(),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.0,
                                        fontFamily: 'quicksand',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Expanded(
                                      child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                        padding: EdgeInsets.only(right: 4.0),
                                        child: GestureDetector(
                                            child:
                                            nestedprodcutslist[tabpostn][index].isFavorite
                                                    ? Icon(
                                                        Icons.favorite,
                                                        color: Colors.red,
                                                        size: 23,
                                                      )
                                                    : Icon(
                                                        Icons.favorite_border,
                                                        color: Colors.red,
                                                        size: 23,
                                                      ),
                                            onTap: () async{
                                              addremoveFavIndex = index;
                                              bool isconnected = await _apputils.check();
                                              if (isconnected != null && isconnected) {

                                                  if (nestedprodcutslist[tabpostn][index]
                                                          .isFavorite ==
                                                      false) {
                                                    _subCategoriesBloc.add(
                                                        AddRemoveFavouriteEvent(
                                                            userID,
                                                            nestedprodcutslist[tabpostn][index]
                                                                .id,
                                                            "1"));
                                                  } else {
                                                    _subCategoriesBloc.add(
                                                        AddRemoveFavouriteEvent(
                                                            userID,
                                                            nestedprodcutslist[tabpostn][index]
                                                                .id,
                                                            "0"));
                                                  }
                                                } else {
                                                  _apputils.showtoast(context,
                                                      "Please make sure Network Connection is available");
                                                }
                                            })),
                                  )),
                                  _nestedcartlist[tabpostn][index].isAdded ==
                                          "false"
                                      ? GestureDetector(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  // border: Border.all(color: Color(0xFFDCDCDC), width: 2.0),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  color: Colors.red),
                                              child: Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        'Add',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12.0,
                                                            fontFamily:
                                                                'quicksand',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )
                                                    ],
                                                  ))),
                                          onTap: () {
                                            clickedaddtocart(index);
                                          },
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                decrcountItem(index);
                                              },
                                              child: Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.black54,
                                                size: 23,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 4.0,
                                                    right: 4.0,
                                                    top: 4.0,
                                                    bottom: 0.0),
                                                child: Text(
                                                  _nestedcartlist[tabpostn]
                                                                  [index]
                                                              .isAdded ==
                                                          "true"
                                                      ? showqnt(double.parse(_nestedcartlist[tabpostn][index]
                                                      .modifiedquantity),_nestedcartlist[tabpostn][index]
                                                      .weight,_nestedcartlist[tabpostn][index]
                                                      .itemType)
                                                  /*  (double.parse(_nestedcartlist[tabpostn]
                                                                  [index]
                                                              .modifiedquantity)).toInt()
                                                              .toString()*/

                                                      : "",
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16.0,
                                                      fontFamily: 'quicksand',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                                child: Icon(
                                                  Icons.add_circle_outline,
                                                  color: Colors.black54,
                                                  size: 23,
                                                ),
                                                onTap: () {
                                                  incrItemcount(index);
                                                })
                                          ],
                                        )
                                ]))
                      ],
                    ),
                  )));
        },
      ),
    );
  }

  double getdiscountprice(double totalprice, double offpercent, int index) {
    double initval = (totalprice - ((offpercent / 100) * totalprice));
    double beforeround=num.parse(initval.toStringAsFixed(1))*2;
    double price = beforeround.ceil() / 2;
    if (_nestedcartlist[tabpostn] != null) {
      _nestedcartlist[tabpostn][index].priceAfterdiscount = price.toString();
    }
    return price;

  }

  void decrcountItem(int index) {

    if(_locationDetailslist[0].availability=="0" || !_apputils.allowOrder(_locationDetailslist[0])){

      _apputils.showNoticeDialog(context, AppStrings.cannotacceptorder);

    }else {

        double itemwght =
        double.parse(_nestedcartlist[tabpostn][index].modifiedquantity);

        setState(() {
          if (_nestedcartlist[tabpostn][index].itemType.toLowerCase() != "kg") {
            if (itemwght > 1) {
              itemwght -= 1;
              _nestedcartlist[tabpostn][index].modifiedquantity =
                  itemwght.toString();

              for (int i = 0; i < _nestedcartlist[tabpostn].length; i++) {
                if (_nestedcartlist[tabpostn][i].isAdded == "true") {
                  _saveorupdate(_nestedcartlist[tabpostn][i]);
                }
              }
            } else {
              // remove from cartitemslist
              _nestedcartlist[tabpostn][index].isAdded = "false";
              _delete(_nestedcartlist[tabpostn][index]);
            }
          } else {
            /*if (itemwght >= 1) {
            itemwght -= 0.5;
            _nestedcartlist[tabpostn][index].modifiedquantity =
                itemwght.toString();

            for (int i = 0; i < _nestedcartlist[tabpostn].length; i++) {
              if (_nestedcartlist[tabpostn][i].isAdded == "true") {
                _saveorupdate(_nestedcartlist[tabpostn][i]);
              }
            }
          } else {
            // remove from cartitemslist
            _nestedcartlist[tabpostn][index].isAdded = "false";
            _delete(_nestedcartlist[tabpostn][index]);
          }*/

            /*if (itemwght >= 2) {
            itemwght -= 1;
            _nestedcartlist[tabpostn][index].modifiedquantity =
                itemwght.toString();

            for (int i = 0; i < _nestedcartlist[tabpostn].length; i++) {
              if (_nestedcartlist[tabpostn][i].isAdded == "true") {
                _saveorupdate(_nestedcartlist[tabpostn][i]);
              }
            }
          } else {
            // remove from cartitemslist
            _nestedcartlist[tabpostn][index].isAdded = "false";
            _delete(_nestedcartlist[tabpostn][index]);
          }*/


            if (_nestedcartlist[tabpostn][index].weight.toLowerCase().contains(
                "kg")) {
              if (itemwght >= 2) {
                itemwght -= 1;
                _nestedcartlist[tabpostn][index].modifiedquantity =
                    itemwght.toString();

                for (int i = 0; i < _nestedcartlist[tabpostn].length; i++) {
                  if (_nestedcartlist[tabpostn][i].isAdded == "true") {
                    _saveorupdate(_nestedcartlist[tabpostn][i]);
                  }
                }
              } else {
                _nestedcartlist[tabpostn][index].isAdded = "false";
                _delete(_nestedcartlist[tabpostn][index]);
              }
            } else {
              double actaulwt = itemwght * 1000;
              if (actaulwt >=
                  (double.parse(getactualweight(
                      _nestedcartlist[tabpostn][index].weight)) *
                      2)) {
                actaulwt -=
                    double.parse(getactualweight(
                        _nestedcartlist[tabpostn][index].weight));
                _nestedcartlist[tabpostn][index].modifiedquantity =
                    (actaulwt / 1000.0).toString();

                for (int i = 0; i < _nestedcartlist[tabpostn].length; i++) {
                  if (_nestedcartlist[tabpostn][i].isAdded == "true") {
                    _saveorupdate(_nestedcartlist[tabpostn][i]);
                  }
                }
              } else {
                _nestedcartlist[tabpostn][index].isAdded = "false";
                _delete(_nestedcartlist[tabpostn][index]);
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

        double itemwght =
        double.parse(_nestedcartlist[tabpostn][index].modifiedquantity);

        setState(() {
          if (_nestedcartlist[tabpostn][index].itemType.toLowerCase() != "kg") {
            itemwght += 1;
            _nestedcartlist[tabpostn][index].modifiedquantity =
                itemwght.toString();
          } else {
            // itemwght += 0.5;

            /*itemwght += 1;
          _nestedcartlist[tabpostn][index].modifiedquantity =
              itemwght.toString();
              */

            if (_nestedcartlist[tabpostn][index].weight.toLowerCase().contains(
                "kg")) {
              itemwght += 1;
              _nestedcartlist[tabpostn][index].modifiedquantity =
                  itemwght.toString();
            } else {
              double actaulwt = itemwght * 1000;
              actaulwt += double.parse(
                  getactualweight(_nestedcartlist[tabpostn][index].weight));
              _nestedcartlist[tabpostn][index].modifiedquantity =
                  (actaulwt / 1000.0).toString();
            }
          }

          for (int i = 0; i < _nestedcartlist[tabpostn].length; i++) {
            if (_nestedcartlist[tabpostn][i].isAdded == "true") {
              _saveorupdate(_nestedcartlist[tabpostn][i]);
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
          _nestedcartlist[tabpostn][index].isAdded = "true";

          for (int i = 0; i < _nestedcartlist[tabpostn].length; i++) {
            if (_nestedcartlist[tabpostn][i].isAdded == "true") {
              _saveorupdate(_nestedcartlist[tabpostn][i]);
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

    Future.delayed(const Duration(milliseconds: 50), ()  {
      WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    });

    return Align(
      alignment: Alignment.bottomCenter,
      child: Wrap(
        children: <Widget>[
          Container(
              key: globalkey_categry,
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                //border: Border.all(color: Colors.blueAccent, width: 1.0),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child:  GestureDetector(
                  child:Padding(
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
                          '₹' + totalcartprice.toString()+"( ${dbcartcount} Items)",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.w500),
                        ),
                      /*  Text(
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
          onTap: (){
            nav_Cartitems(context);
          }))
        ],
      ),
    );
  }

  void nav_Cartitems(BuildContext context) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CartItems();
    }));

      updatecartlist();
      refreshdbdata();

  }

  void updatefavouritecount(int favoriteCount) async {
    await _userPrefs.setFavCount(favoriteCount);

    setState(() {
      nestedprodcutslist[tabpostn][addremoveFavIndex].isFavorite =
          !nestedprodcutslist[tabpostn][addremoveFavIndex].isFavorite;

      actualtext = "No Favourites found";
    });
  }

  Future getsaveddata() async {
    String userdetails = await _userPrefs.getUserdetls();
    if (userdetails != null) {
      setState(() {
        if (_userdatalist.length > 0) {
          _userdatalist.clear();
        }
        debugPrint(
            '@@@@ SAVED USER DATA indvlcategory${json.decode(userdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(userdetails)};
        _userdatalist.addAll(
            List<UserData>.from(mp['data'].map((x) => UserData.fromJson(x))));
        userID = _userdatalist[0].userId;
      });
    }

    String locdetails = await _userPrefs.getLoctndetls();
    if (locdetails != null) {
      setState(() {
        if (_locationDetailslist.length > 0) {
          _locationDetailslist.clear();
        }
        debugPrint(
            '@@@@ SAVED LOCATION DATA indvlcategory ${json.decode(locdetails)}');
        Map<String, dynamic> mp = {"data": json.decode(locdetails)};
        _locationDetailslist.addAll(List<LocationDetls>.from(
            mp['data'].map((x) => LocationDetls.fromJson(x))));
        locationID = _locationDetailslist[0].locationId;
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
