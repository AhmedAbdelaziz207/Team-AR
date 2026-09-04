import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';
// For decodeSubstitutes

class ManualSubstitutesBottomSheet extends StatelessWidget {
  final DietMealModel originalMeal;
  final int originalGrams;
  final List<Map<String, int>> substitutes;

  const ManualSubstitutesBottomSheet({
    super.key,
    required this.originalMeal,
    required this.originalGrams,
    required this.substitutes,
  });

  static void show(BuildContext context, DietMealModel originalMeal,
      int originalGrams, List<Map<String, int>> substitutes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManualSubstitutesBottomSheet(
        originalMeal: originalMeal,
        originalGrams: originalGrams,
        substitutes: substitutes,
      ),
    );
  }

  Future<List<DietMealModel>> _resolveSubstitutes() async {
    try {
      final apiService = getIt<ApiService>();
      final allMeals = await apiService.getDietMeals();
      if (allMeals == null) return [];

      final subIds = substitutes.map((s) => s['mealId']).toSet();
      return allMeals.where((m) => subIds.contains(m.id)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final originalName = isAr
        ? (originalMeal.arabicName?.isNotEmpty == true
            ? originalMeal.arabicName!
            : originalMeal.name ?? '')
        : (originalMeal.name ?? originalMeal.arabicName ?? '');

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.sp)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.sp),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Icon(Icons.swap_horiz_rounded,
                    color: Colors.blue.shade700, size: 28.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'البدائل المتاحة' : 'Available Substitutes',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        '${isAr ? 'بدلاً من' : 'Instead of'} $originalName ($originalGrams${isAr ? 'ج' : 'g'})',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 30),
          Expanded(
            child: FutureBuilder<List<DietMealModel>>(
              future: _resolveSubstitutes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final meals = snapshot.data ?? [];
                if (meals.isEmpty) {
                  return Center(
                    child: Text(
                      isAr ? 'لا توجد بيانات متاحة.' : 'No data available.',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                    ),
                  );
                }

                return ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: substitutes.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final subData = substitutes[index];
                    final mealId = subData['mealId'];
                    final targetGrams = subData['grams'] ?? 0;

                    final meal = meals.firstWhere(
                      (m) => m.id == mealId,
                      orElse: () => const DietMealModel(id: -1),
                    );
                    if (meal.id == -1) return const SizedBox.shrink();

                    final subName = isAr
                        ? (meal.arabicName?.isNotEmpty == true
                            ? meal.arabicName!
                            : meal.name ?? '')
                        : (meal.name ?? meal.arabicName ?? '');

                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16.sp),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.sp),
                            child: CachedNetworkImage(
                              imageUrl: ApiEndPoints.imagesBaseUrl +
                                  (meal.imageURL ?? ''),
                              width: 60.w,
                              height: 60.h,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: Colors.grey.shade200),
                              errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image)),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subName,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(Icons.scale,
                                        size: 14.sp,
                                        color: Colors.blue.shade700),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '$targetGrams ${isAr ? 'جرام' : 'g'}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
