// ─── Symptom Chat Screen ─────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../services/gemini_service.dart';

class SymptomChatScreen extends StatefulWidget {
  const SymptomChatScreen({super.key});
  @override State<SymptomChatScreen> createState() => _SymptomChatScreenState();
}

class _SymptomChatScreenState extends State<SymptomChatScreen> {
  final _scrollCtrl = ScrollController();
  final _msgCtrl = TextEditingController();
  final List<_ChatMsg> _messages = [];
  bool _loading = false;
  final List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    // Initial system + first AI message
    _history.add({'role': 'user', 'text': _systemPrompt()});
    _sendInitial();
  }

  String _systemPrompt() {
    final symptom = context.read<AppStateProvider>().symptomInput;
    return '''You are a medical AI assistant. A patient describes these symptoms: "$symptom". 
Start by acknowledging their symptoms, ask 2-3 clarifying questions, then provide assessment with triage level (emergency/urgent/routine/self-care), causes, and recommendations. Always advise consulting a doctor for serious symptoms.''';
  }

  Future<void> _sendInitial() async {
    final symptom = context.read<AppStateProvider>().symptomInput;
    if (!GeminiService.instance.hasKey) {
      if (!mounted) return;
      _addBot('Please set your Gemini API key to use AI symptom analysis. Tap the key icon in settings.');
      return;
    }
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final reply = await GeminiService.instance.chatSymptom(
        _history,
        'Start by greeting the patient and assessing their symptom: $symptom',
      );
      if (!mounted) return;
      _addBot(reply);
    } catch (e) {
      if (!mounted) return;
      _addBot('Sorry, I could not connect to the AI service. Please check your API key and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addBot(String text) {
    setState(() {
      _messages.add(_ChatMsg(text: text, isUser: false));
      _history.add({'role': 'model', 'text': text});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _loading) return;
    _msgCtrl.clear();
    setState(() {
      _messages.add(_ChatMsg(text: text, isUser: true));
      _history.add({'role': 'user', 'text': text});
      _loading = true;
    });
    _scrollToBottom();

    try {
      final reply = await GeminiService.instance.chatSymptom(_history, text);
      if (!mounted) return;
      _addBot(reply);
    } catch (_) {
      if (!mounted) return;
      _addBot('Sorry, I encountered an error. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: context.read<NavigationProvider>().goBack,
        ),
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]), shape: BoxShape.circle),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MediAI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text('AI Symptom Analyst', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ]),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: AppColors.border)),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) return const _TypingIndicator();
                return _MessageBubble(msg: _messages[i]);
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SafeArea(
              top: false,
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Describe more symptoms or ask a question…'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _loading ? null : _send,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isUser;
  const _ChatMsg({required this.text, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]), shape: BoxShape.circle),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: msg.isUser ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(msg.isUser ? 12 : 2),
                  bottomRight: Radius.circular(msg.isUser ? 2 : 12),
                ),
                border: msg.isUser ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 13,
                  color: msg.isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]), shape: BoxShape.circle),
          child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            _Dot(delay: 0), SizedBox(width: 4),
            _Dot(delay: 150), SizedBox(width: 4),
            _Dot(delay: 300),
          ]),
        ),
      ]),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 1, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay)).then((_) { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(width: 6, height: 6 + _anim.value * 4,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.textSecondary.withValues(alpha: 0.3 + _anim.value * 0.7))),
    );
  }
}
