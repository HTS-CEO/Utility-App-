import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late WebSocketChannel _channel;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? _username;
  bool _showUsernameDialog = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _loadUsername();
  }

  void _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      _showUsernameDialog = _username == null;
    });
    if (_username != null) {
      _connectToWebSocket();
    }
  }

  void _connectToWebSocket() {
    _channel = IOWebSocketChannel.connect(
      Uri.parse('wss://chat-realtime-server-89114ab899ee.herokuapp.com'),
    );

    _channel.sink.add(jsonEncode({
      'type': 'join',
      'username': _username,
      'room': 'default'
    }));

    _channel.stream.listen((message) {
      final decoded = jsonDecode(message);
      if (decoded['type'] == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(decoded['message']),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() {
          _showUsernameDialog = true;
        });
        return;
      }
      if (decoded['type'] == 'new_message') {
        final newMessage = ChatMessage(
          sender: decoded['username'],
          text: decoded['message'],
          isMe: decoded['username'] == _username,
          timestamp: DateTime.parse(decoded['timestamp']),
        );
        if (mounted) {
          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom();
        }
      } else if (decoded['type'] == 'history') {
        setState(() {
          for (var msg in decoded['messages']) {
            _messages.add(ChatMessage(
              sender: msg['username'],
              text: msg['message'],
              isMe: msg['username'] == _username,
              timestamp: DateTime.parse(msg['timestamp']),
            ));
          }
          _scrollToBottom();
        });
      }
    }, onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    });
  }

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

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    if (_username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must set a username first'),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _showUsernameDialog = true;
      });
      return;
    }
    
    final newMessage = ChatMessage(
      sender: _username!,
      text: _messageController.text,
      isMe: true,
      timestamp: DateTime.now(),
    );
    
    if (mounted) {
      setState(() {
        _messages.add(newMessage);
      });
      _scrollToBottom();
    }

    final message = jsonEncode({
      'type': 'send_message',
      'message': _messageController.text,
      'room': 'default'
    });
    
    _channel.sink.add(message);
    _messageController.clear();
  }

  void _setUsername() async {
    if (_usernameController.text.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text.trim());
      setState(() {
        _username = _usernameController.text.trim();
        _showUsernameDialog = false;
      });
      _connectToWebSocket();
      _usernameController.clear();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _channel.sink.close();
    _messageController.dispose();
    _usernameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Chat Room', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFBB86FC).withOpacity(0.8),
                const Color(0xFF03DAC6).withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF3700B3),
                    Color(0xFF121212),
                  ],
                  center: Alignment.topLeft,
                  radius: 1.5,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                              onPressed: () {},
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFBB86FC),
                            const Color(0xFF03DAC6),
                          ],
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showUsernameDialog)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBB86FC).withOpacity(0.5),
                            blurRadius: 20.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Enter your username',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF2C2C2C),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Username',
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            onSubmitted: (_) => _setUsername(),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: _setUsername,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBB86FC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30.0,
                                vertical: 12.0,
                              ),
                            ),
                            child: const Text(
                              'Join Chat',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isMe;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundColor: _getAvatarColor(message.sender),
              child: Text(
                message.sender[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFF3700B3)
                    : const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft: Radius.circular(isMe ? 16.0 : 0.0),
                  bottomRight: Radius.circular(isMe ? 0.0 : 16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.sender,
                      style: const TextStyle(
                        color: Color(0xFF03DAC6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    message.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe)
            const SizedBox(width: 8.0),
        ],
      ),
    );
  }

  Color _getAvatarColor(String sender) {
    final colors = [
      const Color(0xFFBB86FC),
      const Color(0xFF03DAC6),
      const Color(0xFFCF6679),
      const Color(0xFF018786),
      const Color(0xFF6200EE),
    ];
    final index = sender.hashCode % colors.length;
    return colors[index];
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}