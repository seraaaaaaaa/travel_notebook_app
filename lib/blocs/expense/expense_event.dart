import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/models/expense/expense_model.dart';

abstract class ExpenseEvent {}

class GetExpenses extends ExpenseEvent {
  final int destinationId;
  final int? limit;
  final int typeNo;
  final String paymentMethod;
  final int? excludeBudget; // 1-true, 0-false

  GetExpenses(
    this.destinationId, {
    this.limit,
    this.typeNo = 0,
    this.paymentMethod = '',
    this.excludeBudget,
  });
}

class AddExpense extends ExpenseEvent {
  final Expense expense;
  final Destination destination;

  AddExpense(this.expense, this.destination);
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;
  final Destination destination;

  UpdateExpense(this.expense, this.destination);
}

class UpdateAllExpense extends ExpenseEvent {
  final List<Expense> expenses;

  UpdateAllExpense(this.expenses);
}

class DeleteExpense extends ExpenseEvent {
  final Expense expense;
  final Destination destination;

  DeleteExpense(this.expense, this.destination);
}
