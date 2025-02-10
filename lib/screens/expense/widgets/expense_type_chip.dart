import 'package:flutter/material.dart';
import 'package:travel_notebook/themes/constants.dart';

class ExpenseTypeChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ExpenseTypeChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: ChoiceChip(
        showCheckmark: false,
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        side: BorderSide(color: kSecondaryColor.shade100),
        selectedColor: kGreyColor.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        label: Text(label),
        labelStyle: TextStyle(
          color: selected ? kPrimaryColor : kGreyColor.shade800,
        ),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
