import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? username = context.watch<AuthCubit>().state.user?.username;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(l10n.feedPlaceholder),
            const SizedBox(height: 8),
            if (username != null) Text('@$username'),
          ],
        ),
      ),
    );
  }
}
