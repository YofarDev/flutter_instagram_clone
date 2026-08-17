import 'package:flutter/material.dart';

import '../../../../core/widgets/wordmark.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Wordmark(fontSize: 56),
            const SizedBox(height: 32),
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
