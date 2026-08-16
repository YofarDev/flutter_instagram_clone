import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_constants.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: Routes.feed,
        name: 'Feed',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Center(child: Text('Feed placeholder'))),
      ),
    ],
  );
}
