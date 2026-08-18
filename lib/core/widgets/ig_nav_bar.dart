// lib/core/widgets/ig_nav_bar.dart
import 'package:flutter/material.dart';

import '../theme/ig_colors.dart';
import '../utils/haptics.dart';
import 'ig_icon.dart';
import 'ig_icons.dart';

/// Instagram bottom bar: 5 unlabeled icons, no indicator animation.
/// Index 2 (create) fires [onCreate] instead of switching branches.
class IgNavBar extends StatelessWidget {
  const IgNavBar({
    required this.currentIndex,
    required this.onBranchSelected,
    required this.onCreate,
    this.avatarUrl,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onBranchSelected;
  final VoidCallback onCreate;
  final String? avatarUrl;

  static const List<int> _branchIndexOf = <int>[0, 1, -1, 2, 3];

  bool _isActive(int tab) {
    final int? branch = _branchIndexOf[tab] == -1 ? null : _branchIndexOf[tab];
    return branch != null && branch == currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color active = IgColors.textPrimary(brightness);
    final Color inactive = IgColors.textSecondary(brightness);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: brightness == Brightness.dark ? IgColors.black : IgColors.white,
        border: Border(
          top: BorderSide(color: IgColors.divider(brightness), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: Row(
            children: <Widget>[
              _tab(0, IgIcons.home, active, inactive),
              _tab(1, IgIcons.search, active, inactive),
              _tab(2, IgIcons.plusSquare, active, inactive, onCreate),
              _tab(3, IgIcons.reels, active, inactive),
              _avatarTab(active),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(
    int tab,
    IgIconData icon,
    Color active,
    Color inactive, [
    VoidCallback? override,
  ]) {
    final bool isActive = _isActive(tab);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppHaptics.tab();
          (override ?? () => onBranchSelected(_branchIndexOf[tab]))();
        },
        child: Center(
          child: IgIcon(icon, size: 26, color: isActive ? active : inactive),
        ),
      ),
    );
  }

  Widget _avatarTab(Color active) {
    final bool isActive = _isActive(4);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppHaptics.tab();
          onBranchSelected(3);
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? active : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: IgColors.elevatedDark,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? IgIcon(IgIcons.tagged, size: 16, color: active)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
