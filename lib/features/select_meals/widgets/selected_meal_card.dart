import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/network/api_endpoints.dart';
import '../../manage_meals_screen/logic/meal_cubit.dart';
import '../../manage_meals_screen/model/meal_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'meal_counter.dart';

class SelectMealCard extends StatelessWidget {
  final DietMealModel meal;

  const SelectMealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    // No listener here; do not trigger getMeals() after assign. The cubit
    // already emits MealsLoaded with cached/reset meals.
    return InkWell(
      onTap: () {
        context.read<MealCubit>().toggleMealSelection(
              meal.id!,
              meal.numOfGrams ?? 100,
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl:
                    ApiEndPoints.imagesBaseUrl + (meal.imageURL ?? ""),
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
                            final arName = meal.arabicName;
                            final enName = meal.name;
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
                        value: meal.isSelected ?? false,
                        onChanged: (_) {
                          context.read<MealCubit>().toggleMealSelection(
                                meal.id!,
                                meal.numOfGrams ?? 100,
                              );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CounterWidget(
                    key: ValueKey(meal.id),
                    meal: meal,
                    onChanged: (value) {
                      context.read<MealCubit>().updateMealQuantity(
                            meal.id!,
                            value,
                          );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
