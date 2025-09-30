import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';

class MealTypeDropdown extends StatefulWidget {
  final Function(int) onChanged;

  const MealTypeDropdown({
    super.key,
    required this.onChanged,
  });

  @override
  State<MealTypeDropdown> createState() => _MealTypeDropdownState();
}

class _MealTypeDropdownState extends State<MealTypeDropdown> {
  final List<String> mealTypes = [
    AppLocalKeys.proteins.tr(),
    AppLocalKeys.fats.tr(),
    AppLocalKeys.carbs.tr(),
    AppLocalKeys.vegetables.tr(),
    AppLocalKeys.naturalSupplements.tr(),
  ];

  int? selectedIndex = 0 ;


  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedIndex,
      items: List.generate(mealTypes.length, (index) {
        return DropdownMenuItem(
          value: index,
          child: Text(mealTypes[index]),
        );
      }),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedIndex = value;
          });
          widget.onChanged(value);
        }
      },
      decoration: InputDecoration(
        labelText: AppLocalKeys.selectMealType.tr(),
        labelStyle: const TextStyle(color: AppColors.primaryColor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
