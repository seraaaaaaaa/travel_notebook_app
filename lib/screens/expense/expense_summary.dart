import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_event.dart';
import 'package:travel_notebook/blocs/destination/destination_state.dart';
import 'package:travel_notebook/blocs/expense/expense_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_event.dart';
import 'package:travel_notebook/blocs/expense/expense_state.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/screens/expense/all_expense.dart';
import 'package:travel_notebook/screens/expense/expense_detail.dart';
import 'package:travel_notebook/services/image_handler.dart';
import 'package:travel_notebook/services/utils.dart';
import 'package:travel_notebook/screens/expense/widgets/percent_indicator.dart';
import 'package:travel_notebook/screens/expense/widgets/pie_chart.dart';
import 'package:travel_notebook/screens/expense/widgets/expense_item.dart';
import 'package:travel_notebook/components/no_data.dart';
import 'package:travel_notebook/components/section_title.dart';

class ExpenseSummary extends StatefulWidget {
  final Destination destination;

  const ExpenseSummary({super.key, required this.destination});

  @override
  State<ExpenseSummary> createState() => _ExpenseSummaryState();
}

class _ExpenseSummaryState extends State<ExpenseSummary> {
  late ExpenseBloc _expenseBloc;
  late DestinationBloc _destinationBloc;

  late Destination _destination;

  @override
  void initState() {
    _destination = widget.destination;

    _destinationBloc = BlocProvider.of<DestinationBloc>(context);

    _expenseBloc = BlocProvider.of<ExpenseBloc>(context);
    _expenseBloc.add(GetExpenses(_destination.destinationId!, limit: 4));

    super.initState();
  }

  Future _refreshPage() async {
    _destinationBloc.add(
        GetDestination(_destination.destinationId!, _destination.ownCurrency));
    _expenseBloc.add(GetExpenses(_destination.destinationId!, limit: 4));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DestinationBloc, DestinationState>(
          listener: (context, state) {
            if (state is DestinationUpdated) {
              setState(() {
                _destination = state.destination;
              });
            }
          },
        ),
        BlocListener<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseResult) {
              _destinationBloc.add(GetDestination(
                  _destination.destinationId!, _destination.ownCurrency));
            }
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: kPadding),
              PieChartWidget(
                destination: _destination,
              ),
              SectionTitle(
                title: 'Budget Left',
                btnText: 'Record',
                btnAction: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ExpenseDetailPage(
                            destination: _destination,
                          )));
                },
              ),
              PercentIndicator(
                percent: _destination.budgetPercent,
                title:
                    '${formatCurrency(_destination.totalExpense, currency: _destination.currency)} / ${formatCurrency(_destination.budget, currency: _destination.currency)}',
                color: kPrimaryColor.shade600,
              ),
              SectionTitle(
                title: 'Recent Expense',
                btnText: 'Show All',
                btnAction: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AllExpensePage(
                            destination: _destination,
                          )));
                },
              ),
              BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpenseLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ExpensesLoaded) {
                    return state.expenses.isEmpty
                        ? const NoData(
                            msg: 'No Expenses Found',
                            icon: Icons.credit_card,
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.expenses.length > 4
                                ? 4
                                : state.expenses.length,
                            itemBuilder: (context, index) {
                              final expense = state.expenses[index];
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
                            },
                          );
                  } else if (state is ExpenseError) {
                    return Center(child: Text(state.message));
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
