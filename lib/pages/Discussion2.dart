import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class VoiceAssistant extends StatefulWidget {
  const VoiceAssistant({super.key});

  @override
  State<VoiceAssistant> createState() => _VoiceAssistantState();
}

class _VoiceAssistantState extends State<VoiceAssistant> {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  FlutterTts _tts = FlutterTts();
  bool _isRecording = false;
  String _transcription = '';
  String _responseIA = '';
  final String _apiKey = 'AIzaSyDkfnrNvgMcX4vsRt5s8nmo1m4UwG2SfwE';
  final String _apiKey1 = 'AIzaSyDkfnrNvgMcX4vsRt5s8nmo1m4UwG2SfwE';

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<String> _getFilePath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/keneya.wav';
  }

  Future<void> _startRecording() async {
    final path = await _getFilePath();
    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
    );
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() => _isRecording = false);
    if (path != null) {
      await _sendToGoogleSTT(File(path));
    }
  }

  Future<void> _sendToGoogleSTT(File audioFile) async {
    final bytes = await audioFile.readAsBytes();
    final base64Audio = base64Encode(bytes);

    final body = jsonEncode({
      "config": {
        "encoding": "LINEAR16",
        "sampleRateHertz": 16000,
        "languageCode": "fr-FR"
      },
      "audio": {"content": base64Audio}
    });

    final response = await http.post(
      Uri.parse('https://speech.googleapis.com/v1/speech:recognize?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final text = result['results']?[0]?['alternatives']?[0]?['transcript'] ?? '';
      setState(() {
        _transcription = text;
        _responseIA = "Analyse en cours...";
      });
      if (text.isNotEmpty) _sendTextToGemini(text);
    } else {
      setState(() => _transcription = "Erreur API Speech-to-Text");
    }
  }

  Future<void> _sendTextToGemini(String text) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-pro:generateContent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': _apiKey1,
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [{"text": text}]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final answer = data['candidates'][0]['content']['parts'][0]['text'];
      setState(() => _responseIA = answer);
      _speak(answer);
    } else {
      setState(() => _responseIA = "Erreur API Gemini.");
    }
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("fr-FR");
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _tts.stop();
    super.dispose();
  }

  Widget _buildCard(String title, String content, {double maxHeight = 150}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.green.shade100, blurRadius: 10, offset: const Offset(0, 4)),
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
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: maxHeight,
          child: SingleChildScrollView(
            child: Text(
              content.isEmpty ? "..." : content,
              style: const TextStyle(fontSize: 16),
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
      title: const Text('Assistant Keneya'),
      backgroundColor: Colors.green,
    ),
    backgroundColor: Colors.green.shade50,
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCard("🎙️ Transcription", _transcription, maxHeight: 200),
          const SizedBox(height: 20),
          _buildCard("💡 Réponse IA", _responseIA, maxHeight: 200),
          const SizedBox(height: 20),
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: _isRecording ? _stopRecording : _startRecording,
            child: Icon(_isRecording ? Icons.stop : Icons.mic, size: 28),
          ),
        ],
      ),
    ),
  );
}

  }

 

