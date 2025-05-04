import 'package:easy_localization/easy_localization.dart';

String formatDate(DateTime date) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formattedTime = formatter.format(date);
  return formattedTime;
}
