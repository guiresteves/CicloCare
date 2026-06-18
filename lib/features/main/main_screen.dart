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
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 2; // começa na Home

  late final List<Widget> _screens;
  late final List<AnimationController> _iconControllers;
  late final List<Animation<double>> _scaleAnims;

  // Índice da aba Home
  static const int _homeIndex = 2;

  @override
  void initState() {
    super.initState();

    _screens = [
      const MedicationsScreen(),
      const ExamsScreen(),
      // Usa o homeScreenKey para permitir reload externo
      HomeScreen(key: homeScreenKey),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    _iconControllers = List.generate(
      5,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _scaleAnims = _iconControllers
        .map((c) => Tween<double>(begin: 1.0, end: 1.25).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOutBack),
            ))
        .toList();

    // Anima o ícone inicial (Home)
    _iconControllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    for (final c in _iconControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// Navega para uma aba pelo índice.
  /// Se o destino for a Home, dispara reload() para sincronizar os dados.
  void navigateTo(int index) {
    if (index == _currentIndex) {
      // Já está na aba — se for Home, recarrega mesmo assim
      if (index == _homeIndex) {
        homeScreenKey.currentState?.reload();
      }
      return;
    }

    _iconControllers[_currentIndex].reverse();
    setState(() => _currentIndex = index);
    _iconControllers[index].forward();

    // Sempre que voltar para a Home, recarrega os dados
    if (index == _homeIndex) {
      // Pós-frame para garantir que o widget já está montado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        homeScreenKey.currentState?.reload();
      });
    }
  }

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.medication_outlined,
      activeIcon: Icons.medication_rounded,
      label: 'Remédios',
    ),
    _NavItem(
      icon: Icons.science_outlined,
      activeIcon: Icons.science_rounded,
      label: 'Exames',
    ),
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Início',
    ),
    _NavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      label: 'Histórico',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Perfil',
    ),
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
                  onTap: () => navigateTo(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pill animado + ícone com scale
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: ScaleTransition(
                          scale: _scaleAnims[index],
                          child: Icon(
                            selected ? item.activeIcon : item.icon,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textHint,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Label com transição de estilo
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTextStyles.bottomNavLabel.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textHint,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        child: Text(item.label),
                      ),
                    ],
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
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}