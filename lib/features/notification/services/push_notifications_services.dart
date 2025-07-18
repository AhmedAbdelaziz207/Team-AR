import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:team_ar/core/common/notification_model.dart';
import '../../../core/common/notification_type_enum.dart';
import '../../../firebase_options.dart';
import 'local_notification_service.dart';

class FirebaseNotificationsServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static LocalNotificationService localNotificationService =
      LocalNotificationService();

  static String firebaseScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  // static Future<String> getFirebaseAccessToken() async {
  //   final client = await clientViaServiceAccount(
  //     ServiceAccountCredentials.fromJson(
  //       {
  //         "type": "service_account",
  //         "project_id": "teamar-a88ba",
  //         "private_key_id": "6e812fb7887247ffd7dc80169d21efe08d38c1eb",
  //         "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDjxqb3F6OheFKs\n+ot+cC7EleRcvKzSTRBJpYUFPb7IdOQ0KL9gVzZoJsSNaO14ib2o48k/vSMBCjt9\nvbpT0juCsph3A13P9F5SVrgkvjlEdqf5w6nQyLfIoqzjyJovzAxZh15ojByqexp/\nx9ZuRd0d4G6SVQM8YuP1+EKBOORiBJJ3Xh/GS6jGr+C54xZBl28r0rRF6hrPP4aC\nU9V2iz8L3XblPiuqdwdjs04/pmz0mSCwEpQKyB7g8yfwpMaj2K4jYDTsg8fYSbxK\n2KfqIGo9/+Tj3SjcwXWCBigJPbui8cJ1UWA0RpUoVx0vh2zmlg04C8W8edXU6Ee6\nq034nO3pAgMBAAECggEAJuyaOMyV3nCg9EWGlA9YtqiE02I8yF16BJPgFQK1uSzc\nmJtEBRMyTX8ehKnjNv+W5Sc0C4vnUPSuMPE8x7k8CTw6+M+e9vwkKD8Ajerh/3Sl\nhPWuber3GTbPg8eSrctZau1KsWQMPAf4gdClMMgInuPtEV2sxWOC4FRSDSIrSSJ7\nT1JF/lB6XPkxYUqYtYzaeoMQcBdaHmvvv5vi3fbEVGXK8V2cn8fghjJIZBiyGBXz\nAl2ux45h4ukP1YyX6+U334f/vMbO58ZFWLNKPxcJ6jHqJPlJH1hFkeFhNlEZwHLU\nPG/PePT+PZhlOCMFQt8iBo4KFHTwRjLzMzwCSXnIlwKBgQD5nP1J6IJz14RKoVAL\nIuNXDnD6W33yDX8/tPjtjIIw0tyKumNPprgKA1VEW/35taC0LiBCMLXJOk6piZGN\n8hIUviaE3igVSX7yw0uZx7aMqy/SOaLYztDrKfTBMOQBeXRf+z6bCvCugwmdZ1uc\nohAiEQLeWKhfm2a0WQa5uKKBHwKBgQDpmp/8PkJuVQw9XGgR8JMEjR92KRq44frV\n1gnCjlNKywTM9l8PUn4N3e6ADqzSusH/FBAfmqjMvDu3wFCkW0zWzFR7lx4XMF9Z\n4SP0YELej/5jINQ26z5LXcWxgb7FJ91xH3N5RCkPZlkmTYsFJwnbtR6goe9SGwf2\nDk8FP+WH9wKBgQDzpw6HanKMaT81Kilb9X48qFgXyd8yu4IOybSDDLi4t9uXf0EZ\nqv/SplZBGBrd+TEZMD1E3w9TkZrfWu29xSFpJgOrhr9RqCBHD+NoBM5omWFgr+oK\nADdmldnYCsVFuyyh1DnUVeWCM17bStzeFEPzPO+z4o7YZHTobk5mU5gsuQKBgQCp\nqxToMJAvcrYhGyy7WvBtLdLcD57JCdkV1w/fr1/vwuUJuSfyCQhlKfxAJmh/5gVh\nL0FGsx5HFbCKFbR8q5Nzr5Ts7yV70jZvIYbrx77Jx+wMM5vvB42HT+R2uLXGnN3J\ne/5y5X6tILk/iLKgW2pdmX9VTEh2aguuO1ZJic88oQKBgB6BtkvIZlJ3ALcyqvWl\nbK2zPwz09aI78yWqt0KbKeyGIKCoYBd0In3px1Z11JA6QYFZJJL9TMaKrSgKJ8/F\ns4VS2hdpeuBqLdBjIbBKcf6JsSnYt1DeTNIyuBJginBKB4W3CJjLvdzlTmQXmxil\nWEM6Oiczh1ARTwDbB7AYcnxO\n-----END PRIVATE KEY-----\n",
  //         "client_email": "firebase-adminsdk-fbsvc@teamar-a88ba.iam.gserviceaccount.com",
  //         "client_id": "105569416387533680249",
  //         "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  //         "token_uri": "https://oauth2.googleapis.com/token",
  //         "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  //         "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40teamar-a88ba.iam.gserviceaccount.com",
  //         "universe_domain": "googleapis.com"        },
  //     ),
  //     [firebaseScope],
  //   );
  //   return client.credentials.accessToken.data;
  // }

  static init() async {
    messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    log("FCM token: ${await messaging.getToken()}");

    FirebaseMessaging.onBackgroundMessage((message) {
    return  _firebaseMessagingBackgroundHandler(message);
    },);

    FirebaseMessaging.onMessage.listen((event) {
      onMessaging(event);
    });
  }
 static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await LocalNotificationService().initialize(); // مهم في الخلفية
    final data = message.data;

    final notification = NotificationModel.fromJson(data);
    await LocalNotificationService().showNotification(notification);
  }

  static Future onMessageOpenedApp(RemoteMessage message) async {
    await Firebase.initializeApp();
    log(message.notification?.title.toString() ?? "Null");
  }

  static void subscribeToTopic(String topic) async {
    log("subscribeToTopic $topic");
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static void unSubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  static void unSubscribeFromAllTopics() async {
    log("unSubscribeFromAllTopics");
    List<String> topics = [];
    for (String topic in topics) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
  }

  static void onMessaging(RemoteMessage message) {

    log(message.notification?.title.toString() ?? "Null");
    // localNotificationService.initialize();
    localNotificationService.showNotification(
      NotificationModel(
        id: message.messageId ?? "",
        title: message.notification?.title ?? "",
        body: message.notification?.body ?? "",
        type: NotificationType.system,
        createdAt: message.sentTime ?? DateTime.now(),
      ),
    );
  }

  static String getDeviceToken() {
    return FirebaseMessaging.instance.getToken().toString();
  }

  static void sendFcmTokenToServer() async {
    final token = await FirebaseMessaging.instance.getToken();
    // Webservices webservices = Webservices();
    // try {
    //   await webservices.sendFcmToken(token);
    //   log("FCM token sent to server");
    // } catch (e) {
    //   log(e.toString());
    //   log("FCM token not sent to server");
    //
    // }

    log(token.toString());
  }
}
