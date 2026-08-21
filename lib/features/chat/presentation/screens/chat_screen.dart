import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/models/app_user.dart';
import '../../../../core/router/route_constants.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/models/chat_message.dart';
import '../bloc/chat_cubit.dart';
import '../bloc/chat_state.dart';
import '../widgets/typing_dots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

/// Image message: rounded thumbnail, tap opens a fullscreen viewer.
class _ImageBubble extends StatelessWidget {
  const _ImageBubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ImageViewer(url: message.imageUrl!),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
          maxHeight: 320,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          message.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox(
            width: 120,
            height: 120,
            child: Icon(Icons.broken_image_outlined),
          ),
          loadingBuilder: (_, Widget child, ImageChunkEvent? progress) =>
              progress == null
              ? child
              : const SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Shared-post message: cover image with a Post chip, tap opens the post.
class _PostBubble extends StatelessWidget {
  const _PostBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.postDetailPath(message.postId!)),
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
              maxHeight: 320,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              message.imageUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                width: 120,
                height: 120,
                child: Icon(Icons.broken_image_outlined),
              ),
              loadingBuilder: (_, Widget child, ImageChunkEvent? progress) =>
                  progress == null
                  ? child
                  : const SizedBox(
                      width: 120,
                      height: 120,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                AppLocalizations.of(context).chatPostPreview,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Story reply: quoted story image with the reply text beneath it.
class _StoryBubble extends StatelessWidget {
  const _StoryBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.network(
            message.imageUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(
              width: 120,
              height: 120,
              child: Icon(Icons.broken_image_outlined),
            ),
            loadingBuilder: (_, Widget child, ImageChunkEvent? progress) =>
                progress == null
                ? child
                : const SizedBox(
                    width: 120,
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(message.text),
          ),
        ],
      ),
    );
  }
}

/// Black fullscreen viewer; pinch-zooms, tap anywhere to close.
class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: InteractiveViewer(
          maxScale: 4,
          child: Center(child: Image.network(url, fit: BoxFit.contain)),
        ),
      ),
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatCubit>().send(text);
    _controller.clear();
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(AppLocalizations.of(sheetContext).postAddPhoto),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(AppLocalizations.of(sheetContext).postTakePhoto),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      await context.read<ChatCubit>().pickAndSendImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String myUid = context.watch<AuthCubit>().state.user!.uid;
    final AppUser otherUser = context
        .read<ChatCubit>()
        .state
        .conversation
        .otherUser;
    final String username = otherUser.username ?? '';
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => context.push(Routes.userPath(otherUser.uid)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundImage: otherUser.avatarUrl != null
                    ? NetworkImage(otherUser.avatarUrl!)
                    : null,
                child: otherUser.avatarUrl == null
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(username, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
      body: BlocListener<ChatCubit, ChatState>(
        listenWhen: (ChatState p, ChatState c) => p.error != c.error,
        listener: (BuildContext context, ChatState state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
            context.read<ChatCubit>().clearError();
          }
        },
        child: BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (ChatState p, ChatState c) =>
              p.messages != c.messages ||
              p.sending != c.sending ||
              p.otherTyping != c.otherTyping,
          builder: (BuildContext context, ChatState state) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: state.messages.isEmpty
                      ? Center(
                          child: Text(
                            l10n.chatEmpty,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: state.messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ChatMessage message = state
                                .messages[state.messages.length - 1 - index];
                            final bool mine = message.senderId == myUid;
                            // "Seen" rides under the newest own message only
                            ChatMessage? lastOwn;
                            for (final ChatMessage m in state.messages) {
                              if (m.senderId == myUid) lastOwn = m;
                            }
                            final bool showSeen =
                                lastOwn != null &&
                                message.id == lastOwn.id &&
                                message.readAt != null;
                            return Align(
                              alignment: mine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: mine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (message.isPost)
                                    _PostBubble(message: message)
                                  else if (message.isStory)
                                    _StoryBubble(message: message)
                                  else if (message.isImage)
                                    _ImageBubble(message: message, mine: mine)
                                  else
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.75,
                                      ),
                                      decoration: BoxDecoration(
                                        color: mine
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(message.text),
                                    ),
                                  if (showSeen)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 4,
                                        bottom: 2,
                                      ),
                                      child: Text(
                                        l10n.chatSeen,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.5),
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                if (state.sending) const LinearProgressIndicator(minHeight: 2),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (state.otherTyping)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, bottom: 2),
                            child: Semantics(
                              label: l10n.chatTyping,
                              child: const TypingDots(),
                            ),
                          ),
                        Row(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.photo_camera_outlined),
                              tooltip: l10n.chatSendPhoto,
                              onPressed: _pickImage,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: l10n.dmHint,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  filled: true,
                                ),
                                onChanged: (String text) => context
                                    .read<ChatCubit>()
                                    .onInputChanged(text),
                                onSubmitted: (_) => _send(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              tooltip: l10n.dmSend,
                              onPressed: _send,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
