import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_notebook/blocs/destination/destination_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_bloc.dart';
import 'package:travel_notebook/blocs/expense/expense_service.dart';
import 'package:travel_notebook/blocs/todo/todo_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_service.dart';
import 'package:travel_notebook/blocs/todo/todo_service.dart';
import 'package:travel_notebook/screens/destination/all_destination.dart';
import 'package:travel_notebook/screens/welcome.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/themes/theme.dart';

void main() async {
  // Ensure binding before async work
  WidgetsFlutterBinding.ensureInitialized();

  // Load shared preferences before running the app
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final int? prevDestinationId = prefs.getInt('destinationId');
  final String ownCurrency = prefs.getString('currency') ?? '';
  final int ownDecimal = prefs.getInt('ownDecimal') ?? 2;

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<DestinationBloc>(
        create: (context) => DestinationBloc(DestinationService()),
      ),
      BlocProvider<ExpenseBloc>(
        create: (context) => ExpenseBloc(ExpenseService()),
      ),
      BlocProvider<TodoBloc>(
        create: (context) => TodoBloc(TodoService()),
      ),
    ],
    child: MainApp(
      prevDestinationId: prevDestinationId,
      ownCurrency: ownCurrency,
      ownDecimal: ownDecimal,
    ),
  ));
}

class MainApp extends StatelessWidget {
  final int? prevDestinationId;
  final String ownCurrency;
  final int ownDecimal;

  const MainApp({
    super.key,
    required this.prevDestinationId,
    required this.ownCurrency,
    required this.ownDecimal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        color: kBlackColor,
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            theme: GlobalThemData.lightThemeData,
            home: ownCurrency.isEmpty
                ? const WelcomePage()
                : AllDestinationPage(
                    prevDestinationId: prevDestinationId,
                    ownCurrency: ownCurrency,
                    ownDecimal: ownDecimal,
                  ),
            builder: (context, child) => ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 480, name: MOBILE),
                const Breakpoint(start: 481, end: 1200, name: TABLET),
                const Breakpoint(
                  start: 1201,
                  end: double.infinity,
                  name: DESKTOP,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
