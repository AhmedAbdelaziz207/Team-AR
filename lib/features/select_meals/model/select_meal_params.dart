class SelectMealParams {
  final String userId;
  final int mealNum;
  final bool? isUpdate;

  SelectMealParams({
    required this.userId,
    required this.mealNum,
    this.isUpdate,
  });
}
