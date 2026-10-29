import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../state/auth_bloc.dart';
import '../state/auth_event.dart';
import '../state/auth_state.dart';
import '../widgets/automotive_bay_visualizer.dart';
import 'email_login_screen.dart';

class WelcomeAuthScreen extends StatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _cardFadeAnimation;
  late final Animation<Offset> _cardSlideAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _buttonsFadeAnimation;
  late final Animation<Offset> _buttonsSlideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Staggered interval 1: Visualizer Card
    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // Staggered interval 2: Headings
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Staggered interval 3: Action Buttons
    _buttonsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _buttonsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.neonRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Carousel Progress Indicators
                      _buildCarouselDots(),
                      const SizedBox(height: 14),

                      // 2. Animated Automotive Diagnostic Card
                      SlideTransition(
                        position: _cardSlideAnimation,
                        child: FadeTransition(
                          opacity: _cardFadeAnimation,
                          child: const AutomotiveBayVisualizer(),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 3. Headings & Value Proposition
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tu auto bajo control\ninteligente',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                  height: 1.15,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Telemetría preventiva OBD-II y diagnósticos precisos.',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 4. Action Buttons
                      SlideTransition(
                        position: _buttonsSlideAnimation,
                        child: FadeTransition(
                          opacity: _buttonsFadeAnimation,
                          child: Column(
                            children: [
                              _buildGoogleSignInButton(),
                              const SizedBox(height: 14),
                              _buildPhoneSignInButton(),
                              const SizedBox(height: 24),
                              _buildTraditionalEmailLink(),
                              const SizedBox(height: 12),
                            ],
                          ),
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
    );
  }

  Widget _buildCarouselDots() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  context.read<AuthBloc>().add(const LoginWithGoogleEvent());
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E222A),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGoogleGLogo(),
                    const SizedBox(width: 12),
                    const Text(
                      'Continuar con Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildGoogleGLogo() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneSignInButton() {
    return OutlinedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Acceso con celular disponible en la próxima actualización.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: const Color(0xFF0F172A),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_iphone_rounded, size: 20, color: Color(0xFF0F172A)),
          SizedBox(width: 10),
          Text(
            'Ingresar con número celular',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraditionalEmailLink() {
    return Center(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const EmailLoginScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'Iniciar sesión con correo tradicional →',
            style: TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
