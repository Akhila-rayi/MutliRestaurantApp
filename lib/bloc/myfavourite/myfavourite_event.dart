
import 'package:equatable/equatable.dart';

abstract class MyFavouriteEvent extends Equatable {}

class FetchFavouritesEvent extends MyFavouriteEvent {

  String userID;

  FetchFavouritesEvent(this.userID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


class AddRemoveFavouriteEvent extends MyFavouriteEvent {

  String userID,id,status;

  AddRemoveFavouriteEvent(this.userID,this.id,this.status);

  @override
  // TODO: implement props
  List<Object> get props => null;
}

