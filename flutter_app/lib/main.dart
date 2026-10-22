// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0D13),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE1306C),
          secondary: Color(0xFF833AB4),
          surface: Color(0xFF151824),
          background: Color(0xFF0B0D13),
        ),
        fontFamily: 'Roboto',
      ),
      home: const AwareScrollHomeScreen(),
    );
  }
}

class AwareScrollHomeScreen extends StatefulWidget {
  const AwareScrollHomeScreen({super.key});

  @override
  State<AwareScrollHomeScreen> createState() => _AwareScrollHomeScreenState();
}

class _AwareScrollHomeScreenState extends State<AwareScrollHomeScreen> with SingleTickerProviderStateMixin {
  static const MethodChannel _channel = MethodChannel('com.awarescroll/restriction');

  // Instagram target configuration
  static const String targetAppName = 'Instagram';
  static const String targetPackage = 'com.instagram.android';

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

  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _limitOptions = [
    {'label': '30s (Test)', 'min': 1, 'sec': 30},
    {'label': '1 Min', 'min': 1, 'sec': 60},
    {'label': '5 Min', 'min': 5, 'sec': 300},
    {'label': '10 Min', 'min': 10, 'sec': 600},
    {'label': '15 Min', 'min': 15, 'sec': 900},
    {'label': '30 Min', 'min': 30, 'sec': 1800},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _checkPermissions();
    _refreshStatus();

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
    _pulseController.dispose();
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
          const SnackBar(
            backgroundColor: Color(0xFF1F2333),
            content: Text('AwareScroll Guard deactivated.'),
          ),
        );
      }
    } else {
      if (!_hasAccessibility && !_hasUsage) {
        _showPermissionRequiredDialog();
        return;
      }

      try {
        await _channel.invokeMethod('startRestriction', {
          'appName': targetAppName,
          'packageName': targetPackage,
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
            backgroundColor: const Color(0xFF00E676),
            content: Text(
              'AwareScroll is actively guarding Instagram (${_limitSeconds >= 60 ? "$_limitMinutes min" : "$_limitSeconds sec"}).',
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  void _showPermissionRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Color(0xFFE1306C)),
            SizedBox(width: 10),
            Text('Permissions Needed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'To detect when Instagram opens and present the restriction screen upon limit expiry, please enable:\n\n'
          '1. Accessibility Service (Real-time blocker)\n'
          '2. Usage Access\n'
          '3. Display Over Other Apps',
          style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFFB0B7C3)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openSettings('openAccessibilitySettings');
            },
            child: const Text('Accessibility Settings', style: TextStyle(color: Color(0xFF833AB4))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE1306C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _openSettings('openUsageSettings');
            },
            child: const Text('Usage Access', style: TextStyle(color: Colors.white)),
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
        appName: targetAppName,
        limitMinutes: _limitMinutes,
        onCloseApp: () {
          Navigator.pop(ctx);
          SystemNavigator.pop();
        },
        onContinueGranted: (extensionMin) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF00E676),
              content: Text(
                '$extensionMin-minute extension granted. Scroll mindfully!',
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_elapsedSeconds / _limitSeconds).clamp(0.0, 1.0);
    final bool allPermissionsGranted = _hasUsage && _hasOverlay && _hasAccessibility;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white12, width: 1.5),
                          ),
                          child: ClipOval(
                            child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AwareScroll',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Mindful Instagram Habit Control',
                              style: TextStyle(fontSize: 11, color: Color(0xFF7E869E)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Permissions Pill Indicator
                    GestureDetector(
                      onTap: () {
                        if (!allPermissionsGranted) _showPermissionRequiredDialog();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: allPermissionsGranted
                              ? const Color(0xFF00E676).withOpacity(0.12)
                              : const Color(0xFFFFB300).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: allPermissionsGranted
                                ? const Color(0xFF00E676).withOpacity(0.4)
                                : const Color(0xFFFFB300).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              allPermissionsGranted ? Icons.check_circle : Icons.warning_amber_rounded,
                              size: 14,
                              color: allPermissionsGranted ? const Color(0xFF00E676) : const Color(0xFFFFB300),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              allPermissionsGranted ? 'Shield Active' : 'Setup Needed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: allPermissionsGranted ? const Color(0xFF00E676) : const Color(0xFFFFB300),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Instagram Hero Guard Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E2235),
                        Color(0xFF131622),
                      ],
                    ),
                    border: Border.all(
                      color: _isRestricting ? const Color(0xFFE1306C).withOpacity(0.5) : const Color(0xFF262A3D),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isRestricting
                            ? const Color(0xFFE1306C).withOpacity(0.15)
                            : Colors.black.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Header Row: Instagram Branding + Live Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Instagram Gradient Icon
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF833AB4),
                                      Color(0xFFFD1D1D),
                                      Color(0xFFFCB045),
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFD1D1D).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 14),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Instagram',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    targetPackage,
                                    style: TextStyle(fontSize: 11, color: Color(0xFF7E869E)),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Live Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isRestricting
                                  ? (_isTargetInForeground
                                      ? const Color(0xFF00E676).withOpacity(0.16)
                                      : const Color(0xFFFFB300).withOpacity(0.16))
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isRestricting
                                    ? (_isTargetInForeground
                                        ? const Color(0xFF00E676).withOpacity(0.5)
                                        : const Color(0xFFFFB300).withOpacity(0.5))
                                    : Colors.white12,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (_isRestricting)
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      return Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (_isTargetInForeground
                                                  ? const Color(0xFF00E676)
                                                  : const Color(0xFFFFB300))
                                              .withOpacity(0.4 + (_pulseController.value * 0.6)),
                                        ),
                                      );
                                    },
                                  )
                                else
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white38,
                                    ),
                                  ),
                                const SizedBox(width: 7),
                                Text(
                                  _isRestricting
                                      ? (_isTargetInForeground ? 'SCROLLING' : 'GUARDING')
                                      : 'STANDBY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: _isRestricting
                                        ? (_isTargetInForeground
                                            ? const Color(0xFF00E676)
                                            : const Color(0xFFFFB300))
                                        : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Time Display & Radial Ring
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F111A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF1E2333)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('ELAPSED TIME', style: TextStyle(fontSize: 10, letterSpacing: 0.8, color: Color(0xFF7E869E))),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(_elapsedSeconds),
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: _isRestricting && _isTargetInForeground ? const Color(0xFF00E676) : Colors.white,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 36,
                                  width: 1,
                                  color: Colors.white12,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('TIME LIMIT', style: TextStyle(fontSize: 10, letterSpacing: 0.8, color: Color(0xFF7E869E))),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(_limitSeconds),
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFB300),
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Container(height: 8, color: const Color(0xFF1B1F2D)),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF833AB4),
                                            Color(0xFFFD1D1D),
                                            Color(0xFFFCB045),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              _isRestricting
                                  ? (_isTargetInForeground
                                      ? '⚡ Instagram is open! Timer is actively accumulating.'
                                      : '⏳ Open Instagram anytime. The blocker will trigger at the limit.')
                                  : 'Tap "Guard Instagram" below to lock your scrolling boundary.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF949DB5)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Time Limit Preset Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 16, color: Color(0xFFE1306C)),
                        SizedBox(width: 8),
                        Text(
                          'Select Usage Limit',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Access will be blocked the instant this threshold is reached.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7E869E)),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _limitOptions.map((opt) {
                        final sec = opt['sec'] as int;
                        final isSel = sec == _limitSeconds;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _limitMinutes = opt['min'] as int;
                              _limitSeconds = opt['sec'] as int;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFE1306C) : const Color(0xFF151824),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSel ? const Color(0xFFE1306C) : const Color(0xFF262B3D),
                                width: 1.2,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE1306C).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              opt['label'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                color: isSel ? Colors.white : const Color(0xFFB0B7C3),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // System Permissions (Clean Accordion/List)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131622),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF202538)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lock_clock_outlined, size: 16, color: Color(0xFF00E676)),
                              SizedBox(width: 8),
                              Text(
                                'Android Guard Permissions',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          Text('3 Required', style: TextStyle(fontSize: 11, color: Color(0xFF7E869E))),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildPermissionItem(
                        title: 'Accessibility Service',
                        subtitle: 'Instant blocker screen trigger',
                        isGranted: _hasAccessibility,
                        onEnable: () => _openSettings('openAccessibilitySettings'),
                      ),
                      const Divider(color: Color(0xFF1E2335), height: 16),
                      _buildPermissionItem(
                        title: 'Usage Access',
                        subtitle: 'Accurate foreground app tracking',
                        isGranted: _hasUsage,
                        onEnable: () => _openSettings('openUsageSettings'),
                      ),
                      const Divider(color: Color(0xFF1E2335), height: 16),
                      _buildPermissionItem(
                        title: 'Display Over Other Apps',
                        subtitle: 'Draw restriction screen over Instagram',
                        isGranted: _hasOverlay,
                        onEnable: () => _openSettings('openOverlaySettings'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Hero Action Buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    // Primary CTA: Start / Stop Guard
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        onPressed: _toggleRestriction,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: _isRestricting
                                ? const LinearGradient(colors: [Color(0xFFE5484D), Color(0xFFD32F2F)])
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFF833AB4),
                                      Color(0xFFFD1D1D),
                                      Color(0xFFFCB045),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: _isRestricting
                                    ? const Color(0xFFE5484D).withOpacity(0.4)
                                    : const Color(0xFFE1306C).withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isRestricting ? Icons.stop_circle_outlined : Icons.shield_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isRestricting
                                      ? 'STOP GUARDING INSTAGRAM'
                                      : 'GUARD INSTAGRAM (${_limitSeconds >= 60 ? "$_limitMinutes MIN" : "$_limitSeconds SEC"})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Preview Restriction Screen
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: Color(0xFF262B3D)),
                          backgroundColor: const Color(0xFF131622),
                        ),
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: Color(0xFFE1306C)),
                        label: const Text(
                          'Preview Restriction Blocker',
                          style: TextStyle(
                            color: Color(0xFFE1306C),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: _testRestrictionScreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onEnable,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGranted ? const Color(0xFF00E676).withOpacity(0.12) : const Color(0xFFFFB300).withOpacity(0.12),
              ),
              child: Icon(
                isGranted ? Icons.check : Icons.priority_high,
                size: 16,
                color: isGranted ? const Color(0xFF00E676) : const Color(0xFFFFB300),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF7E869E)),
                ),
              ],
            ),
          ],
        ),
        if (!isGranted)
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF1E2335),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onEnable,
            child: const Text(
              'Enable',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE1306C)),
            ),
          )
        else
          const Text('Granted', style: TextStyle(fontSize: 11, color: Color(0xFF00E676), fontWeight: FontWeight.w500)),
      ],
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
  int _step = 0; // 0: Scene 3 (Close vs Continue), 1: Scene 4 (Conscious Question)
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
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 34),
      decoration: const BoxDecoration(
        color: Color(0xFF131622),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: Color(0xFF262B3D), width: 1.5)),
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
        // Top handle indicator
        Container(
          width: 38,
          height: 4,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
        ),

        // Glowing Expiry Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB300).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.4)),
          ),
          child: Text(
            '${widget.limitMinutes.toString().padLeft(2, '0')}:00 LIMIT REACHED',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFB300), fontSize: 11, letterSpacing: 0.8),
          ),
        ),

        const SizedBox(height: 20),

        // Mandatory Headline
        const Text(
          'Your time is up! What would you like to do?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
        ),

        const SizedBox(height: 10),

        Text(
          'You configured a ${widget.limitMinutes}-minute limit for ${widget.appName}.\nTake a conscious breath and decide your next action.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFF8E97B0), height: 1.4),
        ),

        const SizedBox(height: 32),

        // Option 1: Close App (Primary Action)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE1306C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: const Color(0xFFE1306C).withOpacity(0.4),
            ),
            onPressed: widget.onCloseApp,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Close App',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Option 2: Continue (Triggers Follow-Up Question)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2235),
              side: const BorderSide(color: Color(0xFF2E3550)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              setState(() => _step = 1);
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: Color(0xFFCFD5E8), fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  // Scene 4: Follow-up Question
  Widget _buildScene4FollowUp() {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top handle indicator
        Center(
          child: Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
        ),

        // Conscious Reflection Tag
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E676).withOpacity(0.35)),
            ),
            child: const Text(
              'CONSCIOUS RECONSIDERATION',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676), fontSize: 10, letterSpacing: 0.8),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Follow-Up Question
        const Text(
          'What most influenced your decision to continue scrolling?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
        ),

        const SizedBox(height: 6),

        const Text(
          'Acknowledge your trigger before continuing.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF7E869E)),
        ),

        const SizedBox(height: 20),

        // Options List
        ..._reasons.map((reason) {
          final isSelected = reason == _selectedReason;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() => _selectedReason = reason);
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE1306C).withOpacity(0.18) : const Color(0xFF1B1F30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE1306C) : const Color(0xFF262C42),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? const Color(0xFFE1306C) : const Color(0xFF6B728D),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : const Color(0xFFC5CBE0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Confirm & Continue Button
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: const Color(0xFF00E676).withOpacity(0.3),
            ),
            onPressed: () {
              widget.onContinueGranted(5);
            },
            child: const Text(
              'Confirm & Continue (5 min extension)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Back to Close App
        Center(
          child: TextButton(
            onPressed: () {
              setState(() => _step = 0);
            },
            child: const Text(
              'Back',
              style: TextStyle(color: Color(0xFF7E869E), fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
