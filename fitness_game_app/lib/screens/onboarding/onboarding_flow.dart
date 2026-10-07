import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data
  String? _fitnessGoal;
  int? _age;
  double? _weight;
  double? _height;
  String? _bodyShape;
  List<String> _equipment = [];
  List<String> _limitations = [];
  TimeOfDay? _preferredTime;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final userNotifier = ref.read(userDataProvider.notifier);
    final currentUser = ref.read(userDataProvider).value;

    if (currentUser == null) return;

    try {
      await userNotifier.updateUser({
        'fitness_goal': _fitnessGoal,
        'age': _age,
        'weight_kg': _weight,
        'height_cm': _height,
        'body_shape': _bodyShape,
        'available_equipment': _equipment,
        'physical_limitations': _limitations,
        'preferred_workout_time': _preferredTime != null
            ? '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}:00'
            : null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile completed! Welcome to Fitness Game!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup Profile (${_currentPage + 1}/7)'),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildFitnessGoalPage(),
          _buildPersonalInfoPage(),
          _buildEquipmentPage(),
          _buildTimePage(),
          _buildBodyShapePage(),
          _buildLimitationsPage(),
          _buildConfirmationPage(),
        ],
      ),
    );
  }

  Widget _buildFitnessGoalPage() {
    return _OnboardingPage(
      title: 'What\'s your fitness goal?',
      child: Column(
        children: [
          _buildGoalOption('Lose Weight', '🎯', Icons.trending_down),
          _buildGoalOption('Build Muscle', '💪', Icons.fitness_center),
          _buildGoalOption('Stay Fit', '🏃', Icons.directions_run),
          _buildGoalOption('Improve Flexibility', '🧘', Icons.self_improvement),
          _buildGoalOption('General Health', '❤️', Icons.favorite),
        ],
      ),
      onNext: _fitnessGoal != null ? _nextPage : null,
    );
  }

  Widget _buildGoalOption(String label, String emoji, IconData icon) {
    final isSelected = _fitnessGoal == label;
    return Card(
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 32)),
        title: Text(label),
        trailing: isSelected ? const Icon(Icons.check_circle) : null,
        onTap: () => setState(() => _fitnessGoal = label),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return _OnboardingPage(
      title: 'Tell us about yourself',
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
              suffixText: 'years',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _age = int.tryParse(value),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Weight',
              border: OutlineInputBorder(),
              suffixText: 'kg',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _weight = double.tryParse(value),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Height',
              border: OutlineInputBorder(),
              suffixText: 'cm',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _height = double.tryParse(value),
          ),
        ],
      ),
      onNext: _age != null && _weight != null && _height != null ? _nextPage : null,
    );
  }

  Widget _buildEquipmentPage() {
    final equipmentOptions = [
      'None',
      'Dumbbells',
      'Resistance Bands',
      'Yoga Mat',
      'Pull-up Bar',
      'Kettlebell',
    ];

    return _OnboardingPage(
      title: 'What equipment do you have?',
      child: Column(
        children: equipmentOptions
            .map((eq) => CheckboxListTile(
                  title: Text(eq),
                  value: _equipment.contains(eq),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _equipment.add(eq);
                      } else {
                        _equipment.remove(eq);
                      }
                    });
                  },
                ))
            .toList(),
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildTimePage() {
    return _OnboardingPage(
      title: 'When do you prefer to workout?',
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(
              _preferredTime != null
                  ? 'Selected: ${_preferredTime!.format(context)}'
                  : 'Tap to select time',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() => _preferredTime = time);
              }
            },
          ),
        ],
      ),
      onNext: _preferredTime != null ? _nextPage : null,
    );
  }

  Widget _buildBodyShapePage() {
    final bodyShapes = ['Slim', 'Average', 'Athletic', 'Heavy'];

    return _OnboardingPage(
      title: 'Select your body type',
      child: Column(
        children: bodyShapes
            .map((shape) => RadioListTile<String>(
                  title: Text(shape),
                  value: shape,
                  groupValue: _bodyShape,
                  onChanged: (value) => setState(() => _bodyShape = value),
                ))
            .toList(),
      ),
      onNext: _bodyShape != null ? _nextPage : null,
    );
  }

  Widget _buildLimitationsPage() {
    final limitationOptions = [
      'None',
      'Knee Issues',
      'Back Pain',
      'Shoulder Problems',
      'Heart Condition',
      'Other',
    ];

    return _OnboardingPage(
      title: 'Any physical limitations?',
      child: Column(
        children: limitationOptions
            .map((lim) => CheckboxListTile(
                  title: Text(lim),
                  value: _limitations.contains(lim),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _limitations.add(lim);
                      } else {
                        _limitations.remove(lim);
                      }
                    });
                  },
                ))
            .toList(),
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildConfirmationPage() {
    return _OnboardingPage(
      title: 'Confirm Your Profile',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Goal', _fitnessGoal ?? ''),
            _buildInfoRow('Age', '$_age years'),
            _buildInfoRow('Weight', '$_weight kg'),
            _buildInfoRow('Height', '$_height cm'),
            _buildInfoRow('Body Type', _bodyShape ?? ''),
            _buildInfoRow('Equipment', _equipment.join(', ')),
            _buildInfoRow('Limitations', _limitations.isEmpty ? 'None' : _limitations.join(', ')),
            _buildInfoRow('Preferred Time', _preferredTime?.format(context) ?? ''),
            const SizedBox(height: 24),
            const Text(
              'AI will personalize workouts based on your profile',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      onNext: _completeOnboarding,
      nextLabel: 'Complete',
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onNext;
  final String nextLabel;

  const _OnboardingPage({
    required this.title,
    required this.child,
    this.onNext,
    this.nextLabel = 'Next',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(child: child),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(nextLabel),
          ),
        ],
      ),
    );
  }
}
