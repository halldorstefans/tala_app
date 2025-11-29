import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tala_app/data/models/job_api_model.dart';
import 'package:tala_app/data/models/vehicle_api_model.dart';

import '../../../utils/result.dart';
import '../../models/user_api_model.dart';
import 'api_config.dart';

/// Adds the `Authentication` header to a header configuration.
typedef AuthHeaderProvider = String? Function();

class ApiClient {
  ApiClient({String? baseUrl, HttpClient Function()? httpClient})
    : _baseUrl = baseUrl ?? ApiConfig.baseUrl,
      _httpClient = httpClient ?? HttpClient.new;

  final String _baseUrl;
  final HttpClient Function() _httpClient;

  AuthHeaderProvider? _authHeaderProvider;

  set authHeaderProvider(AuthHeaderProvider authHeaderProvider) {
    _authHeaderProvider = authHeaderProvider;
  }

  Future<void> _authHeader(HttpHeaders headers) async {
    final header = _authHeaderProvider?.call();
    if (header != null) {
      headers.add(HttpHeaders.authorizationHeader, header);
    }
  }

  Future<Result<UserApiModel>> getUser(String userId) async {
    final client = _httpClient();
    try {
      final request = await client.getUrl(Uri.parse('$_baseUrl/users/$userId'));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode != 200) {
        return const Result.error(HttpException('Failed to fetch user'));
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final user = UserApiModel.fromJson(jsonDecode(responseBody));
      return Result.ok(user);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<VehicleApiModel>> getVehicle(String vehicleId) async {
    final client = _httpClient();
    try {
      final request = await client.getUrl(
        Uri.parse('$_baseUrl/vehicles/$vehicleId'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode != 200) {
        return const Result.error(HttpException('Failed to fetch vehicle'));
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final vehicle = VehicleApiModel.fromJson(jsonDecode(responseBody));
      return Result.ok(vehicle);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<VehicleApiModel>>> getVehicles() async {
    final client = _httpClient();
    try {
      final request = await client.getUrl(Uri.parse('$_baseUrl/vehicles'));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode != 200) {
        return const Result.error(HttpException('Failed to fetch vehicles'));
      }

      final responseBody = await response.transform(utf8.decoder).join();
      if (responseBody.isEmpty) {
        return Result.ok([]);
      }

      final decoded = jsonDecode(responseBody);

      if (decoded == null || decoded is! List) {
        return Result.ok([]);
      }

      final vehicles = decoded.map((v) => VehicleApiModel.fromJson(v)).toList();
      return Result.ok(vehicles);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> addVehicle(VehicleApiModel vehicle) async {
    final client = _httpClient();
    try {
      final request = await client.postUrl(Uri.parse('$_baseUrl/vehicles'));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      request.add(
        utf8.encode(
          jsonEncode({
            'make': vehicle.make,
            'model': vehicle.model,
            'year': vehicle.year,
            'registration_number': vehicle.registrationNumber,
            'owner_id': vehicle.ownerId,
            'vin': vehicle.vin,
            'colour': vehicle.colour,
            'odometer': vehicle.odometer,
            'nickname': vehicle.nickname,
            'purchase_date': vehicle.purchaseDate?.toUtc().toIso8601String(),
            'notes': vehicle.notes,
            "photo_url": vehicle.photoUrl,
          }),
        ),
      );
      final response = await request.close();

      if (response.statusCode != 201) {
        return const Result.error(HttpException('Failed to add vehicle'));
      }

      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<VehicleApiModel>> updateVehicle(VehicleApiModel vehicle) async {
    final client = _httpClient();
    try {
      final request = await client.putUrl(
        Uri.parse('$_baseUrl/vehicles/${vehicle.id}'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      request.add(
        utf8.encode(
          jsonEncode({
            'id': vehicle.id,
            'make': vehicle.make,
            'model': vehicle.model,
            'year': vehicle.year,
            'registration_number': vehicle.registrationNumber,
            'owner_id': vehicle.ownerId,
            'vin': vehicle.vin,
            'colour': vehicle.colour,
            'odometer': vehicle.odometer,
            'nickname': vehicle.nickname,
            'purchase_date': vehicle.purchaseDate?.toUtc().toIso8601String(),
            'notes': vehicle.notes,
            "photo_url": vehicle.photoUrl,
          }),
        ),
      );
      final response = await request.close();

      if (response.statusCode != 200) {
        return const Result.error(HttpException('Failed to update vehicle'));
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final updatedVehicle = VehicleApiModel.fromJson(jsonDecode(responseBody));
      return Result.ok(updatedVehicle);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> deleteVehicle(String vehicleId) async {
    final client = _httpClient();
    try {
      final request = await client.deleteUrl(
        Uri.parse('$_baseUrl/vehicles/$vehicleId'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode != 204) {
        return const Result.error(HttpException('Failed to delete vehicle'));
      }

      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<String>> uploadVehiclePhoto(
    String vehicleId,
    File photo,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/vehicles/$vehicleId/photos'),
      );

      final authHeader = _authHeaderProvider?.call();
      if (authHeader != null) {
        request.headers['Authorization'] = authHeader;
      }

      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      // Send request
      var response = await request.send();

      if (response.statusCode != 200) {
        return Result.error(Exception('Failed to upload photo'));
      }

      // Parse response
      final responseBody = await response.stream.bytesToString();
      final json = jsonDecode(responseBody);
      final photoUrl = json['photo_url'] as String;

      return Result.ok(photoUrl);
    } catch (e) {
      return Result.error(Exception('Upload error: $e'));
    }
  }

  Future<Result<JobApiModel>> getJob(String vehicleId, String jobId) async {
    final client = _httpClient();
    try {
      final request = await client.getUrl(
        Uri.parse('$_baseUrl/vehicles/$vehicleId/jobs/$jobId'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode != 200) {
        return const Result.error(HttpException('Failed to fetch job'));
      }
      final responseBody = await response.transform(utf8.decoder).join();
      final record = JobApiModel.fromJson(jsonDecode(responseBody));
      return Result.ok(record);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<JobApiModel>>> getJobs(String vehicleId) async {
    final client = _httpClient();
    try {
      final request = await client.getUrl(
        Uri.parse('$_baseUrl/vehicles/$vehicleId/jobs'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode != 200) {
        return const Result.error(HttpException('Failed to fetch jobs'));
      }
      final responseBody = await response.transform(utf8.decoder).join();
      if (responseBody.isEmpty) {
        return Result.ok([]);
      }
      final decoded = jsonDecode(responseBody);
      if (decoded == null || decoded is! List) {
        return Result.ok([]);
      }
      final records = decoded.map((r) => JobApiModel.fromJson(r)).toList();
      return Result.ok(records);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> addJob(String vehicleId, JobApiModel job) async {
    final client = _httpClient();
    try {
      final request = await client.postUrl(
        Uri.parse('$_baseUrl/vehicles/$vehicleId/jobs'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      request.add(
        utf8.encode(
          jsonEncode({
            'vehicle_id': job.vehicleId,
            'title': job.title,
            'start_date': job.startDate?.toUtc().toIso8601String(),
            'completion_date': job.completionDate?.toUtc().toIso8601String(),
            'odometer': job.odometer,
            'category': job.category,
            'status': job.status,
            'description': job.description,
            'cost': job.cost,
          }),
        ),
      );
      final response = await request.close();

      if (response.statusCode != 201) {
        return const Result.error(HttpException('Failed to add job'));
      }

      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<JobApiModel>> updateJob(
    String vehicleId,
    JobApiModel job,
  ) async {
    final client = _httpClient();
    try {
      final request = await client.putUrl(
        Uri.parse('$_baseUrl/vehicles/$vehicleId/jobs/${job.id}'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      request.add(
        utf8.encode(
          jsonEncode({
            'id': job.id,
            'vehicle_id': job.vehicleId,
            'title': job.title,
            'start_date': job.startDate?.toUtc().toIso8601String(),
            'completion_date': job.completionDate?.toUtc().toIso8601String(),
            'odometer': job.odometer,
            'category': job.category,
            'status': job.status,
            'description': job.description,
            'cost': job.cost,
          }),
        ),
      );
      final response = await request.close();

      if (response.statusCode != 200) {
        return const Result.error(HttpException('Failed to update job'));
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final updatedRecord = JobApiModel.fromJson(jsonDecode(responseBody));
      return Result.ok(updatedRecord);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> deleteJob(String vehicleId, String jobId) async {
    final client = _httpClient();
    try {
      final request = await client.deleteUrl(
        Uri.parse('$_baseUrl/vehicles/$vehicleId/jobs/$jobId'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode != 204) {
        return const Result.error(
          HttpException('Failed to delete service record'),
        );
      }

      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<String>> uploadJobPhoto(
    String vehicleId,
    String jobId,
    File photo,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/vehicles/$vehicleId/jobs/$jobId/photos'),
      );

      final authHeader = _authHeaderProvider?.call();
      if (authHeader != null) {
        request.headers['Authorization'] = authHeader;
      }

      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      // Send request
      var response = await request.send();

      if (response.statusCode != 200) {
        return Result.error(Exception('Failed to upload photo'));
      }

      // Parse response
      final responseBody = await response.stream.bytesToString();
      final json = jsonDecode(responseBody);
      final photoUrl = json['photo_url'] as String;

      return Result.ok(photoUrl);
    } catch (e) {
      return Result.error(Exception('Upload error: $e'));
    }
  }

  Future<Result<List<JobPhotosApiModel>>> getJobPhotos(
    String vehicleId,
    String jobId,
  ) async {
    final client = _httpClient();
    try {
      final request = await client.getUrl(
        Uri.parse('$_baseUrl/vehicles/$vehicleId/jobs/$jobId/photos'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode != 200) {
        return const Result.error(HttpException('Failed to fetch job photos'));
      }
      final responseBody = await response.transform(utf8.decoder).join();
      if (responseBody.isEmpty) {
        return Result.ok([]);
      }
      final decoded = jsonDecode(responseBody);
      if (decoded == null || decoded is! List) {
        return Result.ok([]);
      }
      final records = decoded
          .map((r) => JobPhotosApiModel.fromJson(r))
          .toList();
      return Result.ok(records);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> deleteJobPhoto(
    String vehicleId,
    String jobId,
    String photoId,
  ) async {
    final client = _httpClient();
    try {
      final request = await client.deleteUrl(
        Uri.parse('$_baseUrl/vehicles/$vehicleId/jobs/$jobId/photos/$photoId'),
      );
      await _authHeader(request.headers);
      final response = await request.close();
      if (response.statusCode != 200) {
        return Result.error(HttpException('Failed to delete job photo'));
      }
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
