import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

/// Singleton HTTP service that handles all API calls to Supabase Edge Functions.
/// Automatically attaches required apikey + Authorization headers.
class HttpService {
  static final HttpService _instance = HttpService._internal();

  factory HttpService() => _instance;
  HttpService._internal();

  // ─── POST ─────────────────────────────────────────────────────────────────────
  Future<dynamic> post(
    String url, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─── GET ──────────────────────────────────────────────────────────────────────
  Future<dynamic> get(String url, {String? token}) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers(token))
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─── PUT ──────────────────────────────────────────────────────────────────────
  Future<dynamic> put(
    String url, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─── PATCH ────────────────────────────────────────────────────────────────────
  Future<dynamic> patch(
    String url, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse(url),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────────
  Future<dynamic> delete(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final request = http.Request('DELETE', Uri.parse(url));
      request.headers.addAll(_headers(token));
      if (body != null) request.body = jsonEncode(body);

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─── Headers ──────────────────────────────────────────────────────────────────
  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'apikey': ApiConstants.anonKey,
        'Authorization': 'Bearer ${token ?? ApiConstants.anonKey}',
      };

  // ─── Response handler ─────────────────────────────────────────────────────────
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    // Try to parse an error body
    String errorMsg = 'Request failed (${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      errorMsg = body['error'] ?? body['message'] ?? errorMsg;
    } catch (_) {}

    switch (response.statusCode) {
      case 400:
        throw Exception(errorMsg);
      case 401:
        // Show actual server error (e.g. "Invalid login credentials") not a hardcoded message
        throw Exception(errorMsg);
      case 403:
        throw Exception('Forbidden: Insufficient permissions');
      case 404:
        throw Exception(errorMsg.isNotEmpty ? errorMsg : 'Not found');
      default:
        throw Exception(errorMsg);
    }
  }
}
