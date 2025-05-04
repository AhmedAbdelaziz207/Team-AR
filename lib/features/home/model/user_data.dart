import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_data.g.dart';
@JsonSerializable()
class UserData {
  final String? name;
  final String? email;
  final String? imageUrl;
  final String? role;
  final String? gender;
  final String? address;
  final String? phoneNumber;
  final String? age;
  final String? weight;
  final String? long;
  final int? packageId;
  final String? startPackage;
  final String? endPackage;
  final int? reminderOfPackage;

  const UserData(
      {this.name,
      this.email,
      this.imageUrl,
      this.role,
      this.gender,
      this.address,
      this.phoneNumber,
      this.age,
      this.weight,
      this.long,
      this.packageId,
      this.startPackage,
      this.endPackage,
      this.reminderOfPackage});

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);

  int getTotalPackageDays(String startPackage, String endPackage) {
    DateTime start = DateTime.parse(startPackage);
    DateTime end = DateTime.parse(endPackage);
    return end.difference(start).inDays;
  }
}

/*

   "userName": "AhmedRamada",
        "phoneNumber": "010123456789",
        "email": "coach@admin.com",
        "password": null,
        "address": "Egypt",
        "long": 180,
        "weight": 80,
        "age": 28,
        "imageURL": "e0d93f72-9730-4ae5-a35c-143d1fe431c6WhatsApp Image 2025-02-18 at 6.57.52 PM (1).jpeg",
        "gender": "male",
        "startPackage": "2025-10-02T00:00:00",
        "endPackage": "2025-10-08T00:00:00",
        "reminderOfPackage": 196,
        "packageId": 2
 */
