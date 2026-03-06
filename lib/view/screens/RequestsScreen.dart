import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: AppStrings.screenRequests.tr),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 200, child: Center(child: Text("Requests"))),
        ],
      ),
    );
  }
}
