import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'productos_screen.dart';
import 'albaranes_screen.dart';
import 'categorias_screen.dart';
import 'usuarios_screen.dart';
import 'appcc_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _navigateToModule(BuildContext context, String route) {
    Widget screen;
    switch (route) {
      case 'productos':
        screen = const ProductosScreen();
        break;
      case 'albaranes':
        screen = const AlbaranesScreen();
        break;
      case 'appcc':
        screen = const AppccScreen();
        break;
      case 'usuarios':
        screen = const UsuariosScreen();
        break;
      case 'categorias':
        screen = const CategoriasScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Estás seguro que deseas salir?',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 16),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Salir',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.logout();
      
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  List<Map<String, dynamic>> _buildModules(bool isAdmin) {
    final commonModules = [
      {
        'title': 'Productos',
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFFFF8C42),
        'route': 'productos',
      },
      {
        'title': 'Albaranes',
        'icon': Icons.receipt_long_outlined,
        'color': const Color(0xFFFFAA6B),
        'route': 'albaranes',
      },
      {
        'title': 'APPCC',
        'icon': Icons.assignment_outlined,
        'color': const Color(0xFFE67635),
        'route': 'appcc',
      },
    ];

    if (isAdmin) {
      return [
        ...commonModules,
        {
          'title': 'Usuarios',
          'icon': Icons.people_outline,
          'color': const Color(0xFFD96125),
          'route': 'usuarios',
        },
        {
          'title': 'Categorías',
          'icon': Icons.category_outlined,
          'color': const Color(0xFFFF9F5A),
          'route': 'categorias',
        },
      ];
    }

    return commonModules;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final currentUser = authViewModel.currentUser;

    if (currentUser == null) {
      return const LoginScreen();
    }

    final modules = _buildModules(currentUser.isAdmin);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NotMess',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Hola, ${currentUser.nombre}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Cerrar sesión',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          currentUser.isAdmin 
                              ? Icons.admin_panel_settings_outlined 
                              : Icons.person_outline,
                          size: 32,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.nombre,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              currentUser.isAdmin ? 'Administrador' : 'Usuario',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Módulos disponibles',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return _ModuleCard(
                    title: module['title'] as String,
                    icon: module['icon'] as IconData,
                    color: module['color'] as Color,
                    onTap: () => _navigateToModule(context, module['route'] as String),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 58,
                  color: color,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
