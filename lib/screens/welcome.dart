import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_notebook/services/utils.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/screens/destination/all_destination.dart';

class WelcomePage extends StatefulWidget {
  final String ownCurrency;
  final int ownDecimal;

  const WelcomePage({
    super.key,
    this.ownCurrency = '',
    this.ownDecimal = 2,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _currencyController = TextEditingController();
  final FocusNode _currencyFocusNode = FocusNode();

  String _ownCurrency = "";
  int _ownDecimal = 2;
  bool _init = true;

  @override
  void initState() {
    super.initState();

    _ownCurrency = widget.ownCurrency;
    _ownDecimal = widget.ownDecimal;

    if (_ownCurrency.isNotEmpty) {
      _currencyController.text = _ownCurrency;
      _init = false;
    }
  }

  @override
  void dispose() {
    _currencyController.dispose();
    _currencyFocusNode.dispose();
    super.dispose();
  }

  void _navigateToAllDestinationPage() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => AllDestinationPage(
                  ownCurrency: _ownCurrency, ownDecimal: _ownDecimal)),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.425;

    return Scaffold(
      appBar: _init
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.keyboard_backspace),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadding * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/icon/icon.png',
              height: height,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: kPadding),
            Text(
              'Welcome to Travel Notebook',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: kPadding / 2),
            const Text(
              'Your all-in-one travel companion for organizing destinations and tracking expenses effortlessly',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: kGreyColor,
                  height: 1.6,
                  letterSpacing: .4),
            ),
            const SizedBox(height: kPadding * 2.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Row(
                  children: [
                    const Icon(Icons.attach_money, color: kPrimaryColor),
                    const SizedBox(width: kHalfPadding),
                    Text(
                      'Your Currency',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: kGreyColor),
                    ),
                  ],
                )),
                Expanded(
                  child: TextFormField(
                    controller: _currencyController,
                    focusNode: _currencyFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required'; // Allow empty value (if needed)
                      }

                      return null;
                    },
                    autofocus: _init,
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(
                        letterSpacing: 1.2,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.end,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: kHalfPadding),
              ],
            ),
            const SizedBox(height: kHalfPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.more_horiz, color: kPrimaryColor),
                      const SizedBox(width: kHalfPadding),
                      Text(
                        'Decimal Places',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: kGreyColor),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.chevron_left),
                      color: kPrimaryColor,
                      onPressed: _ownDecimal <= 0
                          ? null
                          : () {
                              setState(() {
                                _ownDecimal--;
                              });
                            },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: kPadding),
                      child: Text(
                        _ownDecimal == 0 ? 'N/A' : '.${'0' * _ownDecimal}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: _ownDecimal == 0 ? kGreyColor : null),
                      ),
                    ),
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.chevron_right),
                      color: kPrimaryColor,
                      onPressed: _ownDecimal >= 3
                          ? null
                          : () {
                              setState(() {
                                _ownDecimal++;
                              });
                            },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: kPadding * 2.5),
            TextButton(
              onPressed: () async {
                _ownCurrency = _currencyController.text;
                if (_ownCurrency.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('currency', _ownCurrency);
                  await prefs.setInt('decimalPlaces', _ownDecimal);

                  _navigateToAllDestinationPage();
                } else {
                  _currencyFocusNode.requestFocus(); // Focus the input

                  showToast('Please enter your currency');
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kWhiteColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
