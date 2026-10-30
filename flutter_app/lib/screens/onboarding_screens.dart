// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. WELCOME & SIGN IN SCREEN
// ==========================================
class WelcomeSignInScreen extends StatelessWidget {
  final VoidCallback onProceedToCohort;
  final VoidCallback onSkipToDashboard;

  const WelcomeSignInScreen({
    super.key,
    required this.onProceedToCohort,
    required this.onSkipToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Micro Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A5BFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFF3A5BFF),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'AwareScroll AI • Behavioral Study',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A5BFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'v2.4',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Color(0xFF747688),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.verified_user, size: 16, color: Color(0xFF006B55)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Brand Icon & Header
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF141528).withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'AwareScroll',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Color(0xFF181930),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Reclaim your attention from doom-scrolling.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF747688),
                ),
              ),

              const SizedBox(height: 24),

              // Hero Cute Illustration Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF141528).withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFE1E0FF)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 32)),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A5BFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.laptop_chromebook,
                            color: Color(0xFF3A5BFF),
                            size: 36,
                          ),
                        ),
                        const Text('😺', style: TextStyle(fontSize: 36)),
                        const Text('🧶', style: TextStyle(fontSize: 28)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Mindful Intention • Empathetic Reflection',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF123DE7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Primary Auth CTA: Universal Email Sign In / Registration
              ElevatedButton.icon(
                onPressed: onProceedToCohort,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A5BFF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.email_outlined, size: 20),
                label: const Text(
                  'Sign In or Register with Email',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  if (prefs.getString('student_email') == null || prefs.getString('student_email')!.isEmpty) {
                    await prefs.setString('student_name', 'Guest Student');
                    await prefs.setString('student_user_name', 'Guest Student');
                    await prefs.setString('student_email', 'guest@awarescroll.local');
                    await prefs.setString('student_user_email', 'guest@awarescroll.local');
                    await prefs.setString('student_id', 'GUEST');
                  }
                  await prefs.setBool('user_logged_in', true);
                  await prefs.setBool('has_completed_onboarding', true);
    await prefs.setBool('user_logged_in', true);
                  onSkipToDashboard();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFFC4C5D9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF181930)),
                label: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF181930),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'By continuing, you participate in the anonymous\nMinor Project Screen-Time Self-Regulation Study.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF747688),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. COHORT REGISTRATION SCREEN
// ==========================================
// ==========================================
// 2. COHORT & UNIVERSAL AUTH SCREEN (ANY EMAIL)
// ==========================================
class CohortRegistrationScreen extends StatefulWidget {
  final VoidCallback onProceedToPermissions;

  const CohortRegistrationScreen({
    super.key,
    required this.onProceedToPermissions,
  });

  @override
  State<CohortRegistrationScreen> createState() => _CohortRegistrationScreenState();
}

class _CohortRegistrationScreenState extends State<CohortRegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idController = TextEditingController();
  bool _consentChecked = true;
  bool _obscurePassword = true;
  bool _isSignUp = true;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('student_name') ?? 'Krish Makwana';
      _emailController.text = prefs.getString('student_email') ?? '';
      _passwordController.text = prefs.getString('student_password') ?? '';
      _idController.text = prefs.getString('student_id') ?? '';
    });
  }

  Future<void> _saveAndProceed() async {
    final email = _emailController.text.trim().toLowerCase();
    final name = _nameController.text.trim();
    final password = _passwordController.text;
    final id = _idController.text.trim();

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Gmail / Email address.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    if (password.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 4 characters.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_name', name.isNotEmpty ? name : 'Krish Makwana');
    await prefs.setString('student_user_name', name.isNotEmpty ? name : 'Krish Makwana');
    await prefs.setString('student_email', email);
    await prefs.setString('student_user_email', email);
    await prefs.setString('student_password', password);
    await prefs.setString('student_id', id.isNotEmpty ? id : email);
    await prefs.setBool('user_logged_in', true);
    await prefs.setBool('has_completed_onboarding', true);
    await prefs.setBool('user_logged_in', true);

    widget.onProceedToPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181930)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _isSignUp ? 'Create Student Account' : 'Sign In with Email',
          style: const TextStyle(
            color: Color(0xFF181930),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode switcher tab
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isSignUp = true),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isSignUp ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isSignUp
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Register Account',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _isSignUp ? FontWeight.bold : FontWeight.normal,
                              color: _isSignUp ? const Color(0xFF3A5BFF) : const Color(0xFF747688),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isSignUp = false),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isSignUp ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !_isSignUp
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: !_isSignUp ? FontWeight.bold : FontWeight.normal,
                              color: !_isSignUp ? const Color(0xFF3A5BFF) : const Color(0xFF747688),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _isSignUp ? 'Join Behavioral Study' : 'Welcome Back',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181930),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Log in with any personal Gmail or Email account. Your screen telemetry and intention data will be privately isolated to your device profile.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF444656),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // 1. Full Name Field (Always shown or prefilled)
              _buildInputField(
                label: 'FULL NAME',
                controller: _nameController,
                icon: Icons.person_outline,
                hint: 'e.g. Krish Makwana',
              ),

              const SizedBox(height: 14),

              // 2. Universal Email Field
              _buildInputField(
                label: 'GMAIL / EMAIL ADDRESS (UNIVERSAL)',
                controller: _emailController,
                icon: Icons.alternate_email,
                hint: 'e.g. krish@gmail.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              // 3. Password Field
              _buildInputField(
                label: 'ACCOUNT PASSWORD',
                controller: _passwordController,
                icon: Icons.lock_outline,
                hint: 'Enter your account password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: const Color(0xFF747688),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 14),

              // 4. Student ID / Roll No (Optional)
              _buildInputField(
                label: 'STUDENT ID / ROLL NO. (OPTIONAL)',
                controller: _idController,
                icon: Icons.badge_outlined,
                hint: 'e.g. 24BT04D233 or username',
              ),

              const SizedBox(height: 20),

              // Study Consent Checkbox
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE1E0FF)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _consentChecked,
                      activeColor: const Color(0xFF3A5BFF),
                      onChanged: (val) => setState(() => _consentChecked = val ?? true),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'I agree to log my Instagram intention & session duration anonymously for research credit in the Minor Project.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF444656),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Primary Submit Button
              ElevatedButton(
                onPressed: _consentChecked ? _saveAndProceed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A5BFF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp ? 'CONFIRM & REGISTER' : 'SIGN IN & CONTINUE',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141528).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE1E0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Color(0xFF747688),
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF181930),
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFC4C5D9),
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF3A5BFF)),
              prefixIconConstraints: const BoxConstraints(minWidth: 28, maxHeight: 20),
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}

