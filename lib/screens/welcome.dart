import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/screens/destination/all_destination.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _currencyController = TextEditingController();

  String _ownCurrency = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }

  void _navigateToAllDestinationPage() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => AllDestinationPage(
                    ownCurrency: _ownCurrency,
                  )),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(
                'assets/images/welcome.svg',
                // height: MediaQuery.of(context).size.height * .5,
              ),
              Text(
                'Welcome to Travel Notebook',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your all-in-one travel companion for organizing destinations and tracking expenses effortlessly',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    color: kGreyColor,
                    height: 1.4,
                    letterSpacing: .4),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _currencyController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required'; // Allow empty value (if needed)
                  }

                  return null;
                },
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.done,
                style: const TextStyle(letterSpacing: .6),
                textAlign: TextAlign.start,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kWhiteColor,
                  hintText: 'Enter your currency',
                  hintStyle: const TextStyle(
                      color: kGreyColor, fontWeight: FontWeight.normal),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    borderSide:
                        BorderSide(color: kGreyColor.shade300, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    borderSide:
                        BorderSide(color: kGreyColor.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    borderSide:
                        BorderSide(color: kSecondaryColor.shade200, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () async {
                  _ownCurrency = _currencyController.text;
                  if (_ownCurrency.isNotEmpty) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('currency', _ownCurrency);

                    _navigateToAllDestinationPage();
                  } else {
                    // Navigate to the next page or show a message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter your currency')),
                    );
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
      ),
    );
  }
}
