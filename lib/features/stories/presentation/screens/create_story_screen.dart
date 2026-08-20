import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/haptics.dart';
import '../bloc/create_story_cubit.dart';
import '../bloc/create_story_state.dart';

class CreateStoryScreen extends StatelessWidget {
  const CreateStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createStoryTitle)),
      body: BlocListener<CreateStoryCubit, CreateStoryState>(
        listenWhen: (CreateStoryState p, CreateStoryState c) =>
            p.success != c.success || p.error != c.error,
        listener: (BuildContext context, CreateStoryState state) {
          if (state.success) {
            AppHaptics.success();
            context.pop();
          } else if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.error ?? l10n.errorGeneric)),
              );
          }
        },
        child: BlocBuilder<CreateStoryCubit, CreateStoryState>(
          builder: (BuildContext context, CreateStoryState state) {
            if (state.pickedPath == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<CreateStoryCubit>()
                          .pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.postAddPhoto),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<CreateStoryCubit>()
                          .pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(l10n.postTakePhoto),
                    ),
                  ],
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                GestureDetector(
                  onTap: () => context.read<CreateStoryCubit>().pickImage(
                    ImageSource.gallery,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.file(
                      File(state.pickedPath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.submitting
                      ? null
                      : () => context.read<CreateStoryCubit>().submit(),
                  child: state.submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.storiesAddToStory),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
