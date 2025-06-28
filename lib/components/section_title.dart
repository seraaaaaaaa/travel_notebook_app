import 'package:flutter/material.dart';
import 'package:travel_notebook/themes/constants.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final String btnText;
  final Function()? btnAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle = '',
    this.btnText = '',
    this.btnAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: kHalfPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
            ],
          ),
          if (btnText.isNotEmpty)
            TextButton(
              onPressed: btnAction,
              child: Text(btnText),
            ),
        ],
      ),
    );
  }
}
