import 'package:travel_notebook/models/expense/expense_model.dart';

abstract class ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpensesLoaded extends ExpenseState {
  final List<Expense> expenses;
  final int typeNo;
  final String paymentMethod;

  ExpensesLoaded(this.expenses, this.typeNo, this.paymentMethod);
}

class ExpenseResult extends ExpenseState {
  ExpenseResult();
}

class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError(this.message);
}
