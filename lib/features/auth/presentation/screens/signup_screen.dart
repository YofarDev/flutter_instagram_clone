import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (_password.text != _confirm.text) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.authPasswordsDontMatch)),
        );
      return;
    }
    context.read<AuthCubit>().signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authSignupTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BlocListener<AuthCubit, AuthState>(
              listenWhen: (AuthState p, AuthState c) => p.error != c.error,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
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
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: l10n.authConfirmPassword,
                        controller: _confirm,
                        obscure: true,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.submitting ? null : _submit,
                        child: Text(l10n.authSignup),
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
                        onPressed: () => context.go(Routes.login),
                        child:
                            Text('${l10n.authHasAccount} ${l10n.authLogin}'),
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
