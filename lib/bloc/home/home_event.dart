
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {}

class FetchHomeEvent extends HomeEvent {

  String userID,locationID;

  FetchHomeEvent(this.userID,this.locationID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


class AddRemoveFavouriteEvent extends HomeEvent {

  String userID,id,status;

  AddRemoveFavouriteEvent(this.userID,this.id,this.status);

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class FetchPreviousordersEvent extends HomeEvent {

  String userID;

  FetchPreviousordersEvent(this.userID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}



class SubmitFeedbackEvent extends HomeEvent {

  Map<String,String> feedbackMap;

  SubmitFeedbackEvent(this.feedbackMap);

  @override
  // TODO: implement props
  List<Object> get props => null;
}



class FetchfeedbackservicesEvent extends HomeEvent {

  FetchfeedbackservicesEvent();

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class FetchFavouritesEvent extends HomeEvent {

  String userID;

  FetchFavouritesEvent(this.userID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}


