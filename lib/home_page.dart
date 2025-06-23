// lib/home_page.dart

import 'dart:convert';
import 'package:nova_ai/feature_box.dart';
import 'package:nova_ai/service.dart';
import 'package:nova_ai/pallete.dart';
import "package:flutter/material.dart";
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }
  
  void _resetState() {
    flutterTts.stop(); 
    setState(() {
      generatedContent = null;
      generatedImageUrl = null;
      _isLoading = false;
      lastWords = '';
    });
  }

  Future<void> startListening() async {
    await flutterTts.stop();
    setState(() {});
    await speechToText.listen(
      onResult: onSpeechResult,
      pauseFor: const Duration(seconds: 4),
      localeId: "en_US",
    );
    
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }
  Future<void> processSpeech(String query) async {
    setState(() {
      _isLoading = true;
      generatedContent = null;
      generatedImageUrl = null;
    });

    try {

      final aiResponse = await openAIService.isArtPromptAPI(query);


      if (aiResponse.type == ResponseType.image) {
        generatedImageUrl = aiResponse.content;
        generatedContent = null;
      } else {
        generatedImageUrl = null;
        generatedContent = aiResponse.content;
        await systemSpeak(aiResponse.content);
      }
    } catch (e) {
      generatedContent = "An error occurred: $e";
      generatedImageUrl = null;
    } finally {
      setState(() {
        _isLoading = false;
      });
      lastWords = '';
    }
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nova AI",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const Icon(Icons.menu),
        actions: [
          if (generatedContent != null || generatedImageUrl != null || _isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: const Icon(Icons.replay),
                onPressed: _resetState,
                tooltip: 'Start New Conversation',
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage("assets/images/virtualAssistant.png"),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: generatedImageUrl == null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 40,
                ).copyWith(top: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Pallete.borderColor),
                  borderRadius: BorderRadius.circular(
                    20,
                  ).copyWith(topLeft: Radius.zero),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                    generatedContent ??
                        "Hello, I am Nova AI, your virtual assistant. How can I help you today?",
                    style: TextStyle(
                      fontSize: generatedContent == null ? 20 : 18,
                      color: Pallete.mainFontColor,
                      fontFamily: 'Cera Pro',
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    base64Decode(generatedImageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 10, left: 22),
                child: const Text(
                  "Here are a few features",
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    fontSize: 18,
                    color: Pallete.mainFontColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: const Column(
                children: [
                  FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: "Gemini AI",
                    descriptionText:
                        "A powerful, conversational AI from Google to help you with any question.",
                  ),
                  FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: "AI Image Generation",
                    descriptionText:
                        "Create stunning and imaginative images from just a few words.",
                  ),
                  FeatureBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerText: "Smart Voice Assistant",
                    descriptionText:
                        "Get the best of both worlds with a voice-activated AI assistant.",
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            :() async {
          if (speechToText.isListening) {
                  await stopListening();
                  if (lastWords.isNotEmpty) {
                    await processSpeech(lastWords);
                  }
                } else {
                  await startListening();
                }
        },
        backgroundColor: Pallete.mainFontColor,
        child: Icon(
          speechToText.isListening ? Icons.stop : Icons.mic,
          color: Pallete.whiteColor,
        ),
      ),
    );
  }
}
