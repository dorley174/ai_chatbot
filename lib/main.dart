import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Чат-бот',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();

  Future<String> sendMessage(String message) async {
    String saId = 'b1g82kdcn5grlmu79ano';
    String apiKey = 'AQVN3Hs_kx-A7gZD-QCz_nAy_er3d_FuUCBlamu6';

    Map<String, dynamic> data = {
      "modelUri": "gpt://$saId/yandexgpt-lite/latest",
      "completionOptions": {
        "stream": false,
        "temperature": 0.6,
        "maxTokens": "1000",
      },
      "messages": [
        {
          "role": "system",
          "text": "Отвечай коротко",
        },
        {
          "role": "user",
          "text": message,
        },
      ],
    };

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Api-Key $apiKey",
    };

    try {
      final response = await http.post(
        Uri.parse('https://llm.api.cloud.yandex.net/foundationModels/v1/completion'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Decode the response body as UTF-8 to handle non-ASCII characters
        final decodedResponse = utf8.decode(response.bodyBytes);
        return decodedResponse;
      } else {
        return 'Ошибка: ${response.statusCode}';
      }
    } catch (e) {
      return 'Ошибка при подключении к API: $e';
    }
  }

  String extractResponseText(String responseText) {
    try {
      Map<String, dynamic> data = jsonDecode(responseText);
      String text = data['result']['alternatives'][0]['message']['text'];
      return text;
    } catch (e) {
      return "Ошибка при обработке ответа ИИ.";
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add(Message(text: _controller.text, isUserMessage: true));
      });

      String responseText = await sendMessage(_controller.text);
      String generatedMessage = extractResponseText(responseText);

      setState(() {
        messages.add(Message(text: generatedMessage, isUserMessage: false));
        _controller.clear();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чат-бот'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: message.isUserMessage ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final bool isUserMessage;

  Message({required this.text, required this.isUserMessage});
}
