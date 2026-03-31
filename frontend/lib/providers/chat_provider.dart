import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  final String userId = const Uuid().v4();

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> streamMessage(String content) async {
    if (content.trim().isEmpty) return;
    _error = null;

    // Add user message
    _messages.add(ChatMessage(
      id: const Uuid().v4(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    
    // Add placeholder for AI response
    final aiMsg = ChatMessage(
      id: const Uuid().v4(),
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMsg);
    notifyListeners();

    try {
      final url = Uri.parse('${ApiService.baseUrl}/stream?user_id=$userId&message=${Uri.encodeComponent(content)}');
      final request = http.Request('GET', url);
      final response = await http.Client().send(request);

      await for (final line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (line.trim().isEmpty) continue;
        try {
          final data = json.decode(line);
          if (data['type'] == 'chunk') {
            aiMsg.content += data['content'];
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Stream parse error: $e');
        }
      }
    } catch (e) {
      _error = e.toString();
      aiMsg.content = '⚠️ Error: $_error';
    } finally {
      _isLoading = false;
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
