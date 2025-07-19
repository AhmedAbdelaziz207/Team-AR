class ChatUserModel {
  final String? id;
  final String? userName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? whatsappNumber;
  final String? phoneNumber;
  final int? numOfUnReadMessages;

  ChatUserModel({
    this.id,
    this.userName,
    this.firstName,
    this.lastName,
    this.email,
    this.whatsappNumber,
    this.phoneNumber,
    this.numOfUnReadMessages,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'] as String?,
      userName: json['userName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      numOfUnReadMessages: json['numOfUnReadMessages'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'whatsappNumber': whatsappNumber,
      'phoneNumber': phoneNumber,
      'numOfUnReadMessages': numOfUnReadMessages,
    };
  }
}
