import 'package:travel_notebook/models/destination/destination_model.dart';

abstract class DestinationState {}

class DestinationLoading extends DestinationState {}

class DestinationsLoaded extends DestinationState {
  final List<Destination> destinations;

  DestinationsLoaded(this.destinations);
}

class DestinationUpdated extends DestinationState {
  final Destination destination;

  DestinationUpdated(this.destination);
}

class DestinationResult extends DestinationState {
  final String result;

  DestinationResult(this.result);
}

class DestinationError extends DestinationState {
  final String message;

  DestinationError(this.message);
}
