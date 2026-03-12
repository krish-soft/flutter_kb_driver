import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  late WebViewController controller;
  late String kycURL;

  /// toggle here
  bool useWebView = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    kycURL = args['kycURL'];

    if (useWebView) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(kycURL));
    } else {
      _openExternalBrowser();
    }
  }

  Future<void> _openExternalBrowser() async {
    final uri = Uri.parse(kycURL);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _refreshPage() {
    controller.reload();
  }

  void _closePage() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    /// if external browser used, show empty screen
    if (!useWebView) {
      return const Scaffold(body: Center(child: Text("Opening browser...")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("KYC Upload"),
        actions: [
          /// refresh button
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshPage),

          /// close button
          IconButton(icon: const Icon(Icons.close), onPressed: _closePage),
        ],
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
