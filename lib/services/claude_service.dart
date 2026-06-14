import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ClaudeService {
  static const _model = 'claude-haiku-4-5-20251001';
  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _system =
      'You are Hush, a calm yoga guide. '
      'Respond with 1-3 short, peaceful sentences. '
      'Guide the user with breathing, posture, or mindfulness.';

  String? _apiKey;

  Future<void> _loadKey() async {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('claude')
        .get();
    _apiKey = doc.data()?['apiKey'] as String?;
  }

  Stream<String> stream({required String userMessage}) async* {
    if (_apiKey == null) await _loadKey();
    final key = _apiKey;
    if (key == null || key.isEmpty) return;

    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse(_endpoint))
        ..headers.addAll({
          'Content-Type': 'application/json',
          'X-API-Key': key,
          'anthropic-version': '2023-06-01',
        })
        ..body = jsonEncode({
          'model': _model,
          'max_tokens': 256,
          'stream': true,
          'system': _system,
          'messages': [
            {'role': 'user', 'content': userMessage},
          ],
        });

      final response = await client.send(request);
      if (response.statusCode != 200) return;

      final lineBuffer = StringBuffer();
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        lineBuffer.write(chunk);
        final raw = lineBuffer.toString();
        final parts = raw.split('\n\n');
        lineBuffer
          ..clear()
          ..write(parts.last);

        for (final event in parts.sublist(0, parts.length - 1)) {
          for (final line in event.split('\n')) {
            if (!line.startsWith('data: ')) continue;
            final data = line.substring(6).trim();
            if (data.isEmpty) continue;
            try {
              final map = jsonDecode(data) as Map<String, dynamic>;
              if (map['type'] == 'content_block_delta') {
                final delta = map['delta'] as Map<String, dynamic>;
                if (delta['type'] == 'text_delta') {
                  yield delta['text'] as String;
                }
              }
            } catch (_) {}
          }
        }
      }
    } finally {
      client.close();
    }
  }
}
