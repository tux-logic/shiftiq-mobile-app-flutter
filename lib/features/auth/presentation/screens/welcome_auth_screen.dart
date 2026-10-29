import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../state/auth_bloc.dart';
import '../state/auth_event.dart';
import '../state/auth_state.dart';
import '../widgets/automotive_bay_visualizer.dart';
import 'email_login_screen.dart';

class OnboardingSlideData {
  final String title;
  final String subtitle;
  final int index;

  const OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.index,
  });
}

class WelcomeAuthScreen extends StatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _entranceController;
  late final Animation<double> _cardFadeAnimation;
  late final Animation<Offset> _cardSlideAnimation;

  int _currentPage = 0;

  static const List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      index: 0,
      title: 'Tu auto bajo control\ninteligente',
      subtitle: 'Telemetría preventiva OBD-II y diagnósticos precisos en tiempo real.',
    ),
    OnboardingSlideData(
      index: 1,
      title: 'Control total\nde tu taller',
      subtitle:
          'Gestiona bahías, órdenes de trabajo y recibe diagnósticos DTC en tiempo real sin papeleo.',
    ),
    OnboardingSlideData(
      index: 2,
      title: 'Monitoreo en vivo\nsin cables',
      subtitle:
          'Sincronización instantánea de sensores, salud del motor y alertas de mantenimiento.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToEmailLogin() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EmailLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  void _showWorkshopRegisterDialog() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildWorkshopRegisterSheet(),
    );
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      // 1. Top Animated Dots
                      _buildCarouselDots(),
                      const SizedBox(height: 12),

                      // 2. Automotive Diagnostic Stage Card
                      SlideTransition(
                        position: _cardSlideAnimation,
                        child: FadeTransition(
                          opacity: _cardFadeAnimation,
                          child: const AutomotiveBayVisualizer(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Dynamic Text per Slide
                      SizedBox(
                        height: 140,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, index) {
                            final slide = _slides[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slide.title,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  slide.subtitle,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Slide-Specific Action Buttons with Smooth CrossFade
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _currentPage == 1
                            ? _buildWorkshopSlideButtons()
                            : _buildCustomerSlideButtons(),
                      ),
                      const SizedBox(height: 10),
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
        children: List.generate(_slides.length, (index) {
          final isSelected = _currentPage == index;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSelected ? 28 : 6,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- Slide 0 & 2: Customer / Driver Persona Buttons ---
  Widget _buildCustomerSlideButtons() {
    return Column(
      key: const ValueKey('customer_buttons'),
      children: [
        _buildGoogleSignInButton(
          backgroundColor: const Color(0xFF1E222A),
          textColor: Colors.white,
        ),
        const SizedBox(height: 12),
        _buildPhoneSignInButton(),
        const SizedBox(height: 18),
        _buildTraditionalEmailLink(),
      ],
    );
  }

  // --- Slide 1: Workshop / Technician Persona Buttons ---
  Widget _buildWorkshopSlideButtons() {
    return Column(
      key: const ValueKey('workshop_buttons'),
      children: [
        // Primary: Iniciar Sesión ->
        ElevatedButton(
          onPressed: _navigateToEmailLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Secondary: Registrar mi Taller en ShiftIQ
        OutlinedButton(
          onPressed: _showWorkshopRegisterDialog,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            foregroundColor: const Color(0xFF0F172A),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_outlined, size: 20, color: Color(0xFF0F172A)),
              SizedBox(width: 10),
              Text(
                'Registrar mi Taller en ShiftIQ',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Tertiary: Continuar con Google (Soft pill container)
        _buildGoogleSignInButton(
          backgroundColor: const Color(0xFFF1F5F9),
          textColor: const Color(0xFF1E293B),
          elevation: 0,
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton({
    required Color backgroundColor,
    required Color textColor,
    double elevation = 0,
  }) {
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
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            elevation: elevation,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: textColor),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGoogleGLogo(),
                    const SizedBox(width: 12),
                    Text(
                      'Continuar con Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
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
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontSize: 14,
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
          SnackBar(
            content: const Text('Acceso con celular disponible en la próxima actualización.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        onTap: _navigateToEmailLogin,
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

  Widget _buildWorkshopRegisterSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Únete a la red ShiftIQ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Plataforma integral para talleres',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Digitaliza tus bahías, conecta dispositivos OBD-II de telemetría y administra órdenes de trabajo en tiempo real con tus mecánicos.',
            style: TextStyle(color: Color(0xFF475569), fontSize: 14.5, height: 1.4),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToEmailLogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Comenzar con cuenta de Taller'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
