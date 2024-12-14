import 'package:flutter/material.dart';
import 'package:travel_notebook/themes/constants.dart';

class CategoryItem extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final bool selected;
  final Function() onTap;

  const CategoryItem({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 10, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              categoryName,
              style: TextStyle(
                  fontSize: 15,
                  letterSpacing: .6,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                  color: selected ? kSecondaryColor : kGreyColor),
            ),
            Container(
              width: 38.0,
              height: 4.0,
              color: selected ? kPrimaryColor : kTransparentColor,
              margin: const EdgeInsets.only(top: 4),
            ),
          ],
        ),
      ),
    );
  }
}
