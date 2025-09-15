import 'package:flutter/material.dart';
import 'package:travel_notebook/themes/constants.dart';

class DeleteDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DeleteDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = TextButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: kGreyColor.shade200,
        foregroundColor: kSecondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kHalfPadding / 2),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: kHalfPadding * 2.5, vertical: kHalfPadding),
      ),
      onPressed: onCancel,
      child: const Text("No, Cancel"),
    );

    Widget confirmButton = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: kRedColor,
        foregroundColor: kWhiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kHalfPadding / 2),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: kHalfPadding * 2.5, vertical: kHalfPadding),
      ),
      onPressed: onConfirm,
      child: const Text(
        "Yes, Delete",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kHalfPadding),
      ),
      title: Text(title),
      content: Text(
        content,
        style: Theme.of(context)
            .textTheme
            .labelLarge!
            .copyWith(color: kSecondaryColor),
      ),
      actionsOverflowButtonSpacing: kHalfPadding,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        cancelButton,
        confirmButton,
      ],
    );
  }
}
