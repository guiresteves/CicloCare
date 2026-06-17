import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../home/screens/home_screen.dart';
import '../medications/screens/medications_screen.dart';
import '../exams/screens/exams_screen.dart';
import '../history/screens/history_screen.dart';
import '../profile/screens/profile_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const MedicationsScreen(),
      const ExamsScreen(),
      const HomeScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];
  }

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.medication_outlined,  activeIcon: Icons.medication_rounded,      label: 'Remédios'),
    _NavItem(icon: Icons.science_outlined,     activeIcon: Icons.science_rounded,         label: 'Exames'),
    _NavItem(icon: Icons.home_outlined,        activeIcon: Icons.home_rounded,            label: 'Início'),
    _NavItem(icon: Icons.history_outlined,     activeIcon: Icons.history_rounded,         label: 'Histórico'),
    _NavItem(icon: Icons.person_outline,       activeIcon: Icons.person_rounded,          label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: _navItems.asMap().entries.map((e) {
              final index    = e.key;
              final item     = e.value;
              final selected = index == _currentIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícone com indicador
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryLight
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            selected ? item.activeIcon : item.icon,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textHint,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Label
                        Text(
                          item.label,
                          style: AppTextStyles.bottomNavLabel.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textHint,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}