import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_state.dart';
import '../../../core/network/api_endpoints.dart';
import '../../manage_meals_screen/logic/meal_cubit.dart';
import '../../manage_meals_screen/model/meal_model.dart';
import 'meal_counter.dart';

class SelectMealCard extends StatefulWidget {
  final DietMealModel meal;

  const SelectMealCard({super.key, required this.meal});

  @override
  State<SelectMealCard> createState() => _SelectMealCardState();
}

class _SelectMealCardState extends State<SelectMealCard> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<MealCubit, MealState>(
      listener: (context, state) {
        if (state is MailAssigned) {
            {
            context.read<MealCubit>().getMeals();
            }
        }
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
              child: Image.network(
                ApiEndPoints.imagesBaseUrl + (widget.meal.imageURL ?? ""),
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 60.sp,
                    ),
                  );
                },
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
                          widget.meal.name ?? '',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: widget.meal.isSelected,
                        onChanged: (_) {
                          context.read<MealCubit>().toggleMealSelection(
                                widget.meal.id!,
                                widget.meal.numOfGrams ?? 100,
                              );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CounterWidget(
                    key: ValueKey(widget.meal.id),
                    meal: widget.meal,
                    onChanged: (value) {
                      context.read<MealCubit>().updateMealQuantity(
                            widget.meal.id!,
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
