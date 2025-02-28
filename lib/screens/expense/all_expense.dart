import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_event.dart';
import 'package:travel_notebook/blocs/expense/expense_state.dart';
import 'package:travel_notebook/components/error_msg.dart';
import 'package:travel_notebook/models/expense/enum/expense_type.dart';
import 'package:travel_notebook/components/filter_chip.dart';
import 'package:travel_notebook/screens/expense/reorder_expense.dart';
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

  final List<ExpenseType> _expenseTypes =
      ExpenseType.values.where((e) => e.enabled == false).toList();
  int _currentTypeNo = 0;

  @override
  void initState() {
    super.initState();

    _destination = widget.destination;

    _expenseBloc = BlocProvider.of<ExpenseBloc>(context);
    _expenseBloc
        .add(GetExpenses(_destination.destinationId!, typeNo: _currentTypeNo));
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

  Future _refreshData(int typeNo) async {
    setState(() {
      _currentTypeNo = typeNo;
    });
    _expenseBloc
        .add(GetExpenses(_destination.destinationId!, typeNo: _currentTypeNo));
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Add "All" ChoiceChip at the beginning
                  FilterChoiceChip(
                    label: 'All',
                    selected: _currentTypeNo == 0,
                    onTap: () {
                      _refreshData(0);
                    },
                  ),

                  // Generate ChoiceChips dynamically
                  ...List.generate(_expenseTypes.length, (index) {
                    var expenseType = _expenseTypes[index];
                    return FilterChoiceChip(
                      label: expenseType.name,
                      selected: _currentTypeNo == expenseType.typeNo,
                      onTap: () {
                        _refreshData(expenseType.typeNo);
                      },
                    );
                  }),
                ],
              ),
            ),
            BlocBuilder<ExpenseBloc, ExpenseState>(
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
                      : Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          dateKey,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: kGreyColor,
                                          ),
                                        ),
                                        _currentTypeNo > 0
                                            ? Container()
                                            : GestureDetector(
                                                onTap: () async {
                                                  await Navigator.of(context)
                                                      .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReorderExpensePage(
                                                        destination:
                                                            _destination,
                                                        expenses:
                                                            groupedExpenses[
                                                                dateKey]!,
                                                      ),
                                                    ),
                                                  );

                                                  _refreshData(_currentTypeNo);
                                                },
                                                child: Icon(
                                                  Icons.filter_list,
                                                  color: kGreyColor,
                                                ),
                                              ),
                                      ],
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
                                      destination: _destination,
                                      onUploadReceipt: (imgPath) async {
                                        setState(() {
                                          expense.receiptImg = imgPath;
                                        });
                                        _expenseBloc.add(UpdateExpense(
                                            expense, _destination));
                                      },
                                      onEdit: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ExpenseDetailPage(
                                                      destination: _destination,
                                                      expense: expense,
                                                    )));
                                      },
                                      onDelete: () async {
                                        deductTotalExpenses(
                                            expense, _destination);
                                        await ImageHandler()
                                            .deleteImage(expense.receiptImg);
                                        _expenseBloc.add(DeleteExpense(
                                            expense, _destination));
                                      },
                                    );
                                  }
                                  itemIndex++;
                                }
                              }

                              // Fallback in case of any mismatch
                              return const SizedBox.shrink();
                            },
                          ),
                        );
                } else if (state is ExpenseError) {
                  return ErrorMsg(
                    msg: state.message,
                    onTryAgain: () => Navigator.pop(context),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
