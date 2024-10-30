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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is DestinationResult) {
            Navigator.pop(context);

            // Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.result)),
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: kPadding, vertical: 8),
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
                                  : formatCurrency(_destination.budget),
                              onSaved: (val) {
                                _destination.budget =
                                    parseDouble(val.replaceAll(',', ''));
                              },
                              inputType: 'double',
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
                                  : formatCurrency(_destination.rate),
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
