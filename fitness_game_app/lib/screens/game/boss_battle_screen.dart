import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../services/mediapipe_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import 'game_results_screen.dart';

// Boss state
class BossState {
  final int maxHp;
  final int currentHp;
  final int attackPower;
  final String name;
  final String imageUrl;

  BossState({
    required this.maxHp,
    required this.currentHp,
    required this.attackPower,
    required this.name,
    required this.imageUrl,
  });

  BossState copyWith({int? currentHp}) {
    return BossState(
      maxHp: maxHp,
      currentHp: currentHp ?? this.currentHp,
      attackPower: attackPower,
      name: name,
      imageUrl: imageUrl,
    );
  }

  bool get isDefeated => currentHp <= 0;
  double get hpPercentage => currentHp / maxHp;
}

// Player state
class PlayerState {
  final int maxHp;
  final int currentHp;
  final int maxMana;
  final int currentMana;

  PlayerState({
    this.maxHp = 100,
    this.currentHp = 100,
    this.maxMana = 100,
    this.currentMana = 100,
  });

  PlayerState copyWith({
    int? currentHp,
    int? currentMana,
  }) {
    return PlayerState(
      maxHp: maxHp,
      currentHp: currentHp ?? this.currentHp,
      maxMana: maxMana,
      currentMana: currentMana ?? this.currentMana,
    );
  }

  bool get isDefeated => currentHp <= 0;
  double get hpPercentage => currentHp / maxHp;
  double get manaPercentage => currentMana / maxMana;
}

class BossBattleScreen extends ConsumerStatefulWidget {
  const BossBattleScreen({super.key});

  @override
  ConsumerState<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends ConsumerState<BossBattleScreen> {
  final MediaPipeService _mediaPipe = MediaPipeService();
  bool _isInitialized = false;
  bool _isBattleActive = false;

  late BossState _boss;
  late PlayerState _player;

  DateTime _battleStartTime = DateTime.now();
  Map<String, int> _posesUsed = {};
  Map<PoseType, DateTime> _cooldowns = {};

  @override
  void initState() {
    super.initState();
    _initializeBattle();
  }

  Future<void> _initializeBattle() async {
    try {
      await _mediaPipe.initialize();
      await _mediaPipe.initializeCamera();

      setState(() {
        _isInitialized = true;
        _boss = BossState(
          maxHp: 200,
          currentHp: 200,
          attackPower: 15,
          name: 'Training Boss',
          imageUrl: '',
        );
        _player = PlayerState();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize: $e')),
        );
      }
    }
  }

  void _startBattle() {
    setState(() {
      _isBattleActive = true;
      _battleStartTime = DateTime.now();
    });
    _startPoseDetection();
  }

  void _startPoseDetection() {
    // TODO: Implement continuous pose detection
    // This would use MediaPipe to continuously detect poses
    // and trigger actions based on detected poses
  }

  void _performAction(PoseType poseType) {
    if (!_isBattleActive) return;

    // Check cooldown
    if (_cooldowns.containsKey(poseType)) {
      final elapsed = DateTime.now().difference(_cooldowns[poseType]!);
      final cooldownDuration = _getPoseCooldown(poseType);
      if (elapsed.inSeconds < cooldownDuration) {
        return;
      }
    }

    // Check mana cost
    final manaCost = _getPoseManaCost(poseType);
    if (_player.currentMana < manaCost) {
      _showMessage('Not enough mana!');
      return;
    }

    setState(() {
      // Deduct mana
      _player = _player.copyWith(
        currentMana: (_player.currentMana - manaCost).clamp(0, 100),
      );

      // Perform action
      switch (poseType) {
        case PoseType.punch:
          _boss = _boss.copyWith(currentHp: (_boss.currentHp - 10).clamp(0, _boss.maxHp));
          break;
        case PoseType.uppercut:
          _boss = _boss.copyWith(currentHp: (_boss.currentHp - 25).clamp(0, _boss.maxHp));
          _showMessage('Critical hit!');
          break;
        case PoseType.squat:
          _showMessage('Dodge!');
          break;
        case PoseType.plank:
          _showMessage('Shield activated!');
          break;
        case PoseType.highKnee:
          _player = _player.copyWith(
            currentMana: (_player.currentMana + 30).clamp(0, 100),
          );
          break;
        default:
          break;
      }

      // Set cooldown
      _cooldowns[poseType] = DateTime.now();

      // Track pose usage
      _posesUsed[poseType.toString()] = (_posesUsed[poseType.toString()] ?? 0) + 1;
    });

    // Check if boss is defeated
    if (_boss.isDefeated) {
      _endBattle(victory: true);
    } else {
      // Boss counter-attack
      Future.delayed(const Duration(seconds: 2), _bossAttack);
    }
  }

  void _bossAttack() {
    if (!_isBattleActive || _boss.isDefeated) return;

    setState(() {
      _player = _player.copyWith(
        currentHp: (_player.currentHp - _boss.attackPower).clamp(0, 100),
      );
    });

    if (_player.isDefeated) {
      _endBattle(victory: false);
    }
  }

  int _getPoseManaCost(PoseType poseType) {
    switch (poseType) {
      case PoseType.punch:
        return 10;
      case PoseType.uppercut:
        return 25;
      case PoseType.squat:
        return 15;
      case PoseType.plank:
        return 20;
      case PoseType.highKnee:
        return 0;
      default:
        return 0;
    }
  }

  int _getPoseCooldown(PoseType poseType) {
    switch (poseType) {
      case PoseType.punch:
        return 0;
      case PoseType.uppercut:
        return 2;
      case PoseType.squat:
        return 1;
      case PoseType.plank:
        return 3;
      case PoseType.highKnee:
        return 1;
      default:
        return 0;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _endBattle({required bool victory}) async {
    setState(() {
      _isBattleActive = false;
    });

    final duration = DateTime.now().difference(_battleStartTime);
    final totalPoses = _posesUsed.values.fold(0, (sum, count) => sum + count);

    // Calculate rewards
    int expEarned = victory ? 100 : 50;
    int coinsEarned = victory ? 50 : 20;

    // Speed bonus
    if (victory && duration.inMinutes < 5) {
      expEarned += 20;
    }

    // Variety bonus
    if (totalPoses >= 20) {
      expEarned += 15;
    }

    // Save session to database
    final userData = ref.read(userDataProvider).value;
    if (userData != null) {
      final db = DatabaseService();
      await db.saveWorkoutSession(
        userId: userData.id,
        sessionType: 'game',
        expEarned: expEarned,
        coinsEarned: coinsEarned,
        posesCompleted: _posesUsed,
        bossDefeated: victory,
      );

      // Update user stats
      final updatedUser = userData.addExp(expEarned).addCoins(coinsEarned);
      await ref.read(userDataProvider.notifier).updateUser({
        'exp': updatedUser.exp,
        'coins': updatedUser.coins,
        'level': updatedUser.level,
      });

      // Check for new achievements
      final newAchievements = await db.checkAchievements(userData.id);

      // Reload user data
      await ref.read(userDataProvider.notifier).loadUserData(userData.firebaseUid);
    }

    // Navigate to results
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameResultsScreen(
            victory: victory,
            expEarned: expEarned,
            coinsEarned: coinsEarned,
            duration: duration,
            posesUsed: _posesUsed,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mediaPipe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing camera and pose detection...'),
            ],
          ),
        ),
      );
    }

