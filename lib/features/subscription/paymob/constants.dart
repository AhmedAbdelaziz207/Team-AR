import 'package:url_launcher/url_launcher.dart';

class Constants {
  String api_key =
      "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBMk56WTJNU3dpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS4tdmY4RWRBZWRlZFB2NS1sazJ5SWNiLW0zQm9LWTNSajlBbWxIdkFnRThpSldiWld2Q1FqUnRyZUFObENVWFZrZElCaG14Q1o0ZTl5OUlEYVpzQ2hHUQ==";
  String integration_id = "5233025";
}

Future<void> _pay() async {
  launchUrl(Uri.parse(
      "https://accept.paymob.com/api/acceptance/iframes/948332?payment_token={payment_key_obtained_previously}"));
}

class PaymentManager {}
