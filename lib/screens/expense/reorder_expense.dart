import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_event.dart';
import 'package:travel_notebook/models/expense/expense_model.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/screens/expense/widgets/expense_item.dart';

class ReorderExpensePage extends StatefulWidget {
  final Destination destination;
  final List<Expense> expenses;

  const ReorderExpensePage({
    super.key,
    required this.destination,
    required this.expenses,
  });

  @override
  State<ReorderExpensePage> createState() => _ReorderExpensePageState();
}

class _ReorderExpensePageState extends State<ReorderExpensePage> {
  late ExpenseBloc _expenseBloc;
  late Destination _destination;

  late List<Expense> _expenses;

  @override
  void initState() {
    super.initState();

    _destination = widget.destination;
    _expenses = widget.expenses;

    _expenseBloc = BlocProvider.of<ExpenseBloc>(context);
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
        child: Column(
          children: [
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles:
                  false, // Disable the default drag handles
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final expense = _expenses.removeAt(oldIndex);
                  _expenses.insert(newIndex, expense);

                  for (int i = 0; i < _expenses.length; i++) {
                    _expenses[i].sequence = i;
                  }
                });
                _expenseBloc.add(UpdateAllExpense(_expenses));
              },
              children: List.generate(_expenses.length, (index) {
                final expense = _expenses[index];
                return Container(
                  key: Key(expense.expenseId.toString()),
                  child: ExpenseItem(
                    expense: expense,
                    index: index,
                    destination: _destination,
                    onUploadReceipt: (imgPath) async {},
                    onEdit: () {},
                    onDelete: () async {},
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
