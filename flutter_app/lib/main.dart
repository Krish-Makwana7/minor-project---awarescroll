// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AwareScrollApp());
}

// ==========================================
// THEME & DESIGN SYSTEM: MINDFUL DIGITAL FOCUS
// ==========================================
class AwareScrollTheme {
  static const Color background = Color(0xFFFCF8FF);
  static const Color surface = Color(0xFFFCF8FF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F2FF);
  static const Color surfaceContainer = Color(0xFFF0EDFF);
  static const Color surfaceContainerHigh = Color(0xFFE8E5FC);

  static const Color outline = Color(0xFFE2E4F0);
  static const Color outlineVariant = Color(0xFFC4C5D9);

  static const Color onSurface = Color(0xFF141528);
  static const Color onSurfaceVariant = Color(0xFF6B6F8C);

  static const Color primary = Color(0xFF3A5BFF); // Electric Blue
  static const Color primaryHover = Color(0xFF2C4EF2);
  static const Color primaryFixed = Color(0xFFDEE0FF);

  static const Color secondaryEmerald = Color(0xFF00B894); // Calm Emerald
  static const Color secondaryContainer = Color(0xFFE0F7F8);
  static const Color onSecondaryContainer = Color(0xFF006972);

  static const Color tertiaryAmber = Color(0xFFFF9F43); // Mindful Amber
  static const Color tertiaryContainer = Color(0xFFFFEFE0);
  static const Color onTertiaryText = Color(0xFF7A4300);

