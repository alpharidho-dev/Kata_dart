import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Nav bar bawah aplikasi: Beranda di kiri, tombol "+" bulat di tengah, dan
/// Profil di kanan.
///
/// Tombol "+" bukan tab — dia membuka layar buat postingan, jadi index yang
/// dikirim ke [onItemSelected] cuma 0 (beranda) dan 1 (profil).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onComposePressed,
    this.height = 64,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onComposePressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                isActive: selectedIndex == 0,
                onTap: () => onItemSelected(0),
                label: 'Beranda',
              ),
            ),
            _ComposeButton(onPressed: onComposePressed),
            Expanded(
              child: _NavBarItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                isActive: selectedIndex == 1,
                onTap: () => onItemSelected(1),
                label: 'Profil',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu ikon tab. Saat aktif, ikon berganti ke versi solid dan diberi latar
/// lingkaran tipis plus bayangan halus sebagai penanda posisi.
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: isActive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 18,
                        spreadRadius: -2,
                      ),
                    ]
                  : const [],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey<bool>(isActive),
                size: 26,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                shadows: isActive
                    ? [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposeButton extends StatefulWidget {
  const _ComposeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_ComposeButton> createState() => _ComposeButtonState();
}

class _ComposeButtonState extends State<_ComposeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buat postingan',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1,
          duration: const Duration(milliseconds: 140),
          child: Container(
            width: 54,
            height: 54,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.onPrimary,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
