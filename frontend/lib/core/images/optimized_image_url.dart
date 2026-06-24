String optimizedImageUrl(
  String imageUrl, {
  required int width,
  int quality = 72,
}) {
  final trimmedUrl = imageUrl.trim();
  final uri = Uri.tryParse(trimmedUrl);
  if (uri == null || !uri.hasScheme || width <= 0) {
    return trimmedUrl;
  }

  if (!_supportsRemoteSizing(uri)) {
    return trimmedUrl;
  }

  final queryParameters = Map<String, String>.of(uri.queryParameters);
  queryParameters['auto'] = 'format';
  queryParameters.putIfAbsent('fit', () => 'crop');
  queryParameters['w'] = width.toString();
  queryParameters['q'] = quality.clamp(1, 100).toString();

  return uri.replace(queryParameters: queryParameters).toString();
}

bool _supportsRemoteSizing(Uri uri) {
  final host = uri.host.toLowerCase();
  return host == 'images.unsplash.com' || host.endsWith('.images.unsplash.com');
}
