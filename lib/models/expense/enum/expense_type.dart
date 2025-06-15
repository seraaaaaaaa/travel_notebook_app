import 'package:flutter/material.dart';
import 'package:travel_notebook/themes/constants.dart';

enum ExpenseType {
  // Transportation
  transportation(name: 'Transportation', typeNo: 1, color: kIndigoColor, enabled: false),
  train(name: 'Train', typeNo: 1, icon: Icons.train_outlined),
  bus(name: 'Bus', typeNo: 1, icon: Icons.directions_bus_outlined),
  taxi(name: 'Taxi', typeNo: 1, icon: Icons.local_taxi_outlined),
  parking(name: 'Parking', typeNo: 1, icon: Icons.local_parking_outlined),
  petrol(name: 'Petrol', typeNo: 1, icon: Icons.local_gas_station_outlined),
  flight(name: 'Flight', typeNo: 1, icon: Icons.airplane_ticket_outlined),

  meal(name: 'Meal', typeNo: 2, color: kPrimaryColor, enabled: false),
  food(name: 'Food', typeNo: 2, icon: Icons.flatware_outlined),
  drinks(name: 'Drinks', typeNo: 2, icon: Icons.local_cafe_outlined),
  grocery(name: 'Grocery', typeNo: 2, icon: Icons.shopping_cart_outlined),
  convenienceStore(name: 'Convenience Store', typeNo: 2, icon: Icons.storefront_outlined),

  // Misc
  miscellaneous(name: 'Miscellaneous', typeNo: 3, color: kCyanColor, enabled: false),
  accommodation(name: 'Accommodation', typeNo: 3, icon: Icons.bed_outlined),
  shopping(name: 'Shopping', typeNo: 3, icon: Icons.shopping_bag_outlined),
  souvenir(name: 'Souvenir', typeNo: 3, icon: Icons.redeem_outlined),
  ticket(name: 'Ticket', typeNo: 3, icon: Icons.confirmation_num_outlined),
  others(name: 'Others', typeNo: 3, icon: Icons.dashboard_outlined);

  const ExpenseType({
    required this.name,
    required this.typeNo,
    this.icon,
    this.color,
    this.enabled = true,
  });

  final String name;
  final int typeNo;
  final IconData? icon;
  final Color? color;
  final bool enabled;
}
