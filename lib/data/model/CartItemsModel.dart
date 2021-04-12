class CartItemsModel {
  String id;
  String title;
  String imageURL;
  String itemType;
  String weight;
  String priceUnit;
  String quantity;
  String priceTotal;
  String discount;
  String availability;
  String itemTypeURL;
  String isFavorite;
  String isAdded;
  String priceAfterdiscount;
  String modifiedquantity;

  CartItemsModel(
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
      this.isFavorite,
      this.isAdded,
      this.priceAfterdiscount,
      this.modifiedquantity});

  CartItemsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    imageURL = json['imageURL'];
    itemType = json['itemType'];
    weight = json['weight'];
    priceUnit = json['priceUnit'];
    quantity = json['quantity'];
    priceTotal = json['priceTotal'];
    discount = json['discount'];
    availability = json['availability'];
    itemTypeURL = json['itemTypeURL'];
    isFavorite = json['isFavorite'];
    isAdded = json['isAdded'];
    priceAfterdiscount = json['priceAfterdiscount'];
    modifiedquantity=json["modifiedquantity"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['imageURL'] = this.imageURL;
    data['itemType'] = this.itemType;
    data['weight'] = this.weight;
    data['priceUnit'] = this.priceUnit;
    data['quantity'] = this.quantity;
    data['priceTotal'] = this.priceTotal;
    data['discount'] = this.discount;
    data['availability'] = this.availability;
    data['itemTypeURL'] = this.itemTypeURL;
    data['isFavorite'] = this.isFavorite;
    data['isAdded'] = this.isAdded;
    data['priceAfterdiscount'] = this.priceAfterdiscount;
    data['modifiedquantity']=this.modifiedquantity;
    return data;
  }


}
