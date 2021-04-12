import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:meta/meta.dart';

abstract class LocationState extends Equatable {}

class LocationInitialState extends LocationState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LocationLoadingState extends LocationState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LocationLoadedState extends LocationState {

  List<LocationDetls> locations;

  LocationLoadedState({@required this.locations});

  @override
  // TODO: implement props
  List<Object> get props => [locations];
}

class SelectedLocationLoadedState extends LocationState {

  List<LocationDetls> locations;

  SelectedLocationLoadedState({@required this.locations});

  @override
  // TODO: implement props
  List<Object> get props => [locations];
}

class LocationErrorState extends LocationState {

  String message;

  LocationErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}

