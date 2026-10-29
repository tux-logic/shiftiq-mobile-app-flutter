import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/failures.dart';
import '../../application/check_auth_status_usecase.dart';
import '../../application/get_active_roles_usecase.dart';
import '../../application/login_with_email_usecase.dart';
import '../../application/login_with_google_usecase.dart';
import '../../application/logout_usecase.dart';
import '../../application/sign_up_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final SignUpUseCase signUpUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final GetActiveRolesUseCase getActiveRolesUseCase;
  final GoogleSignIn _googleSignIn;

  AuthBloc({
    required this.loginWithEmailUseCase,
    required this.loginWithGoogleUseCase,
    required this.signUpUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.getActiveRolesUseCase,
    GoogleSignIn? googleSignIn,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn(),
        super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<SignUpEvent>(_onSignUp);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LogoutEvent>(_onLogout);
    on<ClearAuthErrorEvent>(_onClearAuthError);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await checkAuthStatusUseCase();
      if (user != null) {
        final profileRole = await getActiveRolesUseCase(user.id);
        emit(Authenticated(user: user, profileRole: profileRole));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Iniciando sesión...'));
    try {
      final user = await loginWithEmailUseCase(
        email: event.email,
        password: event.password,
      );
      final profileRole = await getActiveRolesUseCase(user.id);
      emit(Authenticated(user: user, profileRole: profileRole));
    } on Failure catch (e) {
      emit(AuthFailureState(message: e.message, code: e.code));
    } catch (e) {
      emit(AuthFailureState(message: 'Error al iniciar sesión: $e'));
    }
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Creando cuenta...'));
    try {
      final user = await signUpUseCase(
        email: event.email,
        password: event.password,
      );
      final profileRole = await getActiveRolesUseCase(user.id);
      emit(Authenticated(user: user, profileRole: profileRole));
    } on Failure catch (e) {
      emit(AuthFailureState(message: e.message, code: e.code));
    } catch (e) {
      emit(AuthFailureState(message: 'Error al registrar usuario: $e'));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Conectando con Google...'));
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(const Unauthenticated());
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        emit(const AuthFailureState(
          message: 'No se pudo obtener el token de Google.',
          code: 'GOOGLE_TOKEN_ERROR',
        ));
        return;
      }

      final user = await loginWithGoogleUseCase(idToken: idToken);
      final profileRole = await getActiveRolesUseCase(user.id);
      emit(Authenticated(user: user, profileRole: profileRole));
    } on Failure catch (e) {
      emit(AuthFailureState(message: e.message, code: e.code));
    } catch (e) {
      emit(AuthFailureState(message: 'Error en Google Sign-In: $e'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Cerrando sesión...'));
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await logoutUseCase();
    } catch (_) {}
    emit(const Unauthenticated());
  }

  void _onClearAuthError(
    ClearAuthErrorEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthFailureState) {
      emit(const Unauthenticated());
    }
  }
}
