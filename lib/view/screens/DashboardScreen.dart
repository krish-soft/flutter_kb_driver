import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: AppStrings.screenDashboard.tr),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 200, child: Center(child: Text("Dashboard"))),
        ],
      ),
    );
  }
}
