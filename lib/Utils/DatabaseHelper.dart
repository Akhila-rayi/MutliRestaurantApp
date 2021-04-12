import 'package:FarmToHome/data/model/CartItemsModel.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  Database _database;

  DatabaseHelper._createInstance();

  String col1 = "actualid";
  String col2 = "id";
  String col3 = "title";
  String col4 = "imageURL";
  String col5 = "itemType";
  String col6 = "weight";
  String col7 = "priceUnit";
  String col8 = "quantity";
  String col9 = "priceTotal";
  String col10 = "discount";
  String col11= "availability";
  String col12 = "itemTypeURL";
  String col13= "isFavorite";
  String col14 = "isAdded";
  String col15= "priceAfterdiscount";
  String col16="modifiedquantity";


  String table_name = "CartProducts";

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }
  Future<Database> get database async {

    if(_database==null){
      _database=await createDatabase();
    }
    return _database;
  }

  Future<Database> createDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'F2H.db');
    var _database = await openDatabase(dbPath,  onCreate: populateDb,version: 1);
    return _database;
  }

  void populateDb( database,  version) async {

    await database.execute(
        "CREATE TABLE $table_name("
            "$col1 INTEGER PRIMARY KEY UNIQUE, "
            "$col2 TEXT, "
            "$col3 TEXT, "
            "$col4 TEXT, "
            "$col5 TEXT, "
            "$col6 TEXT, "
            "$col7 TEXT, "
            "$col8 TEXT, "
            "$col9 TEXT, "
            "$col10 TEXT, "
            "$col11 TEXT, "
            "$col12 TEXT, "
            "$col13 TEXT, "
            "$col14 TEXT, "
            "$col15 TEXT, "
            "$col16 TEXT )"
    );
  }

  Future<int> insertCartitem(CartItemsModel cartItemsModel) async {

    var result = _database.insert("$table_name", cartItemsModel.toJson());
    return result;
  }

  Future<List> getCartitemsMap() async {

    var result = await _database.query("$table_name", columns: ["$col1", "$col2", "$col3", "$col4", "$col5",
      "$col6", "$col7", "$col8", "$col9", "$col10","$col11", "$col12", "$col13", "$col14", "$col15", "$col16"]);
    return result.toList();
  }

  Future<List<CartItemsModel>> getCartitemslist() async {
    var cartitemsmaplist=await getCartitemsMap();
    int count=cartitemsmaplist.length;
    List<CartItemsModel> cartitemslist=new List<CartItemsModel>();
    for(int i=0;i<count;i++){
      cartitemslist.add(CartItemsModel.fromJson(cartitemsmaplist[i]));
    }
    return cartitemslist;
  }

  Future<double> gettotalprice() async {
    var totalprice=0.0;
    List<CartItemsModel> cartitemslist=await getCartitemslist();
    if(cartitemslist.length>0) {
      for (int i = 0; i < cartitemslist.length; i++) {

        if( cartitemslist[i].itemType.toLowerCase()=="kg" && cartitemslist[i].weight.toLowerCase().contains("g")
            && !cartitemslist[i].weight.toLowerCase().contains("k")) {

          //debugPrint("@@@ ${double.parse(cartitemslist[i].modifiedquantity)}");

          double actualwt=double.parse(getactualweight(cartitemslist[i].weight));
          double d=double.parse(cartitemslist[i].modifiedquantity)*1000.0;

          //debugPrint("@@@ after cal ${d/actualwt}");
          totalprice +=( d/actualwt  )* double.parse(cartitemslist[i].priceAfterdiscount);

        }else{
          debugPrint("@@@ ${double.parse(cartitemslist[i].modifiedquantity)}");
          totalprice += double.parse(cartitemslist[i].modifiedquantity) * double.parse(cartitemslist[i].priceAfterdiscount);

        }
      }

      double beforeround=num.parse(totalprice.toStringAsFixed(1))*2;
      double price = beforeround.ceil() / 2;
      return  price;
    }
    return totalprice;

  }

  String getactualweight(String weight) {
    String wt = weight.replaceAll(" ", "").toLowerCase();
    wt = wt.replaceAll("g", "");
    return wt;
  }

  Future<int> gettotalcartcount() async {
    List<CartItemsModel> cartitemslist=await getCartitemslist();
    return cartitemslist.length;
  }


  Future<CartItemsModel> getCartitembyid(String prdctid) async {

    List<Map> results = await _database.query("$table_name",
        columns: ["$col1", "$col2", "$col3", "$col4", "$col5","$col6", "$col7", "$col8", "$col9", "$col10","$col11", "$col12", "$col13", "$col14", "$col15", "$col16"],
        where: '$col2 = ?',
        whereArgs: [prdctid]);

    if (results.length > 0) {
      return new CartItemsModel.fromJson(results.first);
    }

    return null;
  }

  Future<int> updatCartItem(CartItemsModel  cartItemsModel) async {
    return await _database.update("$table_name", cartItemsModel.toJson(),
        where: "$col2 = ?", whereArgs: [cartItemsModel.id]);
  }

  Future<int> deleteCartItem(String id) async {

    return await _database.delete("$table_name", where: '$col2 = ?', whereArgs: [id]);
  }

  void closedb() async {
    await _database.close();
  }

  void deletetable() async{
    await _database.execute("DELETE FROM "+"$table_name");
  }



}
