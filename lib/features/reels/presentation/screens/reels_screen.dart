import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/models/reel.dart';
import '../bloc/reels_cubit.dart';
import '../bloc/reels_state.dart';
import '../widgets/reel_item.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<ReelsCubit, ReelsState>(
        listenWhen: (ReelsState p, ReelsState c) => p.error != c.error,
        listener: (BuildContext context, ReelsState state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.error ?? l10n.errorGeneric)),
              );
            context.read<ReelsCubit>().clearError();
          }
        },
        child: BlocBuilder<ReelsCubit, ReelsState>(
          buildWhen: (ReelsState p, ReelsState c) =>
              p.status != c.status ||
              p.reels != c.reels ||
              p.likedIds != c.likedIds,
          builder: (BuildContext context, ReelsState state) {
            if (state.status == ReelsStatus.loading) {
              return const ColoredBox(
                color: Colors.black,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.reels.isEmpty) {
              return Center(
                child: Text(
                  l10n.reelsTitle,
                  style: const TextStyle(color: Colors.white54),
                ),
              );
            }
            return Stack(
              children: <Widget>[
                PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemCount: state.reels.length,
                  onPageChanged: (int index) {
                    setState(() => _current = index);
                    if (index >= state.reels.length - 2) {
                      context.read<ReelsCubit>().loadMore();
                    }
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final Reel reel = state.reels[index];
                    return ReelItem(
                      key: ValueKey<String>(reel.id),
                      reel: reel,
                      isCurrent: index == _current,
                      isLiked: state.likedIds.contains(reel.id),
                      onLikeTap: () =>
                          context.read<ReelsCubit>().toggleReelLike(reel),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: SafeArea(
                    child: FloatingActionButton.small(
                      onPressed: () => context.push(Routes.createReel),
                      child: const Icon(Icons.add),
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
