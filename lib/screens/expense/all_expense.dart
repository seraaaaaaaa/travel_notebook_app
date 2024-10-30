import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_event.dart';
import 'package:travel_notebook/blocs/expense/expense_state.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/models/expense/expense_model.dart';
import 'package:travel_notebook/screens/expense/expense_detail.dart';
import 'package:travel_notebook/services/image_handler.dart';
import 'package:travel_notebook/services/utils.dart';
import 'package:travel_notebook/screens/expense/widgets/expense_item.dart';
import 'package:travel_notebook/components/no_data.dart';

class AllExpensePage extends StatefulWidget {
  final Destination destination;

  const AllExpensePage({
    super.key,
    required this.destination,
  });

  @override
  State<AllExpensePage> createState() => _AllExpensePageState();
}

class _AllExpensePageState extends State<AllExpensePage> {
  late ExpenseBloc _expenseBloc;
  late Destination _destination;

  @override
  void initState() {
    _destination = widget.destination;

    _expenseBloc = BlocProvider.of<ExpenseBloc>(context);
    _expenseBloc.add(GetExpenses(_destination.destinationId!));

    super.initState();
  }

  Map<String, List<Expense>> _groupExpensesByDate(List<Expense> expenses) {
    Map<String, List<Expense>> groupedExpenses = {};

    for (var expense in expenses) {
      final dateKey = formatDate(expense.createdTime);
      if (groupedExpenses[dateKey] == null) {
        groupedExpenses[dateKey] = [];
      }
      groupedExpenses[dateKey]!.add(expense);
    }

    return groupedExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Expenses'),
      ),
      body: Container(
        padding: const EdgeInsets.all(kPadding),
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ExpensesLoaded) {
              final groupedExpenses = _groupExpensesByDate(state.expenses);
              return state.expenses.isEmpty
                  ? const NoData(
                      msg: 'No Expense Found',
                      icon: Icons.credit_card,
                    )
                  : ListView.builder(
                      itemCount: groupedExpenses.length +
                          state.expenses.length, // account for headers
                      itemBuilder: (context, index) {
                        final dateKeys = groupedExpenses.keys.toList();
                        int itemIndex = 0;

                        for (String dateKey in dateKeys) {
                          // Check if the current item index is the header for this date
                          if (itemIndex == index) {
                            // Return header
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                dateKey,
                                style: const TextStyle(
                                  // fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: kGreyColor,
                                ),
                              ),
                            );
                          }
                          itemIndex++;

                          // Check if the current item index is one of the expenses under this header
                          final expenseList = groupedExpenses[dateKey]!;
                          for (Expense expense in expenseList) {
                            if (itemIndex == index) {
                              return ExpenseItem(
                                expense: expense,
                                currency: _destination.currency,
                                ownCurrency: _destination.ownCurrency,
                                onUploadReceipt: (imgPath) async {
                                  setState(() {
                                    expense.receiptImg = imgPath;
                                  });
                                  _expenseBloc.add(
                                      UpdateExpense(expense, _destination));
                                },
                                onEdit: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ExpenseDetailPage(
                                            destination: _destination,
                                            expense: expense,
                                          )));
                                },
                                onDelete: () async {
                                  deductTotalExpenses(expense, _destination);
                                  await ImageHandler()
                                      .deleteImage(expense.receiptImg);
                                  _expenseBloc.add(
                                      DeleteExpense(expense, _destination));
                                },
                              );
                            }
                            itemIndex++;
                          }
                        }

                        // Fallback in case of any mismatch
                        return const SizedBox.shrink();
                      },
                    );
            } else if (state is ExpenseError) {
              return Center(child: Text(state.message));
            }
            return Container();
          },
        ),
      ),
    );
  }
}
