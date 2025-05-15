import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:travel_notebook/themes/constants.dart';

class PercentIndicator extends StatelessWidget {
  final double percent;
  final String title;
  final Color color;

  const PercentIndicator({
    super.key,
    required this.percent,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: kHalfPadding, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  percent >= 1
                      ? 'Fully Used'
                      : 'Used ${(percent * 100).toInt()}%',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: percent >= 1 ? kRedColor : kSecondaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            barRadius: const Radius.circular(kPadding),
            lineHeight: kPadding,
            percent: percent,
            backgroundColor: kSecondaryColor.shade50,
            progressColor: color,
          ),
        ],
      ),
    );
  }
}
