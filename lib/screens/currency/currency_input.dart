import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/services/utils.dart';

class CurrencyInput extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final Function(String)? onChanged;
  final String prefixText;
  final int decimal;

  const CurrencyInput({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onChanged,
    required this.prefixText,
    required this.decimal,
  });

  @override
  State<CurrencyInput> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: kPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: kSecondaryColor),
          ),
          const SizedBox(
            height: kHalfPadding,
          ),
          TextFormField(
            onTap: () => widget.controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: widget.controller.value.text.length),
            controller: widget.controller,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              CurrencyTextInputFormatter.simpleCurrency(
                  decimalDigits: widget.decimal, name: ''),
            ],
            enableInteractiveSelection: false,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.done,
            style: TextStyle(
                letterSpacing: 1,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: kGreyColor.shade800),
            textAlign: TextAlign.end,
            onChanged: widget.onChanged,
            onEditingComplete: () {
              widget.controller.text = formatCurrency(
                  parseDouble(widget.controller.text), widget.decimal);
            },
            onTapOutside: (event) {
              widget.controller.text = formatCurrency(
                  parseDouble(widget.controller.text), widget.decimal);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(kPadding),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: kPadding),
                child: SizedBox(
                  child: Center(
                    widthFactor: 0.0,
                    child: Text(
                      widget.prefixText,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: kPrimaryColor,
                          letterSpacing: 1.5),
                    ),
                  ),
                ),
              ),
              filled: true,
              fillColor: kSecondaryColor.shade50,
              enabledBorder: InputBorder.none,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
