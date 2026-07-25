import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../domain/models/job_status.dart';
import '../ui/job/form/view_models/job_form_view_model.dart';
import '../ui/job/detail/view_models/job_detail_viewmodel.dart';
import '../ui/job/detail/widgets/job_detail_screen.dart';
import '../ui/job/form/widgets/job_form_screen.dart';
import '../ui/job/list/view_models/job_list_viewmodel.dart';
import '../ui/job/list/widgets/job_list_view.dart';
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
              ),
            ),
          ],
          child: Builder(
            builder: (context) => VehicleDetailScreen(
              viewModel: context.read<VehicleDetailViewModel>(),
              jobListViewModel: context.read<JobListViewModel>(),
            ),
          ),
        );
      },
      routes: [
        GoRoute(
          path: 'jobs',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            final preselect = state.uri.queryParameters['status'];
            return ChangeNotifierProvider(
              create: (context) {
                final vm = JobListViewModel(
                  jobsRepository: context.read(),
                  vehicleId: vehicleId,
                );
                if (preselect != null && JobStatus.isKnown(preselect)) {
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
              )..loadDefaultCategory.execute(),
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
              )..fetchJob.execute((vehicleId, jobId)),
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
                  JobDetailViewModel(jobsRepository: context.read())
                    ..fetchJob.execute((vehicleId, jobId)),
              child: Builder(
                builder: (context) => JobDetailScreen(
                  viewModel: context.read<JobDetailViewModel>(),
                ),
              ),
            );
          },
        ),
      ],
    ),
  ],
);
