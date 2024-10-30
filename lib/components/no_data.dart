import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: kPadding),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: width / 1.5,
              padding: const EdgeInsets.symmetric(
                  horizontal: kPadding, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(1, 2),
                      blurRadius: 3,
                    ),
                  ]),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Icon(
                      icon ?? Icons.reorder,
                      color: kPrimaryColor.withOpacity(.4),
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey.shade200,
                          ),
                          height: 14,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey.shade200,
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
              width: width / 1.5,
              padding: const EdgeInsets.symmetric(
                  horizontal: kPadding, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(1, 2),
                      blurRadius: 3,
                    ),
                  ]),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Icon(
                      icon ?? Icons.reorder,
                      color: Colors.cyan.withOpacity(.4),
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey.shade200,
                          ),
                          height: 14,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey.shade200,
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
