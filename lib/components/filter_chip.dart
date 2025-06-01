import 'package:flutter/material.dart';
import 'package:travel_notebook/themes/constants.dart';

class FilterChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: kHalfPadding),
      child: ChoiceChip(
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(
            vertical: kPadding - kHalfPadding, horizontal: kPadding / 2),
        side: BorderSide(color: kGreyColor.shade300),
        selectedColor: kSecondaryColor.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kHalfPadding * 2),
        ),
        label: Text(label),
        labelStyle: TextStyle(
          color: selected ? kPrimaryColor : kGreyColor.shade800,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
