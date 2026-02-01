class EnvConfig {
  static const String fawaterkApiKey = String.fromEnvironment(
    'FAWATERK_API_KEY',
    defaultValue:
        'd83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd', // Fallback for dev
  );
  static const String paymobApiKey = String.fromEnvironment(
    'PAYMOB_API_KEY',
    defaultValue:
        'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBMk56WTJNU3dpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS4tdmY4RWRBZWRlZFB2NS1sazJ5SWNiLW0zQm9LWTNSajlBbWxIdkFnRThpSldiWld2Q1FqUnRyZUFObENVWFZrZElCaG14Q1o0ZTl5OUlEYVpzQ2hHUQ==',
  );

  static const String paymobIntegrationId = String.fromEnvironment(
    'PAYMOB_INTEGRATION_ID',
    defaultValue: '5233025',
  );
}
