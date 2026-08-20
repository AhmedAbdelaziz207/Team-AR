import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/api_endpoints.dart';
import '../../manage_meals_screen/logic/meal_cubit.dart';
import '../../manage_meals_screen/logic/meal_state.dart';
import '../../manage_meals_screen/model/meal_model.dart';
import 'meal_counter.dart';
import 'admin_substitute_picker_sheet.dart';

class SelectMealCard extends StatelessWidget {
  final DietMealModel meal;
  const SelectMealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<MealCubit>().toggleMealSelection(meal.id!, meal.numOfGrams ?? 100),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: ApiEndPoints.imagesBaseUrl + (meal.imageURL ?? ""),
                    width: 80.w, height: 80.h, fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                    errorWidget: (_, __, ___) => Container(color: Colors.grey[200], padding: const EdgeInsets.all(12), child: Icon(Icons.broken_image, color: Colors.grey, size: 60.sp)),
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
                              () {
                                final isAr = context.locale.languageCode == 'ar';
                                final arName = meal.arabicName;
                                final enName = meal.name;
                                if (isAr) return (arName != null && arName.isNotEmpty) ? arName : (enName ?? '');
                                return enName ?? arName ?? '';
                              }(),
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Checkbox(
                            value: meal.isSelected ?? false,
                            onChanged: (_) => context.read<MealCubit>().toggleMealSelection(meal.id!, meal.numOfGrams ?? 100),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CounterWidget(
                        key: ValueKey(meal.id),
                        meal: meal,
                        onChanged: (value) => context.read<MealCubit>().updateMealQuantity(meal.id!, value),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Substitute + note section (only when selected) ──
            if (meal.isSelected == true) ...[
              const SizedBox(height: 12),
              _SubstituteSection(meal: meal),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Substitute section shown under a selected meal (admin side)
// ─────────────────────────────────────────────────────────────────────────────
class _SubstituteSection extends StatefulWidget {
  final DietMealModel meal;
  const _SubstituteSection({required this.meal});

  @override
  State<_SubstituteSection> createState() => _SubstituteSectionState();
}

class _SubstituteSectionState extends State<_SubstituteSection> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MealCubit>();
    final isAr = context.locale.languageCode == 'ar';
    final noteController = cubit.getItemNoteController(widget.meal.id!);
    final latestNote = noteController.text;
    final latestSubs = decodeSubstitutes(latestNote);
    final latestRegularNote = extractRegularNote(latestNote);

    // Get all meals available for picking
    final allMeals = cubit.state.maybeWhen(
      loaded: (meals) => meals,
      orElse: () => <DietMealModel>[],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Current substitutes summary ──
        if (latestSubs.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.swap_horiz_rounded, color: Colors.green.shade700, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isAr ? 'البدائل المضافة:' : 'Added substitutes:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.green.shade800, fontFamily: 'Cairo'),
                  ),
                ]),
                const SizedBox(height: 6),
                ...latestSubs.map((s) {
                  final subMeal = allMeals.firstWhere((m) => m.id == s['mealId'], orElse: () => DietMealModel(id: -1, name: 'ID ${s['mealId']}'));
                  final subName = isAr
                      ? (subMeal.arabicName?.isNotEmpty == true ? subMeal.arabicName! : subMeal.name ?? 'ID ${s['mealId']}')
                      : (subMeal.name ?? 'ID ${s['mealId']}');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      const Icon(Icons.arrow_right, size: 16, color: Colors.green),
                      Text('$subName — ${s['grams']}g',
                        style: TextStyle(fontSize: 12.sp, color: Colors.green.shade800, fontFamily: 'Cairo', fontWeight: FontWeight.w500)),
                    ]),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // ── Regular note ──
        if (latestRegularNote.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(children: [
              Icon(Icons.notes, size: 14, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Expanded(child: Text(latestRegularNote, style: TextStyle(fontSize: 12.sp, color: Colors.orange.shade900, fontFamily: 'Cairo'))),
            ]),
          ),
          const SizedBox(height: 8),
        ],

        // ── Add / Edit substitutes button ──
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await AdminSubstitutePickerSheet.show(
                context,
                noteController.text,
                allMeals,
              );
              if (result != null) {
                noteController.text = result;
                setState(() {}); // refresh UI
              }
            },
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text(
              latestSubs.isEmpty
                  ? (isAr ? '+ إضافة بديل للوجبة' : '+ Add meal substitute')
                  : (isAr ? '✏️ تعديل البدائل' : '✏️ Edit substitutes'),
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF102E50),
              side: const BorderSide(color: Color(0xFF102E50)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
