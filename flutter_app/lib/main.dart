// ignore_for_file: deprecated_member_use

import 'dart:async';
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
// TAB 3: USER ACCOUNT & INSIGHTS (SCREEN 3)
// ==========================================
class UserAccountInsightsTab extends StatefulWidget {
  const UserAccountInsightsTab({super.key});

  @override
  State<UserAccountInsightsTab> createState() => _UserAccountInsightsTabState();
}

class _UserAccountInsightsTabState extends State<UserAccountInsightsTab> {
  String _selectedRange = 'today';

  @override
  Widget build(BuildContext context) {
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
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
                            Text(
                              'AWARENESS',
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
                              'Lvl 8',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AwareScrollTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'NET CALM',
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
                              '+3.4h',
                              style: TextStyle(
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
                        child: const Text(
                          'Today, Oct 24',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AwareScrollTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _buildKpiCard('SCREEN TIME', '42m', '-38% vs lw', AwareScrollTheme.secondaryEmerald),
                      const SizedBox(width: 8),
                      _buildKpiCard('INTERVENTIONS', '6', '4 held / 2 ext', AwareScrollTheme.primary),
                      const SizedBox(width: 8),
                      _buildKpiCard('CALM SAVED', '18m', 'Preserved', AwareScrollTheme.secondaryEmerald),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 7-day chart
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Rhythm vs 45m Cap',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AwareScrollTheme.onSurface,
                        ),
                      ),
                      Text(
                        'Avg: 37m/day',
                        style: TextStyle(
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

            const SizedBox(height: 16),

            // Compulsive Trigger Breakdown
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
                  const Text(
                    'Compulsive Trigger Breakdown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AwareScrollTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildTriggerBar('Boredom / Under-stimulation', 0.44, '44%', AwareScrollTheme.primary),
                  _buildTriggerBar('Habitual / Reflexive', 0.28, '28%', AwareScrollTheme.tertiaryAmber),
                  _buildTriggerBar('Notifications & DMs', 0.16, '16%', const Color(0xFF6C8CFF)),
                  _buildTriggerBar('Dopamine / Content Hook', 0.12, '12%', AwareScrollTheme.secondaryEmerald),
                ],
              ),
            ),

            const SizedBox(height: 20),
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
              onPressed: widget.onFinished,
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
