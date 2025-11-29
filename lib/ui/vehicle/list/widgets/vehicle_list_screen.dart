import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tala_app/routing/routes.dart';
import 'package:tala_app/ui/vehicle/list/widgets/vehicle_card.dart';

import '../view_models/vehicle_list_viewmodel.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key, required this.viewModel});

  final VehicleListViewModel viewModel;

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Vehicles')),
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
                        Text('Error: ${widget.viewModel.fetchVehicles.error}'),
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
          builder: (context, child) {
            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      if (widget.viewModel.vehicles.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Text('No vehicles found')),
                        )
                      else
                        SliverList.builder(
                          itemCount: widget.viewModel.vehicles.length,
                          itemBuilder: (context, i) {
                            final vehicle = widget.viewModel.vehicles[i];
                            return VehicleCard(
                              vehicle: vehicle,
                              onTap: () {
                                context.push(Routes.vehicleDetails(vehicle.id));
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(Routes.vehicleForm);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
    );
  }
}
