import 'dart:developer';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/features/admin_panal/widget/change_language_section.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/features/auth/login/model/user_role.dart';
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
      if (!mounted) return;
      context.read<UserCubit>().updateImage(userId!, File(pickedImage.path));
    }
  }

  File? image;
  bool isNotificationEnabled = true;
  bool isLoading = true;
  bool _isAdmin = false;
  bool _isUser = false;
  bool _isDeletingAccount = false;
  String? userName;
  String? userEmail;
  String? userImage;

  // تحميل البيانات المخزنة محليًا
  Future<void> loadCachedUserData() async {
    userName = await SharedPreferencesHelper.getString(AppConstants.userName);
    userEmail = await SharedPreferencesHelper.getString(AppConstants.userEmail);
    userImage = await SharedPreferencesHelper.getString(AppConstants.userImage);

    if (userName != null && userEmail != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // حفظ بيانات المستخدم محليًا
  Future<void> saveUserData(String name, String email, String? image) async {
    await SharedPreferencesHelper.setString(AppConstants.userName, name);
    await SharedPreferencesHelper.setString(AppConstants.userEmail, email);
    if (image != null) {
      await SharedPreferencesHelper.setString(AppConstants.userImage, image);
    }
  }

  @override
  void initState() {
    super.initState();
    // تحميل البيانات المخزنة محليًا أولاً
    loadCachedUserData().then((_) {
      // ثم جلب البيانات المحدثة من الخادم
      SharedPreferencesHelper.getString(AppConstants.userId).then((value) {
        if (!mounted) return;
        if (value != null) {
          context.read<UserCubit>().getUser(value);
        }
      });
    });
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await SharedPreferencesHelper.getString(AppConstants.userRole);

    if (!mounted) return;

    setState(() {
      _isAdmin = _isAdminRole(role);
      _isUser = _isUserRole(role);
    });
  }

  bool _isAdminRole(String? role) {
    final r = role?.toLowerCase().trim();
    return r == UserRole.Admin.name.toLowerCase() ||
        r == 'admin' ||
        r == 'adimn' ||
        r == 'administrator';
  }

  bool _isUserRole(String? role) {
    final r = role?.toLowerCase().trim();
    return r == UserRole.User.name.toLowerCase() || r == 'user';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<UserCubit, UserState>(
          buildWhen: (context, state) =>
              state is UserLoading ||
              state is UserSuccess ||
              state is UserFailure,
          builder: (context, state) {
            // إذا كانت البيانات المخزنة محليًا متوفرة وما زلنا في حالة التحميل، نعرض البيانات المخزنة
            if (state is UserLoading && !isLoading && userName != null) {
              return buildUserProfile(userName!, userEmail!, userImage);
            }

            if (state is UserLoading && isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserFailure) {
              // في حالة الفشل، نعرض البيانات المخزنة محليًا إذا كانت متوفرة
              if (!isLoading && userName != null) {
                return buildUserProfile(userName!, userEmail!, userImage);
              }

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

              // حفظ البيانات المحدثة محليًا
              saveUserData(user.userName ?? "", user.email ?? "", user.image);

              return buildUserProfile(
                  user.userName ?? "", user.email ?? "", user.image);
            }

            // إذا كانت البيانات المخزنة محليًا متوفرة ولم نصل إلى أي حالة أخرى، نعرض البيانات المخزنة
            if (!isLoading && userName != null) {
              return buildUserProfile(userName!, userEmail!, userImage);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  // استخراج واجهة المستخدم إلى دالة منفصلة لتجنب تكرار الكود
  Widget buildUserProfile(String name, String email, String? userImagePath) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Background & Avatar Stack
          SizedBox(
            height:
                160.h + 50.h, // Total height to include the overhanging avatar
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 160.h,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.newPrimaryColor,
                        AppColors.copperColor
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalKeys.welcome.tr(),
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Cairo",
                          ),
                        ),
                        Text(
                          ",   $name",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            fontFamily: "Cairo",
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 8.w),
                        const Icon(
                          Icons.waving_hand,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom:
                      0, // Sit exactly at the bottom of the 210.h Stack bounds
                  child: BlocConsumer<UserCubit, UserState>(
                    listener: (context, state) {
                      if (state is UpdateUserImageSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                AppLocalKeys.imageUpdatedSuccessfully.tr()),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is UpdateUserImageFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalKeys.imageUpdateFailed.tr()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return InkWell(
                        onTap: () => pickImage(),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50.r,
                                backgroundColor:
                                    AppColors.grey.withValues(alpha: 0.1),
                                backgroundImage: image != null
                                    ? FileImage(image!)
                                    : userImagePath != null
                                        ? NetworkImage(
                                            ApiEndPoints.usersImagesBaseUrl +
                                                userImagePath)
                                        : null,
                                child: image != null || userImagePath != null
                                    ? null
                                    : Icon(
                                        Icons.person,
                                        size: 50.r,
                                        color: AppColors.newPrimaryColor,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 16.r,
                                backgroundColor: AppColors.newPrimaryColor,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Info Section
                Text(
                  AppLocalKeys.account.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildInfoCard(
                  icon: Icons.person_outline,
                  title: AppLocalKeys.userName.tr(),
                  value: name,
                ),
                SizedBox(height: 12.h),
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  title: AppLocalKeys.email.tr(),
                  value: email,
                ),
                SizedBox(height: 24.h),

                // Settings Section
                Text(
                  AppLocalKeys.general.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.08),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const LanguageSelection(),
                      const Divider(height: 1, thickness: 1),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                        leading: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.newPrimaryColor
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.newPrimaryColor,
                          ),
                        ),
                        title: Text(
                          AppLocalKeys.notifications.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
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
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.08),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                    ),
                    title: Text(
                      AppLocalKeys.logout.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () {
                      SharedPreferencesHelper.removeAll().then((value) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          Routes.login,
                          (route) => false,
                        );
                      });
                    },
                  ),
                ),

                SizedBox(height: 32.h),

                // Delete Account
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      backgroundColor: Colors.red.withValues(alpha: 0.05),
                    ),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    label: _isDeletingAccount
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.redAccent,
                            ),
                          )
                        : Text(
                            AppLocalKeys.deleteAccount.tr(),
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    onPressed: _isDeletingAccount
                        ? null
                        : () => _showDeleteAccountDialog(context),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon, required String title, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.newPrimaryColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(AppLocalKeys.deleteAccountTitle.tr()),
              content: Text(AppLocalKeys.deleteAccountMessage.tr()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(AppLocalKeys.cancel.tr()),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(AppLocalKeys.confirmDelete.tr()),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    setState(() {
      _isDeletingAccount = true;
    });

    final userId = await SharedPreferencesHelper.getString(AppConstants.userId);

    if (!mounted) return;

    if (userId == null) {
      setState(() {
        _isDeletingAccount = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalKeys.deleteAccountError.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await context.read<UserCubit>().deleteUser();

    if (!mounted) return;

    setState(() {
      _isDeletingAccount = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalKeys.deleteAccountSuccess.tr()),
          backgroundColor: Colors.green,
        ),
      );

      await SharedPreferencesHelper.removeAll();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalKeys.deleteAccountError.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
