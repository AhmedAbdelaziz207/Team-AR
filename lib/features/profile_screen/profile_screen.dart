import 'dart:developer';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/features/admin_panal/widget/change_language_section.dart';
import 'package:team_ar/features/admin_panal/widget/logout_button.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
      ),
    );
  }

  // استخراج واجهة المستخدم إلى دالة منفصلة لتجنب تكرار الكود
  Widget buildUserProfile(String name, String email, String? userImagePath) {
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
                ",   $name",
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
                        backgroundColor: AppColors.grey.withValues(alpha: .2),
                        backgroundImage: image != null
                            ? FileImage(image!)
                            : userImagePath != null
                                ? NetworkImage(
                                    ApiEndPoints.usersImagesBaseUrl +
                                        userImagePath,
                                  )
                                : null,
                        child: image != null || userImagePath != null
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
            controller: TextEditingController(text: name),
            suffixIcon: Icons.person,
            prefixIcon: Icons.lock,
            iconColor: AppColors.newPrimaryColor,
          ),
          SizedBox(
            height: 16.h,
          ),
          Text(
            AppLocalKeys.email.tr(),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8.h,
          ),
          CustomTextFormField(
            readOnly: true,
            controller: TextEditingController(text: email),
            suffixIcon: Icons.email_outlined,
            prefixIcon: Icons.lock,
            iconColor: AppColors.newPrimaryColor,
          ),
          SizedBox(
            height: 16.h,
          ),
          Text(AppLocalKeys.general.tr(),
              style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.bold)),
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

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newPrimaryColor,
                ),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                label: _isDeletingAccount
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppLocalKeys.deleteAccount.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                onPressed: _isDeletingAccount
                    ? null
                    : () => _showDeleteAccountDialog(context),
              ),
            ),
          ),

          SizedBox(height: 21.h),
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
