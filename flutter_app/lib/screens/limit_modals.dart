// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. SET YOUR LIMIT MODAL (PRE-SESSION INTENTION)
// ==========================================
class SetYourLimitModal extends StatefulWidget {
  final VoidCallback onLaunchInstagram;

  const SetYourLimitModal({
    super.key,
    required this.onLaunchInstagram,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLaunchInstagram,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SetYourLimitModal(
        onLaunchInstagram: onLaunchInstagram,
      ),
    );
  }

  @override
  State<SetYourLimitModal> createState() => _SetYourLimitModalState();
}

class _SetYourLimitModalState extends State<SetYourLimitModal> {
  int _selectedMinutes = 5;
  String _selectedPurpose = "Reply to DMs";

  final List<String> _purposes = [
    "Reply to DMs",
    "Quick check",
    "Catch up with friends",
    "Education / Research",
    "Entertainment / Reels",
  ];

  final List<int> _durations = [5, 10, 15, 20];

  Future<void> _confirmAndLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('session_limit_minutes', _selectedMinutes);
    await prefs.setString('session_intention', _selectedPurpose);

    if (mounted) {
      Navigator.of(context).pop();
      widget.onLaunchInstagram();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grab handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E4F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Cute Illustration & Tag Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A5BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'AWARESCROLL INTENTION GATE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Color(0xFF3A5BFF),
                  ),
                ),
              ),
              const Row(
                children: [
                  Text('🌱', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 4),
                  Text('🐱', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          const Text(
            'Set Your Focus Boundary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF14152B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose your session purpose and strict duration before entering the feed.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B6F8C),
            ),
          ),

          const SizedBox(height: 18),

          // Purpose Chips
          const Text(
            '1. WHAT IS YOUR GOAL?',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Color(0xFF747688),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _purposes.map((purpose) {
              final isSelected = _selectedPurpose == purpose;
              return ChoiceChip(
                label: Text(purpose),
                selected: isSelected,
                selectedColor: const Color(0xFF3A5BFF),
                backgroundColor: const Color(0xFFF5F2FF),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF14152B),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF3A5BFF) : const Color(0xFFE2E4F0),
                  ),
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedPurpose = purpose);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Duration Chips
          const Text(
            '2. STRICT TIME LIMIT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Color(0xFF747688),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _durations.map((dur) {
              final isSelected = _selectedMinutes == dur;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _selectedMinutes = dur),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF3A5BFF) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3A5BFF)
                              : const Color(0xFFE2E4F0),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF3A5BFF).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            '${dur}m',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF14152B),
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (dur == 5)
                            Text(
                              'Ideal',
                              style: TextStyle(
                                fontSize: 9,
                                color: isSelected ? Colors.white70 : const Color(0xFF00B894),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Primary Launch Button
          ElevatedButton.icon(
            onPressed: _confirmAndLaunch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A5BFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.shield, size: 18),
            label: Text(
              'LAUNCH INSTAGRAM (${_selectedMinutes}M PROTECTED)',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. LIMIT EXPIRY BOTTOM SHEET
// ==========================================
class LimitExpirySheet extends StatelessWidget {
  final VoidCallback onCloseApp;
  final VoidCallback onOpenCatOasis;
  final VoidCallback onOpenSurvey;

  const LimitExpirySheet({
    super.key,
    required this.onCloseApp,
    required this.onOpenCatOasis,
    required this.onOpenSurvey,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCloseApp,
    required VoidCallback onOpenCatOasis,
    required VoidCallback onOpenSurvey,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LimitExpirySheet(
        onCloseApp: onCloseApp,
        onOpenCatOasis: onOpenCatOasis,
        onOpenSurvey: onOpenSurvey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Amber top grab
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9F43),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 18),

          // Circular SVG-styled timer visual
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF9F43).withOpacity(0.12),
              border: Border.all(color: const Color(0xFFFF9F43), width: 3),
            ),
            alignment: Alignment.center,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '05:00',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Color(0xFF824700),
                  ),
                ),
                Text(
                  'LIMIT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9F43),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Mindful Boundary Reached',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF14152B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your 5-minute intended scroll has expired. Reclaim your awareness and preserve mental energy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B6F8C),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Primary Option 1: Close Instagram
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onCloseApp();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B894),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text(
              'CLOSE INSTAGRAM (RECOMMENDED)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          // Option 2: Mindful Cat Companion Break
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onOpenCatOasis();
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFF3A5BFF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFF3A5BFF).withOpacity(0.06),
            ),
            icon: const Text('🐾', style: TextStyle(fontSize: 16)),
            label: const Text(
              'Take a 2-Min Cat Lounge Break',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A5BFF),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Option 3: Continue past limit (opens survey)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOpenSurvey();
            },
            child: const Text(
              'I must continue (Complete Intentionality Check)',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF747688),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. INTENTIONALITY REFLECTION SURVEY MODAL
