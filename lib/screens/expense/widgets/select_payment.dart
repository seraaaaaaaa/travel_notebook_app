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
      choices.add(Container(
        padding: const EdgeInsets.all(4.0),
        child: ChoiceChip(
          showCheckmark: false,
          side: BorderSide(color: kGreyColor.shade100),
          backgroundColor: kGreyColor.shade100,
          selectedColor: kPrimaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          avatar: Icon(
            item.icon,
            color: selectedChoice == item ? kWhiteColor : kGreyColor.shade800,
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
      ));
    }

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        children: _buildChoiceList(),
      ),
    );
  }
}
