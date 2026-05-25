abstract final class JobStatus {
  static const planned = 'planned';
  static const inProgress = 'in_progress';
  static const completed = 'completed';

  static const all = [planned, inProgress, completed];

  static const _labels = {
    planned: 'Planned',
    inProgress: 'In progress',
    completed: 'Completed',
  };

  static bool isKnown(String? value) =>
      value != null && all.contains(value);
}

String statusLabel(String? raw) {
  if (raw == null || raw.isEmpty) return 'Unknown';
  return JobStatus._labels[raw] ?? raw;
}
