import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/models/app_user.dart';
import '../../../../core/models/post.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/utils/normalize_tag.dart';
import '../../../../core/widgets/ig_icon.dart';
import '../../../../core/widgets/ig_icons.dart';
import '../../../../core/widgets/skeleton/shimmer.dart';
import '../../../../core/widgets/skeleton/skeletons.dart';
import '../bloc/explore_cubit.dart';
import '../bloc/explore_state.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            BlocBuilder<SearchCubit, SearchState>(
              buildWhen: (SearchState p, SearchState c) => p.query != c.query,
              builder: (BuildContext context, SearchState state) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: IgIcon(
                        IgIcons.search,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: state.query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _controller.clear();
                                context.read<SearchCubit>().queryChanged('');
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onChanged: (String query) =>
                        context.read<SearchCubit>().queryChanged(query),
                  ),
                );
              },
            ),
            Expanded(
              child: BlocListener<SearchCubit, SearchState>(
                listenWhen: (SearchState p, SearchState c) =>
                    p.error != c.error && c.error != null,
                listener: (BuildContext context, SearchState state) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(state.error ?? l10n.errorGeneric)),
                    );
                  context.read<SearchCubit>().clearError();
                },
                child: BlocBuilder<SearchCubit, SearchState>(
                  buildWhen: (SearchState p, SearchState c) =>
                      p.query != c.query ||
                      p.users != c.users ||
                      p.searching != c.searching,
                  builder: (BuildContext context, SearchState state) {
                    if (state.query.trim().isEmpty) {
                      return BlocListener<ExploreCubit, ExploreState>(
                        listenWhen: (ExploreState p, ExploreState c) =>
                            p.error != c.error,
                        listener: (BuildContext context, ExploreState state) {
                          if (state.error != null) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.error ?? l10n.errorGeneric,
                                  ),
                                ),
                              );
                            context.read<ExploreCubit>().clearError();
                          }
                        },
                        child: BlocBuilder<ExploreCubit, ExploreState>(
                          builder: (BuildContext context, ExploreState state) {
                            if (state.status == ExploreStatus.loading) {
                              return Shimmer(
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1,
                                        mainAxisSpacing: 2,
                                        crossAxisSpacing: 2,
                                      ),
                                  itemCount: 18,
                                  itemBuilder: (_, _) =>
                                      const SkeletonGridTile(),
                                ),
                              );
                            }
                            if (state.posts.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification n) {
                                if (n.metrics.pixels >
                                    n.metrics.maxScrollExtent - 300) {
                                  context.read<ExploreCubit>().loadMore();
                                }
                                return false;
                              },
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1,
                                      mainAxisSpacing: 2,
                                      crossAxisSpacing: 2,
                                    ),
                                itemCount: state.posts.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Post post = state.posts[index];
                                  final String heroTag =
                                      'explore-${post.id}';
                                  return InkWell(
                                    onTap: () => context.push(
                                      Routes.postDetailPath(
                                        post.id,
                                        heroTag: heroTag,
                                      ),
                                      extra: post,
                                    ),
                                    child: Hero(
                                      tag: heroTag,
                                      child: Image.network(
                                        post.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            Container(color: Colors.grey),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    }
                    final String tag = normalizeTag(state.query);
                    final List<AppUser> users = state.users;
                    return ListView(
                      children: <Widget>[
                        if (state.searching)
                          const LinearProgressIndicator(minHeight: 2),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            l10n.searchAccounts,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (users.isEmpty && !state.searching)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: Text(l10n.searchNoResults)),
                          ),
                        for (final AppUser user in users)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(
                                      user.username?.isNotEmpty == true
                                          ? user.username![0].toUpperCase()
                                          : '?',
                                    )
                                  : null,
                            ),
                            title: Text(user.username ?? ''),
                            onTap: () =>
                                context.push(Routes.userPath(user.uid)),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            l10n.searchHashtags,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (tag.isNotEmpty)
                          ListTile(
                            leading: const Icon(Icons.tag),
                            title: Text('#$tag'),
                            onTap: () => context.push(Routes.hashtagPath(tag)),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
