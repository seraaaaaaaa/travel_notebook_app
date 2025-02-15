import 'package:travel_notebook/models/destination/destination_field.dart';
import 'package:travel_notebook/services/utils.dart';

class Destination {
  late int? destinationId;
  late String name;
  late String imgPath;
  late DateTime? startDate;
  late DateTime? endDate;
  late double budget;
  late String currency;
  late int decimal;
  late double rate;
  late int isPin;
  late double totalExpense;
  late double totalTransport;
  late double totalMeal;
  late double totalMisc;

  late double transportPercent;
  late double mealPercent;
  late double miscPercent;

  late double budgetRemaining;
  late double budgetPercent;

  late String ownCurrency;
  late int ownDecimal;

  Destination({
    this.destinationId,
    required this.name,
    required this.imgPath,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.currency,
    required this.decimal,
    required this.rate,
    this.isPin = 0,
    this.totalExpense = 0.0,
    this.totalTransport = 0.0,
    this.totalMeal = 0.0,
    this.totalMisc = 0.0,
    this.transportPercent = 0.0,
    this.mealPercent = 0.0,
    this.miscPercent = 0.0,
    this.budgetRemaining = 0.0,
    this.budgetPercent = 0.0,
    this.ownCurrency = '',
    this.ownDecimal = 0,
  });

  factory Destination.fromJson(Map<String, Object?> json) {
    double budget = json[DestinationField.budget] as double;
    double totalExpense = json[DestinationField.totalExpense] as double;
    double totalTransport = json[DestinationField.totalTransport] as double;
    double totalMeal = json[DestinationField.totalMeal] as double;
    double totalMisc = json[DestinationField.totalMisc] as double;

    double transportPercent = (totalExpense > 0 && totalTransport > 0)
        ? (totalTransport / totalExpense).clamp(0.0, 1.0)
        : 0.0;

    double mealPercent = (totalExpense > 0 && totalMeal > 0)
        ? (totalMeal / totalExpense).clamp(0.0, 1.0)
        : 0.0;

    double miscPercent = (totalExpense > 0 && totalMisc > 0)
        ? (totalMisc / totalExpense).clamp(0.0, 1.0)
        : 0.0;

    double budgetRemaining = budget > 0 ? budget - totalExpense : 0.0;

    double budgetPercent = (totalExpense > 0 && budget > 0)
        ? (totalExpense / budget).clamp(0.0, 1.0)
        : 0.0;

    return Destination(
      destinationId: json[DestinationField.destinationId] as int,
      name: json[DestinationField.name] as String,
      imgPath: json[DestinationField.imgPath] as String,
      startDate: parseDateTime(json[DestinationField.startDate]),
      endDate: parseDateTime(json[DestinationField.endDate]),
      budget: budget,
      currency: json[DestinationField.currency] as String,
      decimal: json[DestinationField.decimal] != null
          ? json[DestinationField.decimal] as int
          : 0,
      rate: json[DestinationField.rate] as double,
      isPin: json[DestinationField.isPin] as int,
      totalExpense: totalExpense,
      totalTransport: totalTransport,
      totalMeal: totalMeal,
      totalMisc: totalMisc,
      transportPercent: transportPercent,
      mealPercent: mealPercent,
      miscPercent: miscPercent,
      budgetRemaining: budgetRemaining,
      budgetPercent: budgetPercent,
    );
  }

  Map<String, Object?> toJson() => {
        DestinationField.destinationId: destinationId,
        DestinationField.name: name,
        DestinationField.imgPath: imgPath,
        DestinationField.startDate: startDate?.toIso8601String(),
        DestinationField.endDate: endDate?.toIso8601String(),
        DestinationField.budget: budget,
        DestinationField.currency: currency,
        DestinationField.decimal: decimal,
        DestinationField.rate: rate,
        DestinationField.isPin: isPin,
        DestinationField.totalExpense: totalExpense,
        DestinationField.totalTransport: totalTransport,
        DestinationField.totalMeal: totalMeal,
        DestinationField.totalMisc: totalMisc,
      };
}
