import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum PaymentMethod {
  cash(name: 'Cash', icon: Iconsax.wallet_3_copy),
  transportationCard(name: 'Transportation Card', icon: Icons.style_outlined),
  card(name: 'Card', icon: Iconsax.cards_copy),
  qrPayment(name: 'QR Payment', icon: Iconsax.scan_barcode_copy),
  others(name: 'Others', icon: Iconsax.receipt_1_copy);

  const PaymentMethod({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}
