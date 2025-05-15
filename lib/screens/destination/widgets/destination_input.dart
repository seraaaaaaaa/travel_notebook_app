import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:travel_notebook/themes/constants.dart';

class DestinationInput extends StatefulWidget {
  final String labelText;
  final String initialValue;
  final Function(String)? onSaved;
  final String? inputType; //'double', 'date', 'image', 'uppercase', ''
  final String prefixText;
  final String hintText;
  final bool required;
  final int decimal;

  const DestinationInput({
    super.key,
    required this.labelText,
    required this.initialValue,
    required this.onSaved,
    this.inputType,
    this.prefixText = '',
    this.hintText = '',
    this.required = false,
    this.decimal = 2,
  });

  @override
  State<DestinationInput> createState() => _DestinationInputState();
}

class _DestinationInputState extends State<DestinationInput> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: kHalfPadding, horizontal: kHalfPadding / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: widget.initialValue,
            inputFormatters: widget.inputType == 'date'
                ? [MaskTextInputFormatter(mask: "##/##/####")]
                : widget.inputType == 'double'
                    ? [
                        CurrencyTextInputFormatter.simpleCurrency(
                          decimalDigits: widget.decimal,
                          name: '',
                        )
                      ]
                    : null,
            keyboardType:
                widget.inputType == 'date' || widget.inputType == 'double'
                    ? TextInputType.number
                    : null,
            textCapitalization: widget.inputType == 'uppercase'
                ? TextCapitalization.characters
                : TextCapitalization.words,
            autovalidateMode:
                widget.inputType == 'date' ? AutovalidateMode.onUnfocus : null,
            validator: (value) {
              if (widget.required) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }

                if (widget.inputType == 'date') {
                  final components = value.split("/");
                  if (components.length == 3) {
                    final day = int.tryParse(components[0]);
                    final month = int.tryParse(components[1]);
                    final year = int.tryParse(components[2]);

                    if (day != null && month != null && year != null) {
                      final date = DateTime(year, month, day);

                      // Check if it's a valid date
                      if (date.year == year &&
                          date.month == month &&
                          date.day == day) {
                        return null; // Valid date
                      }
                    }
                  }

                  return "Invalid date";
                }
              }

              return null;
            },
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            style: const TextStyle(letterSpacing: .6),
            textAlign:
                widget.inputType == 'double' ? TextAlign.end : TextAlign.start,
            onSaved: (newValue) {
              if (widget.onSaved != null) {
                widget.onSaved!(newValue ?? '');
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: kWhiteColor,
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                  color: kGreyColor, fontWeight: FontWeight.normal),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    const BorderRadius.all(Radius.circular(kPadding / 4)),
                borderSide: BorderSide(color: kGreyColor.shade300, width: 1),
              ),
              prefixIcon: widget.prefixText.isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: SizedBox(
                        child: Center(
                          widthFactor: 0.0,
                          child: Text(
                            widget.prefixText,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: kSecondaryColor),
                          ),
                        ),
                      ),
                    ),
              border: OutlineInputBorder(
                borderRadius:
                    const BorderRadius.all(Radius.circular(kPadding / 4)),
                borderSide: BorderSide(color: kGreyColor.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    const BorderRadius.all(Radius.circular(kPadding / 4)),
                borderSide:
                    BorderSide(color: kSecondaryColor.shade200, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
