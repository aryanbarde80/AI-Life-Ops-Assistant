import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFocused = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await context.read<ChatProvider>().streamMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            FadeInLeft(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology_alt_rounded,
                    color: Colors.black, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Intelligence',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                Text('NEURAL LINK ACTIVE',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.primary.withOpacity(0.8),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5)),
              ],
            ),
          ],
        ),
      ),
import '../widgets/thought_visualization.dart';

// ...
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                _scrollToBottom();
                if (provider.messages.isEmpty) return _buildEmptyState();
                return Column(
                  children: [
                    if (provider.isThinking)
                      ThoughtVisualization(logs: provider.thoughtLogs),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        itemCount: provider.messages.length + (provider.isLoading && !provider.isThinking ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.messages.length) {
                             return _buildTypingIndicator();
                          }
                          return FadeInUp(
                            key: ValueKey(provider.messages[index].id),
                            duration: const Duration(milliseconds: 400),
                            child: _buildMessageBubble(provider.messages[index]),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInDown(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: const Icon(Icons.psychology_alt_rounded,
                  color: AppTheme.primary, size: 36),
            ),
            const SizedBox(height: 24),
            const Text('AI Assistant Ready',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Ask anything to optimize your life ops.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _avatar(isAi: true),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent])
                    : null,
                color: isUser ? null : AppTheme.surfaceElevated.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: !isUser ? Border.all(color: AppTheme.border) : null,
              ),
              child: isUser
                  ? Text(msg.content,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600))
                  : MarkdownBody(
                      data: msg.content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                            color: AppTheme.textPrimary, height: 1.6),
                        strong: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ),
          if (isUser) _avatar(isAi: false),
        ],
      ),
    );
  }

  Widget _avatar({required bool isAi}) {
    return Container(
      width: 32,
      height: 32,
      margin: EdgeInsets.only(left: isAi ? 0 : 12, right: isAi ? 12 : 0),
      decoration: BoxDecoration(
        color: isAi ? null : AppTheme.surfaceElevated,
        gradient: isAi
            ? const LinearGradient(colors: [AppTheme.primary, AppTheme.accent])
            : null,
        shape: BoxShape.circle,
        border: !isAi ? Border.all(color: AppTheme.border) : null,
      ),
      child: Icon(isAi ? Icons.psychology_alt_rounded : Icons.person_rounded,
          color: isAi ? Colors.black : AppTheme.textSecondary, size: 18),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _avatar(isAi: true),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Row(
              children: [
                _TypingDot(delay: 0),
                SizedBox(width: 4),
                _TypingDot(delay: 150),
                SizedBox(width: 4),
                _TypingDot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        border: const Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _controller,
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Neural Input...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          BounceInRight(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward_rounded, color: Colors.black),
                onPressed: _sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween(begin: 0.2, end: 1.0).animate(_controller);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 6,
        height: 6,
        decoration:
            const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
      ),
    );
  }
}
