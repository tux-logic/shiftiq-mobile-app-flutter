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
  late final PageController _pageController;
  late final AnimationController _entranceController;
  late final Animation<double> _cardFadeAnimation;
  late final Animation<Offset> _cardSlideAnimation;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
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

  void _goToPage(int page) {
    if (page == _currentPage) return;
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
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
      builder: (context) => Container(
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
                        'Registrar mi Taller',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Red ShiftIQ para talleres automotrices',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Digitaliza la recepción de vehículos, gestiona mecánicos en bahías y lee códigos DTC en tiempo real con escáneres OBD-II.',
              style: TextStyle(color: Color(0xFF475569), fontSize: 14.5, height: 1.4),
            ),
            const SizedBox(height: 24),
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
              child: const Text('Comenzar Registro de Taller'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
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
          child: Column(
            children: [
              const SizedBox(height: 8),

              // 1. Top Carousel Indicators (3 dots)
              _buildTopIndicator(),
              const SizedBox(height: 10),

              // 2. Role Switcher Pill Bar (Conductor vs Taller)
              _buildRoleSwitcherPills(),
              const SizedBox(height: 12),

              // 3. Automotive Diagnostic Stage Card (Pushed into view)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SlideTransition(
                  position: _cardSlideAnimation,
                  child: FadeTransition(
                    opacity: _cardFadeAnimation,
                    child: const AutomotiveBayVisualizer(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Interactive PageView (Swipe across entire bottom half)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildClientSlide(),
                    _buildWorkshopSlide(),
                    _buildLiveTelemetrySlide(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top Dots ---
  Widget _buildTopIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isSelected = _currentPage == index;
        return GestureDetector(
          onTap: () => _goToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isSelected ? 26 : 6,
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
    );
  }

  // --- Segmented Switcher for Instant Visibility ---
  Widget _buildRoleSwitcherPills() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _goToPage(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _currentPage == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _currentPage == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    '🚗 Para Conductores',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          _currentPage == 0 ? FontWeight.w700 : FontWeight.w500,
                      color: _currentPage == 0
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _goToPage(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _currentPage == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _currentPage == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    '🔧 Para Talleres',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          _currentPage == 1 ? FontWeight.w700 : FontWeight.w500,
                      color: _currentPage == 1
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDE 0: CLIENTE / CONDUCTOR (Imagen 1)
  // ==========================================
  Widget _buildClientSlide() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu auto bajo control\ninteligente',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Telemetría preventiva OBD-II y diagnósticos precisos.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),

          // Botón 1: Continuar con Google
          _buildGoogleSignInButton(
            backgroundColor: const Color(0xFF1E222A),
            textColor: Colors.white,
          ),
          const SizedBox(height: 12),

          // Botón 2: Ingresar con número celular
          _buildPhoneSignInButton(),
          const SizedBox(height: 18),

          // Link 3: Iniciar sesión con correo tradicional ->
          _buildTraditionalEmailLink(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDE 1: TALLER / MECÁNICOS (Imagen 2)
  // ==========================================
  Widget _buildWorkshopSlide() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Control total\nde tu taller',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gestiona bahías, órdenes de trabajo y recibe diagnósticos DTC en tiempo real sin papeleo.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),

          // Botón 1: Iniciar Sesión -> (Botón principal oscuro con flecha)
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
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Botón 2: Registrar mi Taller en ShiftIQ (Outline blanco)
          OutlinedButton(
            onPressed: _showWorkshopRegisterDialog,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.white,
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
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Botón 3: Continuar con Google (Soft pill container)
          _buildGoogleSignInButton(
            backgroundColor: const Color(0xFFF1F5F9),
            textColor: const Color(0xFF1E293B),
            elevation: 0,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDE 2: TELEMETRÍA IOT / ADICIONAL
  // ==========================================
  Widget _buildLiveTelemetrySlide() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monitoreo en vivo\nsin cables',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Conecta escáneres OBD-II y recibe alertas instantáneas de códigos de falla antes de que sea tarde.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => _goToPage(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ver plataforma de taller',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _buildGoogleSignInButton(
            backgroundColor: const Color(0xFFF1F5F9),
            textColor: const Color(0xFF1E293B),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- Reusable Google Button ---
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
        backgroundColor: Colors.white,
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
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
