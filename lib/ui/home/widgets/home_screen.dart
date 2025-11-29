import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../routing/routes.dart';
import '../view_models/home_viewmodel.dart';
import '../../auth/logout/widgets/logout_button.dart';
import '../../auth/logout/view_models/logout_viewmodel.dart';
import 'home_vehicle_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tala'),
        actions: [
          LogoutButton(
            viewModel: LogoutViewModel(authRepository: context.read()),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.fetchVehicles,
        builder: (context, child) {
          if (widget.viewModel.fetchVehicles.completed) {
            return child!;
          }
          return Column(
            children: [
              if (widget.viewModel.fetchVehicles.running)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (widget.viewModel.fetchVehicles.error)
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Text('Error: ${widget.viewModel.errorMessage}'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              widget.viewModel.fetchVehicles.execute(),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Vehicles area (data from viewModel)
              Text(
                'My Vehicles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (widget.viewModel.vehicles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No vehicles found. Tap the button below to add your first vehicle.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                ...widget.viewModel.vehicles.map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HomeVehicleCard(
                      title: '${v.year} ${v.make} ${v.model}',
                      nickname: v.nickname,
                      registration: v.registration,
                      imageUrl: v.photoUrl,
                      onTap: () => context.push(Routes.vehicleDetails(v.id)),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              /*TextButton(
                onPressed: () => context.push(Routes.vehicles),
                child: const Text('View All Vehicles'),
              ),*/
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(Routes.vehicleForm);
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Add Vehicle',
          style: theme.textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
