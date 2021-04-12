class Subcategories_response_model {
  String status;
  String message;
  List<SubcategoriesData> data;

  Subcategories_response_model({this.status, this.message, this.data});

  Subcategories_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<SubcategoriesData>();
      json['data'].forEach((v) {
        data.add(new SubcategoriesData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubcategoriesData {
  String titleMain;
  String subcategory;
  List<Products> items;

  SubcategoriesData({this.titleMain, this.subcategory, this.items});

  SubcategoriesData.fromJson(Map<String, dynamic> json) {
    titleMain = json['title_main'];
    subcategory = json['subcategory'];
    if (json['items'] != null) {
      items = new List<Products>();
      json['items'].forEach((v) {
        items.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title_main'] = this.titleMain;
    data['subcategory'] = this.subcategory;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String id;
  String title;
  String imageURL;
  String itemType;
  String weight;
  String priceUnit;
  String quantity;
  String priceTotal;
  String discount;
  bool availability;
  String itemTypeURL;
  bool isFavorite;

  Products(
      {this.id,
        this.title,
        this.imageURL,
        this.itemType,
        this.weight,
        this.priceUnit,
        this.quantity,
        this.priceTotal,
        this.discount,
        this.availability,
        this.itemTypeURL,
        this.isFavorite});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    imageURL = json['imageURL'];
    itemType = json['itemType'];
    weight = json['weight'];
    priceUnit = json['price_unit'];
    quantity = json['quantity'];
    priceTotal = json['price_total'];
    discount = json['discount'];
    availability = json['availability'];
    itemTypeURL = json['itemTypeURL'];
    isFavorite = json['isFavorite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['imageURL'] = this.imageURL;
    data['itemType'] = this.itemType;
    data['weight'] = this.weight;
    data['price_unit'] = this.priceUnit;
    data['quantity'] = this.quantity;
    data['price_total'] = this.priceTotal;
    data['discount'] = this.discount;
    data['availability'] = this.availability;
    data['itemTypeURL'] = this.itemTypeURL;
    data['isFavorite'] = this.isFavorite;
    return data;
  }
}