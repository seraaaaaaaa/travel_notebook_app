import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_event.dart';
import 'package:travel_notebook/blocs/expense/expense_state.dart';
import 'package:travel_notebook/blocs/expense/expense_service.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseService expenseService;

  ExpenseBloc(this.expenseService) : super(ExpenseLoading()) {
    on<GetExpenses>((event, emit) async {
      emit(ExpenseLoading());
      try {
        final expenses = await expenseService.readAllExpenses(
            event.destinationId,
            event.limit,
            event.typeNo,
            event.paymentMethod,
            event.excludeBudget);
        emit(ExpensesLoaded(expenses, event.typeNo, event.paymentMethod));
      } catch (e) {
        emit(ExpenseError('Error occurred: ${e.toString()}'));
      }
    });

    on<AddExpense>((event, emit) async {
      try {
        await expenseService.createExpense(event.expense, event.destination);

        emit(ExpenseResult());
      } catch (e) {
        emit(ExpenseError('Error occurred: ${e.toString()}'));
      }
    });

    on<UpdateExpense>((event, emit) async {
      try {
        await expenseService.updateExpense(event.expense, event.destination);

        emit(ExpenseResult());
      } catch (e) {
        emit(ExpenseError('Error occurred: ${e.toString()}'));
      }
    });

    on<UpdateAllExpense>((event, emit) async {
      try {
        await expenseService.updateAllExpense(event.expenses);
      } catch (e) {
        emit(ExpenseError('Error occurred: ${e.toString()}'));
      }
    });

    on<DeleteExpense>((event, emit) async {
      try {
        await expenseService.deleteExpense(
            event.expense.expenseId!, event.destination);

        emit(ExpenseResult());
      } catch (e) {
        emit(ExpenseError('Error occurred: ${e.toString()}'));
      }
    });
  }
}
