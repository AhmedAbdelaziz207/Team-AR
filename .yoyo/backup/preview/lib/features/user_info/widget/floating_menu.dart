import 'package:flutter/material.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/add_workout/model/add_workout_params.dart';
import 'package:team_ar/features/user_info/model/trainee_model.dart';
import 'package:url_launcher/url_launcher.dart';

class FloatingMenu extends StatefulWidget {
  const FloatingMenu({super.key, this.trainee, this.exerciseId});

  final TrainerModel? trainee;
  final int ? exerciseId;

  @override
  State<FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<FloatingMenu>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  void _openWhatsApp(String phone) async {
    final url = "https://wa.me/$phone";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      // handle error
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required int index,
  }) {
    return ScaleTransition(
      scale: _animation,
      child: Padding(
        padding: EdgeInsets.only(bottom: (index + 1) * 60),
        child: FloatingActionButton(
          heroTag: null,
          mini: true,
          backgroundColor: AppColors.primaryColor.withOpacity(.9),
          onPressed: onPressed,
          tooltip: label,
          child: Icon(
            icon,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isOpen) ...[
          _buildOption(
            icon: Icons.call_end_rounded,
            label: "WhatsApp",
            onPressed: () {
              _openWhatsApp(widget.trainee?.phone ?? "");
            },
            index: 0,
          ),
          _buildOption(
            icon: Icons.fitness_center,
            label: "Workout",
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.addWorkout,
                arguments:  AddWorkoutParams(
                  exerciseId: widget.exerciseId,
                  traineeId: widget.trainee?.id,
                ),
              );
            },
            index: 1,
          ),
          _buildOption(
            icon: Icons.restaurant,
            label: "Diet",
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.adminUserMeals,
                arguments: widget.trainee?.id,
              );
            },
            index: 2,
          ),
        ],

        // Main FAB
        FloatingActionButton(
          onPressed: _toggleMenu,
          backgroundColor: AppColors.primaryColor,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(
              Icons.add,
            ),
          ),
        ),
      ],
    );
  }
}
