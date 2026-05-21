abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';

  static const vehicleForm = '/vehicle-form';
  static String vehicleFormWithId(String? vehicleId) =>
      vehicleId != null ? '$vehicleForm/$vehicleId' : vehicleForm;

  static String vehicleDetails(String vehicleId) => '/vehicle/$vehicleId';

  static String jobs(String vehicleId) => '/vehicle/$vehicleId/jobs';
  static String jobDetails(String vehicleId, String jobId) =>
      '/vehicle/$vehicleId/jobs/$jobId';
  static String jobForm(String vehicleId) => '/vehicle/$vehicleId/jobs/form';
  static String jobFormWithId(String vehicleId, String? jobId) =>
      jobId != null ? '${jobForm(vehicleId)}/$jobId' : jobForm(vehicleId);

  static const profile = '/profile';
}
