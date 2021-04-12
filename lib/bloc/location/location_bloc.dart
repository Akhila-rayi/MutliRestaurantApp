import 'package:FarmToHome/bloc/location/location_event.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:bloc/bloc.dart';
import 'package:FarmToHome/data/repository/location_repository.dart';
import 'package:meta/meta.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationRepository repository;

  LocationBloc({@required this.repository}) : super(LocationInitialState());

  @override
  // TODO: implement initialState
  LocationState get initialState => LocationInitialState();

  @override
  Stream<LocationState> mapEventToState(LocationEvent event) async* {
    if (event is FetchLocationsEvent) {
      yield LocationLoadingState();
      try {
        List<LocationDetls> locations = await repository.getLocations();
        yield LocationLoadedState(locations: locations);
      } catch (e) {
        yield LocationErrorState(message: e.toString());
      }
    }

    if (event is FetchSelectedLocationEvent) {
      yield LocationLoadingState();
      try {
        List<LocationDetls> locations = await repository.selectedLocation(event.userID, event.locationID);
        yield SelectedLocationLoadedState(locations: locations);
      } catch (e) {
        yield LocationErrorState(message: e.toString());
      }
    }
  }
}
