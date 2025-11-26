import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/services/avatar_service.dart';

/// Avatar widget - Displays user avatar
class AvatarWidget extends StatelessWidget {
  /// Avatar widget constructor
  const AvatarWidget({
    required this.avatarId, super.key,
    this.size,
    this.onTap,
  });

  /// Avatar ID
  final String? avatarId;

  /// Size of the avatar
  final double? size;

  /// On tap callback
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double avatarSize = size ?? 40.w;
    final String icon = avatarId != null
        ? AvatarService.getAvatarIcon(avatarId!)
        : AvatarService.getAvatarIcon(AvatarService.getDefaultAvatar());

    final Widget avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2.w,
        ),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(fontSize: avatarSize * 0.5),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}

/// Avatar selector widget - Allows user to select an avatar
class AvatarSelectorWidget extends StatelessWidget {
  /// Avatar selector widget constructor
  const AvatarSelectorWidget({
    required this.selectedAvatarId, required this.onAvatarSelected, super.key,
  });

  /// Currently selected avatar ID
  final String? selectedAvatarId;

  /// Callback when avatar is selected
  final ValueChanged<String> onAvatarSelected;

  @override
  Widget build(BuildContext context) => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: AvatarService.availableAvatars.length,
      itemBuilder: (BuildContext context, int index) {
        final String avatarId = AvatarService.availableAvatars[index];
        final bool isSelected = selectedAvatarId == avatarId;

        return GestureDetector(
          onTap: () => onAvatarSelected(avatarId),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: isSelected ? 3.w : 1.w,
              ),
            ),
            child: Center(
              child: Text(
                AvatarService.getAvatarIcon(avatarId),
                style: TextStyle(fontSize: 32.sp),
              ),
            ),
          ),
        );
      },
    );
}

