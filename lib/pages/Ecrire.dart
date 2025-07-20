import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EcrirePage extends StatefulWidget {
  const EcrirePage({super.key});

  @override
  State<EcrirePage> createState() => _EcrirePageState();
}

class _EcrirePageState extends State<EcrirePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  final String _apiKey = 'AIzaSyB1IaegQbeRuN6R5dAaV2qtEPlKDVStgzY';

  bool _isLoading = false;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text.trim()});
      _isLoading = true;
    });

    _controller.clear();

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
    );

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
    };

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": text.trim()}
          ]
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List<dynamic>?;

        String reply = "Je n'ai pas compris, veuillez reformuler.";

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          if (content != null &&
              content['parts'] != null &&
              content['parts'][0]['text'] != null) {
            reply = content['parts'][0]['text'];
          }
        }

        setState(() {
          _messages.add({"role": "assistant", "content": reply});
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "Erreur API : ${response.statusCode}"
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "Erreur lors de la requête : $e"
        });
        _isLoading = false;
      });
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isUser = message["role"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.green.shade200 : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 14,
                  child: Icon(Icons.local_hospital, size: 16, color: Colors.white),
                ),
              ),
            Flexible(
              child: Text(
                message["content"] ?? "",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (isUser)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 14,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 2,
        title: const Text("Assistant Keneya"),
        leading: const Icon(Icons.health_and_safety),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildMessage(_messages[index]),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Posez votre question...",
                      filled: true,
                      fillColor: Colors.green.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (!_isLoading) _sendMessage(value);
                    },
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () => _sendMessage(_controller.text),
                  child: CircleAvatar(
                    backgroundColor:
                        _isLoading ? Colors.grey : Colors.green,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
