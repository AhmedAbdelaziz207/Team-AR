import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';


class LanguageOption extends StatelessWidget {
  final String flagIcon;
  final String language;
  final String nativeLanguage;
  final bool isSelected;

  const LanguageOption({super.key,
    required this.flagIcon,
    required this.language,
    required this.nativeLanguage,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected ? AppColors.newPrimaryColor : AppColors.secondaryColor,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Image.asset(flagIcon) ,
        ),
        title: Text(
          language,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(nativeLanguage),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.newPrimaryColor)
            : const Icon(Icons.circle_outlined, color: AppColors.lightGrey),
      ),
    );
  }
}