class AppProtectionSetupScreen extends StatefulWidget {
  final VoidCallback onFinishOnboarding;

  const AppProtectionSetupScreen({
    super.key,
    required this.onFinishOnboarding,
  });

  @override
  State<AppProtectionSetupScreen> createState() => _AppProtectionSetupScreenState();
}

class _AppProtectionSetupScreenState extends State<AppProtectionSetupScreen>
    with SingleTickerProviderStateMixin {
  static const platform = MethodChannel('com.awarescroll.app/service');

  bool _accessibilityGranted = false;
  bool _usageStatsGranted = false;
  bool _overlayGranted = false;
  bool _isLoading = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _checkPermissions();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    try {
      final bool hasAccessibility =
          await platform.invokeMethod('isAccessibilityServiceEnabled');
      final bool hasUsage =
          await platform.invokeMethod('isUsageStatsPermissionGranted');
      final bool hasOverlay =
          await platform.invokeMethod('isOverlayPermissionGranted');

      if (mounted) {
        setState(() {
          _accessibilityGranted = hasAccessibility;
          _usageStatsGranted = hasUsage;
          _overlayGranted = hasOverlay;
        });
      }
    } catch (_) {}
  }

  Future<void> _triggerOneClickSetup() async {
    setState(() => _isLoading = true);
    try {
      await platform.invokeMethod('openOneClickAuthorization');
    } catch (_) {}
    await Future.delayed(const Duration(seconds: 1));
    await _checkPermissions();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    await prefs.setBool('user_logged_in', true);
    widget.onFinishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _accessibilityGranted && _usageStatsGranted && _overlayGranted;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181930)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Protection Permissions',
          style: TextStyle(
            color: Color(0xFF181930),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Step chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEE0FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Step 3 of 3 • Final Step',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF123DE7),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: 16,
                        color: allGranted ? const Color(0xFF00B894) : const Color(0xFFFF9F43),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        allGranted ? 'System Shield: ACTIVE' : 'Shield: PENDING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: allGranted ? const Color(0xFF00B894) : const Color(0xFFFF9F43),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Hero Radar Pulse Badge
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3A5BFF).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFF3A5BFF).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF3A5BFF),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x333A5BFF),
                              blurRadius: 18,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          allGranted ? Icons.shield : Icons.shield_outlined,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              const Text(
                'Activate AwareScroll Shield',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181930),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'AwareScroll detects when you open Instagram to prompt your intention and guard against mindless overruns.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF444656),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              // 1-Click Shield Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _triggerOneClickSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A5BFF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.flash_on, size: 20),
                label: Text(
                  _isLoading ? 'Checking...' : '1-Click Shield Authorization',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),

              const SizedBox(height: 18),

              // Permission Details Checklist Cards
              _buildPermCheck(
                title: 'Accessibility Service',
                subtitle: 'Detects Instagram window opening in real-time',
                isGranted: _accessibilityGranted,
                icon: Icons.accessibility_new,
                onTap: () => platform.invokeMethod('openAccessibilitySettings'),
              ),
              const SizedBox(height: 8),
              _buildPermCheck(
                title: 'Usage Access',
                subtitle: 'Tracks active session time vs. your limit',
                isGranted: _usageStatsGranted,
                icon: Icons.data_usage,
                onTap: () => platform.invokeMethod('openUsageStatsSettings'),
              ),
              const SizedBox(height: 8),
              _buildPermCheck(
                title: 'Display Over Apps',
                subtitle: 'Renders mindful reflection modal at limit boundary',
                isGranted: _overlayGranted,
                icon: Icons.layers_outlined,
                onTap: () => platform.invokeMethod('openOverlaySettings'),
              ),

              const SizedBox(height: 24),

              // Complete Button
              ElevatedButton(
                onPressed: _completeSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allGranted ? const Color(0xFF00B894) : const Color(0xFF181930),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  allGranted ? 'ENTER DASHBOARD' : 'CONTINUE TO DASHBOARD',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermCheck({
    required String title,
    required String subtitle,
    required bool isGranted,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isGranted ? const Color(0xFF00B894).withOpacity(0.4) : const Color(0xFFE1E0FF),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isGranted
                    ? const Color(0xFF00B894).withOpacity(0.12)
                    : const Color(0xFFF5F2FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isGranted ? const Color(0xFF00B894) : const Color(0xFF3A5BFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181930),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF747688),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isGranted ? Icons.check_circle : Icons.arrow_forward_ios,
              size: isGranted ? 20 : 14,
              color: isGranted ? const Color(0xFF00B894) : const Color(0xFFC4C5D9),
            ),
          ],
        ),
      ),
    );
  }
}
