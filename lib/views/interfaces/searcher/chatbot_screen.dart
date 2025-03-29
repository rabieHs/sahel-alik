import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Import Gemini API

const geminiApiKey =
    'AIzaSyCIaxbk6OpFJsDdkw7Qun8t6lbt9q5klXI'; // Store API key as constant

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Removed TextField for API Key
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    // Changed to async function
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: _messageController.text,
          isUser: true,
        ));
      });

      final gemini = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: geminiApiKey); // Initialize Gemini API
      final prompt =
          "You are a chatbot assistant for a service provider app. Please answer questions related to the app's features, services, and functionalities. you speak tunisian  " +
              _messageController.text; // User message as prompt with context
      final content = [Content.text(prompt)];
      final response = await gemini.generateContent(content); // Call Gemini API
      final textResponse = response.text; // Extract text response

      setState(() {
        _messages.add(ChatMessage(
          // Add bot response to messages
          text: textResponse ?? 'Error: Could not generate response',
          isUser: false,
        ));
      });

      _messageController.clear();
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      alignment: isUser ? Alignment.topRight : Alignment.topLeft,
      child: Text(text),
    );
  }
}
