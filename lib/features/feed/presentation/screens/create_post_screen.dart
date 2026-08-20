import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/haptics.dart';
import '../bloc/create_post_cubit.dart';
import '../bloc/create_post_state.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _caption = TextEditingController();

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createPostTitle)),
      body: BlocListener<CreatePostCubit, CreatePostState>(
        listenWhen: (CreatePostState p, CreatePostState c) =>
            p.success != c.success || p.error != c.error,
        listener: (BuildContext context, CreatePostState state) {
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
        child: BlocBuilder<CreatePostCubit, CreatePostState>(
          builder: (BuildContext context, CreatePostState state) {
            if (state.pickedPath == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<CreatePostCubit>()
                          .pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.postAddPhoto),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<CreatePostCubit>()
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
                  onTap: () => context.read<CreatePostCubit>().pickImage(
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
                TextField(
                  controller: _caption,
                  decoration: InputDecoration(hintText: l10n.postCaptionHint),
                  maxLines: 3,
                  onChanged: (String value) =>
                      context.read<CreatePostCubit>().captionChanged(value),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.submitting
                      ? null
                      : () => context.read<CreatePostCubit>().submit(),
                  child: state.submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.postShare),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
