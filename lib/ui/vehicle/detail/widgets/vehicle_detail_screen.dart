import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tala_app/data/services/tala_api/api_config.dart';
import 'package:tala_app/routing/routes.dart';
import 'package:tala_app/ui/job/list/view_models/job_list_viewmodel.dart';
import 'package:tala_app/ui/job/list/widgets/job_history_screen.dart';

import '../view_models/vehicle_detail_viewmodel.dart';
import 'package:tala_app/ui/core/themes/dimens.dart';

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({
    super.key,
    required this.viewModel,
    required this.jobListViewModel,
  });

  final VehicleDetailViewModel viewModel;
  final JobListViewModel jobListViewModel;

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final dimens = Dimens.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 1,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: dimens.edgeInsetsScreenSymmetric,
        child: ListenableBuilder(
          listenable: widget.viewModel.fetchVehicle,
          builder: (context, child) {
            if (widget.viewModel.fetchVehicle.running) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              );
            }
            if (widget.viewModel.fetchVehicle.error) {
              return Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Error: ${widget.viewModel.fetchVehicle.result}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => widget.viewModel.fetchVehicle.execute(
                          widget.viewModel.vehicle!.id,
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, child) {
                final vehicle = widget.viewModel.vehicle;
                if (vehicle == null) {
                  return Center(
                    child: Text(
                      'Vehicle not found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (vehicle.photoUrl != null &&
                                  vehicle.photoUrl!.isNotEmpty)
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: AspectRatio(
                                      aspectRatio: 4 / 3,
                                      child: Image.network(
                                        ApiConfig.getPhotoUrl(
                                          vehicle.photoUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                '${vehicle.make} ${vehicle.model}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              Text(
                                '${vehicle.year}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (vehicle.nickname != null &&
                                  vehicle.nickname!.isNotEmpty)
                                Text(
                                  'Nickname: ${vehicle.nickname}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              if (vehicle.colour != null &&
                                  vehicle.colour!.isNotEmpty)
                                Text(
                                  'Colour: ${vehicle.colour}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Odometer: ${vehicle.odometer ?? 'N/A'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontFamily: 'IBMPlexMono'),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Registration: ${vehicle.registration ?? 'N/A'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontFamily: 'IBMPlexMono'),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'VIN: ${vehicle.vin ?? 'N/A'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontFamily: 'IBMPlexMono'),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Purchase: ${vehicle.purchaseDate != null ? vehicle.purchaseDate!.toLocal().toString().split(' ').first : 'N/A'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontFamily: 'IBMPlexMono'),
                                    ),
                                  ),
                                ],
                              ),
                              if (vehicle.notes != null &&
                                  vehicle.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Notes: ${vehicle.notes}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.push(
                                          Routes.vehicleFormWithID(vehicle.id),
                                        );
                                      },
                                      child: const Text('Edit Vehicle'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(
                                          0xFFFF6B35,
                                        ), // Safety Orange
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                      onPressed: () {
                                        Future<void> result = widget
                                            .viewModel
                                            .remove
                                            .execute(vehicle.id);
                                        result.whenComplete(() {
                                          if (mounted) {
                                            context.push(Routes.vehicles);
                                          }
                                        });
                                      },
                                      child: const Text('Remove Vehicle'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Recent Job History',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: JobHistoryScreen(
                            viewModel: widget.jobListViewModel,
                            isSummary: true,
                            summaryCount: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF1B4965),
                            side: BorderSide(
                              color: Color(0xFF1B4965),
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          onPressed: () {
                            context.push(Routes.jobs(vehicle.id));
                          },
                          child: const Text('View Full Job History'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
