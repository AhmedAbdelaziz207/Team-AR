import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showCustomDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'OK',
  String cancelText = 'Cancel',
  IconData icon = Icons.info,
  Color iconColor = Colors.red,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(
              icon,
              size: 50,
              color: iconColor,
            ),
            SizedBox(height: 10.h),
            Text(title,style:  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16.sp) ,),
          ],
        ),
        content: Text(message,style:  Theme.of(context).textTheme.bodyLarge),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: () {
                onCancel();
                Navigator.of(context).pop();
              },
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: () {
              if (onConfirm != null) onConfirm();
              Navigator.of(context).pop();
            },
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}
