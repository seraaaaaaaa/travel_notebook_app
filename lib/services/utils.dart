import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/models/expense/expense_model.dart';
import 'package:travel_notebook/themes/constants.dart';

// Function to format date
String formatDate(DateTime? date) {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  return date == null ? "" : dateFormat.format(date);
}

String formatDateWithTime(DateTime? date) {
  final DateFormat dateFormat = DateFormat('dd MMM yyyy \n hh:mm a');
  return date == null ? "" : dateFormat.format(date);
}

String formatDateWithTimeAndDay(DateTime? date) {
  final DateFormat dateFormat = DateFormat('EEE dd MMM yyyy hh:mm a');
  return date == null ? "" : dateFormat.format(date);
}

String formatDateWithoutYear(DateTime? date) {
  final DateFormat dateFormat = DateFormat('MMM dd');
  return date == null ? "" : dateFormat.format(date).toUpperCase();
}

String formatDateWithYearOnly(DateTime? date) {
  final DateFormat dateFormat = DateFormat('yyyy');
  return date == null ? "" : dateFormat.format(date).toUpperCase();
}

// Function to parse date string to DateTime
DateTime? parseDateString(String dateString) {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  return dateString.isEmpty ? null : dateFormat.parse(dateString);
}

DateTime? parseDateTime(dynamic val) => DateTime.tryParse(val as String? ?? '');

double parseDouble(String amount) {
  try {
    return double.parse(amount.replaceAll(",", ""));
  } catch (e) {
    // Return 0.0 if parsing fails
    return 0.0;
  }
}

String formatPercentage(double amount) {
  return '${(amount * 100).toStringAsFixed(0)}%';
}

String formatCurrency(double amount, int? decimal, {String currency = ''}) {
  // Create a NumberFormat without a symbol
  final NumberFormat currencyFormatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: amount == amount.roundToDouble() ? 0 : decimal);

  // Add a space only if the currency symbol is not empty
  currency = currency.isEmpty ? '' : '$currency ';

  return currency + currencyFormatter.format(amount);
}

String capitalizeFirst(String s) => s[0].toUpperCase() + s.substring(1);

double calculateOwnCurrency(double rate, double foreignAmount) {
  return (rate == 0 || foreignAmount == 0) ? 0.0 : foreignAmount / rate;
}

double calculateForeignCurrency(double ownAmount, double rate) {
  return (rate == 0 || ownAmount == 0) ? 0.0 : ownAmount * rate;
}

void updateTotalExpenses(Expense expense, Destination destination) {
  if (expense.excludeBudget == 1) return;

  destination.totalExpense += expense.amount;

  if (expense.typeNo == 1) {
    //transportation
    destination.totalTransport += expense.amount;
  } else if (expense.typeNo == 2) {
    //meal
    destination.totalMeal += expense.amount;
  } else if (expense.typeNo == 3) {
    //misc
    destination.totalMisc += expense.amount;
  }
}

void deductTotalExpenses(Expense expense, Destination destination) {
  if (expense.excludeBudget == 1) return;

  destination.totalExpense -= expense.amount;

  if (expense.typeNo == 1) {
    //transportation
    destination.totalTransport -= expense.amount;
  } else if (expense.typeNo == 2) {
    //meal
    destination.totalMeal -= expense.amount;
  } else if (expense.typeNo == 3) {
    //misc
    destination.totalMisc -= expense.amount;
  }
}

void showToast(String message, {Color color = kBlackColor}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: color,
    textColor: kWhiteColor,
  );
}
