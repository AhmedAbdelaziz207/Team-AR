import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';
import '../../manage_meals_screen/logic/meal_cubit.dart';

class CounterWidget extends StatefulWidget {
  const CounterWidget({
    super.key,
    this.meal,
    this.onChanged,
  });

  final DietMealModel? meal;
  final void Function(double value)? onChanged;

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  final TextEditingController _controller = TextEditingController();
  double _count = 100;

  @override
  void initState() {
    super.initState();
    _count = widget.meal?.numOfGrams ?? 100;
    _controller.text = _count.toString();

    _controller.addListener(() {
      final text = _controller.text;
      final  grams = double.tryParse(text);
      if (grams != null && widget.meal != null) {
        context.read<MealCubit>().updateMealQuantity(widget.meal!.id!, grams);
      }
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _mealCubit = context.read<MealCubit>();
  //
  //   final state = _mealCubit.state;
  //   if (state is MealsLoaded) {
  //     final meals = state.meals;
  //
  //     final meal = meals.firstWhere(
  //           (m) => m.id == widget.meal?.id,
  //       orElse: () => widget.meal!,
  //     );
  //
  //     _count = meal.numOfGrams ?? 0;
  //     _controller.text = _count.toString();
  //
  //     log("Meal grams from Cubit: $_count");
  //   }
  // }

  void _updateCount(String value) {
    final double? parsed = double.tryParse(value);
    if (parsed != null && parsed >= 0) {
      setState(() {
        _count = parsed;
      });

      if (widget.meal != null && mounted) {
        context.read<MealCubit>().updateMealQuantity(widget.meal!.id!, _count);
      }
    } else {
      _controller.text = _count.toString(); // Reset invalid input
    }

    widget.onChanged!(_count);
  }

  void _increment() {
    setState(() {
      _count++;
      _controller.text = _count.toString();
    });

    if (widget.meal != null && mounted) {
      context.read<MealCubit>().updateMealQuantity(widget.meal!.id!, _count);
    }

    widget.onChanged!(_count);
  }

  void _decrement() {
    if (_count > 0) {
      setState(() {
        _count--;
        _controller.text = _count.toString();
      });

      if (widget.meal != null && mounted) {
        context.read<MealCubit>().updateMealQuantity(widget.meal!.id!, _count);
      }
    }
    widget.onChanged!(_count);
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: _decrement,
        ),
        SizedBox(
          width: 48,
          height: 36,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onSubmitted: _updateCount,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: _increment,
        ),
        Text(
          AppLocalKeys.gram.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            fontFamily: "Cairo",
          ),
        )
      ],
    );
  }
}
