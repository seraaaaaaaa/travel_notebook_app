import 'package:flutter/material.dart';
import 'package:travel_notebook/themes/constants.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double width;
  final double height;
  final double padding;
  final BorderRadius? borderRadius;
  final String tooltipMsg;

  const Indicator({
    super.key,
    required this.color,
    this.text = '',
    required this.isSquare,
    this.width = kHalfPadding + 2,
    this.height = kHalfPadding + 2,
    this.padding = kPadding / 2,
    this.borderRadius,
    this.tooltipMsg = '',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      verticalOffset: -50,
      triggerMode: TooltipTriggerMode.tap,
      message: tooltipMsg,
      child: Container(
        padding: EdgeInsets.all(padding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
                color: color,
              ),
            ),
            if (text.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(left: kHalfPadding / 2),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
          ],
        ),
      ),
    );
  }
}
