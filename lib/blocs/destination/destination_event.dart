import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/models/expense/expense_model.dart';

abstract class DestinationEvent {}

class GetAllDestinations extends DestinationEvent {}

class GetDestination extends DestinationEvent {
  final int destinationId;
  final String ownCurrency;
  final int ownDecimal;

  GetDestination(this.destinationId, this.ownCurrency, this.ownDecimal);
}

class AddDestination extends DestinationEvent {
  final Destination destination;

  AddDestination(this.destination);
}

class UpdateDestination extends DestinationEvent {
  final Destination destination;

  UpdateDestination(this.destination);
}

class UpdateDestinationExpense extends DestinationEvent {
  final Expense expense;

  UpdateDestinationExpense(this.expense);
}

class DeleteDestination extends DestinationEvent {
  final int id;

  DeleteDestination(this.id);
}
