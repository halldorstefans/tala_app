import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ui/job/form/view_models/job_form_view_model.dart';
import '../ui/job/detail/view_models/job_detail_viewmodel.dart';
import '../ui/job/detail/widgets/job_detail_screen.dart';
import '../ui/job/form/widgets/job_form_screen.dart';
import '../ui/job/list/view_models/job_list_viewmodel.dart';
import '../ui/job/list/widgets/job_history_screen.dart';
import '../ui/home/view_models/home_viewmodel.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/vehicle/detail/view_models/vehicle_detail_viewmodel.dart';
import '../ui/vehicle/detail/widgets/vehicle_detail_screen.dart';
import '../ui/vehicle/form/view_models/vehicle_form_viewmodel.dart';
import '../ui/vehicle/form/widgets/vehicle_form_screen.dart';
import 'routes.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        return HomeScreen(
          viewModel: HomeViewModel(vehicleRepository: context.read()),
        );
      },
      routes: [
        GoRoute(
          path: Routes.vehicles,
          redirect: (context, state) => Routes.home,
          routes: [
            GoRoute(
              path: 'form',
              builder: (context, state) {
                final viewModel = VehicleFormViewmodel(
                  vehicleRepository: context.read(),
                );

                return VehicleFormScreen(viewModel: viewModel);
              },
            ),
            GoRoute(
              path: 'form/:vehicleId',
              builder: (context, state) {
                final vehicleId = state.pathParameters['vehicleId']!;

                final viewModel = VehicleFormViewmodel(
                  vehicleRepository: context.read(),
                );

                viewModel.fetchVehicle.execute(vehicleId);

                return VehicleFormScreen(viewModel: viewModel);
              },
            ),
            GoRoute(
              path: ':vehicleId',
              builder: (context, state) {
                final vehicleId = state.pathParameters['vehicleId']!;
                final viewModel = VehicleDetailViewModel(
                  vehicleRepository: context.read(),
                );
                final jobListViewModel = JobListViewModel(
                  jobsRepository: context.read(),
                  vehicleId: vehicleId,
                );

                viewModel.fetchVehicle.execute(vehicleId);

                return VehicleDetailScreen(
                  viewModel: viewModel,
                  jobListViewModel: jobListViewModel,
                );
              },
              routes: [
                GoRoute(
                  path: 'jobs',
                  builder: (context, state) {
                    final vehicleId = state.pathParameters['vehicleId']!;
                    final viewModel = JobListViewModel(
                      jobsRepository: context.read(),
                      vehicleId: vehicleId,
                    );
                    return JobHistoryScreen(viewModel: viewModel);
                  },
                ),
                GoRoute(
                  path: 'jobs/form',
                  builder: (context, state) {
                    final vehicleId = state.pathParameters['vehicleId']!;
                    final viewModel = JobFormViewModel(
                      vehicleId: vehicleId,
                      jobsRepository: context.read(),
                    );

                    return JobFormScreen(viewModel: viewModel);
                  },
                ),
                GoRoute(
                  path: 'jobs/form/:jobId',
                  builder: (context, state) {
                    final vehicleId = state.pathParameters['vehicleId']!;
                    final recordId = state.pathParameters['jobId']!;
                    final viewModel = JobFormViewModel(
                      vehicleId: vehicleId,
                      jobsRepository: context.read(),
                    );

                    viewModel.fetchJob.execute((vehicleId, recordId));

                    return JobFormScreen(viewModel: viewModel);
                  },
                ),
                GoRoute(
                  path: 'jobs/:jobId',
                  builder: (context, state) {
                    final vehicleId = state.pathParameters['vehicleId']!;
                    final recordId = state.pathParameters['jobId']!;
                    final viewModel = JobDetailViewModel(
                      jobsRepository: context.read(),
                    );
                    viewModel.fetchJob.execute((vehicleId, recordId));

                    return JobDetailScreen(viewModel: viewModel);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
