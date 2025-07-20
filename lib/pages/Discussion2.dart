import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class VoiceAssistant extends StatefulWidget {
  const VoiceAssistant({super.key});

  @override
  State<VoiceAssistant> createState() => _VoiceAssistantState();
}

class _VoiceAssistantState extends State<VoiceAssistant> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcription = '';
  String _responseIA = '';
  FlutterTts _tts = FlutterTts();

  final String _apiKeyGemini = 'TA_CLE_API_GEMINI_ICI'; // Remplace par ta clé

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _askPermission();
  }

  Future<void> _askPermission() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission micro refusée')),
      );
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        print('Status: $val');
        if (val == 'done') {
          _stopListening();
        }
      },
      onError: (val) {
        print('Erreur speech_to_text: $val');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${val.errorMsg}')),
        );
      },
    );

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reconnaissance vocale non disponible')),
      );
      return;
    }

    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        setState(() {
          _transcription = result.recognizedWords;
        });
      },
      localeId: 'fr_FR', // Essaie 'en_US' si 'fr_FR' ne fonctionne pas
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);

    if (_transcription.isNotEmpty) {
      setState(() => _responseIA = 'Analyse en cours...');
      await _sendTextToGemini(_transcription);
    }
  }

  Future<void> _sendTextToGemini(String text) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-pro:generateContent',
    );
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': _apiKeyGemini,
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": text}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final answer = data['candidates'][0]['content']['parts'][0]['text'];
      setState(() => _responseIA = answer);
      await _speak(answer);
    } else {
      setState(() => _responseIA = "Erreur API Gemini.");
      print("Erreur Gemini: ${response.body}");
    }
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("fr-FR");
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Widget _buildCard(String title, String content, {double maxHeight = 200}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 10),
          Container(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              minHeight: 100,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                content.isEmpty ? "..." : content,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Arial',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion Vocale', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.green.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard("Transcription", _transcription, maxHeight: 150),
            _buildCard("Réponse IA", _responseIA, maxHeight: 200),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: _isListening ? _stopListening : _startListening,
                child: Icon(_isListening ? Icons.stop : Icons.mic, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
