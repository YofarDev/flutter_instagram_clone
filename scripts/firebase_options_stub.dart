// Compile-only stand-in for the flutterfire-generated lib/firebase_options.dart.
// CI copies this over lib/firebase_options.dart before `flutter analyze` /
// `flutter test` — neither touches Firebase at runtime. Replace it with the
// real `flutterfire configure` output to run the app.
import 'package:firebase_core/firebase_core.dart';

final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Run `flutterfire configure` to generate real '
    'Firebase options.',
  );
}
