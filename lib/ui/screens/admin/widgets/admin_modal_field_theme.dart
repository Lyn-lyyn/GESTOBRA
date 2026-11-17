import 'package:flutter/material.dart';

import 'package:gestobra/config/theme/app_colors.dart';

/// Runs an admin dialog with the shared orange-outline style for form controls.
Future<T?> showAdminDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.naranja),
      );

      return Theme(
        data: theme.copyWith(
          dialogTheme: theme.dialogTheme.copyWith(
            backgroundColor: AppColors.grisfondo,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: AppColors.blanco,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(
                color: AppColors.naranja,
                width: 1.5,
              ),
            ),
            errorBorder: border.copyWith(
              borderSide: const BorderSide(color: AppColors.estadoRojo),
            ),
            focusedErrorBorder: border.copyWith(
              borderSide: const BorderSide(
                color: AppColors.estadoRojo,
                width: 1.5,
              ),
            ),
          ),
        ),
        child: Builder(builder: builder),
      );
    },
  );
}
