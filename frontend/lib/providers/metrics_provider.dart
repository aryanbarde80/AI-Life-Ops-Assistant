import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class SystemMetricsProvider extends ChangeNotifier {
  double latency = 0.0;
  String meshStatus = "SYNCING";
  String memoryUsage = "0 MB";
  bool _isListening = false;

  void startListening() async {
    if (_isListening) return;
    _isListening = true;

    try {
      final url = Uri.parse('${ApiService.baseUrl}/health'); // Fallback for polling
      while (_isListening) {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          latency = 124.0; // Simulate
          meshStatus = "ACTIVE";
          memoryUsage = "342 MB";
          notifyListeners();
        }
        await Future.delayed(const Duration(seconds: 10));
      }
    } catch (e) {
      meshStatus = "ERROR";
      notifyListeners();
    }
  }

  void stopListening() {
    _isListening = false;
  }
}
