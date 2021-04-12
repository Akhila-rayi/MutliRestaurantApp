
import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {}

class FetchSearchProductEvent extends SearchEvent {

  String userID,query;

  FetchSearchProductEvent(this.userID,this.query);

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class AddDelFavouriteEvent extends SearchEvent {

  String userID,id,status;

  AddDelFavouriteEvent(this.userID,this.id,this.status);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


