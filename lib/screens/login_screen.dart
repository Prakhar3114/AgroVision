// screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:plant_disease_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSignUp = false; // toggle between Login and Sign Up
  String? _errorMsg;
  String? _successMsg;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ─── Email Sign In / Sign Up ──────────────────────────────────────────────
  Future<void> _handleEmailAuth() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _successMsg = null;
    });

    final Map<String, dynamic> result;

    if (_isSignUp) {
      result = await AuthService.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      result = await AuthService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _errorMsg = result['error']);
    }
  }

  // ─── Google Sign In ───────────────────────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final result = await AuthService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _errorMsg = result['error']);
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────
  void _showForgotPassword() {
    final controller =
        TextEditingController(text: _emailController.text);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1A12),
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: const Color(0xFF1A3D28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reset Password',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8FFF2))),
              const SizedBox(height: 6),
              const Text(
                  'Enter your email and we\'ll send a reset link.',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF8AB89A))),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Color(0xFFE8FFF2), fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await AuthService.sendPasswordReset(
                        controller.text);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['success'] == true
                              ? 'Reset email sent! Check your inbox.'
                              : result['error'] ?? 'Failed'),
                        ),
                      );
                    }
                  },
                  child: const Text('SEND RESET EMAIL'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
              size: Size.infinite, painter: _LoginGridPainter()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),

                      // ── Logo ──────────────────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00DC64)
                                    .withOpacity(0.08),
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFF00DC64)
                                        .withOpacity(0.2)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Image.asset(
                                    'assets/app_logo.png'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            RichText(
                              text: const TextSpan(children: [
                                TextSpan(
                                    text: 'AGRO',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFE8FFF2),
                                        letterSpacing: 2)),
                                TextSpan(
                                    text: 'VISION',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF00DC64),
                                        letterSpacing: 2)),
                              ]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isSignUp
                                  ? 'Create your account'
                                  : 'Sign in to continue',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF3D6B50),
                                  letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Error message ─────────────────────────────────
                      if (_errorMsg != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252)
                                .withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFFF5252)
                                    .withOpacity(0.3)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFFF5252), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(_errorMsg!,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFFF5252)))),
                          ]),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Email ─────────────────────────────────────────
                      _label('EMAIL ADDRESS'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                            color: Color(0xFFE8FFF2), fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Password ──────────────────────────────────────
                      _label('PASSWORD'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                            color: Color(0xFFE8FFF2), fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon:
                              const Icon(Icons.lock_outline),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() =>
                                _obscurePassword =
                                    !_obscurePassword),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF4D7A5E),
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // ── Forgot password ───────────────────────────────
                      if (!_isSignUp)
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _showForgotPassword,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: const Text('Forgot password?',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF00DC64))),
                            ),
                          ),
                        ),

                      const SizedBox(height: 28),

                      // ── Main button ───────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading ? null : _handleEmailAuth,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF060D09)))
                              : Text(
                                  _isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Divider ───────────────────────────────────────
                      Row(children: [
                        const Expanded(
                            child: Divider(color: Color(0xFF1A3D28))),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12),
                          child: const Text('OR',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF3D6B50),
                                  letterSpacing: 1)),
                        ),
                        const Expanded(
                            child: Divider(color: Color(0xFF1A3D28))),
                      ]),

                      const SizedBox(height: 16),

                      // ── Google Sign In ────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : _handleGoogleSignIn,
                          icon: const Icon(Icons.g_mobiledata,
                              size: 22),
                          label: const Text('Continue with Google'),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Toggle Sign Up / Sign In ──────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isSignUp = !_isSignUp;
                            _errorMsg = null;
                            _successMsg = null;
                          }),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _isSignUp
                                      ? 'Already have an account? '
                                      : 'New to AgroVision? ',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4D7A5E)),
                                ),
                                TextSpan(
                                  text: _isSignUp
                                      ? 'Sign In'
                                      : 'Create Account',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF00DC64),
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Center(
                        child: const Text(
                          'AgroVision  •  AI Plant Disease Detection',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2A4D38),
                              letterSpacing: 0.5),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF3D6B50),
            letterSpacing: 2,
            fontWeight: FontWeight.w600));
  }
}

class _LoginGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00DC64).withOpacity(0.03)
      ..strokeWidth = 0.5;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_LoginGridPainter old) => false;
}