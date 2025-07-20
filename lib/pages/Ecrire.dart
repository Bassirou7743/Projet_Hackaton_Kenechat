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

  final String _apiKey = 'AIzaSyB1IaegQbeRuN6R5dAaV2qtEPlKDVStgzY'; // <-- Remplace par ta vraie clé Gemini

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
      "prompt": {
        "messages": [
          {
            "author": "user",
            "content": {
              "text": text.trim(),
            }
          }
        ]
      },
      "temperature": 0.7,
      "candidateCount": 1,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List<dynamic>?;

        String reply = "Je n'ai pas compris, veuillez reformuler.";

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          if (content != null && content['text'] != null) {
            reply = content['text'];
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
          color: isUser ? Colors.green[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message["content"] ?? "", style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discussion Santé"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Écrivez votre question...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (!_isLoading) _sendMessage(value);
                    },
                    enabled: !_isLoading,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
