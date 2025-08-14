import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_type_enum.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';
import '../logic/notification_cubit.dart';
import '../logic/notification_state.dart';
import '../widgets/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  NotificationCubit? _notificationCubit;
  late TabController _tabController;
  late TextEditingController _searchController;

  String _searchQuery = '';
  NotificationType? _selectedFilter;
  bool _hasInitializationError = false;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController = TextEditingController();
    // Defer initialization to after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotificationCubit();
    });
  }

  void _initializeNotificationCubit() {
    try {
      if (mounted) {
        _notificationCubit = context.read<NotificationCubit>();
        _loadNotifications();
        setState(() {
          _hasInitializationError = false;
          _errorMessage = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasInitializationError = true;
          _errorMessage = 'فشل في تهيئة نظام الإشعارات: ${e.toString()}';
        });
      }
      print('Error initializing NotificationCubit: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotifications() {
    if (_notificationCubit != null && mounted) {
      _notificationCubit!.loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_hasInitializationError) {
      return _buildErrorScaffold();
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: _notificationCubit != null
                  ? BlocBuilder<NotificationCubit, NotificationState>(
                      bloc: _notificationCubit,
                      builder: (context, state) {
                        if (state is NotificationLoading) {
                          return _buildLoadingState();
                        }

                        if (state is NotificationError) {
                          return _buildErrorState(state.message);
                        }

                        if (state is NotificationLoaded) {
                          return _buildNotificationsContent(
                              state.notifications);
                        }

                        return _buildEmptyState();
                      },
                    )
                  : _buildErrorState(
                      AppLocalKeys.errorLoadingNotifications.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalKeys.notifications.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalKeys.errorLoadingNotifications.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    _initializeNotificationCubit();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalKeys.retry.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        AppLocalKeys.notifications.tr(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (_notificationCubit != null)
          BlocBuilder<NotificationCubit, NotificationState>(
            bloc: _notificationCubit,
            builder: (context, state) {
              if (state is NotificationLoaded &&
                  state.notifications.isNotEmpty) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // عدد الإشعارات غير المقروءة
                    if (state.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        switch (value) {
                          case 'mark_all_read':
                            _notificationCubit?.markAllAsRead();
                            break;
                          case 'clear_all':
                            _showClearAllDialog();
                            break;
                          case 'test_notifications':
                            _notificationCubit?.testNotifications();
                            break;
                          case 'settings':
                            _navigateToSettings();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'mark_all_read',
                          child: Row(
                            children: [
                              const Icon(Icons.done_all, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(AppLocalKeys.markAllAsRead.tr()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'test_notifications',
                          child: Row(
                            children: [
                              const Icon(Icons.bug_report,
                                  color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(AppLocalKeys.testNotifications.tr()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              const Icon(Icons.settings, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(AppLocalKeys.settings.tr()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'clear_all',
                          child: Row(
                            children: [
                              const Icon(Icons.clear_all, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(AppLocalKeys.clearAll.tr()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
      bottom: _buildTabBar(),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      tabs: [
        Tab(text: AppLocalKeys.all.tr()),
        Tab(text: AppLocalKeys.unread.tr()),
        Tab(text: AppLocalKeys.subscriptions.tr()),
        Tab(text: AppLocalKeys.workouts.tr()),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // شريط البحث
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalKeys.searchNotifications.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // فلاتر سريعة
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(AppLocalKeys.all.tr(), null),
                const SizedBox(width: 8),
                _buildFilterChip(
                    AppLocalKeys.system.tr(), NotificationType.system),
                const SizedBox(width: 8),
                _buildFilterChip(AppLocalKeys.subscription.tr(),
                    NotificationType.subscriptionExpiry),
                const SizedBox(width: 8),
                _buildFilterChip(AppLocalKeys.workout.tr(),
                    NotificationType.workoutReminder),
                const SizedBox(width: 8),
                _buildFilterChip(
                    AppLocalKeys.offers.tr(), NotificationType.promotion),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationType? type) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? type : null;
        });
      },
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalKeys.errorLoadingNotifications.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _notificationCubit?.loadNotifications(),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalKeys.retry.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsContent(List<NotificationModel> notifications) {
    final filteredNotifications = _filterNotifications(notifications);

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotificationsList(filteredNotifications),
        _buildNotificationsList(
            filteredNotifications.where((n) => !n.isRead).toList()),
        _buildNotificationsList(filteredNotifications
            .where((n) => n.type == NotificationType.subscriptionExpiry)
            .toList()),
        _buildNotificationsList(filteredNotifications
            .where((n) => n.type == NotificationType.workoutReminder)
            .toList()),
      ],
    );
  }

  List<NotificationModel> _filterNotifications(
      List<NotificationModel> notifications) {
    var filtered = notifications;

    // تطبيق فلتر النوع
    if (_selectedFilter != null) {
      filtered = filtered.where((n) => n.type == _selectedFilter).toList();
    }

    // تطبيق فلتر البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            n.body.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () async {
        _notificationCubit?.loadNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NotificationTile(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
              onDelete: () => _handleNotificationDelete(notification),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalKeys.noNotifications.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalKeys.notificationsWillAppearHere.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _notificationCubit?.loadNotifications(),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalKeys.update.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // تحديد الإشعار كمقروء
    if (!notification.isRead) {
      _notificationCubit?.markAsRead(notification.id);
    }

    // التنقل حسب نوع الإشعار
    switch (notification.type) {
      case NotificationType.subscriptionExpiry:
        _navigateToSubscription();
        break;
      case NotificationType.workoutReminder:
        _navigateToWorkout();
        break;
      case NotificationType.promotion:
        _navigateToPromotions();
        break;
      default:
        _showNotificationDetails(notification);
        break;
    }
  }

  void _handleNotificationDelete(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalKeys.deleteNotification.tr()),
        content: Text(AppLocalKeys.confirmDeleteNotification.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              _notificationCubit?.deleteNotification(notification.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalKeys.notificationDeleted.tr())),
              );
            },
            child: Text(
              AppLocalKeys.delete.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalKeys.clearAllNotifications.tr()),
        content: Text(AppLocalKeys.confirmClearAllNotifications.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              _notificationCubit?.clearAllNotifications();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(AppLocalKeys.allNotificationsCleared.tr())),
              );
            },
            child: Text(
              AppLocalKeys.clearAll.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.body),
              const SizedBox(height: 16),
              Text(
                '${AppLocalKeys.date.tr()}: ${notification.createdAt.toString().split('.')[0]}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${AppLocalKeys.type.tr()}: ${_getTypeDisplayName(notification.type)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalKeys.close.tr()),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.system:
        return AppLocalKeys.system.tr();
      case NotificationType.subscriptionExpiry:
        return AppLocalKeys.subscription.tr();
      case NotificationType.workoutReminder:
        return AppLocalKeys.workout.tr();
      case NotificationType.promotion:
        return AppLocalKeys.offers.tr();
      case NotificationType.bookingConfirmation:
        return AppLocalKeys.bookingConfirmation.tr();
      case NotificationType.paymentConfirmation:
        return AppLocalKeys.paymentConfirmation.tr();
      case NotificationType.newContent:
        return AppLocalKeys.newContent.tr();
      case NotificationType.maintenance:
        return AppLocalKeys.maintenance.tr();
      case NotificationType.workoutPlan:
        return AppLocalKeys.workoutPlan.tr();
      case NotificationType.trainerEvaluation:
        return AppLocalKeys.trainerEvaluation.tr();
      case NotificationType.bookingCancellation:
        return AppLocalKeys.bookingCancellation.tr();
      case NotificationType.motivational:
        return AppLocalKeys.motivational.tr();
      case NotificationType.newMember:
        return AppLocalKeys.newMember.tr();
      case NotificationType.bookingRequest:
        return AppLocalKeys.bookingRequest.tr();
      case NotificationType.newReview:
        return AppLocalKeys.newReview.tr();
      case NotificationType.technicalIssue:
        return AppLocalKeys.technicalIssue.tr();
      default:
        return AppLocalKeys.system.tr();
    }
  }

  // دوال التنقل
  void _navigateToSubscription() {
    // Navigator.pushNamed(context, Routes.subscription);
  }

  void _navigateToWorkout() {
    // Navigator.pushNamed(context, Routes.workout);
  }

  void _navigateToPromotions() {
    // Navigator.pushNamed(context, Routes.promotions);
  }

  void _navigateToSettings() {
    // Navigator.pushNamed(context, Routes.notificationSettings);
  }
}
