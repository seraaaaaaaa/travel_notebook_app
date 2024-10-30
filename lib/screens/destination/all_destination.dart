import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_event.dart';
import 'package:travel_notebook/blocs/destination/destination_state.dart';
import 'package:travel_notebook/screens/home.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/screens/destination/destination_detail.dart';
import 'package:travel_notebook/services/image_handler.dart';
import 'package:travel_notebook/screens/destination/widgets/destination_card.dart';
import 'package:travel_notebook/components/no_data.dart';

class AllDestinationPage extends StatefulWidget {
  final int? prevDestinationId;
  final String ownCurrency;

  const AllDestinationPage({
    super.key,
    this.prevDestinationId,
    required this.ownCurrency,
  });

  @override
  State<AllDestinationPage> createState() => _AllDestinationPageState();
}

class _AllDestinationPageState extends State<AllDestinationPage> {
  late DestinationBloc _destinationBloc;
  late List<Destination> _destinations;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _init = true;
  int? _prevDestinationId;
  String _ownCurrency = "";

  @override
  void initState() {
    _prevDestinationId = widget.prevDestinationId;
    _ownCurrency = widget.ownCurrency;

    _destinationBloc = BlocProvider.of<DestinationBloc>(context);
    _destinationBloc.add(GetAllDestinations());

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _refreshPage() async {
    _destinationBloc.add(GetAllDestinations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        title: TextFormField(
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
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            fillColor: Colors.grey[100], // Add grey background
            filled: true, // Enable fill color
            hintText: 'Search...',
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: kPadding),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(
                  right: 20, left: 20), // Add padding to the prefixIcon
              child: SizedBox(
                child: Center(widthFactor: 0.0, child: Icon(Icons.search)),
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: _refreshPage,
          child: BlocConsumer<DestinationBloc, DestinationState>(
            listener: (context, state) {
              if (state is DestinationsLoaded) {
                _destinations = state.destinations;

                if (_prevDestinationId != null && _init) {
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

                  Navigator.push(
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
                return Center(child: Text(state.message));
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
                            onDelete: () async {
                              await ImageHandler()
                                  .deleteImage(destination.imgPath);
                              _destinationBloc.add(DeleteDestination(
                                  destination.destinationId!));
                            },
                          );
                        },
                      );
              }
            },
          ),
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
    );
  }
}
