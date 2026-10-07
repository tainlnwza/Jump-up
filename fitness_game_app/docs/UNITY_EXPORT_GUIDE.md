# Unity VFX & Export Guide

## 🎨 Part 6: Visual Effects Creation (2-3 hours)

### VFX 1: Hit Effect (Normal Attack)

1. **Create Particle System**
   ```
   Hierarchy → Right-click → Effects → Particle System
   Name: "HitEffect"
   ```

2. **Main Module**
   ```
   Duration: 0.5
   Looping: ❌
   Start Lifetime: 0.3
   Start Speed: 3
   Start Size: 0.1 to 0.3
   Start Color: White → Yellow gradient
   Max Particles: 20
   ```

3. **Emission Module**
   ```
   ✅ Enabled
   Rate over Time: 0
   Bursts: 
     - Time: 0
     - Count: 15
   ```

4. **Shape Module**
   ```
   ✅ Enabled
   Shape: Sphere
   Radius: 0.2
   ```

5. **Color over Lifetime**
   ```
   ✅ Enabled
   Color: Gradient
     - Start: White (Alpha 1)
     - End: Yellow (Alpha 0)
   ```

6. **Size over Lifetime**
   ```
   ✅ Enabled
   Size: Curve
     - Start: 1
     - End: 0
   ```

7. **Create Prefab**
   ```
   Drag to Assets/VFX/HitEffect
   Delete from scene
   ```

### VFX 2: Critical Hit Effect

1. **Duplicate HitEffect**
   ```
   Duplicate HitEffect prefab
   Name: "CriticalHitEffect"
   ```

2. **Modify Settings**
   ```
   Main Module:
     - Start Size: 0.2 to 0.5 (larger)
     - Start Speed: 5 (faster)
     - Max Particles: 30 (more)
   
   Emission:
     - Burst Count: 25
   
   Shape:
     - Radius: 0.4 (wider)
   
   Color over Lifetime:
     - Red → Orange → Yellow gradient
   
   Add Sub Emitter:
     - ✅ Enabled
     - Birth: Spawn ring effect
   ```

3. **Add Light Component**
   ```
   Add Component → Light
   Type: Point
   Color: Orange
   Range: 3
   Intensity: 2
   ```

4. **Add Script for Screen Shake** (optional)
   ```csharp
   // Simple shake on instantiate
   public class ScreenShake : MonoBehaviour
   {
       void Start()
       {
           Camera.main.transform.DOShakePosition(0.2f, 0.1f);
           // Or manual shake implementation
       }
   }
   ```

### VFX 3: Shield Effect

1. **Create Particle System**
   ```
   Name: "ShieldEffect"
   ```

2. **Main Module**
   ```
   Duration: 3 (lasts 3 seconds)
   Looping: ✅
   Start Lifetime: 1
   Start Speed: 0
   Start Size: 0.05
   Start Color: Cyan
   Max Particles: 50
   ```

3. **Emission**
   ```
   Rate over Time: 20
   ```

4. **Shape**
   ```
   Shape: Sphere
   Radius: 1.5
   Emit from: Shell (surface only)
   ```

5. **Velocity over Lifetime**
   ```
   ✅ Enabled
   Linear: (0, 0.5, 0) - particles float upward
   ```

6. **Add Shield Mesh** (optional)
   ```
   - Create Sphere: Scale (1.8, 1.8, 1.8)
   - Material: Transparent blue
   - Shader: Universal RP/Particles/Unlit
   - Alpha: 0.3
   - Parent to ShieldEffect
   ```

### VFX 4: Dodge Effect

1. **Create Particle System**
   ```
   Name: "DodgeEffect"
   ```

2. **Main Module**
   ```
   Duration: 0.3
   Looping: ❌
   Start Lifetime: 0.2
   Start Speed: 10
   Start Size: 0.2
   Start Color: White
   Max Particles: 20
   ```

3. **Emission**
   ```
   Bursts: Time 0, Count 15
   ```

4. **Shape**
   ```
   Shape: Cone
   Angle: 25
   Radius: 0.1
   Emit from: Base
   ```

5. **Velocity over Lifetime**
   ```
   Orbital: Random between -2 and 2
   ```

### VFX 5: Heal Effect

1. **Create Particle System**
   ```
   Name: "HealEffect"
   ```

