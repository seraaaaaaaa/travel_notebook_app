import 'package:travel_notebook/models/expense/expense_field.dart';
import 'package:travel_notebook/services/utils.dart';

class Expense {
  late int? expenseId;
  late int destinationId;
  late double amount;
  late double converted;
  late String paymentMethod;
  late int typeNo; //1-Transportation, 2-Meal, 3-Miscellaneous
  late String typeName;
  late String remark;
  late String receiptImg;
  late DateTime? createdTime;
  late int excludeBudget; // 1-true, 0-false

  Expense({
    this.expenseId,
    required this.destinationId,
    required this.amount,
    required this.converted,
    required this.paymentMethod,
    required this.typeNo,
    required this.typeName,
    required this.remark,
    this.receiptImg = '',
    this.createdTime,
    this.excludeBudget = 0,
  });

  factory Expense.fromJson(Map<String, Object?> json) => Expense(
        expenseId: json[ExpenseField.expenseId] as int,
        destinationId: json[ExpenseField.destinationId] as int,
        amount: json[ExpenseField.amount] as double,
        converted: json[ExpenseField.converted] as double,
        paymentMethod: json[ExpenseField.paymentMethod] as String,
        typeNo: json[ExpenseField.typeNo] as int,
        typeName: json[ExpenseField.typeName] as String,
        remark: json[ExpenseField.remark] as String,
        receiptImg: json[ExpenseField.receiptImg] as String,
        createdTime: parseDateTime(json[ExpenseField.createdTime]),
        excludeBudget: json[ExpenseField.excludeBudget] as int,
      );

  Map<String, Object?> toJson() => {
        ExpenseField.expenseId: expenseId,
        ExpenseField.destinationId: destinationId,
        ExpenseField.amount: amount,
        ExpenseField.converted: converted,
        ExpenseField.paymentMethod: paymentMethod,
        ExpenseField.typeNo: typeNo,
        ExpenseField.typeName: typeName,
        ExpenseField.remark: remark,
        ExpenseField.receiptImg: receiptImg,
        ExpenseField.createdTime: createdTime?.toIso8601String(),
        ExpenseField.excludeBudget: excludeBudget,
      };
}
