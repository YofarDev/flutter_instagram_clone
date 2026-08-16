import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BlocListener<AuthCubit, AuthState>(
              listener: (BuildContext context, AuthState state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.error!)));
                }
              },
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (AuthState p, AuthState c) =>
                    p.submitting != c.submitting,
                builder: (BuildContext context, AuthState state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Instagram',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      AuthTextField(
                        label: l10n.authEmail,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: l10n.authPassword,
                        controller: _password,
                        obscure: true,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.submitting
                            ? null
                            : () => context.read<AuthCubit>().signIn(
                                  email: _email.text.trim(),
                                  password: _password.text,
                                ),
                        child: Text(l10n.authLogin),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.authOr, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: state.submitting
                            ? null
                            : () =>
                                context.read<AuthCubit>().signInWithGoogle(),
                        icon: const Icon(Icons.login),
                        label: Text(l10n.authGoogleButton),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.go(Routes.signup),
                        child:
                            Text('${l10n.authNoAccount} ${l10n.authSignup}'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
