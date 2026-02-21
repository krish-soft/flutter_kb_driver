import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/core/controllers/locale_controller.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final LocaleController controller = Get.find<LocaleController>();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (value) {
        controller.changeLocale(value);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'en', child: Text('English')),
        const PopupMenuItem(value: 'hi', child: Text('Hindi')),
        const PopupMenuItem(value: 'gu', child: Text('Gujarati')),
      ],
    );
  }
}
