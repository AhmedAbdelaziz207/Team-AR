import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/trainer_register_success/model/register_success_model.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainerRegistrationSuccess extends StatelessWidget {
  const TrainerRegistrationSuccess({super.key, this.data});

  final RegisterSuccessModel? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and check icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalKeys.registerNewTrainer.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: AppColors.green,
                    size: 26.sp,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${data?.userName ?? ""} (${AppLocalKeys.newUser.tr()})',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Username section
              _InfoField(
                label: AppLocalKeys.email.tr(),
                value: data!.email ?? "",
              ),
              const SizedBox(height: 16),

              // Password section
              _InfoField(
                label: AppLocalKeys.password.tr(),
                value: data!.password ?? "",
              ),
              SizedBox(height: 24.h),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    shareToWhatsApp(data!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    AppLocalKeys.shareToWhatsApp.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (${AppLocalKeys.readOnly.tr()})',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: AppColors.primaryColor),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalKeys.copiedToClipboard.tr()),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> shareToWhatsApp(RegisterSuccessModel data) async {
  final message = '''
🎉 *Trainer Registration Successful!*

👤 User Name : ${data.userName}
🧾 Email: ${data.email}
🔑 Password: ${data.password}
''';

  final url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch WhatsApp';
  }
}
