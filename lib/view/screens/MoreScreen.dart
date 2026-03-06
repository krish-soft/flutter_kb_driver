import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: AppStrings.screenMore.tr),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 200, child: Center(child: Text("More"))),
        ],
      ),
    );
  }
}
