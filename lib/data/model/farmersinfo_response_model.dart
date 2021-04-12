class Farmersinfo_response_model {
  String status;
  String message;
  List<FarmersinfoData> data;

  Farmersinfo_response_model({this.status, this.message, this.data});

  Farmersinfo_response_model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<FarmersinfoData>();
      json['data'].forEach((v) {
        data.add(new FarmersinfoData.fromJson(v));
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

class FarmersinfoData {
  String imageUrl;
  String title;
  String description;

  FarmersinfoData({this.imageUrl, this.title, this.description});

  FarmersinfoData.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl'];
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageUrl'] = this.imageUrl;
    data['title'] = this.title;
    data['description'] = this.description;
    return data;
  }
}