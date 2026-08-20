import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';
import 'package:team_ar/features/manage_meals_screen/repos/diet_meal_repository.dart';

/// Represents a single substitute entry chosen by the admin
class SubstituteEntry {
  final DietMealModel meal;
  int grams;
  SubstituteEntry({required this.meal, this.grams = 100});
}

/// Encodes a list of substitutes into the note string format
String encodeSubstitutes(List<SubstituteEntry> subs, String regularNote) {
  if (subs.isEmpty) return regularNote;
  final encoded = subs.map((s) => '${s.meal.id}:${s.grams}').join(',');
  final note = regularNote.trim();
  return '[SUB]$encoded[/SUB]${note.isNotEmpty ? note : ''}';
}

/// Decodes the note string back to substitute IDs and grams
List<Map<String, int>> decodeSubstitutes(String? note) {
  if (note == null || !note.contains('[SUB]')) return [];
  final start = note.indexOf('[SUB]') + 5;
  final end = note.indexOf('[/SUB]');
  if (start < 0 || end < 0 || end <= start) return [];
  final encoded = note.substring(start, end);
  if (encoded.trim().isEmpty) return [];
  return encoded
      .split(',')
      .map((part) {
        final pieces = part.split(':');
        if (pieces.length != 2) return <String, int>{};
        return {
          'mealId': int.tryParse(pieces[0]) ?? -1,
          'grams': int.tryParse(pieces[1]) ?? 0,
        };
      })
      .where((m) => m.isNotEmpty && m['mealId']! > 0)
      .toList();
}

/// Extracts the regular note (without the [SUB] block)
String extractRegularNote(String? note) {
  if (note == null || !note.contains('[/SUB]')) return note ?? '';
  final end = note.indexOf('[/SUB]') + 7;
  if (end >= note.length) return '';
  return note.substring(end).trim();
}

// ─────────────────────────────────────────────────────────
// Admin Substitute Picker Bottom Sheet
// ─────────────────────────────────────────────────────────

class AdminSubstitutePickerSheet extends StatefulWidget {
  /// The current note value (may already contain [SUB] data)
  final String currentNote;

  /// All meals to pick from
  final List<DietMealModel> allMeals;

  const AdminSubstitutePickerSheet({
    super.key,
    required this.currentNote,
    required this.allMeals,
  });

  static Future<String?> show(
      BuildContext context, String currentNote, List<DietMealModel> allMeals) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminSubstitutePickerSheet(
        currentNote: currentNote,
        allMeals: allMeals,
      ),
    );
  }

  @override
  State<AdminSubstitutePickerSheet> createState() =>
      _AdminSubstitutePickerSheetState();
}

class _AdminSubstitutePickerSheetState
    extends State<AdminSubstitutePickerSheet> {
  final List<SubstituteEntry> _selectedSubs = [];
  late final TextEditingController _noteController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Pre-fill from existing note
    final existing = decodeSubstitutes(widget.currentNote);
    for (final entry in existing) {
      final mealId = entry['mealId']!;
      final grams = entry['grams']!;
      final meal = widget.allMeals.firstWhere((m) => m.id == mealId,
          orElse: () => const DietMealModel(id: -1));
      if (meal.id != -1) {
        _selectedSubs.add(SubstituteEntry(meal: meal, grams: grams));
      }
    }
    _noteController =
        TextEditingController(text: extractRegularNote(widget.currentNote));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<DietMealModel> get _filteredMeals {
    final q = _searchQuery.toLowerCase();
    return widget.allMeals
        .where((m) => m.foodCategory != 4) // exclude supplements
        .where((m) =>
            q.isEmpty ||
            (m.arabicName?.toLowerCase().contains(q) ?? false) ||
            (m.name?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  bool _isAlreadyAdded(DietMealModel meal) =>
      _selectedSubs.any((s) => s.meal.id == meal.id);

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz_rounded,
                        color: Color(0xFF102E50)),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'إدارة البدائل' : 'Manage Substitutes',
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo'),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        final result = encodeSubstitutes(
                            _selectedSubs, _noteController.text);
                        Navigator.pop(context, result);
                      },
                      icon: const Icon(Icons.check, color: Color(0xFF102E50)),
                      label: Text(
                        isAr ? 'حفظ' : 'Save',
                        style: const TextStyle(
                            color: Color(0xFF102E50),
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Selected substitutes summary
              if (_selectedSubs.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'البدائل المختارة:' : 'Selected substitutes:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            fontFamily: 'Cairo',
                            color: Colors.green.shade700),
                      ),
                      const SizedBox(height: 8),
                      ..._selectedSubs
                          .map((sub) => _buildSelectedSubTile(sub, isAr)),
                    ],
                  ),
                ),
                const Divider(),
              ],

              // Regular note
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: isAr
                        ? 'ملاحظة إضافية للمتدرب (اختياري)'
                        : 'Additional note for trainee (optional)',
                    labelStyle: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.notes, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.orange.shade50,
                  ),
                  style: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo'),
                  maxLines: 2,
                ),
              ),

              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: isAr ? 'ابحث عن وجبة...' : 'Search for a meal...',
                    hintStyle: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),

              // Meals list
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: _filteredMeals.length,
                  itemBuilder: (_, i) {
                    final meal = _filteredMeals[i];
                    final alreadyAdded = _isAlreadyAdded(meal);
                    return _buildMealPickerTile(meal, alreadyAdded, isAr);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedSubTile(SubstituteEntry sub, bool isAr) {
    final mealName = isAr
        ? (sub.meal.arabicName?.isNotEmpty == true
            ? sub.meal.arabicName!
            : sub.meal.name ?? '')
        : (sub.meal.name ?? sub.meal.arabicName ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ApiEndPoints.imagesBaseUrl + (sub.meal.imageURL ?? ''),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(mealName,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    fontFamily: 'Cairo')),
          ),
          // Gram counter
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.red, size: 20),
                onPressed: () => setState(() {
                  if (sub.grams > 10) sub.grams -= 10;
                }),
              ),
              Text('${sub.grams}g',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.green, size: 20),
                onPressed: () => setState(() => sub.grams += 10),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => setState(() =>
                _selectedSubs.removeWhere((s) => s.meal.id == sub.meal.id)),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPickerTile(
      DietMealModel meal, bool alreadyAdded, bool isAr) {
    final mealName = isAr
        ? (meal.arabicName?.isNotEmpty == true
            ? meal.arabicName!
            : meal.name ?? '')
        : (meal.name ?? meal.arabicName ?? '');

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          ApiEndPoints.imagesBaseUrl + (meal.imageURL ?? ''),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image)),
        ),
      ),
      title: Text(mealName,
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo')),
      trailing: alreadyAdded
          ? Icon(Icons.check_circle, color: Colors.green.shade600)
          : OutlinedButton(
              onPressed: () => setState(() =>
                  _selectedSubs.add(SubstituteEntry(meal: meal, grams: 100))),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF102E50),
                side: const BorderSide(color: Color(0xFF102E50)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isAr ? 'إضافة' : 'Add',
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Cairo')),
            ),
    );
  }
}
