class ChatUserModel {
  final String? id;
  final String? userName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? whatsappNumber;
  final String? phoneNumber;
  final int? numOfUnReadMessages;
  final String ? lastMessageDateTime;

  ChatUserModel( {
    this.id,
    this.userName,
    this.firstName,
    this.lastName,
    this.email,
    this.whatsappNumber,
    this.phoneNumber,
    this.numOfUnReadMessages,
    this.lastMessageDateTime,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: (json['id'] ?? json['Id'] ?? json['userId'] ?? json['UserId'])?.toString(),
      userName: (json['userName'] ?? json['UserName'])?.toString(),
      firstName: (json['firstName'] ?? json['FirstName'])?.toString(),
      lastName: (json['lastName'] ?? json['LastName'])?.toString(),
      email: (json['email'] ?? json['Email'])?.toString(),
      whatsappNumber: (json['whatsappNumber'] ?? json['WhatsappNumber'])?.toString(),
      phoneNumber: (json['phoneNumber'] ?? json['PhoneNumber'])?.toString(),
      numOfUnReadMessages: (json['numOfUnReadMessages'] ?? json['NumOfUnReadMessages']) as int?,
      lastMessageDateTime: (json['lastMessageTime'] ?? json['LastMessageTime'] ?? json['lastMessageDateTime'])?.toString(),
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
      'lastMessageTime': lastMessageDateTime
    };
  }
}
