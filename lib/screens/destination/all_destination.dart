import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_event.dart';
import 'package:travel_notebook/blocs/destination/destination_state.dart';
import 'package:travel_notebook/components/error_msg.dart';
import 'package:travel_notebook/screens/home.dart';
import 'package:travel_notebook/screens/welcome.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/screens/destination/destination_detail.dart';
import 'package:travel_notebook/services/image_handler.dart';
import 'package:travel_notebook/screens/destination/widgets/destination_card.dart';
import 'package:travel_notebook/components/no_data.dart';

class AllDestinationPage extends StatefulWidget {
  final int? prevDestinationId;
  final String ownCurrency;
  final int ownDecimal;

  const AllDestinationPage({
    super.key,
    this.prevDestinationId,
    required this.ownCurrency,
    required this.ownDecimal,
  });

  @override
  State<AllDestinationPage> createState() => _AllDestinationPageState();
}

class _AllDestinationPageState extends State<AllDestinationPage> {
  late DestinationBloc _destinationBloc;
  late List<Destination> _destinations = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _init = true;
  int? _prevDestinationId;
  String _ownCurrency = "";
  int _ownDecimal = 2;

  bool _canPop = false;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();

    _prevDestinationId = widget.prevDestinationId;
    _ownCurrency = widget.ownCurrency;
    _ownDecimal = widget.ownDecimal;

    _destinationBloc = BlocProvider.of<DestinationBloc>(context);
    _destinationBloc.add(GetAllDestinations());
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _refreshPage() async {
    _destinationBloc.add(GetAllDestinations());
  }

  void _onWillPop() {
    DateTime now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );

      setState(() {
        _canPop = false;
      });
      return;
    }

    setState(() {
      _canPop = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }

        _onWillPop();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 90,
          title: const Text('My Destination'),
          actions: [
            GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WelcomePage(
                            ownCurrency: _ownCurrency,
                            ownDecimal: _ownDecimal,
                          )),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kPadding),
                child: Text(
                  _ownCurrency,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: kSecondaryColor, letterSpacing: 1),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kHalfPadding * 3),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  kPadding, kPadding / 4, kPadding, kHalfPadding),
              child: TextFormField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.done,
                style: const TextStyle(letterSpacing: .6),
                onChanged: (textValue) {
                  setState(() {
                    _searchQuery = textValue;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    borderSide:
                        BorderSide(color: kGreyColor.shade200, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    borderSide:
                        BorderSide(color: kGreyColor.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    borderSide:
                        BorderSide(color: kGreyColor.shade200, width: 1),
                  ),
                  fillColor: kGreyColor[100], // Add grey background
                  filled: true, // Enable fill color
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: kGreyColor),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: kHalfPadding, horizontal: kPadding),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: kHalfPadding * 2),
                    child: SizedBox(
                      child:
                          Center(widthFactor: 0.0, child: Icon(Icons.search)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshPage,
          child: BlocConsumer<DestinationBloc, DestinationState>(
            listener: (context, state) async {
              if (state is DestinationsLoaded) {
                _destinations = state.destinations;

                if (_prevDestinationId != null &&
                    _prevDestinationId! > 0 &&
                    _init) {
                  setState(() {
                    _init = false;
                  });

                  final destination = state.destinations
                      .where(
                        (destination) =>
                            destination.destinationId == _prevDestinationId,
                      )
                      .first;

                  destination.ownCurrency = _ownCurrency;
                  destination.ownDecimal = _ownDecimal;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              destination: destination,
                            )),
                  );
                }
              }

              if (state is DestinationUpdated) {
                _destinations[_destinations.indexWhere((destination) =>
                    destination.destinationId ==
                    state.destination.destinationId)] = state.destination;
              }
            },
            builder: (context, state) {
              if (state is DestinationLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DestinationError) {
                return ErrorMsg(
                  msg: state.message,
                  onTryAgain: () => _refreshPage(),
                );
              } else {
                final destinations = _destinations
                    .where((destination) => destination.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

                return destinations.isEmpty
                    ? const NoData(
                        msg: 'No Destination Found',
                        icon: Icons.location_on,
                      )
                    : ListView.builder(
                        itemCount: destinations.length,
                        itemBuilder: (context, index) {
                          final destination = destinations[index];
                          return DestinationCard(
                            destination: destination,
                            ownCurrency: _ownCurrency,
                            ownDecimal: _ownDecimal,
                            onDelete: () async {
                              await ImageHandler()
                                  .deleteImage(destination.imgPath);
                              _destinationBloc.add(DeleteDestination(
                                  destination.destinationId!));
                            },
                            onPin: () {
                              destination.isPin =
                                  destination.isPin == 1 ? 0 : 1;

                              _destinationBloc
                                  .add(UpdateDestination(destination));
                            },
                          );
                        },
                      );
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DestinationDetailPage(
                        ownCurrency: _ownCurrency,
                      )),
            );
          },
          tooltip: 'Create Destination',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
