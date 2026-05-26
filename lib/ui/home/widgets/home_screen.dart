import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/vehicle.dart';
import '../../../routing/routes.dart';
import '../view_models/home_viewmodel.dart';
import 'home_vehicle_card.dart';

enum _AddAction { vehicle, job }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _onAddPressed() async {
    final vehicles = widget.viewModel.vehicles;
    final action = vehicles.isEmpty
        ? _AddAction.vehicle
        : await showModalBottomSheet<_AddAction>(
            context: context,
            builder: (context) =>
                _AddActionSheet(canAddJob: vehicles.isNotEmpty),
          );
    if (!mounted || action == null) return;
    switch (action) {
      case _AddAction.vehicle:
        context.push(Routes.vehicleFormWithId(null));
      case _AddAction.job:
        await _onAddJobPressed(vehicles);
    }
  }

  Future<void> _onAddJobPressed(List<Vehicle> vehicles) async {
    if (vehicles.length == 1) {
      context.push(Routes.jobForm(vehicles.first.id));
      return;
    }
    final picked = await showModalBottomSheet<Vehicle>(
      context: context,
      builder: (context) => _VehiclePickerSheet(vehicles: vehicles),
    );
    if (picked != null && mounted) {
      context.push(Routes.jobForm(picked.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tala')),
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
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              widget.viewModel.fetchVehicles.execute(),
                          child: const Text('Retry'),
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
                      onTap: () => context.push('/vehicle/${v.id}'),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPressed,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddActionSheet extends StatelessWidget {
  const _AddActionSheet({required this.canAddJob});

  final bool canAddJob;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Add…', style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Vehicle'),
            onTap: () => Navigator.of(context).pop(_AddAction.vehicle),
          ),
          if (canAddJob)
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Job'),
              onTap: () => Navigator.of(context).pop(_AddAction.job),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _VehiclePickerSheet extends StatelessWidget {
  const _VehiclePickerSheet({required this.vehicles});

  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Add job to…',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...vehicles.map(
            (v) => ListTile(
              title: Text('${v.year} ${v.make} ${v.model}'),
              subtitle: v.nickname != null ? Text(v.nickname!) : null,
              onTap: () => Navigator.of(context).pop(v),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
