import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/screens/currency/currency_converter.dart';
import 'package:travel_notebook/screens/expense/expense_summary.dart';
import 'package:travel_notebook/screens/todo/todo_list.dart';
import 'package:travel_notebook/themes/constants.dart';

class HomePage extends StatelessWidget {
  final Destination destination;

  const HomePage({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_backspace),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            destination.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.all(Radius.circular(kPadding * 1.5)),
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.symmetric(horizontal: kHalfPadding),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.all(Radius.circular(kPadding * 1.5)),
                  color: kSecondaryColor.shade50,
                ),
                child: const TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: kTransparentColor,
                  indicator: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(kPadding * 1.5)),
                  ),
                  labelColor: kPrimaryColor,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .4),
                  tabs: [
                    Tab(
                      child: Text(
                        'Expense',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Currency',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tab(
                      child: Text(
                        'To-do',
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setInt('destinationId', -1);
            }
          },
          child: TabBarView(
            children: [
              ExpenseSummary(destination: destination),
              CurrencyConverter(destination: destination),
              TodoList(destinationId: destination.destinationId!),
            ],
          ),
        ),
      ),
    );
  }
}
