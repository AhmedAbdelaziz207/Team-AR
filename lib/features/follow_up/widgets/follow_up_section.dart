import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/follow_up/services/follow_up_service.dart';

class FollowUpSection extends StatefulWidget {
  const FollowUpSection({super.key});

  @override
  State<FollowUpSection> createState() => _FollowUpSectionState();
}

class _FollowUpSectionState extends State<FollowUpSection> {
  List<Map<String, dynamic>> _trainees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await FollowUpService().getTraineesNeedingFollowUp();
    if (mounted) {
      setState(() {
        _trainees = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_trainees.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                '??????? ??????? ??????',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ..._trainees.map((t) {
            // TODO: Fetch user name from API if needed, or just show ID for now
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text('??????? ID: ${t['trainee_id']}',
                  style: TextStyle(color: Colors.red[800])),
            );
          }),
        ],
      ),
    );
  }
}
