

import 'package:flutter/material.dart';

class ActiveDeliveryScreen extends StatelessWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 200, child: Center(child: Text("Active Delivery"))),
      ],
    );
  }
}
