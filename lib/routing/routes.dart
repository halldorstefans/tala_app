abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const vehiclesRelative = 'vehicles';
  static const vehicles = '/$vehiclesRelative';
  static String vehicleDetails(String vehicleId) => '$vehicles/$vehicleId';
  static const vehicleForm = '$vehicles/form';
  static String vehicleFormWithID(String vehicleId) =>
      '$vehicleForm/$vehicleId';
  static String jobs(String vehicleId) => '$vehicles/$vehicleId/jobs';
  static String jobDetails(String vehicleId, String jobId) =>
      '$vehicles/$vehicleId/jobs/$jobId';
  static String jobForm(String vehicleId) => '$vehicles/$vehicleId/jobs/form';
  static String jobFormWithID(String vehicleId, String jobId) =>
      '$vehicles/$vehicleId/jobs/form/$jobId';
  static String profile(String id) => '/profile/$id';
}
