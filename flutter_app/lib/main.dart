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
          secondary: Color(0xFF00E676),
          tertiary: Color(0xFF833AB4),
          surface: Color(0xFF151824),
          background: Color(0xFF0B0D13),
        ),
        fontFamily: 'Roboto',
      ),
      home: const AwareScrollMainShell(),
    );
  }
}

// ==========================================
// ROOT NAVIGATION SHELL (3 BOTTOM TABS)
// ==========================================
class AwareScrollMainShell extends StatefulWidget {
  const AwareScrollMainShell({super.key});

  @override
  State<AwareScrollMainShell> createState() => _AwareScrollMainShellState();
}

class _AwareScrollMainShellState extends State<AwareScrollMainShell> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: const [
          MainControlDashboardTab(),
          InteractiveBlockerTab(),
          UserAccountInsightsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111319),
          border: Border(top: BorderSide(color: Color(0xFF262B3D), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentTabIndex,
          onDestinationSelected: (index) => setState(() => _currentTabIndex = index),
          backgroundColor: const Color(0xFF111319),
          indicatorColor: const Color(0xFFE1306C).withOpacity(0.18),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shield_outlined, color: Color(0xFF8E97B0)),
              selectedIcon: Icon(Icons.shield_rounded, color: Color(0xFFE1306C)),
              label: 'Control',
            ),
            NavigationDestination(
              icon: Icon(Icons.lock_clock_outlined, color: Color(0xFF8E97B0)),
              selectedIcon: Icon(Icons.lock_clock, color: Color(0xFF00E676)),
              label: 'Blocker',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined, color: Color(0xFF8E97B0)),
              selectedIcon: Icon(Icons.insights_rounded, color: Color(0xFF3A5BFF)),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: MAIN CONTROL DASHBOARD (SCREEN 1)
// ==========================================
class MainControlDashboardTab extends StatefulWidget {
  const MainControlDashboardTab({super.key});

  @override
  State<MainControlDashboardTab> createState() => _MainControlDashboardTabState();
}

class _MainControlDashboardTabState extends State<MainControlDashboardTab> with SingleTickerProviderStateMixin {
  static const MethodChannel _channel = MethodChannel('com.awarescroll/restriction');

  static const String targetAppName = 'Instagram';
  static const String targetPackage = 'com.instagram.android';

  int _limitMinutes = 5;
  int _limitSeconds = 300;

  bool _isRestricting = false;
  int _elapsedSeconds = 0;
  bool _isTargetInForeground = false;
  Timer? _statusTimer;

