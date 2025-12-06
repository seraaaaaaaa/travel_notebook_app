import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/models/expense/enum/expense_type.dart';
import 'package:travel_notebook/services/utils.dart';
import 'package:travel_notebook/screens/expense/widgets/indicator.dart';

class PieChartWidget extends StatefulWidget {
  final Destination destination;

  const PieChartWidget({
    super.key,
    required this.destination,
  });

  @override
  State<PieChartWidget> createState() => PieChartWidgetState();
}

class PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;
  bool showForeignCurrency = true;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ResponsiveBreakpoints.of(
        context,
      ).largerThan(MOBILE)
          ? 2
          : 1.5,
      child: Column(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: kHalfPadding,
                      centerSpaceRadius: ResponsiveBreakpoints.of(
                        context,
                      ).largerThan(MOBILE)
                          ? 120
                          : 70,
                      sections: showingSections(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showForeignCurrency = !showForeignCurrency;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remaining',
                          style: Theme.of(context).textTheme.labelLarge!,
                        ),
                        const SizedBox(
                          height: kHalfPadding / 2,
                        ),
                        Text(
                          !showForeignCurrency
                              ? formatCurrency(
                                  calculateOwnCurrency(widget.destination.rate,
                                      widget.destination.budgetRemaining),
                                  widget.destination.ownDecimal)
                              : formatCurrency(
                                  widget.destination.budgetRemaining,
                                  widget.destination.decimal),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          !showForeignCurrency
                              ? widget.destination.ownCurrency
                              : widget.destination.currency,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: kPadding),
          Wrap(
            alignment: WrapAlignment.center,
            children: <Widget>[
              Indicator(
                color: ExpenseType.transportation.color!,
                text: ExpenseType.transportation.name,
                isSquare: false,
                tooltipMsg: formatCurrency(
                  widget.destination.totalTransport,
                  widget.destination.decimal,
                  currency: widget.destination.currency,
                ),
              ),
              Indicator(
                color: ExpenseType.meal.color!,
                text: ExpenseType.meal.name,
                isSquare: false,
                tooltipMsg: formatCurrency(
                  widget.destination.totalMeal,
                  widget.destination.decimal,
                  currency: widget.destination.currency,
                ),
              ),
              Indicator(
                color: ExpenseType.miscellaneous.color!,
                text: ExpenseType.miscellaneous.name,
                isSquare: false,
                tooltipMsg: formatCurrency(
                  widget.destination.totalMisc,
                  widget.destination.decimal,
                  currency: widget.destination.currency,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    Destination destination = widget.destination;

    return destination.totalExpense == 0
        ? List.generate(1, (i) {
            final isTouched = i == touchedIndex;
            final radius = isTouched ? 45.0 : 35.0;

            switch (i) {
              case 0:
                return PieChartSectionData(
                  color: kSecondaryColor.shade50,
                  value: 100,
                  title: '0%',
                  showTitle: isTouched,
                  radius: radius,
                  titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1),
                );

              default:
                throw Error();
            }
          })
        : List.generate(3, (i) {
            final isTouched = i == touchedIndex;
            final radius = isTouched ? 45.0 : 35.0;

            switch (i) {
              case 0:
                return PieChartSectionData(
                  color: ExpenseType.meal.color!,
                  value: destination.mealPercent * 100,
                  title: formatPercentage(destination.mealPercent),
                  showTitle: isTouched,
                  radius: radius,
                  titleStyle: const TextStyle(
                      color: kWhiteColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                );
              case 1:
                return PieChartSectionData(
                  color: ExpenseType.transportation.color!,
                  value: destination.transportPercent * 100,
                  title: formatPercentage(destination.transportPercent),
                  showTitle: isTouched,
                  radius: radius,
                  titleStyle: const TextStyle(
                      color: kWhiteColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                );
              case 2:
                return PieChartSectionData(
                  color: ExpenseType.miscellaneous.color!,
                  value: destination.miscPercent * 100,
                  title: formatPercentage(destination.miscPercent),
                  showTitle: isTouched,
                  radius: radius,
                  titleStyle: const TextStyle(
                      color: kWhiteColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                );

              default:
                throw Error();
            }
          });
  }
}