2. **Main Module**
   ```
   Duration: 2
   Looping: ❌
   Start Lifetime: 1.5
   Start Speed: 2
   Start Size: 0.1 to 0.2
   Start Color: Green → White gradient
   Max Particles: 30
   ```

3. **Emission**
   ```
   Rate over Time: 15
   ```

4. **Shape**
   ```
   Shape: Circle
   Radius: 1
   Emit from: Edge
   ```

5. **Velocity over Lifetime**
   ```
   Linear: (0, 3, 0) - particles rise upward
   ```

6. **Add Glow**
   ```
   Renderer module:
   - Material: Default-Particle-Additive
   ```

### VFX 6: Death Effect

1. **Create Particle System**
   ```
   Name: "DeathEffect"
   ```

2. **Main Module**
   ```
   Duration: 2
   Looping: ❌
   Start Lifetime: 1.5
   Start Speed: 3 to 5
   Start Size: 0.2 to 0.4
   Start Color: Monster color → Black gradient
   Max Particles: 100
   ```

3. **Emission**
   ```
   Rate over Time: 50
   Duration: 1.5 seconds
   ```

4. **Shape**
   ```
   Shape: Sphere
   Radius: 1
   ```

5. **Velocity over Lifetime**
   ```
   Linear: (0, 2, 0)
   Orbital: Random
   ```

6. **Color over Lifetime**
   ```
   Gradient: Monster color → Transparent
   ```

7. **Size over Lifetime**
   ```
   Curve: 1 → 0
   ```

8. **Add Flash Light**
   ```
   Add Component → Light
   Type: Point
   Color: White
   Range: 5
   Intensity: Animate 0 → 5 → 0 over 0.5s
   ```

### VFX 7: Damage Numbers

1. **Create Canvas** (World Space)
   ```
   Hierarchy → Right-click → UI → Canvas
   Name: "DamageNumberCanvas"
   ```

2. **Configure Canvas**
   ```
   Canvas component:
   - Render Mode: World Space
   - Scale: (0.01, 0.01, 0.01)
   ```

3. **Create Text**
   ```
   Right-click Canvas → UI → Text - TextMeshPro
   Name: "DamageNumber"
   ```

4. **Configure Text**
   ```
   TextMeshPro component:
   - Font Size: 50
   - Alignment: Center
   - Color: White (or yellow for normal, red for critical)
   - Outline: Black, width 0.2
   ```

5. **Create Animation Script**
   ```csharp
   // Assets/Scripts/DamageNumber.cs
   using UnityEngine;
   using TMPro;
   
   public class DamageNumber : MonoBehaviour
   {
       public TextMeshProUGUI textMesh;
       public float lifetime = 1f;
       public float floatSpeed = 1f;
       
       private float timer = 0f;
       private Vector3 startPos;
       
       public void Initialize(int damage, bool isCritical)
       {
           textMesh.text = damage.ToString();
           textMesh.color = isCritical ? Color.red : Color.white;
           if (isCritical)
           {
               textMesh.fontSize = 60;
           }
           startPos = transform.position;
       }
       
       void Update()
       {
           timer += Time.deltaTime;
           
           // Float upward
           transform.position = startPos + Vector3.up * floatSpeed * timer;
           
           // Fade out
           Color color = textMesh.color;
           color.a = 1 - (timer / lifetime);
           textMesh.color = color;
           
           // Destroy when done
           if (timer >= lifetime)
           {
               Destroy(gameObject);
           }
       }
   }
   ```

6. **Create Prefab**
   ```
   Drag DamageNumberCanvas to Assets/VFX/
   Delete from scene
   ```

### Assign VFX to Monster Prefab

1. **Open Monster_Prefab**

2. **MonsterController component**
   ```
   - Hit Effect Prefab: Drag HitEffect
   - Critical Hit Effect Prefab: Drag CriticalHitEffect
   - Death Effect Prefab: Drag DeathEffect
   ```

3. **Save Prefab**

---

## 📤 Part 7: Export Unity to Flutter (2-3 hours)

### Step 1: Install Unity-Flutter Package

1. **Add Package**
   ```
   Window → Package Manager
   "+" → Add package from git URL
   URL: https://github.com/juicycleff/flutter-unity-view-widget.git
   ```

