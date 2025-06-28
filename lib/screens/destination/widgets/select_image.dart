import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_notebook/services/image_handler.dart';
import 'package:travel_notebook/themes/constants.dart';

class SelectImage extends StatefulWidget {
  final String initialImgPath;
  final Function(XFile?)? onSelected;

  const SelectImage({
    super.key,
    required this.initialImgPath,
    required this.onSelected,
  });

  @override
  State<SelectImage> createState() => _SelectImageState();
}

class _SelectImageState extends State<SelectImage> {
  XFile? _selectedImg;

  @override
  void initState() {
    _convertImgToXFile(widget.initialImgPath);

    super.initState();
  }

  void _convertImgToXFile(String imgPath) {
    if (imgPath.isNotEmpty) {
      setState(() {
        _selectedImg = XFile(imgPath);
      });
    }
  }

  Future<void> _selectImg() async {
    XFile? file = await ImageHandler().selectImgFromGallery();

    if (file != null) {
      setState(() {
        _selectedImg = file;
      });

      if (widget.onSelected != null) {
        widget.onSelected!(_selectedImg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _selectedImg != null
              ? null
              : () async {
                  _selectImg();
                },
          child: Container(
            margin: const EdgeInsets.symmetric(
                vertical: kHalfPadding, horizontal: kPadding / 2),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .28,
            decoration: BoxDecoration(
              color: kSecondaryColor.shade50,
              border: Border.all(
                color: kGreyColor.shade300,
                width: 1.0,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(kPadding / 4),
              ),
            ),
            child: _selectedImg != null
                ? Image.file(
                    File(_selectedImg!.path),
                    fit: BoxFit.cover,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image,
                        size: kHalfPadding * 3,
                        color: kGreyColor,
                      ),
                      const SizedBox(height: kHalfPadding / 2),
                      Text(
                        'Select Image',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
          ),
        ),
        if (_selectedImg != null)
          Positioned(
              top: 20,
              right: 20,
              child: TextButton(
                  onPressed: () {
                    _selectImg();
                  },
                  child: const Text('Change'))),
      ],
    );
  }
}
