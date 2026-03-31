import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final List<Map<String, String>> _thoughtLogs = [];
  Map<String, String>? _digitalTwinInsight;
  bool _isLoading = false;
  bool _isThinking = false;
  String? _error;
  final String userId = const Uuid().v4();

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<Map<String, String>> get thoughtLogs => List.unmodifiable(_thoughtLogs);
  Map<String, String>? get digitalTwinInsight => _digitalTwinInsight;
  bool get isLoading => _isLoading;
  bool get isThinking => _isThinking;
  String? get error => _error;

  Future<void> streamMessage(String content) async {
    if (content.trim().isEmpty) return;
    _error = null;
    _thoughtLogs.clear();
    _digitalTwinInsight = null;

    // Add user message
    _messages.add(ChatMessage(
      id: const Uuid().v4(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    _isThinking = true;
    notifyListeners();
    
    // Add placeholder for AI response
    final aiMsg = ChatMessage(
      id: const Uuid().v4(),
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMsg);

    try {
      final url = Uri.parse('${ApiService.baseUrl}/stream?user_id=$userId&message=${Uri.encodeComponent(content)}');
      final request = http.Request('GET', url);
      final response = await http.Client().send(request);

      await for (final line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (line.trim().isEmpty) continue;
        try {
          final data = json.decode(line);
          
          if (data['type'] == 'thought') {
            _thoughtLogs.add({
              'agent': data['agent'],
              'content': data['content'],
            });
            notifyListeners();
          } else if (data['type'] == 'digital_twin') {
            _digitalTwinInsight = {
              'prediction': data['prediction'],
              'confidence': data['confidence'].toString(),
            };
            notifyListeners();
          } else if (data['type'] == 'chunk') {
            _isThinking = false;
            aiMsg.content += data['content'];
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Stream parse error: $line -> $e');
        }
      }
    } catch (e) {
      _error = e.toString();
      aiMsg.content = '⚠️ Error: $_error';
    } finally {
      _isLoading = false;
      _isThinking = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _error = null;

    // Add user message immediately
    _messages.add(ChatMessage(
      id: const Uuid().v4(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.sendMessage(
        userId: userId,
        message: content.trim(),
      );

      _messages.add(ChatMessage(
        id: const Uuid().v4(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _messages.add(ChatMessage(
        id: const Uuid().v4(),
        content: '⚠️ Error: $_error',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearHistory() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}