2. **Or use UnityEditor Export** (alternative)
   ```
   - File → Build Settings
   - Platform: Android or iOS
   - Export as Gradle Project (Android) or Xcode Project (iOS)
   ```

### Step 2: Build Settings

#### For Android:

1. **Open Build Settings**
   ```
   File → Build Settings
   Platform: Android
   Click "Switch Platform" (if not already)
   ```

2. **Add Scenes**
   ```
   Click "Add Open Scenes"
   Should show: GameScene
   ```

3. **Player Settings**
   ```
   - Company Name: YourCompany
   - Product Name: FitnessGame
   - Package Name: com.yourcompany.fitnessgame.unity
   - Minimum API Level: Android 7.0 (API 24)
   - Target API Level: Android 13 (API 33)
   - Scripting Backend: IL2CPP
   - ARM64: ✅
   - Export Project: ✅ (important!)
   ```

4. **Export**
   ```
   Export → Choose location: D:\jump up\unity_project\Builds\Android
   Wait for export (5-10 minutes)
   ```

#### For iOS:

1. **Build Settings**
   ```
   Platform: iOS
   Switch Platform
   Add Scenes: GameScene
   ```

2. **Player Settings**
   ```
   - Bundle Identifier: com.yourcompany.fitnessgame.unity
   - Target minimum iOS: 12.0
   - Architecture: ARM64
   - Camera Usage Description: "AR for fitness game"
   ```

3. **Export**
   ```
   Export → Choose location: D:\jump up\unity_project\Builds\iOS
   Wait for export (5-10 minutes)
   ```

### Step 3: Create Flutter-Unity Bridge Files

#### iOS Bridge (Objective-C)

Create file: `Builds/iOS/UnityFlutterBridge.mm`

```objc
#import <Foundation/Foundation.h>
#import "UnityFramework/UnityFramework.h"

extern "C" {
    void _SendMessageToFlutter(const char* message) {
        NSString *msgString = [NSString stringWithUTF8String:message];
        // Post notification to Flutter
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UnityMessage"
                                                            object:nil
                                                          userInfo:@{@"message": msgString}];
    }
}
```

#### Android Bridge (Kotlin)

Create file: `Builds/Android/unityLibrary/src/main/java/com/unity3d/player/UnityPlayerActivity.kt`

```kotlin
package com.unity3d.player

import android.content.Intent
import android.os.Bundle

class UnityPlayerActivity : UnityPlayerActivity() {
    companion object {
        private var messageListener: ((String) -> Unit)? = null
        
        fun setMessageListener(listener: (String) -> Unit) {
            messageListener = listener
        }
    }
    
    fun onUnityMessage(message: String) {
        messageListener?.invoke(message)
    }
}
```

---

## 🔗 Part 8: Flutter Integration Code

### Step 1: Add Unity Widget Package

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_unity_widget: ^2022.2.0
```

Run:
```bash
flutter pub get
```

### Step 2: Create Unity Service

Create: `lib/services/unity_service.dart`

```dart
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
  }
  
  void _handleUnityMessage(String jsonMessage) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonMessage);
      final message = UnityMessage.fromJson(data);
      _messageStream.add(message);
    } catch (e) {
      print('Failed to parse Unity message: $e');
    }
  }
  
  // Send messages to Unity
  void startBattle(String bossId, int difficulty) {
    final message = {
      'type': 'START_BATTLE',
      'data': {
        'bossId': bossId,
        'difficulty': difficulty,
      },
    };
    _sendMessage(message);
  }
  
  void playerAction(String action, int damage) {
    final message = {
      'type': 'PLAYER_ACTION',
      'data': {
        'action': action,
        'damage': damage,
      },
    };
    _sendMessage(message);
  }
  
  void bossAttack(int damage) {
    final message = {
      'type': 'BOSS_ATTACK',
      'data': {
        'damage': damage,
      },
    };
    _sendMessage(message);
  }
  
  void endBattle(bool victory) {
    final message = {
      'type': 'BATTLE_END',
      'data': {
        'victory': victory,
      },
    };
    _sendMessage(message);
  }
  
  void _sendMessage(Map<String, dynamic> message) {
    if (_controller == null) {
      print('Unity controller not ready');
      return;
    }
    
    final jsonMessage = jsonEncode(message);
    _controller!.postMessage(
      'FlutterBridge',
      'OnFlutterMessage',
      jsonMessage,
    );
  }
  
  void dispose() {
    _messageStream.close();
  }
}

