import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/job_detail_viewmodel.dart';

/// The job's cost split: Parts + Other = Total. Its own card on job detail so
/// the breakdown reads clearly, separate from the parts list.
class JobCostBreakdown extends StatelessWidget {
  const JobCostBreakdown({super.key, required this.viewModel});

  final JobDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget line(String label, double value, {bool emphasize = false}) {
      final style = GoogleFonts.jetBrainsMono(
        textStyle: emphasize
            ? theme.textTheme.titleMedium
            : theme.textTheme.bodyMedium,
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: style),
            Text('€${value.toStringAsFixed(2)}', style: style),
          ],
        ),
      );
    }

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(
        children: [
          line('Parts', viewModel.partsTotal),
          line('Other', viewModel.otherCost),
          const Divider(),
          line('Total', viewModel.totalCost, emphasize: true),
        ],
      ),
    );
  }
}
