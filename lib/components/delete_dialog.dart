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
        backgroundColor: Colors.grey.shade200,
        foregroundColor: kSecondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: kPadding),
      ),
      onPressed: onCancel,
      child: const Text("Cancel"),
    );

    Widget confirmButton = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: kWhiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: kPadding),
      ),
      onPressed: onConfirm,
      child: const Text("Confirm"),
    );

    return AlertDialog(
      icon: const Icon(
        Icons.auto_delete_outlined,
        color: Colors.red,
        size: 35,
      ),
      iconPadding: const EdgeInsets.only(top: 34, bottom: 10),
      title: Text(title),
      content: Text(
        content,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        cancelButton,
        confirmButton,
      ],
    );
  }
}
