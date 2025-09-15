import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/screens/destination/destination_detail.dart';
import 'package:travel_notebook/screens/home.dart';
import 'package:travel_notebook/services/utils.dart';
import 'package:travel_notebook/components/delete_dialog.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final String ownCurrency;
  final int ownDecimal;
  final Function() onDelete;
  final Function() onPin;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.ownCurrency,
    required this.ownDecimal,
    required this.onDelete,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('destinationId', destination.destinationId!);

        destination.ownCurrency = ownCurrency;
        destination.ownDecimal = ownDecimal;

        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomePage(
                    destination: destination,
                  )));
        }
      },
      child: Container(
        height: size.height * .285,
        margin: const EdgeInsets.symmetric(
            horizontal: kPadding, vertical: kHalfPadding),
        decoration: BoxDecoration(
          color: kGreyColor.shade500,
          borderRadius: BorderRadius.circular(kPadding),
          image: destination.imgPath.isEmpty
              ? null
              : DecorationImage(
                  opacity: 0.8,
                  fit: BoxFit.cover,
                  image: FileImage(File(destination.imgPath)),
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(kHalfPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: onPin,
                      icon: Icon(
                        destination.isPin == 1 ? Icons.star : Icons.star_border,
                        color: destination.isPin == 1
                            ? kAmberColor
                            : kSecondaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DestinationDetailPage(
                                            destination: destination,
                                            ownCurrency: ownCurrency,
                                          )));
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: kPrimaryColor,
                            )),
                        IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DeleteDialog(
                                    title: "Delete Destination",
                                    content:
                                        "Are you sure you want to delete this destination? All expenses records will be removed.",
                                    onConfirm: () {
                                      Navigator.pop(context);

                                      onDelete();
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
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(kPadding / 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(color: kWhiteColor),
                    ),
                    const SizedBox(height: kPadding / 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${formatDateWithoutYear(destination.startDate)} - ${formatDateWithoutYear(destination.endDate)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: kWhiteColor, fontSize: kPadding),
                        ),
                        Text(
                          formatDateWithYearOnly(destination.startDate),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: kWhiteColor, fontSize: kPadding),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
