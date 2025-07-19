import '../../features/user_info/model/trainee_model.dart';
import '../../features/auth/register/model/user_model.dart';
import '../../features/home/model/user_data.dart';

extension UserModelSubscription on UserModel {
  DateTime? get subscriptionEndPackage => endPackage;

  String? get subscriptionEndPackageString => endPackage?.toIso8601String();

  String? get subscriptionEmail => email;

  int? get subscriptionId => id;
}

extension UserDataSubscription on UserData {
  DateTime? get subscriptionEndPackage {
    if (endPackage == null) return null;
    try {
      return DateTime.parse(endPackage!);
    } catch (e) {
      return null;
    }
  }

  String? get subscriptionEndPackageString => endPackage;

  String? get subscriptionEmail => email;

  int? get subscriptionId => null; // UserData doesn't have ID
}

extension TrainerModelSubscription on TrainerModel {
  DateTime? get subscriptionEndPackage => endPackage;

  String? get subscriptionEndPackageString => endPackage?.toIso8601String();

  String? get subscriptionEmail => email;

  int? get subscriptionId => int.tryParse(id ?? '');
}
