import '../domain/models/progress_status.dart';

abstract final class Routes {
  static const home = '/';

  static const vehicleForm = '/vehicle-form';
  static String vehicleFormWithId(String? vehicleId) =>
      vehicleId != null ? '$vehicleForm/$vehicleId' : vehicleForm;

  static String vehicleDetails(String vehicleId) => '/vehicle/$vehicleId';

  static String jobs(String vehicleId) => '/vehicle/$vehicleId/jobs';
  static String jobsWithStatus(String vehicleId, ProgressStatus status) =>
      '${jobs(vehicleId)}?status=${Uri.encodeComponent(status.wire)}';
  static String jobDetails(String vehicleId, String jobId) =>
      '/vehicle/$vehicleId/jobs/$jobId';
  static String jobForm(String vehicleId) => '/vehicle/$vehicleId/jobs/form';
  static String jobFormWithId(String vehicleId, String? jobId) =>
      jobId != null ? '${jobForm(vehicleId)}/$jobId' : jobForm(vehicleId);

  static String partsUsed(String vehicleId) => '/vehicle/$vehicleId/parts';

  static String projects(String vehicleId) => '/vehicle/$vehicleId/projects';
  static String projectDetails(String vehicleId, String projectId) =>
      '/vehicle/$vehicleId/projects/$projectId';
  static String projectForm(String vehicleId) =>
      '/vehicle/$vehicleId/projects/form';
  static String projectFormWithId(String vehicleId, String? projectId) =>
      projectId != null
      ? '${projectForm(vehicleId)}/$projectId'
      : projectForm(vehicleId);

  static const backup = '/backup';

  static const parts = '/parts';
  static String partDetails(String partId) => '/part/$partId';
  static String partEdit(String partId) => '/part/$partId/edit';
}
