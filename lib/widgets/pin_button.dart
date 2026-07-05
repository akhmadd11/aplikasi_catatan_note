import 'package:flutter/material.dart';

import 'package:aplikasi_catatan_note/utils/constants.dart';

/// A pin/unpin toggle button with smooth icon transition.
///
/// When [isPinned] is true, displays a filled push-pin icon
/// in [AppColors.secondary] (amber). When false, displays
/// an outlined pin icon in grey.
class PinButton extends StatelessWidget {
  const PinButton({
    super.key,
    required this.isPinned,
    required this.onToggle,
  });

  /// Whether the associated note is currently pinned.
  final bool isPinned;

  /// Callback to toggle the pin state.
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      tooltip: isPinned ? 'Lepas sematan' : 'Sematkan',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: Icon(
          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          key: ValueKey<bool>(isPinned),
          color: isPinned ? AppColors.secondary : Colors.grey,
          size: 22,
        ),
      ),
    );
  }
}
