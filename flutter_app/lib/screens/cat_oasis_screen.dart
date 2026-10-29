// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';

class CatOasisScreen extends StatefulWidget {
  final VoidCallback? onReturnToDashboard;

  const CatOasisScreen({super.key, this.onReturnToDashboard});

  @override
  State<CatOasisScreen> createState() => _CatOasisScreenState();
}

class _CatOasisScreenState extends State<CatOasisScreen>
    with TickerProviderStateMixin {
  bool _purrActive = true;
  int _currentQuoteIndex = 0;
  int _yarnRollCount = 0;
  int _treatsRemaining = 3;
  int _stressLevel = 18; // lower is calmer

  String? _cat1MoodText;
  String? _cat2MoodText;

  late AnimationController _bobController;
  late Animation<double> _bobAnimation;

  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  late AnimationController _yarnController;
  late Animation<double> _yarnAnimation;

  final List<Map<String, String>> _catQuotes = [
    {
      "cat": "Mochi (Zen Master Cat)",
      "quote":
          "The algorithm will still be there tomorrow, hooman. Your peaceful evening is happening right now.",
    },
    {
      "cat": "Boba (Sleepy Guardian)",
      "quote":
          "Doom-scrolling drains your battery and your soul. Put the phone down and breathe with me.",
    },
    {
      "cat": "Mochi (Philosopher Cat)",
      "quote":
          "You opened Instagram to check one thing 45 minutes ago. Remember who holds the leash, friend.",
    },
    {
      "cat": "Boba (Chief Nap Officer)",
      "quote":
          "Every notification is just someone else renting space in your head for free. Evict them!",
    },
    {
      "cat": "Mochi (Zen Master Cat)",
      "quote":
          "Infinite scrolling does not lead to infinite wisdom. Come scratch my ears instead.",
    },
    {
      "cat": "Boba (Zen Master Cat)",
      "quote":
          "When you feel the itch to scroll, stretch like a cat, drink cold water, and reclaim your focus.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _bobAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _yarnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _yarnAnimation = Tween<double>(begin: 0, end: -18).animate(
      CurvedAnimation(parent: _yarnController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _bobController.dispose();
    _breatheController.dispose();
    _yarnController.dispose();
    super.dispose();
  }

  void _rollNewQuote() {
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % _catQuotes.length;
    });
  }

  void _tapCat(String catId) {
    _rollNewQuote();
    setState(() {
      _stressLevel = max(5, _stressLevel - 3);
      if (catId == 'mochi') {
        _cat1MoodText = "Purrrr! +1 Focus ✨";
      } else {
        _cat2MoodText = "Meow! Calming down 🧘‍♂️";
      }
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          if (catId == 'mochi') {
            _cat1MoodText = null;
          } else {
            _cat2MoodText = null;
          }
        });
      }
    });
  }

  void _playWithYarn() {
    _yarnController.forward().then((_) => _yarnController.reverse());
    setState(() {
      _yarnRollCount++;
      _stressLevel = max(5, _stressLevel - 2);
    });
  }

  void _giveTreat() {
    if (_treatsRemaining > 0) {
      setState(() {
        _treatsRemaining--;
        _stressLevel = max(5, _stressLevel - 5);
        _cat1MoodText = "Nom nom! 🐟";
        _cat2MoodText = "Tasty fish! ❤️";
      });

      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) {
          setState(() {
            _cat1MoodText = null;
            _cat2MoodText = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuote = _catQuotes[_currentQuoteIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        leading: widget.onReturnToDashboard != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF14152B)),
                onPressed: widget.onReturnToDashboard,
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF3A5BFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'MINDFUL BREAK',
                style: TextStyle(
                  color: Color(0xFF3A5BFF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Neko Wisdom Lounge',
              style: TextStyle(
                color: Color(0xFF14152B),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: const Text('🐾', style: TextStyle(fontSize: 13)),
              label: Text(
                _purrActive ? 'Purr: ON' : 'Purr: OFF',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF14152B),
                ),
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () {
                setState(() => _purrActive = !_purrActive);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Quote Speech Bubble Card
              _buildQuoteBubble(currentQuote),

              const SizedBox(height: 16),

              // 2. Interactive Cats Playground Canvas
              _buildCatsPlayground(),

              const SizedBox(height: 16),

              // 3. Dopamine Reset & Interactive Stats Bar
              _buildDopamineMeter(),

              const SizedBox(height: 16),

              // 4. Action Buttons (Treats & Return to Focus)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _treatsRemaining > 0 ? _giveTreat : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFFF9F43)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: const Color(0xFFFF9F43).withOpacity(0.08),
                      ),
                      icon: const Text('🐟', style: TextStyle(fontSize: 16)),
                      label: Text(
                        'Treat ($_treatsRemaining left)',
                        style: const TextStyle(
                          color: Color(0xFF824700),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (widget.onReturnToDashboard != null) {
                          widget.onReturnToDashboard!();
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A5BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'I\'m Refreshed • Return',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteBubble(Map<String, String> quote) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A5BFF).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A5BFF).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9F43).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('💬', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    quote["cat"] ?? "Zen Master Cat",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14152B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Dopamine Reset',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B894),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${quote["quote"]}"',
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: Color(0xFF14152B),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F2F9)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B894),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Tap cats or yarn to interact',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B6F8C)),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _rollNewQuote,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  foregroundColor: const Color(0xFF3A5BFF),
                ),
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text(
                  'Next Wisdom',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatsPlayground() {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14152B).withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background soft hill lines
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: CustomPaint(
              painter: _HillPainter(),
            ),
          ),

          // Central Yarn Ball
          Positioned(
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Toss the Ball! 🧶',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B6F8C),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _playWithYarn,
                  child: AnimatedBuilder(
                    animation: _yarnAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _yarnAnimation.value),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00B894).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🧶', style: TextStyle(fontSize: 18)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14152B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_yarnRollCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Left Cat (Ginger Mochi)
          Positioned(
            left: 20,
            bottom: 18,
            child: GestureDetector(
              onTap: () => _tapCat('mochi'),
              child: AnimatedBuilder(
                animation: _bobAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bobAnimation.value),
                    child: child,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_cat1MoodText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9F43),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          _cat1MoodText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    _buildGingerCatArt(),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9F43).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Tap Mochi 🐾',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF824700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Cat (Grey Boba)
          Positioned(
            right: 20,
            bottom: 18,
            child: GestureDetector(
              onTap: () => _tapCat('boba'),
              child: AnimatedBuilder(
                animation: _breatheAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breatheAnimation.value,
                    child: child,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_cat2MoodText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A5BFF),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          _cat2MoodText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    _buildGreyCatArt(),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A5BFF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Tap Boba 🐱',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A5BFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGingerCatArt() {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: const Color(0xFFFF9F43), width: 2),
      ),
      alignment: Alignment.center,
      child: const Text(
        '🐱',
        style: TextStyle(fontSize: 48),
      ),
    );
  }

  Widget _buildGreyCatArt() {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8EAF6),
        border: Border.all(color: const Color(0xFF3A5BFF), width: 2),
      ),
      alignment: Alignment.center,
      child: const Text(
        '😸',
        style: TextStyle(fontSize: 46),
      ),
    );
  }

  Widget _buildDopamineMeter() {
    final calmScore = max(0, 100 - _stressLevel);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E4F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.spa, size: 18, color: Color(0xFF00B894)),
                  SizedBox(width: 6),
                  Text(
                    'Mental Calm Level',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14152B),
                    ),
                  ),
                ],
              ),
              Text(
                '$calmScore% Calm',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B894),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: calmScore / 100.0,
              minHeight: 8,
              backgroundColor: const Color(0xFFF0F2F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B894)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            calmScore > 80
                ? 'Your urge to doom-scroll has significantly decreased. Great job!'
                : 'Take a few deep breaths and give Mochi another scratch.',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B6F8C)),
          ),
        ],
      ),
    );
  }
}

class _HillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFFEEF2FF)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.1,
      size.width,
      size.height * 0.5,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFFE0E7FF).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.3,
      size.width,
      size.height * 0.6,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
