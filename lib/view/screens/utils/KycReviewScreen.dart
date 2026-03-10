import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';

class KycReviewScreen extends StatelessWidget {
  const KycReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "KYC Review"),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Icon(Icons.hourglass_top, size: 90, color: Colors.orange),

            SizedBox(height: 25),

            Text(
              AppStrings.textKycUnderReview.tr,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 15),

            Text(
              AppStrings.textKycDetailsSubmitted.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
