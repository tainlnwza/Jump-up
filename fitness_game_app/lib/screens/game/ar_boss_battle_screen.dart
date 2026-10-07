// Flutter Screen: ARBossBattleScreen
// Location: lib/screens/game/ar_boss_battle_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/unity_service.dart';
import '../../services/mediapipe_service.dart';
import '../../models/boss.dart';
import 'dart:async';

class ARBossBattleScreen extends ConsumerStatefulWidget {
  final Boss boss;

  const ARBossBattleScreen({
    Key? key,
    required this.boss,
  }) : super(key: key);

  @override
  ConsumerState<ARBossBattleScreen> createState() => _ARBossBattleScreenState();
}

class _ARBossBattleScreenState extends ConsumerState<ARBossBattleScreen> {
  final UnityService _unityService = UnityService();
  UnityWidgetController? _unityController;
  StreamSubscription? _unityMessageSubscription;
  StreamSubscription? _mediaPipeSubscription;

  // Game state
  bool _isUnityReady = false;
  bool _isMonsterPlaced = false;
  bool _isBattleStarted = false;
  int _playerHp = 100;
  int _playerMaxHp = 100;
  int _playerMana = 50;
  int _playerMaxMana = 50;
  int _bossHp = 200;
  int _bossMaxHp = 200;
  bool _isStaggered = false;
  bool _isBattleEnded = false;
  String _currentAction = 'Ready';

  // Cooldowns
  bool _canAttack = true;
  bool _canUseSkill = true;
  Timer? _attackCooldownTimer;
  Timer? _skillCooldownTimer;
  Timer? _bossAttackTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to Unity messages
    _unityMessageSubscription = _unityService.messages.listen((message) {
      _handleUnityMessage(message);
    });

