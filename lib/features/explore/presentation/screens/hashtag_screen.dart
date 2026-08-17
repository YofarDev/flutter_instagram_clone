import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/post.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/hashtag_cubit.dart';
import '../bloc/hashtag_state.dart';

class HashtagScreen extends StatelessWidget {
  const HashtagScreen({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('#$tag')),
      body: BlocListener<HashtagCubit, HashtagState>(
        listenWhen: (HashtagState p, HashtagState c) => p.error != c.error,
        listener: (BuildContext context, HashtagState state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        child: BlocBuilder<HashtagCubit, HashtagState>(
          builder: (BuildContext context, HashtagState state) {
            if (state.status == HashtagStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.posts.isEmpty) {
              return const SizedBox.shrink();
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: state.posts.length,
              itemBuilder: (BuildContext context, int index) {
                final Post post = state.posts[index];
                return InkWell(
                  onTap: () =>
                      context.push(Routes.postDetailPath(post.id), extra: post),
                  child: Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: Colors.grey),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
