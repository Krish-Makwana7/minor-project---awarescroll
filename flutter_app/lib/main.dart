// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AwareScrollApp());
}

class AwareScrollApp extends StatelessWidget {
  const AwareScrollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AwareScroll',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A5BFF),
          primary: const Color(0xFF3A5BFF),
        ),
      ),
      home: const RestrictionHomeScreen(),
    );
  }
}

class RestrictionHomeScreen extends StatefulWidget {
  const RestrictionHomeScreen({super.key});

  @override
  State<RestrictionHomeScreen> createState() => _RestrictionHomeScreenState();
}

class _RestrictionHomeScreenState extends State<RestrictionHomeScreen> {
  static const MethodChannel _channel = MethodChannel('com.awarescroll/restriction');

  // Scene 1 State: Selected app & time limit
  String _selectedAppName = 'YouTube';
  String _selectedPackage = 'com.google.android.youtube';
  int _limitMinutes = 5;
  int _limitSeconds = 300;

  bool _isRestricting = false;
  int _elapsedSeconds = 0;
  bool _isTargetInForeground = false;
  Timer? _statusTimer;

  // Permissions state
  bool _hasUsage = false;
  bool _hasOverlay = false;
  bool _hasAccessibility = false;

  final List<Map<String, dynamic>> _targetApps = [
    {
      'name': 'YouTube',
      'package': 'com.google.android.youtube',
      'icon': Icons.play_circle_fill,
      'color': Colors.red,
    },
    {
      'name': 'Instagram',
      'package': 'com.instagram.android',
      'icon': Icons.camera_alt,
      'color': Colors.purple,
    },
    {
      'name': 'Snapchat',
      'package': 'com.snapchat.android',
      'icon': Icons.chat_bubble,
      'color': Colors.amber,
    },
    {
      'name': 'Facebook',
      'package': 'com.facebook.katana',
      'icon': Icons.facebook,
      'color': Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _refreshStatus();

    // Poll status every 1 second when active
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _checkPermissions();
        _refreshStatus();
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    try {
      final res = await _channel.invokeMethod<Map>('checkPermissions');
      if (res != null && mounted) {
        setState(() {
          _hasUsage = res['usage'] == true;
          _hasOverlay = res['overlay'] == true;
          _hasAccessibility = res['accessibility'] == true;
        });
      }
    } catch (_) {}
  }

  Future<void> _refreshStatus() async {
    try {
      final res = await _channel.invokeMethod<Map>('getStatus');
      if (res != null && mounted) {
        setState(() {
          _isRestricting = res['isRunning'] == true;
          _elapsedSeconds = (res['elapsedSeconds'] as int?) ?? 0;
          _isTargetInForeground = res['isTargetInForeground'] == true;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleRestriction() async {
    if (_isRestricting) {
      try {
        await _channel.invokeMethod('stopRestriction');
      } catch (_) {}
      setState(() {
        _isRestricting = false;
        _elapsedSeconds = 0;
        _isTargetInForeground = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AwareScroll restriction stopped.')),
        );
      }
    } else {
      // Permission sanity check
      if (!_hasAccessibility && !_hasUsage) {
        _showPermissionRequiredDialog();
        return;
      }

      // Start restriction
      try {
        await _channel.invokeMethod('startRestriction', {
          'appName': _selectedAppName,
          'packageName': _selectedPackage,
          'minutes': _limitMinutes,
          'seconds': _limitSeconds,
        });
      } catch (_) {}
      setState(() {
        _isRestricting = true;
        _elapsedSeconds = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF00B894),
            content: Text('AwareScroll Active! Guarding $_selectedAppName for ${_limitSeconds >= 60 ? "$_limitMinutes min" : "$_limitSeconds sec"}.'),
          ),
        );
      }
    }
  }

  void _showPermissionRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFE5484D)),
            SizedBox(width: 8),
            Text('Permissions Required', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(
          'Android will not allow AwareScroll to see when $_selectedAppName is running unless you enable:\n\n'
          '1. Accessibility Service (Recommended for instant blocking)\n'
          '2. Usage Access\n'
          '3. Display Over Other Apps\n\n'
          'Please enable them to begin tracking.',
          style: const TextStyle(fontSize: 13, height: 1.3),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openSettings('openAccessibilitySettings');
            },
            child: const Text('Open Accessibility'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A5BFF)),
            onPressed: () {
              Navigator.pop(ctx);
              _openSettings('openUsageSettings');
            },
            child: const Text('Open Usage Access', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openSettings(String method) {
    try {
      _channel.invokeMethod(method);
    } catch (_) {}
  }

  void _testRestrictionScreen() {
    try {
      _channel.invokeMethod('testBlocker');
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RestrictionModal(
        appName: _selectedAppName,
        limitMinutes: _limitMinutes,
        onCloseApp: () {
          Navigator.pop(ctx);
          SystemNavigator.pop();
        },
        onContinueGranted: (extensionMin) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF00B894),
              content: Text('$extensionMin-minute extension granted. Use it mindfully!'),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissionsAllGranted = _hasUsage && _hasOverlay && _hasAccessibility;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AwareScroll',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF14152B)),
                ),
                Text(
                  'Social Media App Restriction & Habit Control',
                  style: TextStyle(fontSize: 10, color: Color(0xFF6B6F8C)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Warning Banner if Permissions are completely missing
          if (!_hasAccessibility && !_hasUsage) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5484D).withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFE5484D), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Detection Permissions Required',
                        style: TextStyle(color: Color(0xFFE5484D), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'To detect when you are using $_selectedAppName, Android requires you to turn on Accessibility or Usage Access.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF14152B)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5484D),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () => _openSettings('openAccessibilitySettings'),
                          child: const Text('Enable Accessibility', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A5BFF),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () => _openSettings('openUsageSettings'),
                          child: const Text('Enable Usage Access', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Active Monitoring Live Card
          if (_isRestricting) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF14152B),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3A5BFF).withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _isTargetInForeground ? const Color(0xFF00B894) : Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isTargetInForeground ? 'ACTIVE: $_selectedAppName IN FOREGROUND' : 'GUARDING: WAITING FOR $_selectedAppName',
                            style: TextStyle(
                              color: _isTargetInForeground ? const Color(0xFF00B894) : Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Limit: ${_limitSeconds >= 60 ? "$_limitMinutes m" : "$_limitSeconds s"}',
                        style: const TextStyle(color: Color(0xFFFF9F43), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Guarding $_selectedAppName',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isTargetInForeground
                        ? 'Now detecting $_selectedAppName! Time is actively accumulating.'
                        : 'Open $_selectedAppName normally on your phone. AwareScroll will track and restrict access when the limit is reached.',
                    style: const TextStyle(color: Color(0xFFA0A5BD), fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_elapsedSeconds / _limitSeconds).clamp(0.0, 1.0),
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isTargetInForeground ? const Color(0xFF00B894) : const Color(0xFF3A5BFF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Elapsed: ${_elapsedSeconds ~/ 60}m ${_elapsedSeconds % 60}s',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        'Limit: ${_limitSeconds ~/ 60}m ${_limitSeconds % 60}s',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Step 1: Select Application
          const Text('1. Select Application to Restrict', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Choose the app where scrolling habits need to be controlled.', style: TextStyle(fontSize: 12, color: Color(0xFF6B6F8C))),
          const SizedBox(height: 10),

          ..._targetApps.map((app) {
            final isSelected = app['name'] == _selectedAppName;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: isSelected ? 1.5 : 0.2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF3A5BFF) : const Color(0xFFE2E4F0),
                  width: isSelected ? 1.8 : 1,
                ),
              ),
              color: Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (app['color'] as Color).withOpacity(0.12),
                  child: Icon(app['icon'] as IconData, color: app['color'] as Color, size: 22),
                ),
                title: Text(app['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(app['package'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF6B6F8C))),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF3A5BFF))
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () {
                  setState(() {
                    _selectedAppName = app['name'] as String;
                    _selectedPackage = app['package'] as String;
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 16),

          // Step 2: Set Time Limit
          const Text('2. Set Usage Time Limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('The restriction screen appears the moment you reach this limit.', style: TextStyle(fontSize: 12, color: Color(0xFF6B6F8C))),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              {'label': '30s (Fast Test)', 'min': 1, 'sec': 30},
              {'label': '1 Min (Test)', 'min': 1, 'sec': 60},
              {'label': '5 Min (Default)', 'min': 5, 'sec': 300},
              {'label': '10 Mins', 'min': 10, 'sec': 600},
              {'label': '15 Mins', 'min': 15, 'sec': 900},
            ].map((item) {
              final sec = item['sec'] as int;
              final isSel = sec == _limitSeconds;
              return ChoiceChip(
                label: Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSel ? Colors.white : const Color(0xFF14152B),
                  ),
                ),
                selected: isSel,
                selectedColor: const Color(0xFF3A5BFF),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSel ? const Color(0xFF3A5BFF) : const Color(0xFFE2E4F0)),
                ),
                onSelected: (_) {
                  setState(() {
                    _limitMinutes = item['min'] as int;
                    _limitSeconds = item['sec'] as int;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Step 3: Required Android Permissions
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E4F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Android System Permissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: permissionsAllGranted
                            ? const Color(0xFF00B894).withOpacity(0.12)
                            : const Color(0xFFFF9F43).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        permissionsAllGranted ? 'READY' : 'SETUP NEEDED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: permissionsAllGranted ? const Color(0xFF00B894) : const Color(0xFFFF9F43),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Android requires Accessibility & Usage access so AwareScroll can track YouTube/Instagram and show the restriction screen over it.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B6F8C)),
                ),
                const SizedBox(height: 12),

                // 1. Accessibility Service
                _buildPermissionRow(
                  title: 'Accessibility Service (Required for Blocker)',
                  isGranted: _hasAccessibility,
                  onEnable: () => _openSettings('openAccessibilitySettings'),
                ),

                // 2. Display Over Other Apps
                _buildPermissionRow(
                  title: 'Display Over Other Apps (Overlay Window)',
                  isGranted: _hasOverlay,
                  onEnable: () => _openSettings('openOverlaySettings'),
                ),

                // 3. Usage Access
                _buildPermissionRow(
                  title: 'Usage Access (Foreground Time Tracker)',
                  isGranted: _hasUsage,
                  onEnable: () => _openSettings('openUsageSettings'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Primary Action: ACTIVATE / STOP
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRestricting ? const Color(0xFFE5484D) : const Color(0xFF3A5BFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 1,
              ),
              onPressed: _toggleRestriction,
              child: Text(
                _isRestricting
                    ? 'STOP RESTRICTION'
                    : 'ACTIVATE RESTRICTION FOR $_selectedAppName (${_limitSeconds >= 60 ? "$_limitMinutes MIN" : "$_limitSeconds SEC"})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Test Blocker Directly
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: Color(0xFFE2E4F0)),
              ),
              icon: const Icon(Icons.preview, size: 18, color: Color(0xFF3A5BFF)),
              label: const Text(
                'Test Restriction Screen Now',
                style: TextStyle(color: Color(0xFF3A5BFF), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: _testRestrictionScreen,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPermissionRow({
    required String title,
    required bool isGranted,
    required VoidCallback onEnable,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isGranted ? Icons.check_circle : Icons.error_outline,
                size: 16,
                color: isGranted ? const Color(0xFF00B894) : const Color(0xFFFF9F43),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isGranted ? FontWeight.w500 : FontWeight.bold,
                  color: const Color(0xFF14152B),
                ),
              ),
            ],
          ),
          if (!isGranted)
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onEnable,
              child: const Text('Enable', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// SCENE 3 & 4: RESTRICTION SCREEN & FOLLOW-UP
// ==========================================
class RestrictionModal extends StatefulWidget {
  final String appName;
  final int limitMinutes;
  final VoidCallback onCloseApp;
  final Function(int extensionMin) onContinueGranted;

  const RestrictionModal({
    super.key,
    required this.appName,
    required this.limitMinutes,
    required this.onCloseApp,
    required this.onContinueGranted,
  });

  @override
  State<RestrictionModal> createState() => _RestrictionModalState();
}

class _RestrictionModalState extends State<RestrictionModal> {
  int _step = 0; // 0: Scene 3 (Close vs Continue), 1: Scene 4 (Follow-up Question)
  String _selectedReason = 'Interesting content';

  final List<String> _reasons = [
    'Interesting content',
    'Boredom',
    'Stress / mood',
    'Notifications / messages',
    'Habitual scrolling',
    'Unfinished original purpose',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        color: Color(0xFF14152B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _step == 0 ? _buildScene3Expiry() : _buildScene4FollowUp(),
      ),
    );
  }

  // Scene 3: "Your time is up! What would you like to do?"
  Widget _buildScene3Expiry() {
    return Column(
      key: const ValueKey(0),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9F43).withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '${widget.limitMinutes.toString().padLeft(2, '0')}:00 LIMIT REACHED',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF9F43), fontSize: 11),
          ),
        ),
        const SizedBox(height: 18),

        // Main Question
        const Text(
          'Your time is up! What would you like to do?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.25,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        Text(
          'You configured a ${widget.limitMinutes}-minute limit for ${widget.appName}.\nTake a mindful pause before deciding.',
          style: const TextStyle(fontSize: 13, color: Color(0xFFA0A5BD), height: 1.3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // Option 1: Close App
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A5BFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: widget.onCloseApp,
            child: Text(
              'Close ${widget.appName}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Option 2: Continue
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF1C1E3A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: const BorderSide(color: Color(0xFF2E335B)),
            ),
            onPressed: () {
              setState(() => _step = 1);
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: Color(0xFFCBD0E2), fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // Scene 4: Follow-up question asking user to consciously reconsider
  Widget _buildScene4FollowUp() {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00B894).withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'CONSCIOUS RECONSIDERATION',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00B894), fontSize: 10),
            ),
          ),
        ),
        const SizedBox(height: 14),

        const Center(
          child: Text(
            'What most influenced your decision to continue scrolling?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.25),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),

        const Center(
          child: Text(
            'Please select an answer to confirm your continuation.',
            style: TextStyle(fontSize: 12, color: Color(0xFFA0A5BD)),
          ),
        ),
        const SizedBox(height: 16),

        ..._reasons.map((reason) {
          final isSelected = reason == _selectedReason;
          return GestureDetector(
            onTap: () => setState(() => _selectedReason = reason),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF29357A) : const Color(0xFF1C1E3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3A5BFF) : const Color(0xFF252847),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? const Color(0xFF3A5BFF) : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    reason,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : const Color(0xFF8E94B3),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B894),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              widget.onContinueGranted(5);
            },
            child: const Text(
              'Confirm & Continue (5 min extension)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
