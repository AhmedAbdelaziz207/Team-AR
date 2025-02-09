import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/app_local_keys.dart';
class GenderSelection extends StatefulWidget {
  final Function(String) onGenderSelected;

  const GenderSelection({Key? key, required this.onGenderSelected})
      : super(key: key);

  @override
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
  String? selectedGender;

  void _onGenderChanged(String gender) {
    setState(() {
      selectedGender = gender;
    });
    widget.onGenderSelected(gender);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalKeys.gender.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _buildGenderCheckbox(AppLocalKeys.male.tr()),
            SizedBox(width: 20.w),
            _buildGenderCheckbox(AppLocalKeys.female.tr()),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderCheckbox(String gender) {
    return GestureDetector(
      onTap: () => _onGenderChanged(gender),
      child: Row(
        children: [
          Checkbox(
            value: selectedGender == gender,
            onChanged: (bool? value) => _onGenderChanged(gender),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          Text(gender, style: TextStyle(fontSize: 16.sp)),
        ],
      ),
    );
  }
}
