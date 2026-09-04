import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/features/follow_up/model/follow_up_trainee.dart';
import 'package:team_ar/features/follow_up/services/follow_up_service.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';

class FollowUpSection extends StatefulWidget {
  const FollowUpSection({super.key});

  @override
  State<FollowUpSection> createState() => _FollowUpSectionState();
}

class _FollowUpSectionState extends State<FollowUpSection> {
  final FollowUpService _followUpService = FollowUpService();
  late Future<List<FollowUpTrainee>> _followUpsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _followUpsFuture = _followUpService
        .getFollowUpTraineesWithDetails(getIt<TraineesRepository>());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FollowUpTrainee>>(
      future: _followUpsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final count = snapshot.data!.length;
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE53935),
                Color(0xFFFF7043),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.followUpTrainees).then((_) {
                  setState(() {
                    _refresh();
                  });
                });
              },
              borderRadius: BorderRadius.circular(18.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.alarm_on_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "تنبيه متابعة المتدربين",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  "$count",
                                  style: TextStyle(
                                    color: const Color(0xFFE53935),
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            "يوجد $count متدرب تأخرت متابعتهم لأكثر من 14 يوماً!",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "عرض",
                            style: TextStyle(
                              color: const Color(0xFFE53935),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: const Color(0xFFE53935),
                            size: 11.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
