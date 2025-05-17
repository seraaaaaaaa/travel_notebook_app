import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_state.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/services/utils.dart';
import 'package:travel_notebook/screens/currency/currency_input.dart';
import 'package:travel_notebook/components/section_title.dart';
import 'package:travel_notebook/themes/constants.dart';

class CurrencyConverter extends StatefulWidget {
  final Destination destination;

  const CurrencyConverter({
    super.key,
    required this.destination,
  });

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  late Destination _destination;

  final _ownCurrencyController = TextEditingController();
  final _foreignCurrencyController = TextEditingController();

  @override
  void initState() {
    _destination = widget.destination;

    super.initState();
  }

  @override
  void dispose() {
    _ownCurrencyController.dispose();
    _foreignCurrencyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DestinationBloc, DestinationState>(
      listener: (context, state) {
        if (state is DestinationUpdated) {
          setState(() {
            _destination = state.destination;
          });
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: kPadding * 1.25, vertical: kHalfPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: 'Currency Converter',
              subtitle:
                  '1 ${_destination.ownCurrency} = ${formatCurrency(_destination.rate, null, currency: _destination.currency)}',
            ),
            const SizedBox(
              height: kHalfPadding,
            ),
            CurrencyInput(
              controller: _ownCurrencyController,
              labelText: 'From',
              onChanged: (val) {
                double foreignAmount = calculateForeignCurrency(
                    parseDouble(val), _destination.rate);
                setState(() {
                  _foreignCurrencyController.text =
                      formatCurrency(foreignAmount, _destination.decimal);
                });
              },
              prefixText: _destination.ownCurrency,
              decimal: _destination.ownDecimal,
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(kPadding / 2),
                child: Icon(
                  Icons.swap_vert,
                  color: kSecondaryColor,
                  size: 28,
                ),
              ),
            ),
            CurrencyInput(
              controller: _foreignCurrencyController,
              labelText: 'To',
              onChanged: (val) {
                double ownAmount =
                    calculateOwnCurrency(_destination.rate, parseDouble(val));

                setState(() {
                  _ownCurrencyController.text =
                      formatCurrency(ownAmount, _destination.ownDecimal);
                });
              },
              prefixText: _destination.currency,
              decimal: _destination.decimal,
            ),
          ],
        ),
      ),
    );
  }
}