  static const LinearGradient instagramGradient = LinearGradient(
    colors: [
      Color(0xFF833AB4),
      Color(0xFFE1306C),
      Color(0xFFFD1D1D),
      Color(0xFFFCB045),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
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
        brightness: Brightness.light,
        scaffoldBackgroundColor: AwareScrollTheme.background,
        colorScheme: const ColorScheme.light(
          primary: AwareScrollTheme.primary,
          secondary: AwareScrollTheme.secondaryEmerald,
          tertiary: AwareScrollTheme.tertiaryAmber,
          surface: AwareScrollTheme.surfaceCard,
          background: AwareScrollTheme.background,
          onSurface: AwareScrollTheme.onSurface,
          onBackground: AwareScrollTheme.onSurface,
        ),
        fontFamily: 'Inter',
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

  void _onSwitchTab(int index) {
    setState(() => _currentTabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AwareScrollTheme.background,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          MainControlDashboardTab(
            onNavigateToBlocker: () => _onSwitchTab(1),
          ),
          InteractiveBlockerTab(
            onReturnToControl: () => _onSwitchTab(0),
          ),
          const UserAccountInsightsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AwareScrollTheme.outline, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A141528),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.shield_outlined,
                  activeIcon: Icons.shield,
                  label: 'CONTROL',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.lock_clock_outlined,
                  activeIcon: Icons.lock_clock,
                  label: 'BLOCKER',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.insights_outlined,
                  activeIcon: Icons.insights,
                  label: 'INSIGHTS',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentTabIndex == index;
    final color = isSelected
        ? AwareScrollTheme.primary
        : AwareScrollTheme.onSurfaceVariant;

    return InkWell(
      onTap: () => setState(() => _currentTabIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
                fontFamily: 'monospace',
              ),
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
  final VoidCallback onNavigateToBlocker;

  const MainControlDashboardTab({
    super.key,
    required this.onNavigateToBlocker,
  });

  @override
  State<MainControlDashboardTab> createState() =>
      _MainControlDashboardTabState();
}

class _MainControlDashboardTabState extends State<MainControlDashboardTab>
    with SingleTickerProviderStateMixin {
  static const MethodChannel _channel =
      MethodChannel('com.awarescroll/restriction');

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
      if (mounted) {
        _showPostSessionDebrief();
      }
    } else {
      if (!_hasAccessibility && !_hasUsage) {
        _showPermissionRequiredDialog();
        return;
      }

      // Directly start guard without asking starting questionnaire!
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
            backgroundColor: AwareScrollTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.verified, color: AwareScrollTheme.secondaryEmerald, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Shield Guard Engaged for Instagram (${_limitSeconds >= 60 ? "$_limitMinutes min" : "$_limitSeconds sec"})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AwareScrollTheme.primary),
            SizedBox(width: 8),
            Text(
              'Permissions Needed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AwareScrollTheme.onSurface,
              ),
            ),
          ],
        ),
        content: const Text(
          'AwareScroll requires Accessibility Service or Usage Access to track Instagram usage and block compulsive scrolling.',
          style: TextStyle(
            fontSize: 13,
            color: AwareScrollTheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AwareScrollTheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AwareScrollTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _openSettings('openAccessibilitySettings');
            },
            child: const Text('Grant Access'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings(String method) async {
    try {
      await _channel.invokeMethod(method);
    } catch (_) {}
  }

  String _formatTime(int totalSec) {
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_limitSeconds > 0)
        ? (_elapsedSeconds / _limitSeconds).clamp(0.0, 1.0)
        : 0.0;
    final progressPct = (progress * 100).toInt();

    final grantedCount = (_hasAccessibility ? 1 : 0) +
        (_hasUsage ? 1 : 0) +
        (_hasOverlay ? 1 : 0);

    return Scaffold(
      backgroundColor: AwareScrollTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AwareScrollTheme.primary, Color(0xFF6C8CFF)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x203A5BFF),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.shield_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AWARESCROLL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AwareScrollTheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AwareScrollTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AwareScrollTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AwareScrollTheme.outline),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_outline,
                          color: AwareScrollTheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sub-Header Context Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AwareScrollTheme.outline),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08141528),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AwareScrollTheme.primary,
                                  AwareScrollTheme.secondaryEmerald,
                                  AwareScrollTheme.tertiaryAmber,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.hourglass_top_rounded,
                                color: AwareScrollTheme.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'AwareScroll',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AwareScrollTheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: AwareScrollTheme.primaryFixed,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'v2.4',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AwareScrollTheme.primary,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'Mindful Instagram Habit Control',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AwareScrollTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AwareScrollTheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AwareScrollTheme.secondaryEmerald.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AwareScrollTheme.secondaryEmerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'SHIELD ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AwareScrollTheme.onSecondaryContainer,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Hero Card: Real-Time Dopamine Telemetry
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AwareScrollTheme.outline),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C141528),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(
                                  gradient: AwareScrollTheme.instagramGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Color(0xFFE1306C),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Instagram',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AwareScrollTheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'com.instagram.android',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AwareScrollTheme.onSurfaceVariant,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isRestricting && _isTargetInForeground
                                  ? const Color(0xFFE8F8F0)
                                  : AwareScrollTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isRestricting && _isTargetInForeground
                                    ? AwareScrollTheme.secondaryEmerald.withOpacity(0.4)
                                    : AwareScrollTheme.outline,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _isRestricting && _isTargetInForeground
                                        ? AwareScrollTheme.secondaryEmerald
                                        : AwareScrollTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _isRestricting
                                      ? (_isTargetInForeground ? 'SCROLLING' : 'GUARDING')
                                      : 'IDLE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: _isRestricting && _isTargetInForeground
                                        ? const Color(0xFF007E59)
                                        : AwareScrollTheme.onSurfaceVariant,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Dual Telemetry Monospace Readout
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AwareScrollTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AwareScrollTheme.outline),
                        ),
                        child: Row(
                          children: [
                            // Elapsed
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.timelapse, size: 14, color: AwareScrollTheme.primary),
                                      SizedBox(width: 4),
                                      Text(
                                        'ELAPSED TIME',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.6,
                                          color: AwareScrollTheme.onSurfaceVariant,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        _formatTime(_elapsedSeconds),
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: AwareScrollTheme.primary,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'live',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AwareScrollTheme.onSurfaceVariant,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 42, color: AwareScrollTheme.outline),
                            const SizedBox(width: 14),
                            // Limit
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.lock_clock, size: 14, color: AwareScrollTheme.tertiaryAmber),
                                      SizedBox(width: 4),
                                      Text(
                                        'TIME LIMIT',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.6,
                                          color: AwareScrollTheme.onSurfaceVariant,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        _formatTime(_limitSeconds),
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: AwareScrollTheme.onSurface,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'cap',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AwareScrollTheme.onSurfaceVariant,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Container(
                              height: 8,
                              color: AwareScrollTheme.surfaceContainer,
                            ),
                            FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: progress >= 0.9
                                      ? AwareScrollTheme.tertiaryAmber
                                      : AwareScrollTheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bolt, size: 14, color: AwareScrollTheme.tertiaryAmber),
                              SizedBox(width: 4),
                              Text(
                                'Instagram is guarded. Time is accumulating.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AwareScrollTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$progressPct%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AwareScrollTheme.primary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Select Usage Limit Header & Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 17, color: AwareScrollTheme.primary),
                        SizedBox(width: 6),
                        Text(
                          'Select Usage Limit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AwareScrollTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'DAILY GRACE CAP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AwareScrollTheme.onSurfaceVariant.withOpacity(0.8),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _limitOptions.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final opt = _limitOptions[i];
                    final sec = opt['sec'] as int;
                    final isSel = sec == _limitSeconds;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _limitMinutes = opt['min'] as int;
                          _limitSeconds = opt['sec'] as int;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AwareScrollTheme.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? AwareScrollTheme.primary : AwareScrollTheme.outline,
                          ),
                          boxShadow: isSel
                              ? const [
                                  BoxShadow(
                                    color: Color(0x303A5BFF),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : const [
                                  BoxShadow(
                                    color: Color(0x06141528),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              color: isSel ? Colors.white : AwareScrollTheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Android Guard Permissions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_user_outlined, size: 17, color: AwareScrollTheme.secondaryEmerald),
                        SizedBox(width: 6),
                        Text(
                          'Android Guard Permissions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AwareScrollTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$grantedCount/3 OPERATIONAL',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AwareScrollTheme.secondaryEmerald,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AwareScrollTheme.outline),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08141528),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildPermissionItem(
                        icon: Icons.accessibility_new_rounded,
                        title: 'Accessibility Service',
                        subtitle: 'Active & Monitoring Feed Actions',
                        isGranted: _hasAccessibility,
                        onEnable: () => _openSettings('openAccessibilitySettings'),
                      ),
                      const Divider(color: AwareScrollTheme.outline, height: 16),
                      _buildPermissionItem(
                        icon: Icons.query_stats_rounded,
                        title: 'Usage Access',
                        subtitle: 'Granted Foreground Window Telemetry',
                        isGranted: _hasUsage,
                        onEnable: () => _openSettings('openUsageSettings'),
                      ),
                      const Divider(color: AwareScrollTheme.outline, height: 16),
                      _buildPermissionItem(
                        icon: Icons.layers_rounded,
                        title: 'Display Over Other Apps',
                        subtitle: 'Overlay & Mindful Blocker Ready',
                        isGranted: _hasOverlay,
                        onEnable: () => _openSettings('openOverlaySettings'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                child: Column(
                  children: [
                    // Primary Guard Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRestricting
                              ? const Color(0xFFE53935)
                              : AwareScrollTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0x403A5BFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _handleGuardButtonClick,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isRestricting ? Icons.stop_circle_outlined : Icons.shield,
                              size: 19,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isRestricting
                                  ? 'STOP GUARDING INSTAGRAM'
                                  : 'GUARD INSTAGRAM (${_limitSeconds >= 60 ? "$_limitMinutes MIN" : "$_limitSeconds SEC"})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Preview Restriction Blocker Ghost Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AwareScrollTheme.onSurface,
                          side: const BorderSide(color: AwareScrollTheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: widget.onNavigateToBlocker,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.visibility_outlined, size: 17, color: AwareScrollTheme.onSurfaceVariant),
                            SizedBox(width: 8),
                            Text(
                              'Preview Restriction Blocker',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 16, color: AwareScrollTheme.onSurfaceVariant),
                          ],
                        ),
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
    required IconData icon,
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
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AwareScrollTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AwareScrollTheme.onSurface),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AwareScrollTheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AwareScrollTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (isGranted)
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AwareScrollTheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 15, color: AwareScrollTheme.secondaryEmerald),
          )
        else
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: AwareScrollTheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onEnable,
            child: const Text(
              'Enable',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AwareScrollTheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ==========================================
// TAB 2: INTERACTIVE BLOCKER & SURVEY TAB
// ==========================================
class InteractiveBlockerTab extends StatefulWidget {
  final VoidCallback onReturnToControl;

  const InteractiveBlockerTab({
    super.key,
    required this.onReturnToControl,
  });

  @override
  State<InteractiveBlockerTab> createState() => _InteractiveBlockerTabState();
}

class _InteractiveBlockerTabState extends State<InteractiveBlockerTab>
    with SingleTickerProviderStateMixin {
  static const MethodChannel _channel =
      MethodChannel('com.awarescroll/restriction');

  int _activeState = 1; // 1: Gate, 2: Reflect (Survey), 3: Unlock

  // Survey Choices (User's Exact 7 Questions)
  String _selectedPurpose = 'Reply to a message';
  String _selectedTrigger = 'Interesting content';
  String _selectedCategory = 'Reels / Entertainment';
  String _selectedWorkImpact = 'Delayed a task';
  String _selectedFeeling = 'Neutral';
  String _selectedSupposedActivity = 'Working';
  String _selectedHelpStop = 'Time warning';
  int _selectedExtensionMin = 5;

  Timer? _countdownTimer;
  int _countdownRemainingSec = 300;

  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _breatheController.dispose();
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

  Future<void> _handleUnlockCommitment() async {
    try {
      await _channel.invokeMethod('recordSurveyResponse', {
        'appName': 'Instagram',
        'packageName': 'com.instagram.android',
        'limitMinutes': 5,
        'elapsedSeconds': 300,
        'extensionMinutes': _selectedExtensionMin,
        'purpose': _selectedPurpose,
        'trigger': _selectedTrigger,
        'category': _selectedCategory,
        'workImpact': _selectedWorkImpact,
        'feeling': _selectedFeeling,
        'supposedActivity': _selectedSupposedActivity,
        'helpStop': _selectedHelpStop,
        'sessionOutcome': 'extended',
      });
      await _channel.invokeMethod('grantExtension', {
        'minutes': _selectedExtensionMin,
      });
    } catch (_) {}
    _switchState(3);
  }

  Future<void> _handleCloseApp() async {
    try {
      await _channel.invokeMethod('closeTargetApp');
    } catch (_) {}
    widget.onReturnToControl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AwareScrollTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Prototype Nav / State Switcher
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AwareScrollTheme.outline)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock_clock, size: 16, color: AwareScrollTheme.tertiaryAmber),
                      SizedBox(width: 6),
                      Text(
                        'AWARESCROLL DEMO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AwareScrollTheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AwareScrollTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AwareScrollTheme.outline),
                    ),
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

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: _buildActiveStateView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateChip(String label, int index) {
    final isSel = _activeState == index;
    return GestureDetector(
      onTap: () => _switchState(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? AwareScrollTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
            color: isSel ? Colors.white : AwareScrollTheme.onSurfaceVariant,
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
        return _buildState2Survey();
      case 3:
      default:
        return _buildState3Unlock();
    }
  }

  // ==========================================
  // STATE 1: LIMIT REACHED GATE
  // ==========================================
  Widget _buildState1Gate() {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AwareScrollTheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AwareScrollTheme.tertiaryAmber.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_clock, size: 14, color: AwareScrollTheme.onTertiaryText),
              SizedBox(width: 5),
              Text(
                '05:00 LIMIT REACHED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AwareScrollTheme.onTertiaryText,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Breathing Circle Visualizer
        AnimatedBuilder(
          animation: _breatheController,
          builder: (ctx, child) {
            final scale = 0.94 + (_breatheController.value * 0.12);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x333A5BFF),
                      Color(0x33FF9F43),
                      Color(0x3300B894),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AwareScrollTheme.primary.withOpacity(0.18),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AwareScrollTheme.outline),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.self_improvement, color: AwareScrollTheme.primary, size: 38),
                        SizedBox(height: 4),
                        Text(
                          'BREATHE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AwareScrollTheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Satellite Focus Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AwareScrollTheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AwareScrollTheme.tertiaryAmber.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.air, size: 14, color: AwareScrollTheme.onTertiaryText),
              SizedBox(width: 5),
              Text(
                '4s Inhale • 4s Exhale',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AwareScrollTheme.onTertiaryText,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Your time is up!\nWhat would you like to do?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AwareScrollTheme.onSurface,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'You set a 5-minute boundary for Instagram. Take an intentional pause before continuing or wrapping up.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AwareScrollTheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 36),

        // Action Buttons
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AwareScrollTheme.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _handleCloseApp,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.door_front_door_outlined, size: 19),
                SizedBox(width: 8),
                Text(
                  'Close Instagram',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AwareScrollTheme.onSurface,
              side: const BorderSide(color: AwareScrollTheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _switchState(2),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology_outlined, size: 18, color: AwareScrollTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Continue (Requires Reflection)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 16, color: AwareScrollTheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STATE 2: CONSCIOUS REFLECTION SURVEY
  // ==========================================
  Widget _buildState2Survey() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flow header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => _switchState(1),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AwareScrollTheme.outline),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, size: 14, color: AwareScrollTheme.onSurfaceVariant),
                    SizedBox(width: 4),
                    Text(
                      'Close App',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AwareScrollTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '● RECONSIDERATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Color(0xFF00A86B),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Progress line
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 4,
            width: double.infinity,
            color: AwareScrollTheme.outline,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.75,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AwareScrollTheme.instagramGradient,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Conscious Reflection',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AwareScrollTheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Answer the following reflections to unlock a temporary extension.',
          style: TextStyle(
            fontSize: 12,
            color: AwareScrollTheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),

        // Q1: Purpose
        _buildSurveyCard(
          number: '1',
          title: 'Purpose of Usage',
          subtitle: 'Why do you want use it, clearly mention your purpose?',
          options: const [
            'Reply to a message',
            'Checking someone\'s reply',
            'Check updates',
            'Nothing to do, so watch reels',
            'Finished all tasks, want to watch reels',
            'Study or research',
            'Opened automatically / out of habit',
          ],
          selected: _selectedPurpose,
          onSelect: (val) => setState(() => _selectedPurpose = val),
        ),

        // Q2: Trigger Factor
        _buildSurveyCard(
          number: '2',
          title: 'Psychological Trigger',
          subtitle: 'What most influenced your decision to continue?',
          options: const [
            'Interesting content',
            'Boredom',
            'Stress / mood',
            'Notifications / messages',
            'Habitual scrolling',
            'Unfinished original purpose',
          ],
          selected: _selectedTrigger,
          onSelect: (val) => setState(() => _selectedTrigger = val),
        ),

        // Q3: Content Category
        _buildSurveyCard(
          number: '3',
          title: 'Content Category',
          subtitle: 'Which content category kept you engaged?',
          options: const [
            'Comedy / Memes',
            'Education / Technology',
            'News / Politics',
            'Stories / Personal content',
            'Fitness / Lifestyle',
            'Music / Entertainment',
            'Other / Mixed',
          ],
          selected: _selectedCategory,
          onSelect: (val) => setState(() => _selectedCategory = val),
        ),

        // Q4: Effect on planned work
        _buildSurveyCard(
          number: '4',
          title: 'Effect on Planned Work',
          subtitle: 'How did this session affect your planned work?',
          options: const [
            'No task planned',
            'Delayed a task',
            'Interrupted a task',
            'No negative impact / planned break',
          ],
          selected: _selectedWorkImpact,
          onSelect: (val) => setState(() => _selectedWorkImpact = val),
        ),

        // Q5: Emotional state
        _buildSurveyCard(
          number: '5',
          title: 'Emotional State',
          subtitle: 'How do you feel after scrolling?',
          options: const [
            'Satisfied',
            'Relaxed',
            'Neutral',
            'Bored',
            'Stressed / regretful',
          ],
          selected: _selectedFeeling,
          onSelect: (val) => setState(() => _selectedFeeling = val),
        ),

        // Q6: Supposed to be doing
        _buildSurveyCard(
          number: '6',
          title: 'Displaced Intention',
          subtitle: 'What were you supposed to be doing?',
          options: const [
            'Studying',
            'Working',
            'Sleeping',
            'Socializing',
            'Relaxing',
            'Nothing planned',
          ],
          selected: _selectedSupposedActivity,
          onSelect: (val) => setState(() => _selectedSupposedActivity = val),
        ),

        // Q7: What would help stop
        _buildSurveyCard(
          number: '7',
          title: 'Intervention Help',
          subtitle: 'What would have helped you stop?',
          options: const [
            'Time warning',
            'Original-purpose reminder',
            'Mood check',
            'Break suggestion',
            'App closure',
          ],
          selected: _selectedHelpStop,
          onSelect: (val) => setState(() => _selectedHelpStop = val),
        ),

        // Q8: Extension Commitment
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AwareScrollTheme.outline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06141528),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Color(0xFFE8F8F0),
                    child: Text(
                      '8',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A86B),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Extension Commitment',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AwareScrollTheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose your conscious extension duration:',
                style: TextStyle(
                  fontSize: 12,
                  color: AwareScrollTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDurationChip(2, '+2m', 'Quick check'),
                  const SizedBox(width: 8),
                  _buildDurationChip(5, '+5m', 'Rec', isRecommended: true),
                  const SizedBox(width: 8),
                  _buildDurationChip(10, '+10m', 'Deep dive'),
                  const SizedBox(width: 8),
                  _buildDurationChip(15, '+15m', 'Cap'),
                ],
              ),
            ],
          ),
        ),

        // Confirm & Unlock CTA
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AwareScrollTheme.secondaryEmerald,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _handleUnlockCommitment,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Confirm & Unlock (+$_selectedExtensionMin Min Extension)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.lock_open, size: 18),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Center(
          child: Text(
            'Instagram will re-lock immediately when this extension expires.',
            style: TextStyle(
              fontSize: 10,
              color: AwareScrollTheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSurveyCard({
    required String number,
    required String title,
    required String subtitle,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AwareScrollTheme.outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06141528),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: AwareScrollTheme.surfaceContainerHigh,
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AwareScrollTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AwareScrollTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AwareScrollTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: options.map((opt) {
              final isSel = opt == selected;
              return GestureDetector(
                onTap: () => onSelect(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSel ? AwareScrollTheme.surfaceContainerLow : const Color(0xFFFCF8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel ? AwareScrollTheme.primary : AwareScrollTheme.outline,
                      width: isSel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            color: isSel ? AwareScrollTheme.primary : AwareScrollTheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSel ? AwareScrollTheme.primary : Colors.white,
                          border: Border.all(
                            color: isSel ? AwareScrollTheme.primary : AwareScrollTheme.outlineVariant,
                          ),
                        ),
                        child: isSel
                            ? const Center(
                                child: Icon(Icons.check, size: 11, color: Colors.white),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip(int min, String label, String sub, {bool isRecommended = false}) {
    final isSel = _selectedExtensionMin == min;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedExtensionMin = min),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFE8F8F0) : const Color(0xFFFCF8FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? AwareScrollTheme.secondaryEmerald : AwareScrollTheme.outline,
              width: isSel ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSel ? AwareScrollTheme.secondaryEmerald : AwareScrollTheme.onSurface,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  color: isSel ? AwareScrollTheme.secondaryEmerald : AwareScrollTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STATE 3: UNLOCK CONFIRMATION & COUNTDOWN
  // ==========================================
  Widget _buildState3Unlock() {
    final m = _countdownRemainingSec ~/ 60;
    final s = _countdownRemainingSec % 60;
    final countdownStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    final total = _selectedExtensionMin * 60;
    final pct = total > 0 ? (_countdownRemainingSec / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F8F0),
            shape: BoxShape.circle,
            border: Border.all(color: AwareScrollTheme.secondaryEmerald.withOpacity(0.3)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2000B894),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.lock_open, color: AwareScrollTheme.secondaryEmerald, size: 42),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F8F0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            '● SESSION UNLOCKED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Color(0xFF00A86B),
              fontFamily: 'monospace',
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Extension Granted',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AwareScrollTheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Scroll with mindful awareness. Your countdown has initiated.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AwareScrollTheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 24),

        // Live Countdown Ticker Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AwareScrollTheme.outline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C141528),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'REMAINING ALLOWANCE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AwareScrollTheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                countdownStr,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: AwareScrollTheme.secondaryEmerald,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: AwareScrollTheme.surfaceContainer,
                  valueColor: const AlwaysStoppedAnimation<Color>(AwareScrollTheme.secondaryEmerald),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AwareScrollTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: widget.onReturnToControl,
            child: const Text(
              'Return to Control Dashboard',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// TAB 3: USER ACCOUNT & INSIGHTS (DATA SCIENCE LAB)
// ==========================================
class UserAccountInsightsTab extends StatefulWidget {
  const UserAccountInsightsTab({super.key});

  @override
  State<UserAccountInsightsTab> createState() => _UserAccountInsightsTabState();
}

class _UserAccountInsightsTabState extends State<UserAccountInsightsTab> {
  static const MethodChannel _channel = MethodChannel('com.awarescroll/restriction');

  String _selectedRange = 'today';
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  String _studentId = 'Loading...';
  String _cloudSyncUrl = 'https://script.google.com/macros/s/AKfycby_awarescroll/exec';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadTelemetry();
  }

  Future<void> _loadTelemetry() async {
    setState(() => _isLoading = true);
    try {
      final jsonStr = await _channel.invokeMethod<String>('getSurveyHistory');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          _records = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
      final sId = await _channel.invokeMethod<String>('getStudentId');
      if (sId != null && sId.isNotEmpty) {
        _studentId = sId;
      }
      final cUrl = await _channel.invokeMethod<String>('getCloudSyncUrl');
      if (cUrl != null && cUrl.isNotEmpty) {
        _cloudSyncUrl = cUrl;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changeStudentId() async {
    final controller = TextEditingController(text: _studentId);
    final newId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Set Student / Roll No ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Each of the 60+ students in your study should have a distinct identifier for data science grouping.',
              style: TextStyle(fontSize: 12, color: AwareScrollTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Student Identifier',
                hintText: 'e.g. Student_042 or ROLL_105',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AwareScrollTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newId != null && newId.isNotEmpty && newId != _studentId) {
      try {
        await _channel.invokeMethod('setStudentId', {'studentId': newId});
        setState(() => _studentId = newId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AwareScrollTheme.secondaryEmerald,
              content: Text('Student ID updated to $newId'),
            ),
          );
        }
      } catch (_) {}
    }
  }

  Future<void> _changeCloudSyncUrl() async {
    final controller = TextEditingController(text: _cloudSyncUrl);
    final newUrl = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Central Cloud Webhook', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All 60+ student devices stream survey records directly into this central Google Sheets / Webhook endpoint.',
              style: TextStyle(fontSize: 12, color: AwareScrollTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Webhook URL',
                hintText: 'https://script.google.com/macros/s/.../exec',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AwareScrollTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save URL'),
          ),
        ],
      ),
    );

    if (newUrl != null && newUrl.isNotEmpty && newUrl != _cloudSyncUrl) {
      try {
        await _channel.invokeMethod('setCloudSyncUrl', {'url': newUrl});
        setState(() => _cloudSyncUrl = newUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AwareScrollTheme.secondaryEmerald,
              content: Text('Cloud Webhook URL updated!'),
            ),
          );
        }
      } catch (_) {}
    }
  }

  Future<void> _syncToCloudMaster() async {
    setState(() => _isSyncing = true);
    try {
      final success = await _channel.invokeMethod<bool>('syncAllToCloud') ?? false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: success ? AwareScrollTheme.secondaryEmerald : AwareScrollTheme.tertiaryAmber,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                Icon(success ? Icons.cloud_done : Icons.cloud_queue, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    success
                        ? 'Master Cloud Sync Complete! (${_records.length} records pushed)'
                        : 'Local buffer saved! Will auto-push when cloud endpoint is reachable.',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    }
    if (mounted) {
      setState(() => _isSyncing = false);
    }
  }

  Future<void> _armPreemptiveGuard() async {
    try {
      await _channel.invokeMethod('startRestriction', {
        'appName': 'Instagram',
        'packageName': 'com.instagram.android',
        'minutes': 1,
        'seconds': 60,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AwareScrollTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🛡️ Pre-emptive Guard Armed! Instagram intercept active to block habitual night scrolling.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _copyCsvDataset() async {
    try {
      final csv = await _channel.invokeMethod<String>('getSurveyCsv') ?? '';
      await Clipboard.setData(ClipboardData(text: csv));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AwareScrollTheme.secondaryEmerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'CSV Dataset copied! (${_records.length} records ready for Excel / Google Sheets)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to copy CSV: $e')),
        );
      }
    }
  }

  Future<void> _copyJsonDataset() async {
    try {
      final jsonStr = await _channel.invokeMethod<String>('getSurveyHistory') ?? '';
      await Clipboard.setData(ClipboardData(text: jsonStr));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AwareScrollTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.code, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'JSON Dataset copied! (${_records.length} records ready for Python / Pandas)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to copy JSON: $e')),
        );
      }
    }
  }

  Future<void> _reloadSampleTelemetry() async {
    try {
      await _channel.invokeMethod('loadSampleTelemetry');
      await _loadTelemetry();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AwareScrollTheme.primary,
            content: Text('Loaded 15+ Data Science sample sessions across 7 days!'),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _clearTelemetry() async {
    try {
      await _channel.invokeMethod('clearSurveyHistory');
      setState(() => _records = []);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telemetry dataset cleared.')),
        );
      }
    } catch (_) {}
  }

  void _showRawDataTable() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AwareScrollTheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.table_chart, color: AwareScrollTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Raw Dataset (${_records.length} rows)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AwareScrollTheme.onSurface),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Text(
              'Telemetry collected from Instagram continuation surveys for your Data Science project.',
              style: TextStyle(fontSize: 12, color: AwareScrollTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _records.isEmpty
                  ? const Center(child: Text('No records collected yet.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(AwareScrollTheme.surfaceContainerLow),
                          columns: const [
                            DataColumn(label: Text('Student ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            DataColumn(label: Text('Trigger (Q2)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            DataColumn(label: Text('Category (Q3)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            DataColumn(label: Text('Work Impact (Q4)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            DataColumn(label: Text('Feeling (Q5)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            DataColumn(label: Text('Supposed (Q6)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            DataColumn(label: Text('Ext (Min)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          ],
                          rows: _records.map((r) {
                            return DataRow(
                              cells: [
                                DataCell(Text((r['studentId'] ?? _studentId).toString(), style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AwareScrollTheme.primary))),
                                DataCell(Text((r['timestamp'] ?? '').toString().split('T').last.split('+').first, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
                                DataCell(Text((r['dayOfWeek'] ?? '').toString(), style: const TextStyle(fontSize: 11))),
                                DataCell(Text((r['trigger'] ?? '').toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AwareScrollTheme.onSurface))),
                                DataCell(Text((r['category'] ?? '').toString(), style: const TextStyle(fontSize: 11))),
                                DataCell(Text((r['workImpact'] ?? '').toString(), style: const TextStyle(fontSize: 11))),
                                DataCell(Text((r['feeling'] ?? '').toString(), style: const TextStyle(fontSize: 11))),
                                DataCell(Text((r['supposedActivity'] ?? '').toString(), style: const TextStyle(fontSize: 11))),
                                DataCell(Text('+${r['extensionMinutes'] ?? 0}m', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AwareScrollTheme.secondaryEmerald))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper metrics calculations
  Map<String, double> _computeDistribution(String key) {
    if (_records.isEmpty) return {};
    final counts = <String, int>{};
    for (final r in _records) {
      final val = (r[key] ?? 'Unknown').toString();
      counts[val] = (counts[val] ?? 0) + 1;
    }
    final total = _records.length;
    final res = <String, double>{};
    counts.forEach((k, v) {
      res[k] = v / total;
    });
    return res;
  }

  Map<String, int> _computeDayMinutes() {
    final dayMinutes = {'M': 35, 'T': 40, 'W': 45, 'T2': 42, 'F': 28, 'S': 30, 'S2': 24};
    for (final r in _records) {
      final day = (r['dayOfWeek'] ?? '').toString().toLowerCase();
      final sec = (r['elapsedSeconds'] as int?) ?? 300;
      final m = (sec / 60).round();
      if (day.startsWith('mon')) dayMinutes['M'] = (dayMinutes['M']! + m) ~/ 2;
      if (day.startsWith('tue')) dayMinutes['T'] = (dayMinutes['T']! + m) ~/ 2;
      if (day.startsWith('wed')) dayMinutes['W'] = (dayMinutes['W']! + m) ~/ 2;
      if (day.startsWith('thu')) dayMinutes['T2'] = (dayMinutes['T2']! + m) ~/ 2;
      if (day.startsWith('fri')) dayMinutes['F'] = (dayMinutes['F']! + m) ~/ 2;
      if (day.startsWith('sat')) dayMinutes['S'] = (dayMinutes['S']! + m) ~/ 2;
      if (day.startsWith('sun')) dayMinutes['S2'] = (dayMinutes['S2']! + m) ~/ 2;
    }
    return dayMinutes;
  }

  Map<String, dynamic> _computeFuturePrediction() {
    final hourCounts = <int, int>{};
    for (final r in _records) {
      final h = (r['hourOfDay'] as int?) ?? 22;
      hourCounts[h] = (hourCounts[h] ?? 0) + 1;
    }
    int peakHour = 22;
    int maxCount = 0;
    hourCounts.forEach((h, c) {
      if (c > maxCount) {
        maxCount = c;
        peakHour = h;
      }
    });

    final windowStart = peakHour % 12 == 0 ? 12 : peakHour % 12;
    final startAmPm = peakHour >= 12 ? 'PM' : 'AM';
    final windowEnd = (peakHour + 1) % 12 == 0 ? 12 : (peakHour + 1) % 12;
    final endAmPm = (peakHour + 1) >= 12 ? 'PM' : 'AM';
    final dangerWindowStr = '$windowStart:00 $startAmPm – $windowEnd:30 $endAmPm';

    final triggerDist = _computeDistribution('trigger');
    String topTrigger = 'Boredom / Fatigue';
    double topTriggerPct = 0.44;
    if (triggerDist.isNotEmpty) {
      final sorted = triggerDist.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      topTrigger = sorted.first.key;
      topTriggerPct = sorted.first.value;
    }

    final catDist = _computeDistribution('category');
    String topCat = 'Comedy / Memes';
    double topCatPct = 0.58;
    if (catDist.isNotEmpty) {
      final sorted = catDist.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      topCat = sorted.first.key;
      topCatPct = sorted.first.value;
    }

    final now = DateTime.now();
    final hourDiff = (now.hour - peakHour).abs();
    int riskScore;
    String riskLabel;
    Color riskColor;
    if (hourDiff <= 1 || (now.hour >= 21 && peakHour >= 21)) {
      riskScore = 84;
      riskLabel = 'CRITICAL VULNERABILITY';
      riskColor = const Color(0xFFE53935);
    } else if (hourDiff <= 3 || now.hour >= 18) {
      riskScore = 65;
      riskLabel = 'HIGH VULNERABILITY';
      riskColor = AwareScrollTheme.tertiaryAmber;
    } else if (now.hour >= 12 && now.hour < 18) {
      riskScore = 38;
      riskLabel = 'MODERATE RISK';
      riskColor = AwareScrollTheme.primary;
    } else {
      riskScore = 18;
      riskLabel = 'LOW RISK';
      riskColor = AwareScrollTheme.secondaryEmerald;
    }

    final nextUrgeStr = 'Tonight at ~$windowStart:${((peakHour * 7) % 30) + 15} $startAmPm';
    const displacementForecast = 'High probability of displacing 35m+ of study/sleep';

    return {
      'dangerWindow': dangerWindowStr,
      'peakHour': peakHour,
      'topTrigger': topTrigger,
      'topTriggerPct': (topTriggerPct * 100).round(),
      'topCat': topCat,
      'topCatPct': (topCatPct * 100).round(),
      'riskScore': riskScore,
      'riskLabel': riskLabel,
      'riskColor': riskColor,
      'nextUrgeStr': nextUrgeStr,
      'displacementForecast': displacementForecast,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AwareScrollTheme.background,
        body: Center(child: CircularProgressIndicator(color: AwareScrollTheme.primary)),
      );
    }

    final triggerDist = _computeDistribution('trigger');
    final categoryDist = _computeDistribution('category');
    final workImpactDist = _computeDistribution('workImpact');
    final feelingDist = _computeDistribution('feeling');
    final dayMins = _computeDayMinutes();
    final prediction = _computeFuturePrediction();

    final totalInterventions = _records.length;
    final totalMinutes = _records.fold<int>(0, (sum, r) => sum + (((r['elapsedSeconds'] as int?) ?? 300) ~/ 60));
    final calmPreservedMin = _records.fold<int>(0, (sum, r) {
      final ext = (r['extensionMinutes'] as int?) ?? 0;
      return sum + (ext <= 2 ? 15 : (ext <= 5 ? 10 : 5));
    });

    return Scaffold(
      backgroundColor: AwareScrollTheme.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // Profile & Focus Hero Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AwareScrollTheme.outline),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A141528),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AwareScrollTheme.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AwareScrollTheme.outline),
                                ),
                                child: const Center(
                                  child: Icon(Icons.person, color: AwareScrollTheme.primary, size: 26),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: AwareScrollTheme.secondaryEmerald,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Alex Morgan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AwareScrollTheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: AwareScrollTheme.primaryFixed,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'PRO',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AwareScrollTheme.primary,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                '@alex.mindful',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AwareScrollTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AwareScrollTheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AwareScrollTheme.tertiaryAmber.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.local_fire_department, size: 15, color: AwareScrollTheme.tertiaryAmber),
                            SizedBox(width: 4),
                            Text(
                              '14d Streak',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AwareScrollTheme.onTertiaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AwareScrollTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Column(
                          children: [
                            Text(
                              'SHIELD HEALTH',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: AwareScrollTheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              '94%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AwareScrollTheme.secondaryEmerald,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'AWARENESS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: AwareScrollTheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Lvl ${(totalInterventions / 3).clamp(1, 10).toInt()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AwareScrollTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'NET CALM',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: AwareScrollTheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '+${(calmPreservedMin / 60).toStringAsFixed(1)}h',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AwareScrollTheme.secondaryEmerald,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Time Filter Switcher
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AwareScrollTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _buildTimeFilterItem('Today', 'today'),
                  _buildTimeFilterItem('This Week', 'week'),
                  _buildTimeFilterItem('This Month', 'month'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Primary Metric Module: Instagram Focus
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AwareScrollTheme.outline),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08141528),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.stream, size: 18, color: AwareScrollTheme.primary),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instagram Focus',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AwareScrollTheme.onSurface,
                                ),
                              ),
                              Text(
                                'Target cap: 45 min/day',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AwareScrollTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AwareScrollTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_records.length} Sessions',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AwareScrollTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _buildKpiCard('TOTAL TIME', '${totalMinutes}m', 'Tracked', AwareScrollTheme.secondaryEmerald),
                      const SizedBox(width: 8),
                      _buildKpiCard('INTERVENTIONS', '$totalInterventions', 'Responses', AwareScrollTheme.primary),
                      const SizedBox(width: 8),
                      _buildKpiCard('CALM SAVED', '${calmPreservedMin}m', 'Preserved', AwareScrollTheme.secondaryEmerald),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 7-day chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily Rhythm vs 45m Cap',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AwareScrollTheme.onSurface,
                        ),
                      ),
                      Text(
                        'Avg: ${(totalMinutes / 7).round()}m/day',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AwareScrollTheme.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar('M', dayMins['M']!, 45),
                      _buildBar('T', dayMins['T']!, 45),
                      _buildBar('W', dayMins['W']!, 45, isExceeded: dayMins['W']! > 45),
                      _buildBar('T', dayMins['T2']!, 45, isToday: true),
                      _buildBar('F', dayMins['F']!, 45),
                      _buildBar('S', dayMins['S']!, 45),
                      _buildBar('S', dayMins['S2']!, 45),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==========================================
            // FUTURE ANALYSIS PREDICTION (PAST -> PRESENT -> FUTURE)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFF9F7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AwareScrollTheme.primary.withOpacity(0.35), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x123A5BFF),
                    blurRadius: 14,
                    offset: Offset(0, 4),
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3A5BFF), Color(0xFF833AB4)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Future Analysis Prediction',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AwareScrollTheme.onSurface,
                                ),
                              ),
                              Text(
                                'Past Telemetry • Present Risk • Future Move',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AwareScrollTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (prediction['riskColor'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: (prediction['riskColor'] as Color).withOpacity(0.4)),
                        ),
                        child: Text(
                          prediction['riskLabel'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: prediction['riskColor'] as Color,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 1. PAST: Behavioral Trends
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AwareScrollTheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.history_toggle_off_rounded, size: 15, color: AwareScrollTheme.primary),
                            SizedBox(width: 6),
                            Text(
                              'PAST TELEMETRY (Behavior Pattern)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: AwareScrollTheme.primary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Peak Danger Window', style: TextStyle(fontSize: 10, color: AwareScrollTheme.onSurfaceVariant)),
                                  const SizedBox(height: 2),
                                  Text(
                                    prediction['dangerWindow'] as String,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AwareScrollTheme.onSurface),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 28, color: AwareScrollTheme.outline),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Primary Trigger', style: TextStyle(fontSize: 10, color: AwareScrollTheme.onSurfaceVariant)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${prediction['topTrigger']} (${prediction['topTriggerPct']}%)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AwareScrollTheme.onSurface),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 2. PRESENT: Live Vulnerability Risk Score
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AwareScrollTheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.speed_rounded, size: 15, color: AwareScrollTheme.tertiaryAmber),
                                SizedBox(width: 6),
                                Text(
                                  'PRESENT VULNERABILITY SCORE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: AwareScrollTheme.tertiaryAmber,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${prediction['riskScore']}% Risk',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: prediction['riskColor'] as Color,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (prediction['riskScore'] as int) / 100.0,
                            minHeight: 8,
                            backgroundColor: AwareScrollTheme.surfaceContainerLow,
                            valueColor: AlwaysStoppedAnimation<Color>(prediction['riskColor'] as Color),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (prediction['riskScore'] as int) >= 60
                              ? '⚠️ Approaching peak habit window. Fatigue or boredom will strongly tempt Instagram opening.'
                              : '✅ Lower vulnerability right now. Shield is actively preserving focus.',
                          style: const TextStyle(fontSize: 11, color: AwareScrollTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 3. FUTURE: Predictive Urge Forecast & Impact
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF6FE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2D6F5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology_outlined, size: 16, color: Color(0xFF7E3FF2)),
                            SizedBox(width: 6),
                            Text(
                              'PREDICTED NEXT HABIT MOVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Color(0xFF7E3FF2),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🔮 Next Urge Forecast: ${prediction['nextUrgeStr']}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AwareScrollTheme.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Driver: ${prediction['topTrigger']} -> ${prediction['topCat']}',
                          style: const TextStyle(fontSize: 11, color: AwareScrollTheme.onSurfaceVariant),
                        ),
                        Text(
                          'Displacement Impact: ${prediction['displacementForecast']}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFFC0392B), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. ACTIONABLE AVOIDANCE PLAN
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AwareScrollTheme.secondaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AwareScrollTheme.secondaryEmerald.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.checklist_rounded, size: 16, color: AwareScrollTheme.secondaryEmerald),
                            SizedBox(width: 6),
                            Text(
                              'HOW TO AVOID THIS HABIT LOOP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: AwareScrollTheme.secondaryEmerald,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('1. ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AwareScrollTheme.secondaryEmerald)),
                            Expanded(child: Text('Physical Distance: Place phone across the room 15 min prior to peak window.', style: TextStyle(fontSize: 11, color: AwareScrollTheme.onSurface))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('2. ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AwareScrollTheme.secondaryEmerald)),
                            Expanded(child: Text('Micro-Intervention: Substitute the reflex with 2-minute mindful breathing or water.', style: TextStyle(fontSize: 11, color: AwareScrollTheme.onSurface))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('3. ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AwareScrollTheme.secondaryEmerald)),
                            Expanded(child: Text('Pre-emptive Lock: Arm the AwareScroll restriction shield right now.', style: TextStyle(fontSize: 11, color: AwareScrollTheme.onSurface))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Pre-emptive Guard CTA
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AwareScrollTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.shield_rounded, size: 18),
                      label: const Text(
                        '🛡️ Arm Pre-emptive Guard (Lock Danger Window)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _armPreemptiveGuard,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==========================================
            // 60+ STUDENTS RESEARCH & MASTER CLOUD SYNC
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFF7F5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AwareScrollTheme.secondaryEmerald.withOpacity(0.4), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1000B894),
                    blurRadius: 12,
                    offset: Offset(0, 4),
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AwareScrollTheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.group_work_rounded, color: AwareScrollTheme.secondaryEmerald, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '60+ Student Research Study',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AwareScrollTheme.onSurface,
                                ),
                              ),
                              Text(
                                'Data Science Master Repository',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AwareScrollTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _changeStudentId,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AwareScrollTheme.primaryFixed,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AwareScrollTheme.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _studentId,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AwareScrollTheme.primary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit, size: 11, color: AwareScrollTheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'All 60+ participants stream question responses (Purpose, Trigger, Category, Impact, Emotion, Displaced Task) with unique student IDs into a centralized dataset for Python & Pandas analytics.',
                    style: TextStyle(fontSize: 11, color: AwareScrollTheme.onSurfaceVariant, height: 1.4),
                  ),

                  const SizedBox(height: 12),

                  // Cloud Sync Banner / Trigger Button
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AwareScrollTheme.outline),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.cloud_sync_outlined, size: 16, color: AwareScrollTheme.primary),
                                SizedBox(width: 6),
                                Text(
                                  'Master Cloud Webhook',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AwareScrollTheme.onSurface),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: _changeCloudSyncUrl,
                              child: const Text('Configure ⚙️', style: TextStyle(fontSize: 10, color: AwareScrollTheme.primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _cloudSyncUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AwareScrollTheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AwareScrollTheme.secondaryEmerald,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            icon: _isSyncing
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.cloud_upload_outlined, size: 16),
                            label: Text(
                              _isSyncing ? 'Syncing Records...' : '☁️ Push Data to Class Master Cloud',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _isSyncing ? null : _syncToCloudMaster,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Export Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AwareScrollTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.file_download_outlined, size: 16),
                          label: const Text('Copy CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: _copyCsvDataset,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B46C1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.code_rounded, size: 16),
                          label: const Text('Copy JSON', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: _copyJsonDataset,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AwareScrollTheme.onSurface,
                            side: const BorderSide(color: AwareScrollTheme.outline),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.table_view_outlined, size: 16, color: AwareScrollTheme.primary),
                          label: const Text('Inspect Table', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          onPressed: _showRawDataTable,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AwareScrollTheme.onSurface,
                            side: const BorderSide(color: AwareScrollTheme.outline),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.auto_graph_outlined, size: 16, color: AwareScrollTheme.tertiaryAmber),
                          label: const Text('Reload Sample', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          onPressed: _reloadSampleTelemetry,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 14, color: AwareScrollTheme.onSurfaceVariant),
                      label: const Text('Clear Telemetry', style: TextStyle(fontSize: 10, color: AwareScrollTheme.onSurfaceVariant)),
                      onPressed: _clearTelemetry,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Compulsive Trigger Breakdown (from Real Dataset!)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AwareScrollTheme.outline),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08141528),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Compulsive Trigger Breakdown',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AwareScrollTheme.onSurface,
                        ),
                      ),
                      Text(
                        'Q2 Telemetry',
                        style: TextStyle(fontSize: 10, color: AwareScrollTheme.primary, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (triggerDist.isEmpty)
                    const Text('No trigger data recorded yet.', style: TextStyle(fontSize: 12, color: AwareScrollTheme.onSurfaceVariant))
                  else
                    ...triggerDist.entries.map((e) {
                      final pct = (e.value * 100).round();
                      final color = e.key.contains('Boredom')
                          ? AwareScrollTheme.primary
                          : (e.key.contains('Habitual')
                              ? AwareScrollTheme.tertiaryAmber
                              : (e.key.contains('Notifications')
                                  ? const Color(0xFF6C8CFF)
                                  : AwareScrollTheme.secondaryEmerald));
                      return _buildTriggerBar(e.key, e.value, '$pct%', color);
                    }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content Category Distribution (from Real Dataset!)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AwareScrollTheme.outline),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08141528),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Content Category Distribution',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AwareScrollTheme.onSurface,
                        ),
                      ),
                      Text(
                        'Q3 Telemetry',
                        style: TextStyle(fontSize: 10, color: AwareScrollTheme.secondaryEmerald, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (categoryDist.isEmpty)
                    const Text('No category data recorded yet.', style: TextStyle(fontSize: 12, color: AwareScrollTheme.onSurfaceVariant))
                  else
                    ...categoryDist.entries.map((e) {
                      final pct = (e.value * 100).round();
                      return _buildTriggerBar(e.key, e.value, '$pct%', AwareScrollTheme.secondaryEmerald);
                    }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Productivity Impact & Emotional Sentiment Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AwareScrollTheme.outline),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08141528),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Work Impact & Post-Scroll Sentiment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AwareScrollTheme.onSurface,
                        ),
                      ),
                      Text(
                        'Q4 & Q5',
                        style: TextStyle(fontSize: 10, color: AwareScrollTheme.tertiaryAmber, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (workImpactDist.isEmpty && feelingDist.isEmpty)
                    const Text('No impact data recorded yet.', style: TextStyle(fontSize: 12, color: AwareScrollTheme.onSurfaceVariant))
                  else ...[
                    const Text('Work Impact:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AwareScrollTheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    ...workImpactDist.entries.map((e) {
                      final pct = (e.value * 100).round();
                      final col = e.key.contains('Delayed') || e.key.contains('Interrupted') ? const Color(0xFFE53935) : AwareScrollTheme.secondaryEmerald;
                      return _buildTriggerBar(e.key, e.value, '$pct%', col);
                    }),
                    const SizedBox(height: 8),
                    const Text('Post-Scroll Emotion:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AwareScrollTheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    ...feelingDist.entries.map((e) {
                      final pct = (e.value * 100).round();
                      final col = e.key.contains('Stressed') ? const Color(0xFFE53935) : AwareScrollTheme.primary;
                      return _buildTriggerBar(e.key, e.value, '$pct%', col);
                    }),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterItem(String label, String value) {
    final isSel = _selectedRange == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRange = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? AwareScrollTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                color: isSel ? Colors.white : AwareScrollTheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildKpiCard(String label, String value, String sub, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AwareScrollTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: AwareScrollTheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AwareScrollTheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: col,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildBar(String day, int val, int cap, {bool isToday = false, bool isExceeded = false}) {
    final heightRatio = (val / 60.0).clamp(0.1, 1.0);
    final col = isExceeded
        ? const Color(0xFFE53935)
        : (isToday ? AwareScrollTheme.primary : AwareScrollTheme.primary.withOpacity(0.35));

    return Column(
      children: [
        Text(
          '${val}m',
          style: TextStyle(
            fontSize: 9,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AwareScrollTheme.primary : AwareScrollTheme.onSurfaceVariant,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 16,
          height: 80 * heightRatio,
          decoration: BoxDecoration(
            color: col,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AwareScrollTheme.primary : AwareScrollTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static Widget _buildTriggerBar(String label, double ratio, String percent, Color col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AwareScrollTheme.onSurface,
                ),
              ),
              Text(
                percent,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: col,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AwareScrollTheme.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(col),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// POST-SESSION DEBRIEF MODAL (SCREEN 5)
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AwareScrollTheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AwareScrollTheme.secondaryEmerald, size: 44),
          const SizedBox(height: 10),
          const Text(
            'Session Complete!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AwareScrollTheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'You successfully honored your boundary and stepped away.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AwareScrollTheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AwareScrollTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AwareScrollTheme.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      'SCROLLED',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 0.6,
                        color: AwareScrollTheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AwareScrollTheme.onSurface,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Container(height: 30, width: 1, color: AwareScrollTheme.outline),
                const Column(
                  children: [
                    Text(
                      'CALM SAVED',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 0.6,
                        color: AwareScrollTheme.secondaryEmerald,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '+15m 00s',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AwareScrollTheme.secondaryEmerald,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'How do you feel right now?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AwareScrollTheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),

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
                    color: isSel ? AwareScrollTheme.primaryFixed : AwareScrollTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel ? AwareScrollTheme.primary : AwareScrollTheme.outline,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? AwareScrollTheme.primary : AwareScrollTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Did this delay your planned tasks?',
                style: TextStyle(fontSize: 12, color: AwareScrollTheme.onSurface),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _taskDelayed = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: !_taskDelayed ? AwareScrollTheme.secondaryContainer : AwareScrollTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !_taskDelayed ? AwareScrollTheme.secondaryEmerald : AwareScrollTheme.outline,
                        ),
                      ),
                      child: const Text('No 👍', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _taskDelayed = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _taskDelayed ? AwareScrollTheme.primaryFixed : AwareScrollTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _taskDelayed ? AwareScrollTheme.primary : AwareScrollTheme.outline,
                        ),
                      ),
                      child: const Text('Yes ⏳', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AwareScrollTheme.secondaryEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                try {
                  const MethodChannel('com.awarescroll/restriction').invokeMethod('recordSurveyResponse', {
                    'appName': 'Instagram',
                    'packageName': 'com.instagram.android',
                    'limitMinutes': widget.limitSeconds ~/ 60,
                    'elapsedSeconds': widget.elapsedSeconds,
                    'extensionMinutes': 0,
                    'purpose': 'Mindful Wrap-up',
                    'trigger': 'Mindful Exit',
                    'category': 'General',
                    'workImpact': _taskDelayed ? 'Delayed a task' : 'No task planned',
                    'feeling': _selectedSentiment,
                    'supposedActivity': 'Stepped Away',
                    'helpStop': 'App closure',
                    'sessionOutcome': 'closed_mindfully',
                  });
                } catch (_) {}
                widget.onFinished();
              },
              child: const Text(
                'Finish & Return to Home →',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
