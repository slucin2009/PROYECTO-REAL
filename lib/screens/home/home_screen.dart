import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/core/constants/app_strings.dart';
import 'package:campus_fix/models/app_user.dart';
import 'package:campus_fix/providers/auth_provider.dart';
import 'package:campus_fix/screens/lost_found/lost_items_screen.dart';
import 'package:campus_fix/screens/maintenance/maintenance_list_screen.dart';
import 'package:campus_fix/screens/claims/claims_screen.dart';
import 'package:campus_fix/screens/admin/admin_dashboard_screen.dart';
import 'package:campus_fix/services/auth_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final bool studentMode;

  const HomeScreen({super.key, required this.studentMode});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavBarTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.studentMode) {
      final studentId = ref.watch(studentSessionIdProvider);
      final pages = <Widget>[
        _StudentHomeScreen(),
        LostItemsScreen(studentMode: true, studentSessionId: studentId),
        MaintenanceListScreen(studentMode: true, studentSessionId: studentId),
        ClaimsScreen(studentMode: true, studentSessionId: studentId),
      ];

      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appName),
          elevation: 0,
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: AppStrings.exitStudentModeButton,
              onPressed: () async {
                ref.read(studentModeProvider.notifier).state = false;
                ref.read(studentSessionIdProvider.notifier).state = null;
              },
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentPage,
          onDestinationSelected: _onNavBarTap,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
            NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Objetos'),
            NavigationDestination(icon: Icon(Icons.build), label: 'Mantenimiento'),
            NavigationDestination(icon: Icon(Icons.assignment), label: 'Reclamos'),
          ],
        ),
      );
    }

    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        final isAdmin = user != null && user.role != UserRole.student;
        final pages = <Widget>[
          _AuthorityHomeScreen(user: user),
          LostItemsScreen(studentMode: false, currentUser: user),
          const MaintenanceListScreen(studentMode: false),
          const ClaimsScreen(studentMode: false),
          if (isAdmin) const AdminDashboardScreen(),
        ];

        final destinations = <NavigationDestination>[
          const NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          const NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Objetos'),
          const NavigationDestination(icon: Icon(Icons.build), label: 'Mantenimiento'),
          const NavigationDestination(icon: Icon(Icons.assignment), label: 'Reclamos'),
          if (isAdmin) const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.appName),
            elevation: 0,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
                onPressed: () => _confirmSignOut(context),
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentPage,
            onDestinationSelected: _onNavBarTap,
            destinations: destinations,
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => const Scaffold(body: Center(child: Text(AppStrings.errorGeneral))),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Deseas cerrar sesión en tu cuenta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true || !mounted) return;

    try {
      await AuthService.instance.signOut();
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Error al cerrar sesión. Intenta de nuevo.')),
      );
    }
  }
}

class _StudentHomeScreen extends StatelessWidget {
  const _StudentHomeScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.studentModeDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          _InfoCard(
            icon: Icons.inventory_2,
            title: 'Objetos Perdidos',
            subtitle: 'Desliza o toca "Objetos" para ver los objetos encontrados en el colegio.',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.build,
            title: 'Reportar Problemas',
            subtitle: 'Reporta problemas de infraestructura o mantenimiento en el colegio.',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.assignment,
            title: 'Tus Reclamos',
            subtitle: 'Visualiza el estado de tus reclamos sobre objetos perdidos.',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Desliza horizontalmente o usa los botones inferiores para navegar.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorityHomeScreen extends StatelessWidget {
  final AppUser? user;

  const _AuthorityHomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'Autoridad';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, $name',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.appSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          _InfoCard(
            icon: Icons.inventory_2,
            title: 'Objetos Perdidos',
            subtitle: 'Administra los objetos perdidos encontrados en el colegio.',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.build,
            title: 'Mantenimiento',
            subtitle: 'Visualiza, actualiza y elimina reportes de mantenimiento.',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.assignment,
            title: 'Reclamos',
            subtitle: 'Administra los reclamos de estudiantes sobre objetos perdidos.',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Desliza horizontalmente o usa los botones inferiores para navegar.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
