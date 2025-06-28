import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_event.dart';
import 'package:travel_notebook/blocs/expense/expense_state.dart';
import 'package:travel_notebook/components/error_msg.dart';
import 'package:travel_notebook/models/expense/enum/expense_type.dart';
import 'package:travel_notebook/components/filter_chip.dart';
import 'package:travel_notebook/models/expense/enum/payment_method.dart';
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
  final List<PaymentMethod> _paymentMethods = PaymentMethod.values;

  int _filterTypeNo = 0;
  String _filterPaymentMethod = '';

  @override
  void initState() {
    super.initState();

    _destination = widget.destination;

    _expenseBloc = BlocProvider.of<ExpenseBloc>(context);
    _expenseBloc.add(GetExpenses(
      _destination.destinationId!,
      typeNo: _filterTypeNo,
      paymentMethod: _filterPaymentMethod,
    ));
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

  Future _refreshData() async {
    _expenseBloc.add(GetExpenses(
      _destination.destinationId!,
      typeNo: _filterTypeNo,
      paymentMethod: _filterPaymentMethod,
    ));
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
        actions: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPadding),
              child: Icon(
                _filterTypeNo > 0 || _filterPaymentMethod.isNotEmpty
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined,
                color: _filterTypeNo > 0 || _filterPaymentMethod.isNotEmpty
                    ? kPrimaryColor
                    : kSecondaryColor,
              ),
            ),
            onTap: () async {
              final result = await showModalBottomSheet(
                context: context,
                builder: (context) {
                  int currentTypeNo = _filterTypeNo;
                  String currentPaymentMethod = _filterPaymentMethod;

                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      return Padding(
                        padding: const EdgeInsets.all(kPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: kPadding),
                              child: Row(
                                children: [
                                  const Icon(Icons.filter_list,
                                      color: kSecondaryColor),
                                  const SizedBox(
                                    width: kHalfPadding,
                                  ),
                                  Text('Filter',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: kPadding / 2),
                              child: Text('Expense Type',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ),
                            Wrap(
                              children: [
                                FilterChoiceChip(
                                  label: 'All',
                                  selected: currentTypeNo == 0,
                                  onTap: () {
                                    setModalState(() {
                                      currentTypeNo = 0;
                                    });
                                  },
                                ),
                                ...List.generate(_expenseTypes.length, (index) {
                                  var expenseType = _expenseTypes[index];
                                  return FilterChoiceChip(
                                    label: expenseType.name,
                                    selected:
                                        currentTypeNo == expenseType.typeNo,
                                    onTap: () {
                                      setModalState(() {
                                        currentTypeNo = expenseType.typeNo;
                                      });
                                    },
                                  );
                                }),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: kPadding / 2),
                              child: Text('Payment Method',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ),
                            Wrap(
                              children: [
                                FilterChoiceChip(
                                  label: 'All',
                                  selected: currentPaymentMethod.isEmpty,
                                  onTap: () {
                                    setModalState(() {
                                      currentPaymentMethod = '';
                                    });
                                  },
                                ),
                                ...List.generate(_paymentMethods.length,
                                    (index) {
                                  var paymentMethod = _paymentMethods[index];
                                  return FilterChoiceChip(
                                    label: paymentMethod.name,
                                    selected: currentPaymentMethod ==
                                        paymentMethod.name,
                                    onTap: () {
                                      setModalState(() {
                                        currentPaymentMethod =
                                            paymentMethod.name;
                                      });
                                    },
                                  );
                                }),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: kPadding),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: kSecondaryColor),
                                        onPressed: () {
                                          setModalState(() {
                                            currentTypeNo = 0;
                                            currentPaymentMethod = '';
                                          });
                                          Navigator.pop(context, {
                                            'typeNo': currentTypeNo,
                                            'paymentMethod':
                                                currentPaymentMethod,
                                          });
                                        },
                                        child: const Text('Clear')),
                                  ),
                                  const SizedBox(
                                    width: kPadding,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, {
                                            'typeNo': currentTypeNo,
                                            'paymentMethod':
                                                currentPaymentMethod,
                                          });
                                        },
                                        child: const Text('Apply')),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              );

              if (result != null) {
                setState(() {
                  _filterTypeNo = result['typeNo'];
                  _filterPaymentMethod = result['paymentMethod'];
                });
                _refreshData();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ExpenseDetailPage(
                      destination: _destination,
                    )),
          );
        },
        tooltip: 'Record Expense',
        child: const Icon(
          Icons.edit_note,
          size: kHalfPadding * 3,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kPadding, vertical: kHalfPadding),
        child: Column(
          children: [
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
                            itemCount:
                                groupedExpenses.length + state.expenses.length,
                            itemBuilder: (context, index) {
                              final dateKeys = groupedExpenses.keys.toList();
                              int itemIndex = 0;

                              for (String dateKey in dateKeys) {
                                // Check if the current item index is the header for this date
                                if (itemIndex == index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: kHalfPadding),
                                    child: Text(
                                      dateKey,
                                      style: const TextStyle(
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
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
