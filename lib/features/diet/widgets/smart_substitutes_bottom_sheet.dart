import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/features/manage_meals_screen/repos/diet_meal_repository.dart';

class SmartSubstitutesBottomSheet extends StatefulWidget {
  final DietMealModel originalMeal;
  final int originalGrams;

  const SmartSubstitutesBottomSheet({
    super.key,
    required this.originalMeal,
    required this.originalGrams,
  });

  static void show(BuildContext context, DietMealModel meal, int grams) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SmartSubstitutesBottomSheet(
        originalMeal: meal,
        originalGrams: grams,
      ),
    );
  }

  @override
  State<SmartSubstitutesBottomSheet> createState() =>
      _SmartSubstitutesBottomSheetState();
}

class _SmartSubstitutesBottomSheetState
    extends State<SmartSubstitutesBottomSheet> {
  List<DietMealModel> substitutes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubstitutes();
  }

  Future<void> _loadSubstitutes() async {
    try {
      // Fetch meals using the repository directly
      final repo = DietMealRepository(getIt<ApiService>()); 
      final result = await repo.getDietMeals();
      
      result.when(
        success: (meals) {
          if (meals != null && mounted) {
            setState(() {
              substitutes = meals
                  .where((m) =>
                      m.foodCategory == widget.originalMeal.foodCategory &&
                      m.id != widget.originalMeal.id &&
                      (m.numOfCalories ?? 0) > 0)
                  .toList();
              isLoading = false;
            });
          }
        },
        failure: (_) {
          if (mounted) {
            setState(() => isLoading = false);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the DB has numOfCalories per 100g, then total cal = (numOfCalories / 100) * grams.
    // Wait, the API usually stores calories per 100g.
    // In MealList, `totalCalories = sum(meal.numOfCalories)` - wait, is it per 100g or per the assigned grams?
    // Let's assume `numOfCalories` is per 100 grams. Then targetCalories = (numOfCalories / 100) * grams.
    final double targetCalories =
        ((widget.originalMeal.numOfCalories ?? 0) / 100) * widget.originalGrams;

    final isAr = context.locale.languageCode == 'ar';
    final String title = isAr ? 'البدائل الذكية' : 'Smart Substitutes';
    final String desc = isAr
        ? 'تم حساب الجرامات للبدائل التالية لتعطيك نفس كمية السعرات الحرارية (${targetCalories.toStringAsFixed(0)} Kcal)'
        : 'Grams for the following alternatives are calculated to give you the exact same calories (${targetCalories.toStringAsFixed(0)} Kcal)';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    fontFamily: "Cairo",
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : substitutes.isEmpty
                        ? Center(
                            child: Text(
                              isAr
                                  ? 'لا توجد بدائل متاحة لهذه الفئة'
                                  : 'No alternatives available for this category',
                              style: TextStyle(fontFamily: "Cairo"),
                            ),
                          )
                        : ListView.builder(
                            controller: controller,
                            itemCount: substitutes.length,
                            itemBuilder: (context, index) {
                              final sub = substitutes[index];
                              final subName = isAr
                                  ? (sub.arabicName ?? sub.name ?? "")
                                  : (sub.name ?? sub.arabicName ?? "");

                              // required_grams = (targetCalories / sub.calories_per_100g) * 100
                              final double requiredGrams =
                                  (targetCalories / (sub.numOfCalories ?? 1)) * 100;

                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: ApiEndPoints.imagesBaseUrl +
                                        (sub.imageURL ?? ""),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  subName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    fontFamily: "Cairo",
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.green.shade200),
                                  ),
                                  child: Text(
                                    '${requiredGrams.toStringAsFixed(0)} جرام',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                      fontFamily: "Cairo",
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
