import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_notebook/blocs/destination/destination_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_event.dart';
import 'package:travel_notebook/blocs/destination/destination_state.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/services/image_handler.dart';
import 'package:travel_notebook/services/utils.dart';
import 'package:travel_notebook/screens/destination/widgets/destination_input.dart';
import 'package:travel_notebook/screens/destination/widgets/select_image.dart';
import 'package:travel_notebook/components/section_title.dart';

class DestinationDetailPage extends StatefulWidget {
  final Destination? destination;
  final String ownCurrency;

  const DestinationDetailPage({
    super.key,
    this.destination,
    required this.ownCurrency,
  });

  @override
  State<DestinationDetailPage> createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late DestinationBloc _destinationBloc;
  late Destination _destination;

  bool _isAddNew = false;
  XFile? _selectedImg;

  @override
  void initState() {
    _destinationBloc = BlocProvider.of<DestinationBloc>(context);

    if (widget.destination == null) {
      _isAddNew = true;
      _destination = Destination(
          name: '',
          imgPath: '',
          startDate: null,
          endDate: null,
          budget: 0.00,
          currency: '',
          decimal: 0,
          rate: 0);
    } else {
      _destination = widget.destination!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocListener<DestinationBloc, DestinationState>(
        listener: (context, state) {
          if (state is DestinationError) {
            Navigator.pop(context);

            // Show an error message
            showToast(state.message, color: kRedColor);
          } else if (state is DestinationResult) {
            Navigator.pop(context);

            // Show a success message
            showToast(state.result);
          }
        },
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: kPadding, vertical: kPadding / 2),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Destination Details',
                      subtitle:
                          'Please fill in the information about your trip',
                    ),
                    const SizedBox(
                      height: kPadding,
                    ),
                    DestinationInput(
                      labelText: 'Destination Name',
                      initialValue: _destination.name,
                      onSaved: (val) {
                        _destination.name = val;
                      },
                      required: true,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DestinationInput(
                            labelText: 'Arrival Date',
                            initialValue: formatDate(_destination.startDate),
                            onSaved: (val) {
                              _destination.startDate = parseDateString(val);
                            },
                            inputType: 'date',
                            hintText: 'dd/mm/yyyy',
                          ),
                        ),
                        Expanded(
                          child: DestinationInput(
                            labelText: 'Departure Date',
                            initialValue: formatDate(_destination.endDate),
                            onSaved: (val) {
                              _destination.endDate = parseDateString(val);
                            },
                            inputType: 'date',
                            hintText: 'dd/mm/yyyy',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DestinationInput(
                            labelText: 'Currency',
                            initialValue: _destination.currency,
                            onSaved: (val) {
                              _destination.currency = val;
                            },
                            required: true,
                            inputType: 'uppercase',
                          ),
                        ),
                        Expanded(
                          child: DestinationInput(
                            labelText: 'Budget',
                            initialValue: _isAddNew
                                ? ''
                                : formatCurrency(
                                    _destination.budget,
                                    null,
                                  ),
                            onSaved: (val) {
                              _destination.budget =
                                  parseDouble(val.replaceAll(',', ''));
                            },
                            inputType: 'double',
                            decimal: _destination.decimal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DestinationInput(
                            labelText: 'Exchange Rate',
                            initialValue: _isAddNew
                                ? ''
                                : formatCurrency(
                                    _destination.rate,
                                    null,
                                  ),
                            onSaved: (val) {
                              _destination.rate =
                                  parseDouble(val.replaceAll(',', ''));
                            },
                            inputType: 'double',
                            prefixText: '1 ${widget.ownCurrency} =',
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kHalfPadding,
                          vertical: kPadding - kHalfPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Decimal Places',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: kTransparentColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    side: BorderSide(
                                        color: kSecondaryColor.shade100),
                                  ),
                                ),
                                padding: const EdgeInsets.all(0),
                                icon: const Icon(Icons.chevron_left),
                                color: kPrimaryColor,
                                onPressed: _destination.decimal <= 0
                                    ? null
                                    : () {
                                        setState(() {
                                          _destination.decimal--;
                                        });
                                      },
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: kPadding),
                                child: Text(
                                  _destination.decimal == 0
                                      ? 'N/A'
                                      : '.${'0' * _destination.decimal}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: .4,
                                      color: _destination.decimal == 0
                                          ? kGreyColor
                                          : null),
                                ),
                              ),
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: kTransparentColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    side: BorderSide(
                                        color: kSecondaryColor.shade100),
                                  ),
                                ),
                                padding: const EdgeInsets.all(0),
                                icon: const Icon(Icons.chevron_right),
                                color: kPrimaryColor,
                                onPressed: _destination.decimal >= 3
                                    ? null
                                    : () {
                                        setState(() {
                                          _destination.decimal++;
                                        });
                                      },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SelectImage(
                        initialImgPath: _destination.imgPath,
                        onSelected: (val) async {
                          setState(() {
                            _selectedImg = val;
                          });
                        }),
                  ]),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: ElevatedButton(
              onPressed: _saveDestination, child: const Text('Save')),
        ),
      ),
    );
  }

  void _saveDestination() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedImg != null) {
        String imgPath = await ImageHandler().saveImageToFolder(_selectedImg);
        _destination.imgPath = imgPath;
      }

      if (_isAddNew) {
        _destinationBloc.add(AddDestination(_destination));
      } else {
        _destinationBloc.add(UpdateDestination(_destination));
      }
    }
  }
}
