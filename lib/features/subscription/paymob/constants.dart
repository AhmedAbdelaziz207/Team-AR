import 'package:url_launcher/url_launcher.dart';
import 'package:team_ar/core/config/env_config.dart';

class Constants {
  String api_key = EnvConfig.paymobApiKey;
  String integration_id = EnvConfig.paymobIntegrationId;
}

Future<void> _pay() async {
  launchUrl(Uri.parse(
      "https://accept.paymob.com/api/acceptance/iframes/948332?payment_token={payment_key_obtained_previously}"));
}

class PaymentManager {}
