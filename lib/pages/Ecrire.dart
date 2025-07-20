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
  final String _apiKey = 'TA_CLÉ_API_ICI'; // Mets ta vraie clé ici
  bool _isLoading = false;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text.trim()});
      _isLoading = true;
    });

    _controller.clear();

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
    );

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": "Réponds en français : $text"}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 1,
        "topP": 1,
        "maxOutputTokens": 2048
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'];

        String reply = "Je n'ai pas compris. Veuillez reformuler.";

        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'];
          if (parts != null && parts.isNotEmpty) {
            reply = parts[0]['text'];
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
          "content": "Erreur de réseau : $e"
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Text(
          message["content"] ?? "",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("Messagerie", style: TextStyle(color: Colors.white)),
        centerTitle: true,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (!_isLoading) _sendMessage(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Écrivez votre question en santé...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green, size: 28),
                  onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
