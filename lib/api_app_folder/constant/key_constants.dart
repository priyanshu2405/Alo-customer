import 'dart:io' show Platform;

/// Sent as the `X-API-Key` header on unauthenticated config endpoints.
const String appApiKey = '2Vqqr0PRUi2lareWPE7bRGtoyjbUQdaB';

/// Google Maps API keys for native SDKs (Android manifest & iOS AppDelegate)
const String googleMapsApiKeyAndroid = 'AIzaSyBDoZWzDdhnnXe0Kuaz0qcPZT_vsUltoxo';
const String googleMapsApiKeyIOS = 'AIzaSyDWTIoANjvo1nKkig_yiCHgxICxWNPvIpc';

/// Google Maps Web Services API key (Places API New, Routes API)
/// Used for HTTP REST calls across both Android and iOS
const String googleMapsWebApiKey = 'AIzaSyBDoZWzDdhnnXe0Kuaz0qcPZT_vsUltoxo';

String get googleMapsApiKey => googleMapsWebApiKey;
