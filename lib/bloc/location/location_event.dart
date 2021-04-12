
import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable{}

class FetchLocationsEvent extends LocationEvent {
  @override
  // TODO: implement props
  List<Object> get props => null;
}


class FetchSelectedLocationEvent extends LocationEvent {

  String userID,locationID;

  FetchSelectedLocationEvent(this.userID,this.locationID);

  @override
  // TODO: implement props
  List<Object> get props => null;
}