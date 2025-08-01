import 'dart:developer';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';
import 'package:team_ar/features/admin_panal/widget/change_language_section.dart';
import 'package:team_ar/features/admin_panal/widget/logout_button.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import 'package:team_ar/features/home/user/logic/user_state.dart';
import '../../core/prefs/shared_pref_manager.dart';
import '../../core/utils/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });

      final userId =
          await SharedPreferencesHelper.getString(AppConstants.userId);

      log("userId : $userId");
      context.read<UserCubit>().updateImage(userId!, File(pickedImage.path));
    }
  }

  File? image;

  bool isNotificationEnabled = true;

  @override
  void initState() {
    SharedPreferencesHelper.getString(AppConstants.userId).then(
      (value) {
        context.read<UserCubit>().getUser(value!);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<UserCubit, UserState>(
            buildWhen: (context, state) =>
                state is UserLoading ||
                state is UserSuccess ||
                state is UserFailure,
            builder: (context, state) {
              if (state is UserLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is UserFailure) {
                return Center(
                    child: Text(
                  state.errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: "Cairo",
                  ),
                ));
              }
              if (state is UserSuccess) {
                final user = state.userData;
          
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalKeys.welcome.tr(),
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Cairo",
                            ),
                          ),
                          Text(
                            ",   ${user.userName}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Cairo",
                            ),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          const Icon(
                            Icons.waving_hand,
                            color: AppColors.newPrimaryColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 21.h),
                            
                      BlocConsumer<UserCubit, UserState>(
                        listener: (context, state) {
                          if (state is UpdateUserImageSuccess) {
                            // show snack bar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("تم تعديل الصورة"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            if (state is UpdateUserImageFailure) {
                              // show snack bar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("فشل تعديل الصورة"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        builder: (context, state) {
                          return Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () => pickImage(),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 30.r,
                                    backgroundColor:
                                        AppColors.grey.withOpacity(.2),
                                    backgroundImage: image != null
                                        ? FileImage(image!)
                                        : null,
                                    child: image != null || user.image != null
                                        ? null
                                        : Image.asset(
                                            AppAssets.avatar,
                                            color: AppColors.newPrimaryColor,
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 15.r,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.edit,
                                        color: AppColors.newPrimaryColor,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppLocalKeys.account.tr(),
                        style: TextStyle(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      Text(
                        AppLocalKeys.userName.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      CustomTextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: user.userName),
                        suffixIcon: Icons.person,
                        prefixIcon: Icons.lock,
                        iconColor: AppColors.newPrimaryColor,
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      Text(
                        AppLocalKeys.email.tr(),
                        style: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      CustomTextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: user.email),
                        suffixIcon: Icons.email_outlined,
                        prefixIcon: Icons.lock,
                        iconColor: AppColors.newPrimaryColor,
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      // Text(
                      //   AppLocalKeys.password.tr(),
                      //   style: TextStyle(
                      //       fontSize: 12.sp, fontWeight: FontWeight.bold),
                      // ),
                      // SizedBox(
                      //   height: 8.h,
                      // ),
                      // ListTile(
                      //   onTap: () {
                      //     Navigator.pushNamed(context, Routes.changePassword);
                      //   },
                      //   contentPadding: EdgeInsets.zero,
                      //   leading: const Icon(
                      //     Icons.lock,
                      //     color: AppColors.newPrimaryColor,
                      //   ),
                      //   title: Text(
                      //     AppLocalKeys.changePassword.tr(),
                      //     style: TextStyle(
                      //       fontSize: 16.sp,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      //   trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      // ),
                      // SizedBox(
                      //   height: 16.h,
                      // ),
                      Text(AppLocalKeys.general.tr(),
                          style: TextStyle(
                              fontSize: 21.sp, fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 30.h,
                      ),
                      const LanguageSelection(),
                      SizedBox(
                        height: 21.h,
                      ),
                            
                      // Notification
                            
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.notifications,
                          color: AppColors.newPrimaryColor,
                        ),
                        title: Text(
                          AppLocalKeys.notifications.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Switch(
                          value: isNotificationEnabled,
                          activeColor: AppColors.newPrimaryColor,
                          onChanged: (value) {
                            setState(() {
                              isNotificationEnabled = value;
                            });
                          },
                        ),
                      ),
                      // Logout
                      const Align(
                        alignment: Alignment.center,
                        child: LogoutButton(),
                      ),
                            
                      SizedBox(height: 21.h),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
