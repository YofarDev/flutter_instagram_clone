import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupServiceLocator();
  // Demo capture mode: `--dart-define=DEMO_LOGIN=email:password` signs in
  // automatically so screen recording never fights the login keyboard.
  const String demoLogin = String.fromEnvironment('DEMO_LOGIN');
  if (demoLogin.isNotEmpty) {
    final int sep = demoLogin.indexOf(':');
    unawaited(
      getIt<AuthCubit>().signIn(
        email: demoLogin.substring(0, sep),
        password: demoLogin.substring(sep + 1),
      ),
    );
  }
  runApp(const MyApp());
}