class UnityMessage {
  final String type;
  final Map<String, dynamic> data;
  
  UnityMessage({required this.type, required this.data});
  
  factory UnityMessage.fromJson(Map<String, dynamic> json) {
    return UnityMessage(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
}
```

### Step 3: Create AR Boss Battle Screen

Create: `lib/screens/game/ar_boss_battle_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../../services/unity_service.dart';
import '../../services/mediapipe_service.dart';

class ARBossBattleScreen extends ConsumerStatefulWidget {
  const ARBossBattleScreen({super.key});

  @override
  ConsumerState<ARBossBattleScreen> createState() => _ARBossBattleScreenState();
}

class _ARBossBattleScreenState extends ConsumerState<ARBossBattleScreen> {
  final UnityService _unityService = UnityService();
  final MediaPipeService _mediaPipe = MediaPipeService();
  
  UnityWidgetController? _unityController;
  bool _isUnityReady = false;
  bool _isMonsterPlaced = false;
  bool _isBattleActive = false;
  
  // Game state
  int _playerHp = 100;
  int _playerMana = 100;
  int _bossHp = 200;
  final int _bossMaxHp = 200;
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
    _listenToUnityMessages();
  }
  
  Future<void> _initializeGame() async {
    try {
      await _mediaPipe.initialize();
      await _mediaPipe.initializeCamera();
    } catch (e) {
      _showError('Failed to initialize: $e');
    }
  }
  
  void _listenToUnityMessages() {
    _unityService.messages.listen((message) {
      switch (message.type) {
        case 'UNITY_READY':
          setState(() => _isUnityReady = true);
          break;
          
        case 'AR_PLANE_DETECTED':
          // Show instruction to place monster
          break;
          
        case 'MONSTER_PLACED':
          setState(() => _isMonsterPlaced = true);
          _showStartBattleDialog();
          break;
          
        case 'DAMAGE_DEALT':
          final damage = message.data['damage'] as int;
          final currentHp = message.data['currentHp'] as int;
          setState(() {
            _bossHp = currentHp;
          });
          break;
          
        case 'MONSTER_STAGGERED':
          _showMessage('Monster is stunned! Free hits!');
          break;
          
        case 'MONSTER_RECOVERED':
          _showMessage('Monster recovered!');
          break;
          
        case 'MONSTER_DEFEATED':
          _endBattle(victory: true);
          break;
      }
    });
  }
  
  void _onUnityCreated(UnityWidgetController controller) {
    _unityController = controller;
    _unityService.setController(controller);
  }
  
  void _startBattle() {
    setState(() => _isBattleActive = true);
    _unityService.startBattle('monster_001', 1);
    _startPoseDetection();
  }
  
  void _startPoseDetection() {
    // Integrate MediaPipe pose detection
    // When pose detected, call _performAction
  }
  
  void _performAction(PoseType poseType) {
    if (!_isBattleActive) return;
    
    int damage = 0;
    int manaCost = 0;
    String actionName = '';
    
    switch (poseType) {
      case PoseType.punch:
        damage = 10;
        manaCost = 10;
        actionName = 'PUNCH';
        break;
      case PoseType.uppercut:
        damage = 25;
        manaCost = 25;
        actionName = 'UPPERCUT';
        break;
      case PoseType.squat:
        manaCost = 15;
        actionName = 'SQUAT';
        break;
      case PoseType.plank:
        manaCost = 20;
        actionName = 'PLANK';
        break;
      case PoseType.highKnee:
        _playerMana = (_playerMana + 30).clamp(0, 100);
        actionName = 'HIGH_KNEE';
        setState(() {});
        return;
    }
    
    if (_playerMana < manaCost) {
      _showMessage('Not enough mana!');
      return;
    }
    
    setState(() {
      _playerMana = (_playerMana - manaCost).clamp(0, 100);
    });
    
    _unityService.playerAction(actionName, damage);
    
    // Boss counter-attack after 2 seconds
    if (damage > 0) {
      Future.delayed(const Duration(seconds: 2), _bossCounterAttack);
    }
  }
  
  void _bossCounterAttack() {
    if (!_isBattleActive) return;
    
    final damage = 15;
    setState(() {
      _playerHp = (_playerHp - damage).clamp(0, 100);
    });
    
    _unityService.bossAttack(damage);
    
    if (_playerHp <= 0) {
      _endBattle(victory: false);
    }
  }
  
  void _endBattle({required bool victory}) {
    setState(() => _isBattleActive = false);
    _unityService.endBattle(victory);
    
    // Navigate to results
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameResultsScreen(
          victory: victory,
          expEarned: victory ? 100 : 50,
          coinsEarned: victory ? 50 : 20,
          duration: const Duration(minutes: 5),
          posesUsed: {},
        ),
      ),
    );
  }
  
  void _showStartBattleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monster Placed!'),
        content: const Text('Ready to start battle?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startBattle();
            },
            child: const Text('START'),
          ),
        ],
      ),
    );
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
  
  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }
  
  @override
  void dispose() {
    _unityService.dispose();
    _mediaPipe.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Unity AR View
            UnityWidget(
              onUnityCreated: _onUnityCreated,
              onUnityMessage: (message) {
                // Already handled by service
              },
              fullscreen: false,
            ),
            
            // UI Overlay
            if (_isUnityReady) ...[
              // Boss HP Bar (top)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _buildBossHpBar(),
              ),
              
              // Player Stats (bottom)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildPlayerStats(),
              ),
              
              // Instructions
              if (!_isMonsterPlaced)
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Point camera at flat surface\nMonster will appear automatically',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
            ] else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBossHpBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'Training Boss',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _bossHp / _bossMaxHp,
            minHeight: 20,
            backgroundColor: Colors.grey,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          Text(
            '$_bossHp / $_bossMaxHp',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayerStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // HP
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: _playerHp / 100,
                  minHeight: 16,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_playerHp',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Mana
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: _playerMana / 100,
                  minHeight: 16,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_playerMana',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## ✅ Testing Checklist

### Unity Editor Testing

- [ ] Monster animates correctly (all 5 animations)
- [ ] VFX spawn and play correctly
- [ ] Scripts have no compilation errors
- [ ] AR Plane detection works in Play mode (limited)
- [ ] FlutterBridge logs messages correctly

### Device Testing (Required for AR)

- [ ] App installs on device
- [ ] AR camera opens
- [ ] Plane detection works on flat surface
- [ ] Monster places automatically
- [ ] Monster faces camera
- [ ] HP bars update correctly
- [ ] Hit effects play on attack
- [ ] Critical hits look different
- [ ] Monster staggers at 25% HP
- [ ] Death animation plays
- [ ] No crashes during gameplay
- [ ] Performance: 30+ FPS

---

## 🚀 Build & Deploy

### Android APK Build

```bash
cd fitness_game_app
flutter build apk --release
```

### iOS Build

```bash
cd fitness_game_app
flutter build ios --release
```

---

## ⚡ Performance Optimization Tips

### Unity Optimizations

1. **Quality Settings**
   - Single shadow quality level
   - Disable MSAA (mobile)
   - Lower shadow distance

2. **Particle Limits**
   - Max 200 particles total on screen
   - Use object pooling for VFX

3. **Model Optimization**
   - Keep monster under 10K polygons
   - 1K textures on low-end devices

4. **Script Optimization**
   - Cache component references
   - Avoid GetComponent in Update()
   - Use object pooling for damage numbers

### Flutter Optimizations

1. **Widget Rebuilds**
   - Use const constructors
   - Minimize setState() scope

2. **Memory**
   - Dispose controllers properly
   - Clear texture caches

---

## 📚 Troubleshooting

### Unity won't export
- Check all scenes are added in Build Settings
- Verify platform modules installed
- Check for script compilation errors

### Monster doesn't appear
- Check prefab is assigned in ARPlacementManager
- Verify AR permissions granted
- Test on well-lit flat surface

### VFX don't play
- Check prefabs assigned in MonsterController
- Verify particle systems have "Play On Awake" disabled
- Check VFX scripts for errors

### Flutter-Unity communication fails
- Check bridge scripts are in correct locations
- Verify JSON message format
- Check Unity logs for errors

---

## 🎉 Completion

When all steps are complete, you will have:
- ✅ Fully animated 3D monster
- ✅ AR placement working
- ✅ All VFX functional
- ✅ Flutter ↔ Unity communication
- ✅ Complete game loop

**Ready for Phase 2 testing and refinement!** 🚀
