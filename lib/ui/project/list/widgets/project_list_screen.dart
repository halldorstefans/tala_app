import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../../../core/themes/dimens.dart';
import '../view_models/project_list_viewmodel.dart';
import 'project_card.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key, required this.viewModel});

  final ProjectListViewModel viewModel;

  Future<void> _openForm(BuildContext context) async {
    await context.push(Routes.projectForm(viewModel.vehicleId));
    if (!context.mounted) return;
    viewModel.fetchProjects.execute(viewModel.vehicleId);
  }

  Future<void> _openDetail(BuildContext context, String projectId) async {
    await context.push(Routes.projectDetails(viewModel.vehicleId, projectId));
    if (!context.mounted) return;
    viewModel.fetchProjects.execute(viewModel.vehicleId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimens = Dimens.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Projects',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
      ),
      body: ListenableBuilder(
        listenable: viewModel.fetchProjects,
        builder: (context, _) {
          if (viewModel.fetchProjects.running) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            );
          }
          if (viewModel.fetchProjects.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${viewModel.fetchProjects.result}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        viewModel.fetchProjects.execute(viewModel.vehicleId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final projects = viewModel.projects;
              if (projects.isEmpty) {
                return Center(
                  child: Text(
                    'No projects yet.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  dimens.paddingScreenHorizontal,
                  dimens.paddingScreenVertical,
                  dimens.paddingScreenHorizontal,
                  // Clear the FAB + system nav bar at the bottom.
                  dimens.paddingScreenVertical +
                      MediaQuery.paddingOf(context).bottom +
                      72,
                ),
                itemCount: projects.length,
                separatorBuilder: (context, _) =>
                    const SizedBox(height: Dimens.space2),
                itemBuilder: (context, i) => ProjectCard(
                  project: projects[i],
                  summary: viewModel.summaryFor(projects[i].id),
                  onTap: () => _openDetail(context, projects[i].id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
