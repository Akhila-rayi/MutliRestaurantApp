class GiveOrderfeedback {
  String userId;
  String orderId;
  String locationId;
  String cartIds;
  String rating;
  String note;

  GiveOrderfeedback(
      {this.userId,
        this.orderId,
        this.locationId,
        this.cartIds,
        this.rating,
        this.note});

  GiveOrderfeedback.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    orderId = json['order_id'];
    locationId = json['locationId'];
    cartIds = json['cart_ids'];
    rating = json['rating'];
    note = json['note'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = new Map<String, String>();
    data['user_id'] = this.userId;
    data['order_id'] = this.orderId;
    data['locationId'] = this.locationId;
    data['cart_ids'] = this.cartIds;
    data['rating'] = this.rating;
    data['note'] = this.note;
    return data;
  }
}