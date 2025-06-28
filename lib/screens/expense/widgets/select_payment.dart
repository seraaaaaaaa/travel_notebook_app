import 'package:flutter/material.dart';
import 'package:travel_notebook/themes/constants.dart';

class SelectPayment extends StatefulWidget {
  final List<dynamic> choiceList;
  final dynamic selectedChoice;
  final Function(dynamic)? onSelectionChanged;

  const SelectPayment(
    this.choiceList,
    this.selectedChoice, {
    super.key,
    this.onSelectionChanged,
  });

  @override
  State<SelectPayment> createState() => _SelectPaymentState();
}

class _SelectPaymentState extends State<SelectPayment> {
  dynamic selectedChoice = "";

  _buildChoiceList() {
    List<Widget> choices = [];
    selectedChoice = widget.selectedChoice;
    for (var item in widget.choiceList) {
      choices.add(
        ChoiceChip(
          showCheckmark: false,
          side: BorderSide(color: kGreyColor.shade100),
          backgroundColor: kGreyColor.shade100,
          selectedColor: kPrimaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kHalfPadding * 2)),
          avatar: Padding(
            padding: const EdgeInsets.only(left: kHalfPadding / 2),
            child: Icon(
              item.icon,
              color: selectedChoice == item ? kWhiteColor : kGreyColor.shade800,
            ),
          ),
          label: Text(item.name),
          labelStyle: TextStyle(
              color:
                  selectedChoice == item ? kWhiteColor : kGreyColor.shade800),
          selected: selectedChoice == item,
          onSelected: (selected) {
            setState(() {
              selectedChoice = item;
            });
            if (widget.onSelectionChanged != null) {
              widget.onSelectionChanged!(selectedChoice);
            }
          },
        ),
      );
    }

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        spacing: kHalfPadding / 2,
        children: _buildChoiceList(),
      ),
    );
  }
}
