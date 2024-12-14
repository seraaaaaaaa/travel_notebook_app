import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:travel_notebook/themes/constants.dart';

class ErrorMsg extends StatelessWidget {
  final String msg;
  final Function()? onTryAgain;

  const ErrorMsg({
    super.key,
    this.msg = '',
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: kPadding,
          ),
          SvgPicture.asset(
            'assets/images/error.svg',
            height: size.height * .18,
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            'Something Went Wrong',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Text(
              msg,
              style:
                  Theme.of(context).textTheme.labelLarge!.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: kPadding,
          ),
          SizedBox(
            width: size.width / 2,
            child: TextButton(
              onPressed: onTryAgain,
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }
}
