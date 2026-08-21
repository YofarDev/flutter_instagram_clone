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
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _caption.dispose();
    _pageController.dispose();
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
            if (state.pickedPaths.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<CreatePostCubit>()
                          .pickImages(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.postAddPhoto),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<CreatePostCubit>()
                          .pickImages(ImageSource.camera),
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
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: <Widget>[
                      PageView.builder(
                        controller: _pageController,
                        itemCount: state.pickedPaths.length,
                        itemBuilder: (BuildContext context, int index) =>
                            Image.file(
                              File(state.pickedPaths[index]),
                              fit: BoxFit.cover,
                            ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _RemoveButton(
                          onPressed: () {
                            final int page = _pageController.hasClients
                                ? _pageController.page?.round() ?? 0
                                : 0;
                            context.read<CreatePostCubit>().removeImageAt(page);
                            if (page > 0) {
                              _pageController.jumpToPage(page - 1);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (state.pickedPaths.length > 1)
                  _PageDots(
                    count: state.pickedPaths.length,
                    controller: _pageController,
                  ),
                const SizedBox(height: 8),
                if (state.pickedPaths.length < CreatePostCubit.maxImages)
                  OutlinedButton.icon(
                    onPressed: () => context.read<CreatePostCubit>().pickImages(
                      ImageSource.gallery,
                    ),
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(l10n.postAddMore),
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

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.controller});

  final int count;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final Color active = Theme.of(context).colorScheme.onSurface;
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        final int page = controller.hasClients
            ? controller.page?.round() ?? 0
            : 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < count; i++)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == page ? active : active.withValues(alpha: 0.25),
                ),
              ),
          ],
        );
      },
    );
  }
}
