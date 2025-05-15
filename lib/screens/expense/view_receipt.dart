import 'dart:io';
import 'package:flutter/material.dart';
import 'package:travel_notebook/services/image_handler.dart';
import 'package:travel_notebook/components/delete_dialog.dart';
import 'package:travel_notebook/themes/constants.dart';

class ViewReceipt extends StatelessWidget {
  final String imagePath;
  final Function(String) onDeleteImage;

  const ViewReceipt({
    super.key,
    required this.imagePath,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: kPadding / 2),
            child: IconButton(
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeleteDialog(
                        title: "Delete Image",
                        content: "Are you sure you want to delete this image?",
                        onConfirm: () async {
                          Navigator.pop(context); // pop dialog
                          Navigator.pop(context, 'deleted'); // pop page

                          await ImageHandler().deleteImage(imagePath);

                          onDeleteImage('');
                        },
                        onCancel: () {
                          Navigator.pop(context);
                        },
                      );
                    });
              },
              icon: const Icon(
                Icons.delete_outline,
                color: kRedColor,
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: FutureBuilder<bool>(
            future: File(imagePath).exists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show loading indicator while image is loading
                return const CircularProgressIndicator();
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  !snapshot.data!) {
                // If image loading fails
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 60,
                      color: kGreyColor.shade300,
                    ),
                    const SizedBox(
                      height: kHalfPadding,
                    ),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                          letterSpacing: .4,
                          color: kGreyColor.shade400,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              } else {
                // Show the image if it exists
                return Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Failed to display image',
                        style: TextStyle(fontSize: 18));
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
