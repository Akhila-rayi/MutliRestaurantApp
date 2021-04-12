
import 'package:equatable/equatable.dart';

abstract class SubCategoriesEvent extends Equatable {}

class FetchSubCategoriesEvent extends SubCategoriesEvent {

  String userID,locID,category;

  FetchSubCategoriesEvent(this.userID,this.locID,this.category);

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class AddRemoveFavouriteEvent extends SubCategoriesEvent {

  String userID,id,status;

  AddRemoveFavouriteEvent(this.userID,this.id,this.status);

  @override
  // TODO: implement props
  List<Object> get props => null;
}

