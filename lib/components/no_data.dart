import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:travel_notebook/themes/constants.dart';

class NoData extends StatelessWidget {
  final String msg;
  final IconData? icon;

  const NoData({
    super.key,
    required this.msg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: kPadding * 1.5, vertical: kPadding),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: width /
                  (ResponsiveBreakpoints.of(
                    context,
                  ).largerThan(MOBILE)
                      ? 2
                      : 1.5),
              padding: const EdgeInsets.symmetric(
                  horizontal: kPadding, vertical: kHalfPadding),
              decoration: BoxDecoration(
                  color: kGreyColor.shade50,
                  borderRadius: BorderRadius.circular(kPadding / 2),
                  boxShadow: [
                    BoxShadow(
                      color: kGreyColor.shade300,
                      offset: const Offset(1, 2),
                      blurRadius: 3,
                    ),
                  ]),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: kHalfPadding),
                    child: Icon(
                      icon ?? Icons.reorder,
                      color: kPrimaryColor.withValues(alpha: .4),
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(kHalfPadding / 2),
                            color: kGreyColor.shade200,
                          ),
                          height: 14,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: kPadding / 2),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(kHalfPadding / 2),
                            color: kGreyColor.shade200,
                          ),
                          height: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: kPadding),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: width /
                  (ResponsiveBreakpoints.of(
                    context,
                  ).largerThan(MOBILE)
                      ? 2
                      : 1.5),
              padding: const EdgeInsets.symmetric(
                  horizontal: kPadding, vertical: kHalfPadding),
              decoration: BoxDecoration(
                  color: kGreyColor.shade50,
                  borderRadius: BorderRadius.circular(kPadding / 2),
                  boxShadow: [
                    BoxShadow(
                      color: kGreyColor.shade300,
                      offset: const Offset(1, 2),
                      blurRadius: 3,
                    ),
                  ]),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: kHalfPadding),
                    child: Icon(
                      icon ?? Icons.reorder,
                      color: kCyanColor.withValues(alpha: .4),
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(kHalfPadding / 2),
                            color: kGreyColor.shade200,
                          ),
                          height: 14,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: kPadding / 2),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(kHalfPadding / 2),
                            color: kGreyColor.shade200,
                          ),
                          height: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              msg,
              style: const TextStyle(
                  letterSpacing: .4, color: kGreyColor, height: 1.4),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
