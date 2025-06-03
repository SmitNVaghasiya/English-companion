import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_strings.dart';
import '../providers/chat_provider.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final FlutterTts _flutterTts = FlutterTts();
  String _statusMessage = 'Initializing...';
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      final status = await Permission.microphone.request();
      if (status.isGranted) {
        setState(() {
          _statusMessage = 'Tap to start recording';
        });
      } else {
        setState(() {
          _statusMessage = AppStrings.permissionDenied;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing: $e';
      });
    }
  }

  Future<void> _startRecording() async {
    if (_isCancelled) return;
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/voice_chat.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
      setState(() {
        _statusMessage = 'Recording...';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error starting recording: $e';
      });
    }
  }

  Future<void> _stopRecordingAndProcess(ChatProvider chatProvider) async {
    try {
      await _recorder.stop();
      setState(() {
        _statusMessage = 'Processing audio...';
      });

      final file = File(
        '${(await getTemporaryDirectory()).path}/voice_chat.m4a',
      );
      if (await file.exists()) {
        final response = await _sendAudioToApi(file);
        if (response != null && response.isNotEmpty) {
          await _playTts(response);
          setState(() {
            _statusMessage = 'Response played';
          });
        } else {
          setState(() {
            _statusMessage = 'Received empty response';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Audio file not found';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error processing audio: $e';
      });
    }
  }

  Future<String?> _sendAudioToApi(File audioFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${await ApiConfig.baseUrl}${ApiConfig.voiceChatEndpoint}'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        return await response.stream.bytesToString();
      } else {
        setState(() {
          _statusMessage = 'API error: ${response.statusCode}';
        });
        return null;
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error sending audio: $e';
      });
      return null;
    }
  }

  Future<void> _playTts(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      setState(() {
        _statusMessage = 'Error playing TTS: $e';
      });
    }
  }

  void _cancelRecording() {
    setState(() {
      _isCancelled = true;
      _statusMessage = 'Recording cancelled';
    });
    _recorder.stop();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    Future<void> handleRecordButtonPress() async {
      if (chatProvider.state.isLoading || _isCancelled) return;
      
      if (!mounted) return;
      
      // Store the current context before any async operation
      final currentContext = context;
      
      try {
        if (chatProvider.state.voiceStatus == VoiceStatus.recording) {
          await _stopRecordingAndProcess(chatProvider);
          if (!mounted) return;
          // Check if the widget is still in the tree before using the context
          if (currentContext.mounted) {
            await chatProvider.toggleVoiceRecording(currentContext);
          }
        } else {
          await _startRecording();
          if (!mounted) return;
          // Check if the widget is still in the tree before using the context
          if (currentContext.mounted) {
            await chatProvider.toggleVoiceRecording(currentContext);
          }
        }
        
        if (mounted) {
          setState(() {
            _statusMessage = chatProvider.state.voiceStatus == VoiceStatus.recording
                ? 'Recording...'
                : 'Tap to start recording';
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Chat'),
        actions: [
          IconButton(
            icon: Icon(
              chatProvider.state.isMuted ? Icons.volume_off : Icons.volume_up,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => chatProvider.toggleMute(),
            tooltip: chatProvider.state.isMuted ? 'Unmute' : 'Mute',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: chatProvider.state.isLoading || _isCancelled 
                  ? null 
                  : handleRecordButtonPress,
              child: Text(
                chatProvider.state.voiceStatus == VoiceStatus.recording
                    ? 'Stop Recording'
                    : 'Start Recording',
              ),
            ),
            const SizedBox(height: 20),
            if (chatProvider.state.voiceStatus == VoiceStatus.speaking)
              const CircularProgressIndicator(),
            if (chatProvider.state.voiceStatus == VoiceStatus.recording ||
                chatProvider.state.voiceStatus == VoiceStatus.speaking)
              ElevatedButton(
                onPressed: _cancelRecording,
                child: const Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }
}
