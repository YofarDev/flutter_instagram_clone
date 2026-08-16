import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../bloc/edit_profile_cubit.dart';
import '../bloc/edit_profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _username;
  late final TextEditingController _bio;

  @override
  void initState() {
    super.initState();
    final EditProfileState state = context.read<EditProfileCubit>().state;
    _username = TextEditingController(text: state.username);
    _bio = TextEditingController(text: state.bio);
  }

  @override
  void dispose() {
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 70,
    );
    if (picked != null && mounted) {
      context.read<EditProfileCubit>().avatarPicked(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfileTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BlocListener<EditProfileCubit, EditProfileState>(
              listenWhen: (EditProfileState p, EditProfileState c) =>
                  p.success != c.success || p.error != c.error,
              listener: (BuildContext context, EditProfileState state) {
                if (state.success) {
                  context.pop();
                } else if (state.error != null) {
                  // ponytail: string match on failure message; typed Failure when more cases appear
                  final String message = state.error!.contains('Username is taken')
                      ? l10n.usernameTaken
                      : state.error!;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(message)));
                }
              },
              child: BlocBuilder<EditProfileCubit, EditProfileState>(
                buildWhen: (EditProfileState p, EditProfileState c) =>
                    p.avatarPath != c.avatarPath ||
                    p.submitting != c.submitting,
                builder: (BuildContext context, EditProfileState state) {
                  final String? url = state.initial.avatarUrl;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: state.avatarPath != null
                            ? FileImage(File(state.avatarPath!))
                            : url != null
                                ? NetworkImage(url)
                                : null,
                        child: state.avatarPath == null && url == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      TextButton(
                        onPressed: _pickAvatar,
                        child: Text(l10n.editProfileChangePhoto),
                      ),
                      TextField(
                        controller: _username,
                        onChanged:
                            context.read<EditProfileCubit>().usernameChanged,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingUsername,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bio,
                        onChanged: context.read<EditProfileCubit>().bioChanged,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingBio,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.submitting
                            ? null
                            : () =>
                                context.read<EditProfileCubit>().submit(),
                        child: Text(l10n.profileSave),
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