    // Listen to MediaPipe pose detection
    final mediaPipeService = ref.read(mediaPipeServiceProvider);
    _mediaPipeSubscription = mediaPipeService.poseStream.listen((pose) {
      if (_isBattleStarted && !_isBattleEnded) {
        _handlePoseDetection(pose);
      }
    });
  }

  void _handleUnityMessage(UnityMessage message) {
    setState(() {
      switch (message.type) {
        case 'UNITY_READY':
          _isUnityReady = true;
          print('[Flutter] Unity is ready');
          break;

        case 'AR_PLANE_DETECTED':
          print('[Flutter] AR plane detected');
          break;

        case 'MONSTER_PLACED':
          _isMonsterPlaced = true;
          print('[Flutter] Monster placed');
          // Auto-start battle after 1 second
          Future.delayed(Duration(seconds: 1), () {
            _startBattle();
          });
          break;

        case 'BATTLE_STARTED':
          _isBattleStarted = true;
          _startBossAttackTimer();
          print('[Flutter] Battle started');
          break;

        case 'DAMAGE_DEALT':
          final damage = message.data['damage'] as int;
          final currentHp = message.data['currentHp'] as int;
          final isCritical = message.data['isCritical'] as bool;

          _bossHp = currentHp;
          _currentAction = isCritical ? 'Critical Hit! -$damage' : 'Hit! -$damage';

          print('[Flutter] Boss HP: $_bossHp');

          if (_bossHp <= 0) {
            _onVictory();
          }
          break;

        case 'MONSTER_STAGGERED':
          _isStaggered = true;
          _currentAction = 'Boss Staggered! Bonus Time!';
          print('[Flutter] Boss staggered');
          break;

        case 'MONSTER_RECOVERED':
          _isStaggered = false;
          _currentAction = 'Boss Recovered!';
          print('[Flutter] Boss recovered');
          break;

        case 'MONSTER_DEFEATED':
          _onVictory();
          break;

        case 'ATTACK_HIT':
          // Boss attack lands, player takes damage
          _takeDamage(20);
          break;

        case 'ANIMATION_COMPLETE':
          print('[Flutter] Animation complete: ${message.data['animation']}');
          break;

        default:
          print('[Flutter] Unknown Unity message: ${message.type}');
      }
    });
  }

  void _handlePoseDetection(PoseData pose) {
    if (!_canAttack || _isBattleEnded) return;

    // Punch detection
    if (pose.isPunching && _canAttack) {
      _performAttack('PUNCH', 20, 10);
    }
    // Uppercut detection (critical hit)
    else if (pose.isUppercut && _canAttack) {
      _performAttack('UPPERCUT', 35, 15);
    }
    // Defensive poses
    else if (pose.isSquatting) {
      _performDefense('SQUAT');
    }
    else if (pose.isPlank) {
      _performDefense('PLANK');
    }
  }

  void _performAttack(String action, int damage, int manaCost) {
    if (_playerMana < manaCost) {
      _showMessage('Not enough mana!');
      return;
    }

    setState(() {
      _playerMana -= manaCost;
      _currentAction = action;
      _canAttack = false;
    });

    // Send to Unity
    _unityService.playerAction(action, damage);

    // Cooldown
    _attackCooldownTimer?.cancel();
    _attackCooldownTimer = Timer(Duration(milliseconds: 1500), () {
      setState(() {
        _canAttack = true;
      });
    });
  }

  void _performDefense(String action) {
    setState(() {
      _currentAction = 'Defending: $action';
    });

    // Reduce next boss attack damage
    // Handled by game logic
  }

  void _takeDamage(int damage) {
    setState(() {
      _playerHp -= damage;
      _playerHp = _playerHp.clamp(0, _playerMaxHp);
      _currentAction = 'Hit! -$damage HP';
    });

    if (_playerHp <= 0) {
      _onDefeat();
    }
  }

  void _startBattle() {
    _unityService.startBattle(widget.boss.id, widget.boss.difficulty);
  }

  void _startBossAttackTimer() {
    _bossAttackTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!_isBattleEnded && !_isStaggered) {
        _unityService.bossAttack(20);
        setState(() {
          _currentAction = 'Boss Attacking!';
        });
      }
    });
  }

  void _onVictory() {
    if (_isBattleEnded) return;

    setState(() {
      _isBattleEnded = true;
      _currentAction = 'Victory!';
    });

    _bossAttackTimer?.cancel();
    _unityService.endBattle(true);

    Future.delayed(Duration(seconds: 2), () {
      _navigateToResults(true);
    });
  }

  void _onDefeat() {
    if (_isBattleEnded) return;

    setState(() {
      _isBattleEnded = true;
      _currentAction = 'Defeated...';
    });

    _bossAttackTimer?.cancel();
    _unityService.endBattle(false);

    Future.delayed(Duration(seconds: 2), () {
      _navigateToResults(false);
    });
  }

  void _navigateToResults(bool victory) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BattleResultScreen(
          victory: victory,
          boss: widget.boss,
          playerHp: _playerHp,
          playerMaxHp: _playerMaxHp,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 1)),
    );
  }

  void _onUnityCreated(UnityWidgetController controller) {
    _unityController = controller;
    _unityService.setController(controller);
    print('[Flutter] Unity widget created');
  }

  void _onUnitySceneLoaded(SceneLoaded scene) {
    print('[Flutter] Unity scene loaded: ${scene.name}');
  }

  @override
  void dispose() {
    _attackCooldownTimer?.cancel();
    _skillCooldownTimer?.cancel();
    _bossAttackTimer?.cancel();
    _unityMessageSubscription?.cancel();
    _mediaPipeSubscription?.cancel();
    _unityService.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Unity AR View (Fullscreen)
          UnityWidget(
            onUnityCreated: _onUnityCreated,
            onUnitySceneLoaded: _onUnitySceneLoaded,
            fullscreen: false,
          ),

          // UI Overlay
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Spacer(),
                if (!_isMonsterPlaced) _buildPlacementGuide(),
                if (_isBattleStarted) _buildActionText(),
                SizedBox(height: 20),
                if (_isBattleStarted) _buildPlayerStats(),
                SizedBox(height: 20),
              ],
            ),
          ),

          // Exit button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => _showExitDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Boss HP Bar
          _buildHealthBar(
            label: widget.boss.name,
            current: _bossHp,
            max: _bossMaxHp,
            color: Colors.red,
          ),

          if (_isStaggered)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⚡ BONUS TIME ⚡',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthBar({
    required String label,
    required int current,
    required int max,
    required Color color,
  }) {
    double percentage = current / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 4),
                ],
              ),
            ),
            Text(
              '$current / $max',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 4),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlacementGuide() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.center_focus_weak, color: Colors.white, size: 48),
          SizedBox(height: 12),
          Text(
            'Point camera at flat surface',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Move your phone slowly to detect the ground',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionText() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _currentAction,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPlayerStats() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Player HP
          _buildHealthBar(
            label: 'Your HP',
            current: _playerHp,
            max: _playerMaxHp,
            color: Colors.green,
          ),
          SizedBox(height: 12),
          // Player Mana
          _buildManaBar(),
        ],
      ),
    );
  }

  Widget _buildManaBar() {
    double percentage = _playerMana / _playerMaxMana;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mana',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$_playerMana / $_playerMaxMana',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Battle?'),
        content: Text('Progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _unityService.endBattle(false);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit battle
            },
            child: Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Placeholder for BattleResultScreen
class BattleResultScreen extends StatelessWidget {
  final bool victory;
  final Boss boss;
  final int playerHp;
  final int playerMaxHp;

  const BattleResultScreen({
    Key? key,
    required this.victory,
    required this.boss,
    required this.playerHp,
    required this.playerMaxHp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              victory ? '🎉 VICTORY!' : '💀 DEFEATED',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('HP Remaining: $playerHp / $playerMaxHp'),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for PoseData
class PoseData {
  final bool isPunching;
  final bool isUppercut;
  final bool isSquatting;
  final bool isPlank;

  PoseData({
    this.isPunching = false,
    this.isUppercut = false,
    this.isSquatting = false,
    this.isPlank = false,
  });
}
