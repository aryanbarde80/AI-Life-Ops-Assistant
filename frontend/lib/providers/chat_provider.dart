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
