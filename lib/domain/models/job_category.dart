abstract final class JobCategory {
  static const maintenance = 'maintenance';
  static const repair = 'repair';
  static const restoration = 'restoration';
  static const inspection = 'inspection';
  static const upgrade = 'upgrade';
  static const electrical = 'electrical';
  static const bodywork = 'bodywork';

  static const predefined = [
    maintenance,
    repair,
    restoration,
    inspection,
    upgrade,
    electrical,
    bodywork,
  ];

  static const _labels = {
    maintenance: 'Maintenance',
    repair: 'Repair',
    restoration: 'Restoration',
    inspection: 'Inspection',
    upgrade: 'Upgrade',
    electrical: 'Electrical',
    bodywork: 'Bodywork',
  };

  static bool isPredefined(String? value) =>
      value != null && predefined.contains(value);
}

String categoryLabel(String? raw) {
  if (raw == null || raw.isEmpty) return 'Uncategorized';
  return JobCategory._labels[raw] ?? raw;
}