  bool _hasUsage = false;
  bool _hasOverlay = false;
  bool _hasAccessibility = false;

  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _limitOptions = [
    {'label': '30s (Test)', 'min': 1, 'sec': 30},
    {'label': '1 Min', 'min': 1, 'sec': 60},
    {'label': '5 Min (Default)', 'min': 5, 'sec': 300},
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

  Future<void> _handleGuardButtonClick() async {
    if (_isRestricting) {
      try {
        await _channel.invokeMethod('stopRestriction');
      } catch (_) {}
      setState(() {
        _isRestricting = false;
        _elapsedSeconds = 0;
        _isTargetInForeground = false;
      });
      // Show Post-Session Debrief
      if (mounted) {
        _showPostSessionDebrief();
      }
    } else {
      if (!_hasAccessibility && !_hasUsage) {
        _showPermissionRequiredDialog();
        return;
      }
      
      // Start guard directly with configured time limit - no start questions!
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
              'AwareScroll Guard Active! Guarding Instagram for ${_limitSeconds >= 60 ? "$_limitMinutes min" : "$_limitSeconds sec"}.',
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  void _showPostSessionDebrief() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PostSessionDebriefModal(
        elapsedSeconds: _elapsedSeconds,
        limitSeconds: _limitSeconds,
        onFinished: () {
          Navigator.pop(ctx);
        },
      ),
    );
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
          'To detect Instagram and intercept access when your limit is reached, please enable:\n\n'
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

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_elapsedSeconds / _limitSeconds).clamp(0.0, 1.0);
    final bool allPermissionsGranted = _hasUsage && _hasOverlay && _hasAccessibility;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
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
                  Container(
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
                ],
              ),
            ),
          ),

          // Hero Instagram Guard Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E2235), Color(0xFF131622)],
                  ),
                  border: Border.all(
                    color: _isRestricting ? const Color(0xFFE1306C).withOpacity(0.5) : const Color(0xFF262A3D),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isRestricting ? const Color(0xFFE1306C).withOpacity(0.15) : Colors.black.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
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
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Instagram', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(targetPackage, style: TextStyle(fontSize: 11, color: Color(0xFF7E869E))),
                              ],
                            ),
                          ],
                        ),
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
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white38),
                                ),
                              const SizedBox(width: 7),
                              Text(
                                _isRestricting ? (_isTargetInForeground ? 'SCROLLING' : 'GUARDING') : 'STANDBY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: _isRestricting
                                      ? (_isTargetInForeground ? const Color(0xFF00E676) : const Color(0xFFFFB300))
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Clocks container
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
                              Container(height: 36, width: 1, color: Colors.white12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('TIME LIMIT', style: TextStyle(fontSize: 10, letterSpacing: 0.8, color: Color(0xFF7E869E))),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(_limitSeconds),
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFFFB300), fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

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
                                        colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
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
                                    ? '⚡ Instagram is open! Timer is accumulating.'
                                    : '⏳ Waiting for Instagram. The blocker triggers at the limit.')
                                : 'Tap "Guard Instagram" below to anchor your intention and begin.',
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

          // Limit Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Usage Limit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFE1306C) : const Color(0xFF151824),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSel ? const Color(0xFFE1306C) : const Color(0xFF262B3D)),
                          ),
                          child: Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
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

          // Permissions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131622),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF202538)),
                ),
                child: Column(
                  children: [
                    _buildPermissionItem('Accessibility Service', 'Instant blocker screen trigger', _hasAccessibility, () => _openSettings('openAccessibilitySettings')),
                    const Divider(color: Color(0xFF1E2335), height: 16),
                    _buildPermissionItem('Usage Access', 'Foreground app tracking', _hasUsage, () => _openSettings('openUsageSettings')),
                    const Divider(color: Color(0xFF1E2335), height: 16),
                    _buildPermissionItem('Display Over Other Apps', 'Draw restriction overlay', _hasOverlay, () => _openSettings('openOverlaySettings')),
                  ],
                ),
              ),
            ),
          ),

          // Primary Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _handleGuardButtonClick,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: _isRestricting
                              ? const LinearGradient(colors: [Color(0xFFE5484D), Color(0xFFD32F2F)])
                              : const LinearGradient(colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_isRestricting ? Icons.stop_circle_outlined : Icons.shield_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _isRestricting ? 'STOP GUARDING INSTAGRAM' : 'GUARD INSTAGRAM (${_limitSeconds >= 60 ? "$_limitMinutes MIN" : "$_limitSeconds SEC"})',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String title, String subtitle, bool isGranted, VoidCallback onEnable) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(isGranted ? Icons.check_circle : Icons.warning_amber_rounded, size: 16, color: isGranted ? const Color(0xFF00E676) : const Color(0xFFFFB300)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF7E869E))),
              ],
            ),
          ],
        ),
        if (!isGranted)
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF1E2335),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onEnable,
            child: const Text('Enable', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE1306C))),
          )
        else
          const Text('Active', style: TextStyle(fontSize: 11, color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ==========================================
// TAB 2: INTERACTIVE BLOCKER PROTOTYPE (SCREEN 6)
// ==========================================
class InteractiveBlockerTab extends StatefulWidget {
  const InteractiveBlockerTab({super.key});

  @override
  State<InteractiveBlockerTab> createState() => _InteractiveBlockerTabState();
}

class _InteractiveBlockerTabState extends State<InteractiveBlockerTab> {
  int _activeState = 1; // 1: Gate, 2: Reflect, 3: Unlock

  // State 2 selections for extension survey
  String _selectedPurpose = 'Reply to a message';
  String _selectedTrigger = 'Interesting content';
  String _selectedCategory = 'Reels / Entertainment';
  String _selectedWorkImpact = 'Delayed a task';
  String _selectedFeeling = 'Neutral';
  String _selectedSupposedActivity = 'Working';
  String _selectedHelpStop = 'Time warning';
  int _selectedExtensionMin = 5;

  // State 3 countdown ticker
  Timer? _countdownTimer;
  int _countdownRemainingSec = 300;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _switchState(int newState) {
    setState(() {
      _activeState = newState;
      if (newState == 3) {
        _countdownRemainingSec = _selectedExtensionMin * 60;
        _countdownTimer?.cancel();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted && _countdownRemainingSec > 0) {
            setState(() => _countdownRemainingSec--);
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Prototype State Switcher Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF111319),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: Color(0xFFE1306C)),
                    SizedBox(width: 6),
                    Text('BLOCKER PROTOTYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xFF8E97B0))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: const Color(0xFF1E2333), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      _buildStateChip('1: Gate', 1),
                      _buildStateChip('2: Reflect', 2),
                      _buildStateChip('3: Unlock', 3),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body Content depending on active state
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildActiveStateView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateChip(String label, int stateIndex) {
    final isSelected = _activeState == stateIndex;
    return GestureDetector(
      onTap: () => _switchState(stateIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE1306C) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF8E97B0),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveStateView() {
    switch (_activeState) {
      case 1:
        return _buildState1Gate();
      case 2:
        return _buildState2Reflect();
      case 3:
      default:
        return _buildState3Unlock();
    }
  }

  // STATE 1: GATE
  Widget _buildState1Gate() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB300).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.4)),
          ),
          child: const Text('05:00 LIMIT REACHED', style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8)),
        ),
        const SizedBox(height: 32),
        // Breathing Ring
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE1306C).withOpacity(0.3), width: 2),
            gradient: RadialGradient(
              colors: [const Color(0xFF833AB4).withOpacity(0.2), const Color(0xFF151824)],
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.spa, color: Color(0xFFE1306C), size: 40),
              SizedBox(height: 8),
              Text('Mindful Gate', style: TextStyle(color: Color(0xFF8E97B0), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF151824), borderRadius: BorderRadius.circular(16)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.air, size: 14, color: Color(0xFF00E676)),
              SizedBox(width: 6),
              Text('Take a breath • 4s Inhale, 4s Exhale', style: TextStyle(color: Color(0xFF8E97B0), fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your time is up.\nWhat would you like to do?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
        ),
        const SizedBox(height: 10),
        const Text(
          "You've reached your configured 5-minute Instagram limit. Choose whether to step away or consciously evaluate your decision to continue.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF7E869E), height: 1.4),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE1306C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            label: const Text('Close Instagram', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Instagram locked & closed. Boundary preserved!')),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF151824),
              side: const BorderSide(color: Color(0xFF262B3D)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _switchState(2),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue (Requires Reflection)', style: TextStyle(color: Color(0xFFCFD5E8), fontWeight: FontWeight.w600, fontSize: 14)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16, color: Color(0xFFE1306C)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STATE 2: REFLECT (SURVEY FORM)
  Widget _buildState2Reflect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _switchState(1),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, size: 16, color: Color(0xFF8E97B0)),
                  SizedBox(width: 4),
                  Text('Close App', style: TextStyle(fontSize: 12, color: Color(0xFF8E97B0))),
                ],
              ),
            ),
            const Text('● EXTENSION SURVEY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00E676), letterSpacing: 0.8)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 4,
            width: double.infinity,
            color: const Color(0xFF1E2333),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.75,
              child: Container(color: const Color(0xFFE1306C)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Mindful Extension Survey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Please complete these reflections to consciously unlock an extension.', style: TextStyle(fontSize: 12, color: Color(0xFF7E869E))),
        const SizedBox(height: 20),

        // Q1: Purpose
        _buildQuestionCard(
          number: '1',
          title: 'Purpose of Usage',
          subtitle: 'Why do you want use it, clearly mention your purpose?',
          child: Column(
            children: [
              'Reply to a message',
              "Checking someone's reply",
              'Check updates',
              'Nothing to do, so watch reels',
              'Finished all tasks, want to watch reels',
              'Study or research',
              'Opened automatically / out of habit',
            ].map((opt) => _buildRadioOption(opt, _selectedPurpose, (v) => setState(() => _selectedPurpose = v))).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Q2: Decision to Continue
        _buildQuestionCard(
          number: '2',
          title: 'Decision Factor',
          subtitle: 'What most influenced your decision to continue?',
          child: Column(
            children: [
              'Interesting content',
              'Boredom',
              'Stress / mood',
              'Notifications / messages',
              'Habitual scrolling',
              'Unfinished original purpose',
            ].map((opt) => _buildRadioOption(opt, _selectedTrigger, (v) => setState(() => _selectedTrigger = v))).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Q3: Content Category
        _buildQuestionCard(
          number: '3',
          title: 'Content Category',
          subtitle: 'Which content category kept you engaged?',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Comedy / Memes',
              'Education / Technology',
              'News / Politics',
              'Stories / Personal content',
              'Fitness / Lifestyle',
              'Music / Entertainment',
              'Other / Mixed',
            ].map((cat) {
              final isSel = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFE1306C) : const Color(0xFF151824),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSel ? const Color(0xFFE1306C) : const Color(0xFF262B3D)),
                  ),
                  child: Text(cat, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : const Color(0xFFB0B7C3), fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Q4: Effect on planned work
        _buildQuestionCard(
          number: '4',
          title: 'Effect on Planned Work',
          subtitle: 'How did this session affect your planned work?',
          child: Column(
            children: [
              'No task planned',
              'Delayed a task',
              'Interrupted a task',
              'No negative impact / planned break',
            ].map((opt) => _buildRadioOption(opt, _selectedWorkImpact, (v) => setState(() => _selectedWorkImpact = v))).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Q5: Feeling after scrolling
        _buildQuestionCard(
          number: '5',
          title: 'Emotional State',
          subtitle: 'How do you feel after scrolling?',
          child: Column(
            children: [
              'Satisfied',
              'Relaxed',
              'Neutral',
              'Bored',
              'Stressed / regretful',
            ].map((opt) => _buildRadioOption(opt, _selectedFeeling, (v) => setState(() => _selectedFeeling = v))).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Q6: Supposed to be doing
        _buildQuestionCard(
          number: '6',
          title: 'Intended Activity',
          subtitle: 'What were you supposed to be doing?',
          child: Column(
            children: [
              'Studying',
              'Working',
              'Sleeping',
              'Socializing',
              'Relaxing',
              'Nothing planned',
            ].map((opt) => _buildRadioOption(opt, _selectedSupposedActivity, (v) => setState(() => _selectedSupposedActivity = v))).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Q7: What would have helped stop
        _buildQuestionCard(
          number: '7',
          title: 'Intervention Help',
          subtitle: 'What would have helped you stop?',
          child: Column(
            children: [
              'Time warning',
              'Original-purpose reminder',
              'Mood check',
              'Break suggestion',
              'App closure',
            ].map((opt) => _buildRadioOption(opt, _selectedHelpStop, (v) => setState(() => _selectedHelpStop = v))).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Q8: Extension Duration
        _buildQuestionCard(
          number: '8',
          title: 'Extension Duration',
          subtitle: 'How much time do you consciously commit to extend?',
          child: Row(
            children: [
              _buildExtCard(2, 'Quick check'),
              const SizedBox(width: 8),
              _buildExtCard(5, 'Default', isRecommended: true),
              const SizedBox(width: 8),
              _buildExtCard(10, '+10m'),
              const SizedBox(width: 8),
              _buildExtCard(15, '+15m'),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.lock_open, size: 20),
            label: Text('Confirm & Extend Time (+${_selectedExtensionMin}m)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: () => _switchState(3),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String opt, String selectedVal, Function(String) onSelect) {
    final isSel = opt == selectedVal;
    return GestureDetector(
      onTap: () => onSelect(opt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFE1306C).withOpacity(0.18) : const Color(0xFF151824),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSel ? const Color(0xFFE1306C) : const Color(0xFF262B3D)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(opt, style: TextStyle(fontSize: 13, color: isSel ? Colors.white : const Color(0xFFB0B7C3), fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
            ),
            Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_off, size: 16, color: isSel ? const Color(0xFFE1306C) : Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildExtCard(int min, String caption, {bool isRecommended = false}) {
    final isSel = _selectedExtensionMin == min;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedExtensionMin = min),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF00E676).withOpacity(0.18) : const Color(0xFF151824),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSel ? const Color(0xFF00E676) : const Color(0xFF262B3D)),
          ),
          child: Column(
            children: [
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(color: const Color(0xFF00E676), borderRadius: BorderRadius.circular(6)),
                  child: const Text('REC', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              Text('+$min m', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSel ? const Color(0xFF00E676) : Colors.white)),
              const SizedBox(height: 2),
              Text(caption, style: const TextStyle(fontSize: 9, color: Color(0xFF7E869E))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard({required String number, required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111319), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF202538))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 10, backgroundColor: const Color(0xFFE1306C).withOpacity(0.2), child: Text(number, style: const TextStyle(fontSize: 10, color: Color(0xFFE1306C), fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF7E869E))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // STATE 3: UNLOCK
  Widget _buildState3Unlock() {
    final m = _countdownRemainingSec ~/ 60;
    final s = _countdownRemainingSec % 60;
    final timerText = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00E676).withOpacity(0.12),
            border: Border.all(color: const Color(0xFF00E676).withOpacity(0.4), width: 2),
          ),
          child: const Icon(Icons.lock_open, color: Color(0xFF00E676), size: 50),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFF151824), borderRadius: BorderRadius.circular(20)),
          child: const Text('SESSION UNLOCKED', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8)),
        ),
        const SizedBox(height: 16),
        const Text('Extension Granted', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        const Text('Scroll with mindful awareness. Your countdown has initiated.', style: TextStyle(fontSize: 12, color: Color(0xFF7E869E))),
        const SizedBox(height: 24),

        // Live Countdown Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF151824), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF262B3D))),
          child: Column(
            children: [
              Text(timerText, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Color(0xFF00E676))),
              const SizedBox(height: 4),
              const Text('REMAINING IN EXTENSION', style: TextStyle(fontSize: 10, letterSpacing: 0.8, color: Color(0xFF7E869E))),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Commitment Recap Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF111319), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF202538))),
          child: Column(
            children: [
              _buildRecapRow('Stated Purpose', _selectedPurpose),
              const Divider(color: Color(0xFF1E2335), height: 16),
              _buildRecapRow('Continue Trigger', _selectedTrigger),
              const Divider(color: Color(0xFF1E2335), height: 16),
              _buildRecapRow('Supposed to be doing', _selectedSupposedActivity),
              const Divider(color: Color(0xFF1E2335), height: 16),
              _buildRecapRow('Extension Allowance', '+$_selectedExtensionMin Minutes'),
            ],
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.arrow_outward, size: 20),
            label: const Text('Enter Instagram', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resuming Instagram session. Use it with intention!')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecapRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF7E869E))),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

// ==========================================
// TAB 3: USER ACCOUNT & INSIGHTS (SCREEN 3)
// ==========================================
class UserAccountInsightsTab extends StatelessWidget {
  const UserAccountInsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF151824),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF262B3D)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFE1306C),
                          child: Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Alex Morgan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(color: const Color(0xFFE1306C).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('PRO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFE1306C))),
                                ),
                              ],
                            ),
                            const Text('@alex.mindful', style: TextStyle(fontSize: 11, color: Color(0xFF7E869E))),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFFFFB300).withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                      child: const Row(
                        children: [
                          Icon(Icons.local_fire_department, size: 14, color: Color(0xFFFFB300)),
                          SizedBox(width: 4),
                          Text('14d Streak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFFB300))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFF0F111A), borderRadius: BorderRadius.circular(14)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('SHIELD HEALTH', style: TextStyle(fontSize: 9, color: Color(0xFF7E869E))),
                          SizedBox(height: 2),
                          Text('94%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
                        ],
                      ),
                      Column(
                        children: [
                          Text('AWARENESS', style: TextStyle(fontSize: 9, color: Color(0xFF7E869E))),
                          SizedBox(height: 2),
                          Text('Lvl 8', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE1306C))),
                        ],
                      ),
                      Column(
                        children: [
                          Text('NET CALM', style: TextStyle(fontSize: 9, color: Color(0xFF7E869E))),
                          SizedBox(height: 2),
                          Text('+3.4h', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3A5BFF))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // KPI Cards
          Row(
            children: [
              _buildKpiCard('SCREEN TIME', '42m', '-38% vs lw', const Color(0xFF00E676)),
              const SizedBox(width: 8),
              _buildKpiCard('FRICTIONS', '6', '4 held / 2 ext', const Color(0xFFE1306C)),
              const SizedBox(width: 8),
              _buildKpiCard('CALM SAVED', '18m', 'Preserved', const Color(0xFF3A5BFF)),
            ],
          ),

          const SizedBox(height: 20),

          // 7-Day Bar Chart
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFF151824), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF262B3D))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daily Rhythm vs 45m Cap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Avg: 37m/day', style: TextStyle(fontSize: 11, color: Color(0xFFE1306C))),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar('M', 35, 45),
                    _buildBar('T', 40, 45),
                    _buildBar('W', 52, 45, isExceeded: true),
                    _buildBar('T', 42, 45, isToday: true),
                    _buildBar('F', 28, 45),
                    _buildBar('S', 30, 45),
                    _buildBar('S', 24, 45),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Compulsive Trigger Breakdown
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFF151824), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF262B3D))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Compulsive Trigger Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 14),
                _buildTriggerBar('Boredom / Under-stimulation', 0.44, '44%', const Color(0xFFE1306C)),
                _buildTriggerBar('Habitual / Reflexive', 0.28, '28%', const Color(0xFFFFB300)),
                _buildTriggerBar('Notifications & DMs', 0.16, '16%', const Color(0xFF3A5BFF)),
                _buildTriggerBar('Dopamine / Content Hook', 0.12, '12%', const Color(0xFF00E676)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildKpiCard(String label, String value, String sub, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF151824), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF262B3D))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF7E869E))),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: col)),
          ],
        ),
      ),
    );
  }

  static Widget _buildBar(String day, int val, int cap, {bool isToday = false, bool isExceeded = false}) {
    final heightRatio = (val / 60.0).clamp(0.1, 1.0);
    final col = isExceeded ? const Color(0xFFFF4D6D) : (isToday ? const Color(0xFFE1306C) : const Color(0xFF3A5BFF).withOpacity(0.6));
    return Column(
      children: [
        Text('${val}m', style: TextStyle(fontSize: 9, color: isToday ? Colors.white : const Color(0xFF7E869E))),
        const SizedBox(height: 6),
        Container(
          width: 18,
          height: 100 * heightRatio,
          decoration: BoxDecoration(
            color: col,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: TextStyle(fontSize: 10, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? const Color(0xFFE1306C) : const Color(0xFF7E869E))),
      ],
    );
  }

  static Widget _buildTriggerBar(String label, double ratio, String percent, Color col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFFC5CBE0))),
              Text(percent, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: const Color(0xFF0F111A),
              valueColor: AlwaysStoppedAnimation<Color>(col),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 5: POST-SESSION DEBRIEF MODAL
// ==========================================
class PostSessionDebriefModal extends StatefulWidget {
  final int elapsedSeconds;
  final int limitSeconds;
  final VoidCallback onFinished;

  const PostSessionDebriefModal({
    super.key,
    required this.elapsedSeconds,
    required this.limitSeconds,
    required this.onFinished,
  });

  @override
  State<PostSessionDebriefModal> createState() => _PostSessionDebriefModalState();
}

class _PostSessionDebriefModalState extends State<PostSessionDebriefModal> {
  String _selectedSentiment = 'Satisfied';
  bool _taskDelayed = false;

  final List<Map<String, String>> _sentiments = [
    {'label': 'Satisfied', 'emoji': '😊'},
    {'label': 'Relaxed', 'emoji': '😌'},
    {'label': 'Neutral', 'emoji': '😐'},
    {'label': 'Bored', 'emoji': '🥱'},
    {'label': 'Regretful', 'emoji': '😣'},
  ];

  @override
  Widget build(BuildContext context) {
    final m = widget.elapsedSeconds ~/ 60;
    final s = widget.elapsedSeconds % 60;
    final timeStr = '${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF111319),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF262B3D), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const Icon(Icons.check_circle_outline, color: Color(0xFF00E676), size: 48),
          const SizedBox(height: 12),
          const Text('Session Complete!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('You successfully honored your boundary and stepped away.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF7E869E))),
          const SizedBox(height: 20),

          // Telemetry
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF151824), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF262B3D))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('SCROLLED', style: TextStyle(fontSize: 10, color: Color(0xFF7E869E))),
                    const SizedBox(height: 4),
                    Text(timeStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace')),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.white12),
                const Column(
                  children: [
                    Text('CALM SAVED', style: TextStyle(fontSize: 10, color: Color(0xFF00E676))),
                    SizedBox(height: 4),
                    Text('+15m 00s', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00E676), fontFamily: 'monospace')),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sentiment
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('How do you feel right now?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _sentiments.map((item) {
              final label = item['label']!;
              final emoji = item['emoji']!;
              final isSel = label == _selectedSentiment;
              return GestureDetector(
                onTap: () => setState(() => _selectedSentiment = label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFE1306C).withOpacity(0.2) : const Color(0xFF151824),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? const Color(0xFFE1306C) : const Color(0xFF262B3D)),
                  ),
                  child: Column(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(label, style: TextStyle(fontSize: 9, color: isSel ? Colors.white : const Color(0xFF7E869E))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Accountability toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Did this delay your planned tasks?', style: TextStyle(fontSize: 12, color: Color(0xFFC5CBE0))),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _taskDelayed = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: !_taskDelayed ? const Color(0xFF00E676).withOpacity(0.2) : const Color(0xFF151824),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('No 👍', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _taskDelayed = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _taskDelayed ? const Color(0xFFE1306C).withOpacity(0.2) : const Color(0xFF151824),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Yes ⏳', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: widget.onFinished,
              child: const Text('Finish & Return to Home →', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
