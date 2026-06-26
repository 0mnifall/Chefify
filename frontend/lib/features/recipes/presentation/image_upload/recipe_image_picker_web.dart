// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

Future<String?> pickRecipeHeroImageUrl() {
  final completer = Completer<String?>();
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;

  input.onChange.first.then((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    completer.complete(file == null ? null : html.Url.createObjectUrl(file));
  });

  input.click();
  return completer.future;
}