    if (!_isBattleActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('Boss Battle')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_kabaddi, size: 100),
              const SizedBox(height: 24),
              Text(
                _boss.name,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Get ready to battle!'),
              const SizedBox(height: 8),
              const Text('Use exercise poses to attack'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _startBattle,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('START BATTLE', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            if (_mediaPipe.cameraController != null)
              SizedBox.expand(
                child: CameraPreview(_mediaPipe.cameraController!),
              ),

            // UI Overlay
            Column(
              children: [
                // Boss HP
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black54,
                  child: Column(
                    children: [
                      Text(
                        _boss.name,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _boss.hpPercentage,
                        minHeight: 20,
                        backgroundColor: Colors.grey,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                      Text(
                        '${_boss.currentHp} / ${_boss.maxHp}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Player stats
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black54,
                  child: Column(
                    children: [
                      // HP
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _player.hpPercentage,
                              minHeight: 16,
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_player.currentHp}',
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
                              value: _player.manaPercentage,
                              minHeight: 16,
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_player.currentMana}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Debug buttons (for testing)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black54,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _performAction(PoseType.punch),
                        child: const Text('Punch'),
                      ),
                      ElevatedButton(
                        onPressed: () => _performAction(PoseType.uppercut),
                        child: const Text('Uppercut'),
                      ),
                      ElevatedButton(
                        onPressed: () => _performAction(PoseType.squat),
                        child: const Text('Squat'),
                      ),
                      ElevatedButton(
                        onPressed: () => _performAction(PoseType.plank),
                        child: const Text('Plank'),
                      ),
                      ElevatedButton(
                        onPressed: () => _performAction(PoseType.highKnee),
                        child: const Text('High Knee'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
