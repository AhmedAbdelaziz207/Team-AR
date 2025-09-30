import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/app_local_keys.dart';
import '../../manage_meals_screen/logic/meal_cubit.dart';
import '../../manage_meals_screen/model/meal_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NaturalSupplementCard extends StatefulWidget {
  final DietMealModel meal;

  const NaturalSupplementCard({super.key, required this.meal});

  @override
  State<NaturalSupplementCard> createState() => _NaturalSupplementCardState();
}

class _NaturalSupplementCardState extends State<NaturalSupplementCard> {
  final TextEditingController _usageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing usage instructions if any
    _usageController.text = widget.meal.usageInstructions ?? '';
  }

  @override
  void dispose() {
    _usageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<MealCubit>().toggleNaturalSupplementSelection(
              widget.meal.id!,
              _usageController.text,
            );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl:
                        ApiEndPoints.imagesBaseUrl + (widget.meal.imageURL ?? ""),
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 60.sp,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (() {
                                final isAr = context.locale.languageCode == 'ar';
                                final arName = widget.meal.arabicName;
                                final enName = widget.meal.name;
                                if (isAr) {
                                  return (arName != null && arName.isNotEmpty)
                                      ? arName
                                      : (enName ?? '');
                                }
                                return enName ?? arName ?? '';
                              })(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Checkbox(
                            value: widget.meal.isSelected ?? false,
                            onChanged: (_) {
                              context.read<MealCubit>().toggleNaturalSupplementSelection(
                                    widget.meal.id!,
                                    context.read<MealCubit>().noteController.text,
                                  );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.meal.isSelected ?? false) ...[
              const SizedBox(height: 12),
              TextField(
                controller: context.read<MealCubit>().noteController,
                decoration: InputDecoration(
                  labelText: AppLocalKeys.howToUseIt.tr(),
                  hintText: AppLocalKeys.enterUsageInstructions.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  prefixIcon: Icon(Icons.eco, color: Colors.green),
                ),
                maxLines: 2,
                onChanged: (value) {
                  context.read<MealCubit>().updateNaturalSupplementUsage(
                        widget.meal.id!,
                        value,
                      );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
