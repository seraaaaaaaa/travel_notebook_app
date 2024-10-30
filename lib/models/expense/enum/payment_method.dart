import 'package:flutter/material.dart';

enum PaymentMethod {
  cash(name: 'Cash', icon: Icons.account_balance_wallet_outlined),
  transportationCard(name: 'Transportation Card', icon: Icons.style_outlined),
  card(name: 'Card', icon: Icons.credit_card),
  qrPayment(name: 'QR Payment', icon: Icons.qr_code_2),
  others(name: 'Others', icon: Icons.more_horiz);

  const PaymentMethod({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}
