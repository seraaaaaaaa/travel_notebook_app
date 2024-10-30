import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.only(top: 10),
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
              subtitle.isEmpty
                  ? Container()
                  : Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
            ],
          ),
          btnText.isEmpty
              ? Container()
              : TextButton(
                  onPressed: btnAction,
                  child: Text(btnText),
                ),
        ],
      ),
    );
  }
}
