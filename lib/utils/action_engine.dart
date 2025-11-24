import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionEngine {
  final Dio _dio;
  final Map<String, String> headers;

  ActionEngine({Map<String, String>? headers})
      : headers = headers ?? {},
        _dio = Dio(
          BaseOptions(
            headers: headers ?? {'Content-Type': 'application/json'},
            validateStatus: (status) => status != null && status < 500,
          ),
        );

  Future<void> executeAction({
    required Map<String, dynamic> action,
    required BuildContext context,
    Map<String, dynamic>? formValues,
    VoidCallback? onSuccess,
  }) async {
    final actionType = action['type'] as String?;

    switch (actionType) {
      case 'api_call':
        await _handleApiCall(
          action: action,
          context: context,
          formValues: formValues,
          onSuccess: onSuccess,
        );
        break;

      case 'open_link':
        await _handleOpenLink(action: action, context: context);
        break;

      default:
        _showMessage(
          context: context,
          message: 'Unknown action type: $actionType',
          isError: true,
        );
    }
  }

  Future<void> _handleApiCall({
    required Map<String, dynamic> action,
    required BuildContext context,
    Map<String, dynamic>? formValues,
    VoidCallback? onSuccess,
  }) async {
    final method = (action['method'] as String?)?.toUpperCase() ?? 'POST';
    final url = action['url'] as String?;
    final successMessage = action['success_message'] as String? ?? 'Success';
    final errorMessage =
        action['error_message'] as String? ?? 'An error occurred';

    if (url == null || url.isEmpty) {
      _showMessage(context: context, message: 'Invalid URL', isError: true);
      return;
    }

    try {
      Response? response;

      switch (method) {
        case 'GET':
          response = await _dio.get(url, queryParameters: formValues);
          break;
        case 'POST':
          response = await _dio.post(url, data: formValues);
          break;
        case 'PUT':
          response = await _dio.put(url, data: formValues);
          break;
        case 'DELETE':
          response = await _dio.delete(url);
          break;
        case 'PATCH':
          response = await _dio.patch(url, data: formValues);
          break;
        default:
          _showMessage(
            context: context,
            message: 'Unsupported HTTP method: $method',
            isError: true,
          );
          return;
      }

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        _showMessage(context: context, message: successMessage, isError: false);
        onSuccess?.call();

        // Chaining: onSuccess action
        if (action['onSuccess'] != null) {
          await executeAction(
            action: action['onSuccess'],
            context: context,
            formValues: formValues,
          );
        }
      } else {
        _showMessage(context: context, message: errorMessage, isError: true);
        
        // Chaining: onError action
        if (action['onError'] != null) {
          await executeAction(
            action: action['onError'],
            context: context,
            formValues: formValues,
          );
        }
      }
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      _showMessage(context: context, message: errorMessage, isError: true);
      
      // Chaining: onError action
      if (action['onError'] != null) {
        await executeAction(
          action: action['onError'],
          context: context,
          formValues: formValues,
        );
      }
    } catch (e) {
      print('Unexpected Error: $e');
      _showMessage(context: context, message: errorMessage, isError: true);
      
      // Chaining: onError action
      if (action['onError'] != null) {
        await executeAction(
          action: action['onError'],
          context: context,
          formValues: formValues,
        );
      }
    }
  }

  Future<void> _handleOpenLink({
    required Map<String, dynamic> action,
    required BuildContext context,
  }) async {
    final url = action['url'] as String?;

    if (url == null || url.isEmpty) {
      _showMessage(context: context, message: 'Invalid URL', isError: true);
      return;
    }

    try {
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } else {
        _showMessage(
          context: context,
          message: 'Cannot open link',
          isError: true,
        );
      }
    } catch (e) {
      print('Link Error: $e');
      _showMessage(
        context: context,
        message: 'Failed to open link',
        isError: true,
      );
    }
  }

  void _showMessage({
    required BuildContext context,
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
