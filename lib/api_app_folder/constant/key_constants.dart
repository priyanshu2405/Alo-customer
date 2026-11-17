import 'dart:io' show Platform;

/// Sent as the `X-API-Key` header on unauthenticated config endpoints.
const String appApiKey = '2Vqqr0PRUi2lareWPE7bRGtoyjbUQdaB';

/// Google Maps API keys
const String googleMapsApiKeyAndroid = 'AIzaSyBDoZWzDdhnnXe0Kuaz0qcPZT_vsUltoxo';
const String googleMapsApiKeyIOS = 'AIzaSyDWTIoANjvo1nKkig_yiCHgxICxWNPvIpc';

String get googleMapsApiKey => Platform.isIOS ? googleMapsApiKeyIOS : googleMapsApiKeyAndroid;
