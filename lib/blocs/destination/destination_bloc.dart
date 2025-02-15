import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_event.dart';
import 'package:travel_notebook/blocs/destination/destination_state.dart';
import 'package:travel_notebook/blocs/destination/destination_service.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final DestinationService destinationService;

  DestinationBloc(this.destinationService) : super(DestinationLoading()) {
    on<GetAllDestinations>((event, emit) async {
      emit(DestinationLoading());
      try {
        final destinations = await destinationService.readAllDestinations();
        emit(DestinationsLoaded(destinations));
      } catch (e) {
        emit(DestinationError('Error occurred: ${e.toString()}'));
      }
    });

    on<GetDestination>((event, emit) async {
      emit(DestinationLoading());
      try {
        final destination =
            await destinationService.readDestination(event.destinationId);
        destination.ownCurrency = event.ownCurrency;
        destination.ownDecimal = event.ownDecimal;

        emit(DestinationUpdated(destination));
      } catch (e) {
        emit(DestinationError('Error occurred: ${e.toString()}'));
      }
    });

    on<AddDestination>((event, emit) async {
      try {
        String result =
            await destinationService.createDestination(event.destination);
        emit(DestinationResult(result));

        add(GetAllDestinations());
      } catch (e) {
        emit(DestinationError('Error occurred: ${e.toString()}'));
      }
    });

    on<UpdateDestination>((event, emit) async {
      try {
        String result =
            await destinationService.updateDestination(event.destination);
        emit(DestinationResult(result));

        add(GetAllDestinations());
      } catch (e) {
        emit(DestinationError('Error occurred: ${e.toString()}'));
      }
    });

    on<DeleteDestination>((event, emit) async {
      try {
        String result = await destinationService.deleteDestination(event.id);
        emit(DestinationResult(result));

        add(GetAllDestinations());
      } catch (e) {
        emit(DestinationError('Error occurred: ${e.toString()}'));
      }
    });
  }
}
