import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';
import 'package:team_ar/features/auth/register/logic/admin_register_cubit.dart';
import 'package:team_ar/features/auth/register/logic/register_state.dart';

class AdminRegisterScreen extends StatelessWidget {
  const AdminRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminRegisterCubit>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.mediumLavender,
        toolbarHeight: 100.h,
        title: Text(
          'Add User',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.white),
        ),
        leading: const AppBarBackButton(
          color: AppColors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: cubit.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                Text(
                  'Create new user (admin)',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 16.h),

                // Username
                CustomTextFormField(
                  controller: cubit.userNameController,
                  hintText: 'Username',
                  suffixIcon: Icons.person,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                SizedBox(height: 16.h),

                // Email
                CustomTextFormField(
                  controller: cubit.emailController,
                  hintText: 'Email',
                  suffixIcon: Icons.email,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!regex.hasMatch(v.trim())) return 'Invalid email';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password
                CustomTextFormField(
                  controller: cubit.passwordController,
                  hintText: 'Password',
                  suffixIcon: Icons.lock,
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Min 6 chars'
                      : null,
                ),
                SizedBox(height: 16.h),

                // Package ID
                CustomTextFormField(
                  controller: cubit.packageIdController,
                  hintText: 'Package ID',
                  suffixIcon: Icons.tag,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final n = int.tryParse(v.trim());
                    if (n == null) return 'Must be a number';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Start Package (YYYY-MM-DD)
                CustomTextFormField(
                  controller: cubit.startPackageController,
                  hintText: 'Start date (YYYY-MM-DD)',
                  suffixIcon: Icons.calendar_month,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                SizedBox(height: 16.h),

                // End Package (YYYY-MM-DD)
                CustomTextFormField(
                  controller: cubit.endPackageController,
                  hintText: 'End date (YYYY-MM-DD)',
                  suffixIcon: Icons.calendar_today,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                SizedBox(height: 28.h),

                BlocConsumer<AdminRegisterCubit, RegisterState>(
                  listener: (context, state) {
                    state.maybeWhen(
                      success: (data) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User created')),
                        );
                        Navigator.of(context).pop(true);
                      },
                      failure: (err) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err.message ?? 'Failed')),
                        );
                      },
                      orElse: () {},
                    );
                  },
                  builder: (context, state) {
                    final isLoading = state is RegisterLoading;
                    return SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : cubit.submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.primaryColor.withOpacity(.85),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.6,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Create',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppColors.white),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
