import 'package:flutter/material.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/view/components/language_switcher.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? leading;

  const CommonAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: IconTheme(
              data: const IconThemeData(color: AppColors.textOnPrimary),
              child: Row(
                children: [
                  /// BACK BUTTON
                  if (showBack)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    )
                  else if (leading != null)
                    leading!,

                  if (showBack || leading != null) const SizedBox(width: 6),

                  /// TITLE AREA
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              style: const TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  /// ACTIONS
                  ...[
                    const LanguageSwitcher(),
                    if (actions != null) ...actions!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
