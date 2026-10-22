// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'models.dart';

void main() {
  runApp(const AwareScrollApp());
}

class AwareScrollApp extends StatelessWidget {
  const AwareScrollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AwareScroll AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isAuthenticated = false;
  String _userEmail = '';

  // Local state telemetry for sessions
  final List<SessionRecord> _sessions = [
    SessionRecord(
      id: 'session-1',
      appName: 'Instagram',
      intendedMinutes: 5,
      actualMinutes: 5.0,
      closedOnFirstReminder: true,
      timeOfDay: 'morning',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    SessionRecord(
      id: 'session-2',
      appName: 'YouTube',
      intendedMinutes: 5,
      actualMinutes: 10.0,
      closedOnFirstReminder: false,
      timeOfDay: 'afternoon',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      feedback: {
        'decision': 'Interesting content',
        'feeling': 'Relaxed',
      },
    ),
  ];

  void _triggerInterruptionModal({String appName = 'Instagram'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InterruptionFlowModal(
        appName: appName,
        onSessionCompleted: (record) {
          setState(() {
            _sessions.insert(0, record);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return AuthScreen(
        onAuthenticated: (email) {
          setState(() {
            _userEmail = email;
            _isAuthenticated = true;
          });
        },
      );
    }

    final screens = [
      DashboardView(
        sessions: _sessions,
        userEmail: _userEmail,
        onTriggerTestInterruption: () => _triggerInterruptionModal(),
      ),
      AppSelectorView(
        onSelectApp: (appName) => _triggerInterruptionModal(appName: appName),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AwareScroll AI',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _userEmail.isNotEmpty ? _userEmail : 'GSFC University Study',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary, size: 20),
            onPressed: () => setState(() => _isAuthenticated = false),
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps, color: AppColors.primary),
            label: 'Apps',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _triggerInterruptionModal(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.timer_outlined, color: Colors.white),
        label: const Text('Simulate 5m Expiry', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ==========================================
// SCREEN 1: GOOGLE WORKSPACE AUTH SCREEN
// ==========================================
class AuthScreen extends StatefulWidget {
  final Function(String email) onAuthenticated;
  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _rollController = TextEditingController();
  String? _errorMessage;

  void _verifyAndSignIn(String email) {
    final clean = email.trim().toLowerCase();
    if (!clean.endsWith('@gsfcuniversity.ac.in')) {
      setState(() {
        _errorMessage = 'Access Restricted: Only official @gsfcuniversity.ac.in accounts are permitted.';
      });
      return;
    }
    setState(() => _errorMessage = null);
    widget.onAuthenticated(clean);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Institutional Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'GSFC UNIVERSITY • BEHAVIORAL STUDY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Center Illustration & Pitch
              Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AwareScroll AI',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Social Media Time Restriction & Rapid Survey',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),

              // Bottom Authentication Options
              Column(
                children: [
                  // Primary 1-Tap Google Workspace Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 1,
                        shape: RoundedCornerShape(14),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.blue),
                      label: const Text(
                        'Sign In with GSFC Google Account',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () {
                        // Instant simulated verification for study demo
                        _verifyAndSignIn('student@gsfcuniversity.ac.in');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'OR ENTER ROLL NO',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _rollController,
                          decoration: InputDecoration(
                            hintText: 'e.g. 22bt04001',
                            suffixText: '@gsfcuniversity.ac.in',
                            suffixStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedCornerShape(12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          if (_rollController.text.isNotEmpty) {
                            _verifyAndSignIn('${_rollController.text.trim()}@gsfcuniversity.ac.in');
                          }
                        },
                        child: const Text('Enter', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Exclusive to GSFC University students & faculty. Telemetry data is anonymously aggregated for class presentations.',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SCREEN 2: IN-BUILT DASHBOARD & CHRONOTYPE
// ==========================================
class DashboardView extends StatelessWidget {
  final List<SessionRecord> sessions;
  final String userEmail;
  final VoidCallback onTriggerTestInterruption;

  const DashboardView({
    super.key,
    required this.sessions,
    required this.userEmail,
    required this.onTriggerTestInterruption,
  });

  @override
  Widget build(BuildContext context) {
    final totalMinutesToday = sessions.fold<double>(0, (sum, s) => sum + s.actualMinutes).toInt();
    final firstReminderRate = sessions.isNotEmpty
        ? (sessions.where((s) => s.closedOnFirstReminder).length * 100) ~/ sessions.length
        : 100;

    final morningMins = sessions.where((s) => s.timeOfDay == 'morning').fold<double>(0, (sum, s) => sum + s.actualMinutes).toInt();
    final afternoonMins = sessions.where((s) => s.timeOfDay == 'afternoon').fold<double>(0, (sum, s) => sum + s.actualMinutes).toInt();
    final eveningMins = sessions.where((s) => s.timeOfDay == 'evening').fold<double>(0, (sum, s) => sum + s.actualMinutes).toInt();
    final nightMins = sessions.where((s) => s.timeOfDay == 'night').fold<double>(0, (sum, s) => sum + s.actualMinutes).toInt();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 2x2 Telemetry Cards
        Row(
          children: [
            Expanded(child: _StatCard(title: 'Time Today', value: '$totalMinutesToday min', subtitle: 'Social media usage')),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: '1st Reminder Success', value: '$firstReminderRate%', subtitle: 'Closed on 5m alarm', valueColor: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(title: 'Recorded Sessions', value: '${sessions.length}', subtitle: 'Total logs')),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Limit Enforcement', value: 'Strict 5m', subtitle: 'Auto-lock active', valueColor: AppColors.accentReflect)),
          ],
        ),

        const SizedBox(height: 20),

        // Chronotype Analysis Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Peak Usage Times (Chronotype)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Icon(Icons.schedule, size: 16, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ChronotypeCol(label: 'Morning', time: '6am-12pm', minutes: morningMins),
                  _ChronotypeCol(label: 'Afternoon', time: '12-5pm', minutes: afternoonMins),
                  _ChronotypeCol(label: 'Evening', time: '5-9pm', minutes: eveningMins),
                  _ChronotypeCol(label: 'Night', time: '9pm-6am', minutes: nightMins),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Session History Header
        const Text('Recent Session History & Surveys', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (sessions.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('No sessions logged yet.')))
        else
          ...sessions.map((s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedCornerShape(12),
                color: Colors.white,
                elevation: 0.5,
                child: ListTile(
                  title: Text(s.appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(
                    '${s.timeOfDay.toUpperCase()} • ${s.actualMinutes.toInt()} mins • ${s.closedOnFirstReminder ? "Closed on 1st" : "Extended (Survey filled)"}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (s.closedOnFirstReminder ? AppColors.secondary : AppColors.accentReflect).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.closedOnFirstReminder ? 'Protected' : 'Extended',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: s.closedOnFirstReminder ? AppColors.secondary : AppColors.accentReflect,
                      ),
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color? valueColor;

  const _StatCard({required this.title, required this.value, required this.subtitle, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor ?? AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ChronotypeCol extends StatelessWidget {
  final String label;
  final String time;
  final int minutes;
  const _ChronotypeCol({required this.label, required this.time, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(time, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('$minutes m', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }
}

// ==========================================
// SCREEN 3: APP SELECTION & TIME LIMITS
// ==========================================
class AppSelectorView extends StatelessWidget {
  final Function(String appName) onSelectApp;
  const AppSelectorView({super.key, required this.onSelectApp});

  @override
  Widget build(BuildContext context) {
    final apps = [
      {'name': 'Instagram', 'category': 'Reels & Feed', 'icon': Icons.camera_alt, 'color': Colors.purple},
      {'name': 'YouTube', 'category': 'Shorts & Videos', 'icon': Icons.play_circle_fill, 'color': Colors.red},
      {'name': 'Snapchat', 'category': 'Spotlight & Stories', 'icon': Icons.chat_bubble, 'color': Colors.amber},
      {'name': 'Facebook', 'category': 'Feed & Watch', 'icon': Icons.facebook, 'color': Colors.blue},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Guarded Social Apps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 6),
        const Text('Click an app to set limit and simulate 5-minute scrolling interruption.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        ...apps.map((app) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedCornerShape(14),
              color: Colors.white,
              elevation: 0.5,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (app['color'] as Color).withOpacity(0.12),
                  child: Icon(app['icon'] as IconData, color: app['color'] as Color),
                ),
                title: Text(app['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(app['category'] as String, style: const TextStyle(fontSize: 11)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedCornerShape(10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => onSelectApp(app['name'] as String),
                  child: const Text('Set 5m', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            )),
      ],
    );
  }
}

// ==========================================
// SCREEN 4: 5-MIN INTERRUPTION & RAPID SURVEY
// ==========================================
class InterruptionFlowModal extends StatefulWidget {
  final String appName;
  final Function(SessionRecord) onSessionCompleted;

  const InterruptionFlowModal({
    super.key,
    required this.appName,
    required this.onSessionCompleted,
  });

  @override
  State<InterruptionFlowModal> createState() => _InterruptionFlowModalState();
}

class _InterruptionFlowModalState extends State<InterruptionFlowModal> {
  int _step = 0; // 0: Expiry Alert, 1: Survey Form, 2: Quote & 5m Free

  // Survey responses
  String _decisionTrigger = 'Boredom';
  String _contentCategory = 'Comedy / Memes';
  String _workImpact = 'Delayed a task';
  String _feeling = 'Neutral';
  String _supposedToDo = 'Studying';
  String _helpfulStopper = 'Time warning';

  String _quoteText = '';
  String _quoteAuthor = '';

  void _generateQuote() {
    if (_supposedToDo.contains('Studying')) {
      _quoteText = 'You have power over your mind - not outside events. Realize this, and you will find strength.';
      _quoteAuthor = 'Marcus Aurelius';
    } else if (_decisionTrigger.contains('Boredom') || _decisionTrigger.contains('Habitual')) {
      _quoteText = 'It is not that we have a short time to live, but that we waste a lot of it.';
      _quoteAuthor = 'Seneca';
    } else {
      _quoteText = 'Clarity about what matters provides clarity about what does not.';
      _quoteAuthor = 'Cal Newport';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _step == 0
            ? _buildExpiryPrompt()
            : _step == 1
                ? _buildSurveyForm()
                : _buildQuoteAndExtension(),
      ),
    );
  }

  // Phase 1: 5-Minute Limit Expiry (CLOSE vs CONTINUE)
  Widget _buildExpiryPrompt() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentReflect.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '5:00 LIMIT REACHED',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentReflect, fontSize: 11),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Take a breath? 5 minutes completed on ${widget.appName}.',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Mindful pause: Would you like to close the app now, or answer a rapid 3-second survey to continue?',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedCornerShape(14),
            ),
            onPressed: () {
              // Positive compliance logged!
              widget.onSessionCompleted(SessionRecord(
                id: 'sess-${DateTime.now().millisecondsSinceEpoch}',
                appName: widget.appName,
                intendedMinutes: 5,
                actualMinutes: 5.0,
                closedOnFirstReminder: true,
                timeOfDay: _getCurrentTimeBucket(),
                timestamp: DateTime.now(),
              ));
              Navigator.pop(context);
            },
            child: Text('CLOSE ${widget.appName.toUpperCase()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedCornerShape(14),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            onPressed: () => setState(() => _step = 1),
            child: const Text('Continue scrolling anyway', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }

  // Phase 2: Rapid 3-5s Survey Form
  Widget _buildSurveyForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Quick 3-Second Reflection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Select your immediate answers to receive your tailored quote.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 12),

          _buildChipQuestion('1. What kept you scrolling?', [
            'Interesting content',
            'Boredom',
            'Stress / mood',
            'Notifications',
            'Habitual scrolling',
          ], _decisionTrigger, (val) => setState(() => _decisionTrigger = val)),

          _buildChipQuestion('2. Content category?', [
            'Comedy / Memes',
            'Education / Tech',
            'News / Politics',
            'Stories / Personal',
            'Entertainment',
          ], _contentCategory, (val) => setState(() => _contentCategory = val)),

          _buildChipQuestion('3. What were you supposed to be doing?', [
            'Studying',
            'Working',
            'Sleeping',
            'Socializing',
            'Nothing planned',
          ], _supposedToDo, (val) => setState(() => _supposedToDo = val)),

          _buildChipQuestion('4. How do you feel right now?', [
            'Satisfied',
            'Relaxed',
            'Neutral',
            'Bored',
            'Regretful',
          ], _feeling, (val) => setState(() => _feeling = val)),

          _buildChipQuestion('5. Did scrolling impact planned tasks?', [
            'No impact',
            'Delayed a task',
            'Skipped completely',
          ], _workImpact, (val) => setState(() => _workImpact = val)),

          _buildChipQuestion('6. What would help you stop?', [
            'Time warning',
            'Screen lock',
            'Accountability prompt',
            'Mindful pause',
          ], _helpfulStopper, (val) => setState(() => _helpfulStopper = val)),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedCornerShape(14),
              ),
              onPressed: () {
                _generateQuote();
                setState(() => _step = 2);
              },
              child: const Text('SUBMIT & GET QUOTE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Phase 3: Quote & 5-Min Extension
  Widget _buildQuoteAndExtension() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '5-MINUTE EXTENSION UNLOCKED',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 11),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '“$_quoteText”',
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          '— $_quoteAuthor',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text(
          'Notice: After this 5-minute extension, the app will strictly lock to protect your focus.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedCornerShape(14),
            ),
            onPressed: () {
              widget.onSessionCompleted(SessionRecord(
                id: 'sess-${DateTime.now().millisecondsSinceEpoch}',
                appName: widget.appName,
                intendedMinutes: 5,
                actualMinutes: 10.0,
                closedOnFirstReminder: false,
                timeOfDay: _getCurrentTimeBucket(),
                timestamp: DateTime.now(),
                feedback: {
                  'decision': _decisionTrigger,
                  'contentCategory': _contentCategory,
                  'supposedToDo': _supposedToDo,
                  'feeling': _feeling,
                  'workImpact': _workImpact,
                  'helpfulStopper': _helpfulStopper,
                },
              ));
              Navigator.pop(context);
            },
            child: Text('CONTINUE TO ${widget.appName.toUpperCase()} (5 MIN)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildChipQuestion(String title, List<String> options, String selected, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((opt) {
            final isSel = opt == selected;
            return ChoiceChip(
              label: Text(opt, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.textPrimary)),
              selected: isSel,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.bgLight,
              onSelected: (_) => onSelect(opt),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  String _getCurrentTimeBucket() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }
}
