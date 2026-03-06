import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text("Earnings")),
        ListTile(title: Text("Delivery History")),
        ListTile(title: Text("Wallet")),
        ListTile(title: Text("Support")),
        ListTile(title: Text("Settings")),
      ],
    );
  }
}
