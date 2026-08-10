import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../domain/models/progress_status.dart';
import '../ui/job/form/view_models/job_form_view_model.dart';
import '../ui/job/detail/view_models/job_detail_viewmodel.dart';
import '../ui/job/detail/widgets/job_detail_screen.dart';
import '../ui/job/form/widgets/job_form_screen.dart';
import '../ui/job/list/view_models/job_list_viewmodel.dart';
import '../ui/job/list/widgets/job_list_view.dart';
import '../ui/project/detail/view_models/project_detail_viewmodel.dart';
import '../ui/project/detail/widgets/project_detail_screen.dart';
import '../ui/project/form/view_models/project_form_view_model.dart';
import '../ui/project/form/widgets/project_form_screen.dart';
import '../ui/project/list/view_models/project_list_viewmodel.dart';
import '../ui/project/list/widgets/project_list_screen.dart';
import '../ui/part/detail/view_models/part_detail_viewmodel.dart';
import '../ui/part/detail/widgets/part_detail_screen.dart';
import '../ui/part/form/view_models/part_form_view_model.dart';
import '../ui/part/form/widgets/part_form_screen.dart';
import '../ui/part/catalogue/view_models/parts_catalogue_viewmodel.dart';
import '../ui/part/catalogue/widgets/parts_catalogue_screen.dart';
import '../ui/part/used/view_models/parts_used_viewmodel.dart';
import '../ui/part/used/widgets/parts_used_screen.dart';
import '../ui/backup/view_models/backup_viewmodel.dart';
import '../ui/backup/widgets/backup_screen.dart';
import '../ui/home/view_models/home_viewmodel.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/vehicle/detail/view_models/vehicle_detail_viewmodel.dart';
import '../ui/vehicle/detail/widgets/vehicle_detail_screen.dart';
import '../ui/vehicle/form/view_models/vehicle_form_view_model.dart';
import '../ui/vehicle/form/widgets/vehicle_form_screen.dart';
import 'routes.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => HomeViewModel(vehicleRepository: context.read()),
        child: Builder(
          builder: (context) =>
              HomeScreen(viewModel: context.read<HomeViewModel>()),
        ),
      ),
    ),
    GoRoute(
      path: Routes.backup,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => BackupViewModel(backupService: context.read()),
        child: Builder(
          builder: (context) =>
              BackupScreen(viewModel: context.read<BackupViewModel>()),
        ),
      ),
    ),
    GoRoute(
      path: Routes.parts,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) =>
            PartsCatalogueViewModel(partsRepository: context.read()),
        child: Builder(
          builder: (context) => PartsCatalogueScreen(
            viewModel: context.read<PartsCatalogueViewModel>(),
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/part/:partId',
      builder: (context, state) {
        final partId = state.pathParameters['partId']!;
        return ChangeNotifierProvider(
          create: (context) =>
              PartDetailViewModel(partsRepository: context.read())
                ..load.execute(partId),
          child: Builder(
            builder: (context) => PartDetailScreen(
              viewModel: context.read<PartDetailViewModel>(),
            ),
          ),
        );
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final partId = state.pathParameters['partId']!;
            return ChangeNotifierProvider(
              create: (context) =>
                  PartFormViewModel(partsRepository: context.read())
                    ..fetchPart.execute(partId),
              child: Builder(
                builder: (context) => PartFormScreen(
                  viewModel: context.read<PartFormViewModel>(),
                ),
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: Routes.vehicleForm,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) =>
            VehicleFormViewModel(vehicleRepository: context.read()),
        child: Builder(
          builder: (context) => VehicleFormScreen(
            viewModel: context.read<VehicleFormViewModel>(),
          ),
        ),
      ),
    ),
    GoRoute(
      path: '${Routes.vehicleForm}/:vehicleId',
      builder: (context, state) {
        final vehicleId = state.pathParameters['vehicleId']!;
        return ChangeNotifierProvider(
          create: (context) =>
              VehicleFormViewModel(vehicleRepository: context.read())
                ..fetchVehicle.execute(vehicleId),
          child: Builder(
            builder: (context) => VehicleFormScreen(
              viewModel: context.read<VehicleFormViewModel>(),
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: '/vehicle/:vehicleId',
      builder: (context, state) {
        final vehicleId = state.pathParameters['vehicleId']!;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) =>
                  VehicleDetailViewModel(vehicleRepository: context.read())
                    ..fetchVehicle.execute(vehicleId),
            ),
            ChangeNotifierProvider(
              create: (context) => JobListViewModel(
                jobsRepository: context.read(),
                vehicleId: vehicleId,
                partsRepository: context.read(),
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => ProjectListViewModel(
                projectsRepository: context.read(),
                vehicleId: vehicleId,
                partsRepository: context.read(),
              ),
            ),
          ],
          child: Builder(
            builder: (context) => VehicleDetailScreen(
              viewModel: context.read<VehicleDetailViewModel>(),
              jobListViewModel: context.read<JobListViewModel>(),
              projectListViewModel: context.read<ProjectListViewModel>(),
            ),
          ),
        );
      },
      routes: [
        GoRoute(
          path: 'jobs',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            final preselect = ProgressStatus.fromWire(
              state.uri.queryParameters['status'],
            );
            return ChangeNotifierProvider(
              create: (context) {
                final vm = JobListViewModel(
                  jobsRepository: context.read(),
                  vehicleId: vehicleId,
                );
                if (preselect != null) {
                  vm.setStatusFilter({preselect});
                }
                return vm;
              },
              child: Builder(
                builder: (context) =>
                    JobListView(viewModel: context.read<JobListViewModel>()),
              ),
            );
          },
        ),
        GoRoute(
          path: 'jobs/form',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            return ChangeNotifierProvider(
              create: (context) => JobFormViewModel(
                vehicleId: vehicleId,
                jobsRepository: context.read(),
                preferences: context.read(),
                projectsRepository: context.read(),
              )
                ..loadDefaultCategory.execute()
                ..loadProjects.execute(),
              child: Builder(
                builder: (context) =>
                    JobFormScreen(viewModel: context.read<JobFormViewModel>()),
              ),
            );
          },
        ),
        GoRoute(
          path: 'jobs/form/:jobId',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            final jobId = state.pathParameters['jobId']!;
            return ChangeNotifierProvider(
              create: (context) => JobFormViewModel(
                vehicleId: vehicleId,
                jobsRepository: context.read(),
                preferences: context.read(),
                projectsRepository: context.read(),
              )
                ..fetchJob.execute((vehicleId, jobId))
                ..loadProjects.execute(),
              child: Builder(
                builder: (context) =>
                    JobFormScreen(viewModel: context.read<JobFormViewModel>()),
              ),
            );
          },
        ),
        GoRoute(
          path: 'jobs/:jobId',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            final jobId = state.pathParameters['jobId']!;
            return ChangeNotifierProvider(
              create: (context) =>
                  JobDetailViewModel(
                    jobsRepository: context.read(),
                    partsRepository: context.read(),
                  )..fetchJob.execute((vehicleId, jobId)),
              child: Builder(
                builder: (context) => JobDetailScreen(
                  viewModel: context.read<JobDetailViewModel>(),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: 'parts',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            return ChangeNotifierProvider(
              create: (context) => PartsUsedViewModel(
                partsRepository: context.read(),
                vehicleId: vehicleId,
              ),
              child: Builder(
                builder: (context) => PartsUsedScreen(
                  viewModel: context.read<PartsUsedViewModel>(),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: 'projects',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            return ChangeNotifierProvider(
              create: (context) => ProjectListViewModel(
                projectsRepository: context.read(),
                vehicleId: vehicleId,
                partsRepository: context.read(),
              ),
              child: Builder(
                builder: (context) => ProjectListScreen(
                  viewModel: context.read<ProjectListViewModel>(),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: 'projects/form',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            return ChangeNotifierProvider(
              create: (context) => ProjectFormViewModel(
                projectsRepository: context.read(),
                vehicleId: vehicleId,
              ),
              child: Builder(
                builder: (context) => ProjectFormScreen(
                  viewModel: context.read<ProjectFormViewModel>(),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: 'projects/form/:projectId',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            final projectId = state.pathParameters['projectId']!;
            return ChangeNotifierProvider(
              create: (context) => ProjectFormViewModel(
                projectsRepository: context.read(),
                vehicleId: vehicleId,
              )..fetchProject.execute(projectId),
              child: Builder(
                builder: (context) => ProjectFormScreen(
                  viewModel: context.read<ProjectFormViewModel>(),
                ),
              ),
            );
          },
        ),
        // Declared after the `form` routes so 'form' isn't captured as an id.
        GoRoute(
          path: 'projects/:projectId',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            final projectId = state.pathParameters['projectId']!;
            return ChangeNotifierProvider(
              create: (context) => ProjectDetailViewModel(
                projectsRepository: context.read(),
                partsRepository: context.read(),
                jobsRepository: context.read(),
                vehicleId: vehicleId,
                projectId: projectId,
              ),
              child: Builder(
                builder: (context) => ProjectDetailScreen(
                  viewModel: context.read<ProjectDetailViewModel>(),
                ),
              ),
            );
          },
        ),
      ],
    ),
  ],
);
