// Flutter Service: UnityService
// Location: lib/services/unity_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityService {
  UnityWidgetController? _controller;
  final StreamController<UnityMessage> _messageStream = StreamController.broadcast();

  Stream<UnityMessage> get messages => _messageStream.stream;
  bool get isReady => _controller != null;

  void setController(UnityWidgetController controller) {
    _controller = controller;
    _controller?.onUnityMessage((message) {
      _handleUnityMessage(message);
    });
    print('[UnityService] Controller set');
  }

  void _handleUnityMessage(dynamic message) {
    try {
      final String jsonMessage = message.toString();
      print('[UnityService] Received: $jsonMessage');

      final Map<String, dynamic> data = jsonDecode(jsonMessage);
      final unityMessage = UnityMessage.fromJson(data);
      _messageStream.add(unityMessage);
    } catch (e) {
      print('[UnityService] Failed to parse Unity message: $e');
    }
  }

  // Send messages to Unity
  void startBattle(String bossId, int difficulty) {
    final message = {
      'type': 'START_BATTLE',
      'data': jsonEncode({
        'bossId': bossId,
        'difficulty': difficulty,
      }),
    };
    _sendMessage(message);
  }

  void playerAction(String action, int damage) {
    final message = {
      'type': 'PLAYER_ACTION',
      'data': jsonEncode({
        'action': action,
        'damage': damage,
      }),
    };
    _sendMessage(message);
  }

  void bossAttack(int damage) {
    final message = {
      'type': 'BOSS_ATTACK',
      'data': jsonEncode({
        'damage': damage,
      }),
    };
    _sendMessage(message);
  }

  void endBattle(bool victory) {
    final message = {
      'type': 'BATTLE_END',
      'data': jsonEncode({
        'victory': victory,
      }),
    };
    _sendMessage(message);
  }

  void resetGame() {
    final message = {
      'type': 'RESET_GAME',
      'data': '{}',
    };
    _sendMessage(message);
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_controller == null) {
      print('[UnityService] Controller not ready');
      return;
    }

    final jsonMessage = jsonEncode(message);
    print('[UnityService] Sending: $jsonMessage');

    try {
      _controller!.postMessage(
        'FlutterBridge',
        'OnFlutterMessage',
        jsonMessage,
      );
    } catch (e) {
      print('[UnityService] Failed to send message: $e');
    }
  }

  void pause() {
    _controller?.pause();
  }

  void resume() {
    _controller?.resume();
  }

  void dispose() {
    _messageStream.close();
    _controller?.dispose();
  }
}

class UnityMessage {
  final String type;
  final Map<String, dynamic> data;

  UnityMessage({required this.type, required this.data});

  factory UnityMessage.fromJson(Map<String, dynamic> json) {
    return UnityMessage(
      type: json['type'] as String,
      data: json['data'] is String
          ? jsonDecode(json['data'])
          : json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
    };
  }
}