// ==========================================
class ReflectionSurveyModal extends StatefulWidget {
  final VoidCallback onCompleteSurvey;

  const ReflectionSurveyModal({
    super.key,
    required this.onCompleteSurvey,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCompleteSurvey,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReflectionSurveyModal(
        onCompleteSurvey: onCompleteSurvey,
      ),
    );
  }

  @override
  State<ReflectionSurveyModal> createState() => _ReflectionSurveyModalState();
}

class _ReflectionSurveyModalState extends State<ReflectionSurveyModal> {
  static const platform = MethodChannel('com.awarescroll.app/service');

  String _wasImportant = "No, mindless scrolling";
  String _necessity = "Total distraction";
  String _reason = "Avoiding other work";
  bool _isSubmitting = false;

  final List<String> _necessityOptions = [
    "Essential update",
    "Helpful / Inspiring",
    "Just entertaining",
    "Total distraction",
  ];

  final List<String> _reasons = [
    "Finishing a conversation",
    "Got hooked on Reels",
    "Avoiding other work",
    "Pure boredom",
  ];

  Future<void> _submitSurvey(bool shouldContinue) async {
    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('student_email') ??
          prefs.getString('student_id') ??
          '24bt04d233@gsfcuniversity.ac.in';

      // Log telemetry event to native Kotlin & Google Sheet Webhook
      await platform.invokeMethod('recordTelemetryFeedback', {
        'studentId': studentId,
        'wasImportant': _wasImportant,
        'necessity': _necessity,
        'reason': _reason,
        'continued': shouldContinue,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {}

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      widget.onCompleteSurvey();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F43),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A5BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'INTENTIONALITY CHECK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Color(0xFF3A5BFF),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const Text(
              'Intentionality Check',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14152B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Help AwareScroll understand your session value before extending time.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B6F8C)),
            ),

            const SizedBox(height: 16),

            // Question 1: Was that scroll important?
            const Text(
              '1. Was that scroll important?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceCard(
                    title: 'Yes, meaningful',
                    icon: Icons.check,
                    color: const Color(0xFF3A5BFF),
                    isSelected: _wasImportant == 'Yes, meaningful',
                    onTap: () => setState(() => _wasImportant = 'Yes, meaningful'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildChoiceCard(
                    title: 'No, mindless',
                    icon: Icons.close,
                    color: const Color(0xFFFF9F43),
                    isSelected: _wasImportant == 'No, mindless scrolling',
                    onTap: () => setState(() => _wasImportant = 'No, mindless scrolling'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Question 2: Information necessity
            const Text(
              '2. Was the information consumed necessary?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: _necessityOptions.map((opt) {
                final isSelected = _necessity == opt;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => setState(() => _necessity = opt),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3A5BFF).withOpacity(0.08)
                            : const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF3A5BFF) : const Color(0xFFE2E4F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 18,
                            color: isSelected ? const Color(0xFF3A5BFF) : const Color(0xFF747688),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            opt,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF3A5BFF) : const Color(0xFF14152B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // Question 3: Why do you need more time?
            const Text(
              '3. Why do you need more time?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reasons.map((r) {
                final isSelected = _reason == r;
                return ChoiceChip(
                  label: Text(r),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFF9F43),
                  backgroundColor: const Color(0xFFF5F2FF),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF14152B),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _reason = r);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Quick breathing tip card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00B894).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF00B894).withOpacity(0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco, color: Color(0xFF00B894), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quick tip: Inhale for 4 seconds, exhale for 4 seconds before extending your screen-time.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF006B55), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Action Buttons
            ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitSurvey(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F43),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isSubmitting ? 'SAVING...' : 'SAVE & CONTINUE (+5 MINS)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            const SizedBox(height: 8),

            OutlinedButton(
              onPressed: _isSubmitting ? null : () => _submitSurvey(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE5484D),
                side: const BorderSide(color: Color(0xFFE5484D)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save & Close Instagram',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF5F2FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E4F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF14152B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
