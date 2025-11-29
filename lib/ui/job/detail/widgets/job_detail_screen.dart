import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:tala_app/data/services/tala_api/api_config.dart';
import 'package:tala_app/ui/job/detail/view_models/job_detail_viewmodel.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../routing/routes.dart';
import '../../../core/themes/dimens.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.viewModel});

  final JobDetailViewModel viewModel;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  void _openGallery(List<String> urls, int initialIndex) {
    // No need to set state or store initialIndex
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                  itemCount: urls.length,
                  pageController: PageController(initialPage: initialIndex),
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(
                        ApiConfig.getPhotoUrl(urls[index]),
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  },
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimens = Dimens.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.viewModel.job != null
              ? widget.viewModel.job!.title
              : 'Job Details',
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 1,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: dimens.edgeInsetsScreenSymmetric,
        child: ListenableBuilder(
          listenable: widget.viewModel.fetchJob,
          builder: (context, child) {
            if (widget.viewModel.fetchJob.running) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              );
            }
            if (widget.viewModel.fetchJob.error) {
              return Center(
                child: Column(
                  children: [
                    Text('Error: ${widget.viewModel.fetchJob.result}'),
                    SizedBox(height: 16),
                    if (widget.viewModel.job != null)
                      ElevatedButton(
                        onPressed: () => widget.viewModel.fetchJob.execute((
                          widget.viewModel.job!.vehicleId,
                          widget.viewModel.job!.id,
                        )),
                        child: Text('Retry'),
                      ),
                  ],
                ),
              );
            }
            return ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, child) {
                final job = widget.viewModel.job;
                if (job == null) {
                  return Center(
                    child: Text(
                      'Job not found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.viewModel.job?.title ?? 'Job Detail',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Start Date: ${widget.viewModel.job!.startDate?.toLocal().toString().split(' ')[0]}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontFamily: 'IBMPlexMono'),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Completion Date: ${widget.viewModel.job!.completionDate?.toLocal().toString().split(' ')[0]}',
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
                                      'Status: ${widget.viewModel.job!.status}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontFamily: 'IBMPlexMono'),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Category: ${widget.viewModel.job!.category}',
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
                                      'Odometer: ${widget.viewModel.job!.odometer} km',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontFamily: 'IBMPlexMono'),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Cost: \$${widget.viewModel.job!.cost?.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontFamily: 'IBMPlexMono'),
                                    ),
                                  ),
                                ],
                              ),
                              if (job.description != null &&
                                  job.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    'Description: ${job.description!}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              if (job.photoUrls != null &&
                                  job.photoUrls!.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    job.photoUrls!.length,
                                    (i) => Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _openGallery(job.photoUrls!, i),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              ApiConfig.getPhotoUrl(
                                                job.photoUrls![i],
                                              ),
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () async {
                                                final confirm =
                                                    await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title: const Text(
                                                              'Delete Photo',
                                                            ),
                                                            content: const Text(
                                                              'Are you sure you want to delete this photo?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(
                                                                      false,
                                                                    ),
                                                                child:
                                                                    const Text(
                                                                      'Cancel',
                                                                    ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(true),
                                                                child:
                                                                    const Text(
                                                                      'Delete',
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                    );
                                                if (confirm == true) {
                                                  String photoId = job
                                                      .photoUrls![i]
                                                      .split('/')
                                                      .last;
                                                  await widget
                                                      .viewModel
                                                      .deleteJobPhoto
                                                      .execute((
                                                        job.vehicleId,
                                                        job.id,
                                                        photoId,
                                                      ));
                                                  await widget
                                                      .viewModel
                                                      .fetchJob
                                                      .execute((
                                                        job.vehicleId,
                                                        job.id,
                                                      ));
                                                }
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.push(
                                          Routes.jobFormWithID(
                                            widget.viewModel.job!.vehicleId,
                                            widget.viewModel.job!.id,
                                          ),
                                        );
                                      },
                                      child: const Text('Edit Service'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFF6B35),
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),

                                      onPressed: () {
                                        Future<void> result = widget
                                            .viewModel
                                            .removeJob
                                            .execute((
                                              widget.viewModel.job!.vehicleId,
                                              widget.viewModel.job!.id,
                                            ));
                                        result.whenComplete(() {
                                          if (mounted) {
                                            context.push(
                                              Routes.vehicleDetails(
                                                widget.viewModel.job!.vehicleId,
                                              ),
                                            );
                                          }
                                        });
                                      },
                                      child: const Text('Remove job'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
