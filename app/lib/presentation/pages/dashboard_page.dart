import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/project_bloc.dart';

import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_state.dart';
import '../blocs/theme/theme_cubit.dart';
import '../widgets/tech_loading.dart';
import '../../domain/repositories/project_repository.dart';

import '../widgets/dashboard_stats_widget.dart';
import '../widgets/project_filter_bar.dart';
import '../widgets/project_card.dart';
import '../widgets/branding_footer.dart';
import 'profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // print('📊 [DASHBOARD] Building DashboardPage');
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            // print('📊 [DASHBOARD] Creating ProjectBloc');
            return ProjectBloc(context.read<ProjectRepository>())
              ..add(LoadProjects());
          },
        ),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            return Row(
              children: [
                NavigationRail(
                  leading: Builder(builder: (context) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    return Container(
                      height: 50,
                      width: 50,
                      margin: const EdgeInsets.only(bottom: 20, top: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          isDark
                              ? 'assets/images/logo_dark_theme.jpg'
                              : 'assets/images/logo_light_theme.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),
                  selectedIndex: 0,
                  onDestinationSelected: (int index) {
                    // Handle navigation
                  },
                  labelType: NavigationRailLabelType.selected,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Proyectos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Perfil'),
                    ),
                  ],
                  trailing: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: IconButton(
                      onPressed: () => _showCreateProjectDialog(context),
                      icon: const Icon(Icons.add_circle,
                          size: 40, color: Color(0xFFF59E0B)),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _buildDashboardContent(context, isDesktop: true),
                ),
              ],
            );
          }

          return _buildDashboardContent(context, isDesktop: false);
        },
      ),
      floatingActionButton: Builder(builder: (context) {
        // Only show FAB on mobile, as Desktop has it in the Rail
        if (MediaQuery.of(context).size.width > 800) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          onPressed: () => _showCreateProjectDialog(context),
          backgroundColor: const Color(0xFFF59E0B), // Orange
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Proyecto'),
        );
      }),
    );
  }

  Widget _buildDashboardContent(BuildContext context,
      {required bool isDesktop}) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProjectBloc>().add(LoadProjects());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          // App Bar with Stats
          SliverAppBar(
            expandedHeight: 280, // Increased height for stats
            floating: false,
            pinned: true,
            // On desktop, we might want less height or different styling
            // keeping consistent for now but could reduce expandedHeight
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1), // Indigo
                      Color(0xFF8B5CF6), // Purple
                      Color(0xFFA855F7), // Purple light
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Logo Branding
                                  // NOTE: Using Image.asset with correct path.
                                  // Assuming user wants the logo visible.
                                  // Since we are in a purple header, we need to check if we want the logo here or just text.
                                  // Let's put the logo above 'Hola'.
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Logo Widget
                                    Builder(builder: (context) {
                                      final isDark =
                                          Theme.of(context).brightness ==
                                              Brightness.dark;
                                      return Container(
                                        height: 60,
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Image.asset(
                                          isDark
                                              ? 'assets/images/logo_dark_theme.jpg'
                                              : 'assets/images/logo_light_theme.jpg',
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    }),
                                    const Text(
                                      '👋 Hola',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Mis Proyectos',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Theme Toggle & Avatar
                              Row(
                                children: [
                                  BlocBuilder<ThemeCubit, ThemeMode>(
                                    builder: (context, mode) {
                                      return IconButton(
                                        icon: Icon(
                                          mode == ThemeMode.light
                                              ? Icons.dark_mode
                                              : Icons.light_mode,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => context
                                            .read<ThemeCubit>()
                                            .toggleTheme(),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  BlocBuilder<ProfileBloc, ProfileState>(
                                    builder: (context, state) {
                                      if (state is ProfileLoaded) {
                                        return Hero(
                                          tag: 'profile-avatar',
                                          child: CircleAvatar(
                                            radius: 24,
                                            backgroundColor: Colors.white,
                                            child: Text(
                                              state.profile.name.isNotEmpty
                                                  ? state.profile.name[0]
                                                      .toUpperCase()
                                                  : '?',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats Widget
                        BlocBuilder<ProjectBloc, ProjectState>(
                          builder: (context, state) {
                            if (state is ProjectLoaded) {
                              return DashboardStatsWidget(
                                  projects: state.allProjects);
                            }
                            return const SizedBox(height: 80); // Placeholder
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ProjectFilterBar(),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            sliver: BlocBuilder<ProjectBloc, ProjectState>(
              builder: (context, state) {
                if (state is ProjectLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                        child: TechLoading(message: 'LOADING PROJECTS...')),
                  );
                } else if (state is ProjectError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error: ${state.message}')),
                  );
                } else if (state is ProjectLoaded) {
                  final projects = state.filteredProjects;
                  if (projects.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron proyectos',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent:
                          isDesktop ? 300 : 200, // Wider cards on desktop
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75, // Taller for image + text
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProjectCard(project: projects[index]);
                      },
                      childCount: projects.length,
                    ),
                  );
                }
                return const SliverFillRemaining(child: SizedBox.shrink());
              },
            ),
          ),

          // Branding Footer
          const SliverToBoxAdapter(
            child: BrandingFooter(),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    // ... (Keep existing dialog logic)
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear Nuevo Proyecto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Describe el proyecto y comienza a recibir cotizaciones',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre del proyecto *',
                  hintText: 'Ej: Renovación de casa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Detalles del proyecto...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locCtrl,
                decoration: InputDecoration(
                  labelText: 'Ubicación *',
                  hintText: 'Ciudad, Estado',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (nameCtrl.text.isEmpty || locCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Por favor completa los campos requeridos')),
                        );
                        return;
                      }
                      context.read<ProjectBloc>().add(
                            CreateProjectEvent(
                                nameCtrl.text, descCtrl.text, locCtrl.text),
                          );
                      Navigator.pop(dialogCtx);
                    },
                    child: const Text('Crear Proyecto'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
