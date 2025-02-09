import 'package:flutter/material.dart';
import 'package:team_ar/core/theme/app_colors.dart';

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({super.key,  this.color = AppColors.black});
  final Color color ;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => Navigator.pop(context),
        icon:  Icon(Icons.arrow_back_ios,color: color,));
  }
}
