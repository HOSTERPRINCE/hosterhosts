import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:hosterhosts/home_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hosterhosts/login.dart';
import 'auth_service.dart';
import 'dart:math' as math;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  bool _isRegisterButtonHovered = false;
  bool _isSignInButtonHovered = false;
  bool _isEmailFieldFocused = false;
  bool _isPasswordFieldFocused = false;
  bool _isConfirmPasswordFieldFocused = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    _floatAnimation = Tween<double>(begin: -15, end: 15)
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _rotateAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _fadeController.forward();
    _slideController.forward();
    _floatController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void register(BuildContext context) async {
    final AuthService auth = AuthService();
    String emailText = email.text.trim();
    String passwordText = password.text.trim();
    String confirmPasswordText = confirmPassword.text.trim();

    if (emailText.isEmpty || passwordText.isEmpty || confirmPasswordText.isEmpty) {
      _showSnackBar(context, "All fields are required.", Colors.red);
      return;
    }

    if (!_isValidEmail(emailText)) {
      _showSnackBar(context, "Please enter a valid email address.", const Color(0xFFFF6B35));
      return;
    }

    if (passwordText.length < 6) {
      _showSnackBar(context, "Password must be at least 6 characters long.", const Color(0xFFFF6B35));
      return;
    }

    if (passwordText != confirmPasswordText) {
      _showSnackBar(context, "Passwords do not match.", Colors.red);
      return;
    }

    try {
      await auth.signUpWithEmailPassword(emailText, passwordText);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage()));
      _showSnackBar(context, "Account created successfully!", Colors.green);
    } catch (e) {
      _showSnackBar(context, _getFriendlyErrorMessage(e.toString()), Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
  }

  String _getFriendlyErrorMessage(String error) {
    if (error.contains("email-already-in-use")) {
      return "This email is already in use. Try logging in.";
    } else if (error.contains("invalid-email")) {
      return "The email address is invalid.";
    } else if (error.contains("weak-password")) {
      return "Your password is too weak. Try a stronger one.";
    } else {
      return "An unexpected error occurred. Please try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D21),
              Color(0xFF1A1A3A),
              Color(0xFF2D1B69),
              Color(0xFF11998E),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Particle background
            ParticleBackground(),

            // Animated geometric shapes (reduced for mobile)
            if (!isMobile) ...List.generate(8, (index) => _buildGeometricShape(index))
            else ...List.generate(4, (index) => _buildGeometricShape(index)),

            // Gradient orbs (reduced for mobile)
            if (!isMobile) ...List.generate(4, (index) => _buildGradientOrb(index))
            else ...List.generate(2, (index) => _buildGradientOrb(index)),

            // Main content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 40 : (isTablet ? 30 : 16),
                              vertical: isDesktop ? 40 : (isTablet ? 30 : 20),
                            ),
                            child: isDesktop
                                ? _buildDesktopLayout()
                                : _buildMobileLayout(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.cyan.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 750,
            borderRadius: 32,
            blur: 20,
            alignment: Alignment.bottomCenter,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            child: Row(
              children: [
                // Left side - Enhanced gaming showcase
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 750,
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildEnhancedGameShowcase(),
                        const SizedBox(height: 50),
                        Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: Colors.cyan,
                          child: Text(
                            "JOIN THE ULTIMATE\nGAMING REVOLUTION",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.orbitron(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Create your account and dive into the world of competitive gaming,\nconnect with fellow gamers, and dominate the leaderboards",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildGameStats(),
                      ],
                    ),
                  ),
                ),

                // Right side - Enhanced register form
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 750,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: _buildCredentialsBox(isDesktop: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildEnhancedGameShowcase(),
        const SizedBox(height: 30),
        Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.cyan,
          child: Text(
            "JOIN HOSTERHOST",
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "CREATE YOUR GAMING LEGACY",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.cyan,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 30),
        _buildCredentialsBox(isDesktop: false),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCredentialsBox({required bool isDesktop}) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 450 : double.infinity,
      ),
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 0),
      padding: EdgeInsets.all(isDesktop ? 50 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isDesktop ? 0 : 24),
        color: isDesktop ? Colors.transparent : null,
      ),
      child: isDesktop
          ? _buildRegisterForm(isDesktop)
          : GlassmorphicContainer(
        width: double.infinity,
        height: 480,
        borderRadius: 24,
        blur: 15,
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildRegisterForm(isDesktop),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(bool isDesktop) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Create Account",
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 28 : 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),

        const SizedBox(height: 8),

        Text(
          "Join the elite gaming community today",
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 15 : 13,
            color: Colors.white60,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2),

        SizedBox(height: isDesktop ? 40 : 30),

        // Enhanced Email field
        _buildEnhancedTextField(
          hintText: "Email Address",
          controller: email,
          icon: Icons.email_outlined,
          isDesktop: isDesktop,
          isPassword: false,
          delay: 400,
          isFocused: _isEmailFieldFocused,
          onFocusChange: (focused) {
            setState(() {
              _isEmailFieldFocused = focused;
            });
          },
        ),

        SizedBox(height: isDesktop ? 20 : 16),

        // Enhanced Password field
        _buildEnhancedTextField(
          hintText: "Password",
          controller: password,
          icon: Icons.lock_outline,
          isDesktop: isDesktop,
          isPassword: true,
          delay: 600,
          isFocused: _isPasswordFieldFocused,
          onFocusChange: (focused) {
            setState(() {
              _isPasswordFieldFocused = focused;
            });
          },
        ),

        SizedBox(height: isDesktop ? 20 : 16),

        // Enhanced Confirm Password field
        _buildEnhancedTextField(
          hintText: "Confirm Password",
          controller: confirmPassword,
          icon: Icons.lock_outline,
          isDesktop: isDesktop,
          isPassword: true,
          delay: 800,
          isFocused: _isConfirmPasswordFieldFocused,
          onFocusChange: (focused) {
            setState(() {
              _isConfirmPasswordFieldFocused = focused;
            });
          },
        ),

        SizedBox(height: isDesktop ? 40 : 30),

        // Enhanced Register button
        _buildEnhancedRegisterButton(isDesktop)
            .animate()
            .fadeIn(delay: 1000.ms, duration: 600.ms)
            .slideY(begin: 0.3),

        SizedBox(height: isDesktop ? 30 : 24),

        // Enhanced Sign in section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "Already have an account? ",
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: isDesktop ? 14 : 12,
                ),
              ),
            ),
            MouseRegion(
              onEnter: (_) => setState(() => _isSignInButtonHovered = true),
              onExit: (_) => setState(() => _isSignInButtonHovered = false),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _isSignInButtonHovered
                        ? Colors.white.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: _isSignInButtonHovered
                          ? [const Color(0xFF00D4FF), const Color(0xFFFF6B9D)]
                          : [const Color(0xFF00D4FF), const Color(0xFF5B47FB)],
                    ).createShader(bounds),
                    child: Text(
                      "Sign In",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildEnhancedTextField({
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    required bool isDesktop,
    bool isPassword = false,
    required int delay,
    required bool isFocused,
    required Function(bool) onFocusChange,
  }) {
    return Focus(
      onFocusChange: onFocusChange,
      child: MouseRegion(
        onEnter: (_) => setState(() {}),
        onExit: (_) => setState(() {}),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isFocused
                  ? [
                Colors.cyan.withOpacity(0.2),
                Colors.purple.withOpacity(0.1),
              ]
                  : [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: isFocused
                  ? Colors.cyan.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isFocused
                    ? Colors.cyan.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                blurRadius: isFocused ? 15 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isDesktop ? 16 : 14,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: isDesktop ? 16 : 14,
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isFocused ? Colors.cyan : Colors.white70,
                  size: isDesktop ? 24 : 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : 16,
                vertical: isDesktop ? 20 : 16,
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).slideX(begin: -0.3);
  }

  Widget _buildEnhancedRegisterButton(bool isDesktop) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isRegisterButtonHovered = true),
      onExit: (_) => setState(() => _isRegisterButtonHovered = false),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..scale(_isRegisterButtonHovered ? 1.02 : 1.0),
            child: Container(
              width: double.infinity,
              height: isDesktop ? 55 : 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: _isRegisterButtonHovered
                      ? [
                    const Color(0xFF00D4FF),
                    const Color(0xFF5B47FB),
                    const Color(0xFFFF6B9D),
                    const Color(0xFFFFD700),
                  ]
                      : [
                    const Color(0xFF00D4FF),
                    const Color(0xFF5B47FB),
                    const Color(0xFFFF6B9D),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isRegisterButtonHovered
                        ? Colors.cyan.withOpacity(0.6)
                        : Colors.cyan.withOpacity(0.4),
                    blurRadius: _isRegisterButtonHovered ? 25 : 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => register(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()
                        ..rotateZ(_isRegisterButtonHovered ? 0.2 : 0),
                      child: Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: isDesktop ? 20 : 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "CREATE ACCOUNT",
                      style: GoogleFonts.orbitron(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedGameShowcase() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isMobile = screenWidth <= 768;

    return Container(
      height: isDesktop ? 200 : (isMobile ? 100 : 140),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEnhancedGameCard(
            'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop&crop=center',
            'BATTLE ROYALE',
            'PUBG',
            0,
            isDesktop,
            isMobile,
          ),
          _buildEnhancedGameCard(
            'https://images.unsplash.com/photo-1493711662062-fa541adb3fc8?w=400&h=300&fit=crop&crop=center',
            'FPS ARENA',
            'VALORANT , CS',
            1,
            isDesktop,
            isMobile,
          ),
          _buildEnhancedGameCard(
            'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=300&fit=crop&crop=center',
            'STRATEGY',
            'CHESS',
            2,
            isDesktop,
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGameCard(String imageUrl, String title, String players, int index, bool isDesktop, bool isMobile) {
    return Expanded(
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
            child: MouseRegion(
            onEnter: (_) => setState(() {}),
    onExit: (_) => setState(() {}),
    child: AnimatedBuilder(
    animation: _floatAnimation,
    builder: (context, child) {
    return Transform.translate(
    offset: Offset(0, _floatAnimation.value * (index % 2 == 0 ? 1 : -1)),
    child: GlassmorphicContainer(
    width: double.infinity,
    height: isDesktop ? 200 : (isMobile ? 100 : 140),
    borderRadius: isMobile ? 12 : 20,
    blur: 10,
    alignment: Alignment.bottomCenter,
    border: 2,
    linearGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
    Colors.white.withOpacity(0.1),
    Colors.white.withOpacity(0.05),
    ],
    ),
    borderGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
    Colors.cyan.withOpacity(0.3),
    Colors.purple.withOpacity(0.3),
    ],
    ),
    child: Stack(
    fit: StackFit.expand,
    children: [
    ClipRRect(
    borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
    child: CachedNetworkImage(
    imageUrl: imageUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[800]!,
    highlightColor: Colors.grey[600]!,
    child: Container(color: Colors.grey[800]),
    ),
    errorWidget: (context, url, error) {
    return Container(
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
    gradient: LinearGradient(
    colors: [
    Colors.cyan.withOpacity(0.3),
    Colors.purple.withOpacity(0.3),
    ],
    ),
    ),
    child: Icon(
    Icons.games,
    color: Colors.white,
    size: isDesktop ? 50 : (isMobile ? 20 : 35),
    ),
    );
    },
    ),
    ),
    Container(
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.7),
        ],
      ),
    ),
    ),
      Positioned(
        bottom: isMobile ? 8 : 16,
        left: isMobile ? 8 : 16,
        right: isMobile ? 8 : 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.orbitron(
                fontSize: isMobile ? 8 : (isDesktop ? 14 : 10),
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(height: 4),
              Text(
                players,
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 12 : 8,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    ],
    ),
    ),
    );
    },
    ),
            ),
        ),
    ).animate().fadeIn(delay: (300 * (index + 1)).ms, duration: 800.ms).slideY(begin: 0.3);
  }

  Widget _buildGameStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard("50K+", "Active Players", Icons.people),
        _buildStatCard("200+", "Tournaments", Icons.emoji_events),
        _buildStatCard("₹10L+", "Prize Pool", Icons.currency_rupee),
      ],
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_pulseAnimation.value * 0.1),
          child: GlassmorphicContainer(
            width: 120,
            height: 80,
            borderRadius: 16,
            blur: 10,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyan.withOpacity(0.3),
                Colors.purple.withOpacity(0.3),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.cyan,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  number,
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeometricShape(int index) {
    final colors = [
      Colors.cyan.withOpacity(0.1),
      Colors.purple.withOpacity(0.1),
      Colors.pink.withOpacity(0.1),
      Colors.orange.withOpacity(0.1),
    ];

    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Positioned(
          top: (index * 150.0) % MediaQuery.of(context).size.height,
          left: (index * 200.0) % MediaQuery.of(context).size.width,
          child: Transform.rotate(
            angle: _rotateAnimation.value * 2 * math.pi + (index * 0.5),
            child: Container(
              width: 60 + (index * 20.0),
              height: 60 + (index * 20.0),
              decoration: BoxDecoration(
                shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                color: colors[index % colors.length],
                borderRadius: index % 2 != 0 ? BorderRadius.circular(12) : null,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOrb(int index) {
    final colors = [
      [Colors.cyan.withOpacity(0.3), Colors.blue.withOpacity(0.1)],
      [Colors.purple.withOpacity(0.3), Colors.pink.withOpacity(0.1)],
      [Colors.orange.withOpacity(0.3), Colors.red.withOpacity(0.1)],
      [Colors.green.withOpacity(0.3), Colors.teal.withOpacity(0.1)],
    ];

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Positioned(
          top: (index * 180.0) % MediaQuery.of(context).size.height + _floatAnimation.value,
          right: (index * 120.0) % (MediaQuery.of(context).size.width * 0.5),
          child: Container(
            width: 100 + (index * 30.0),
            height: 100 + (index * 30.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: colors[index % colors.length],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ParticleBackground extends StatefulWidget {
  @override
  _ParticleBackgroundState createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // Create particles
    for (int i = 0; i < 50; i++) {
      particles.add(Particle());
    }

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double size;
  late Color color;

  Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble() * 400;
    y = math.Random().nextDouble() * 800;
    vx = (math.Random().nextDouble() - 0.5) * 2;
    vy = (math.Random().nextDouble() - 0.5) * 2;
    size = math.Random().nextDouble() * 3 + 1;

    final colors = [
      Colors.cyan.withOpacity(0.6),
      Colors.purple.withOpacity(0.6),
      Colors.pink.withOpacity(0.6),
      Colors.orange.withOpacity(0.6),
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  void update(double width, double height) {
    x += vx;
    y += vy;

    if (x < 0 || x > width) vx = -vx;
    if (y < 0 || y > height) vy = -vy;

    x = x.clamp(0, width);
    y = y.clamp(0, height);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      particle.update(size.width, size.height);

      paint.color = particle.color;
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}