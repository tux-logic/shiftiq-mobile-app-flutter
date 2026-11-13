import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/core_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/profile_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';

/// ViewModel managing profile viewing, editing, and session termination
/// strictly consuming live endpoints from the deployed Render backend.
class ProfileViewModel extends ChangeNotifier {
  final ProfileApi profileApi;
  final EmployeeRegistrationApi employeeRegistrationApi;
  final SessionStorage sessionStorage;

  ProfileViewModel({
    required this.profileApi,
    required this.employeeRegistrationApi,
    required this.sessionStorage,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  String? _successMessage;
  String? get successMessage => _successMessage;

  UserProfileContext? _profileContext;
  UserProfileContext? get profileContext => _profileContext;

  String _userEmail = '';
  String get userEmail => _userEmail;

  String _activeBranchName = 'Sede Principal Surquillo';
  String get activeBranchName => _activeBranchName;

  String _activeBranchId = '';
  String get activeBranchId => _activeBranchId;

  String _specialtyName = 'Mecánica General';
  String get specialtyName => _specialtyName;

  double _salary = 2800.0;
  double get salary => _salary;

  bool get isOwner {
    final roles = _profileContext?.roles ?? sessionStorage.roles;
    return _profileContext?.owner != null ||
        roles.contains('ROLE_OWNER') ||
        roles.contains('OWNER');
  }

  bool get isEmployee {
    final roles = _profileContext?.roles ?? sessionStorage.roles;
    return _profileContext?.employee != null ||
        roles.contains('ROLE_EMPLOYEE') ||
        roles.contains('EMPLOYEE');
  }

  String get displayName {
    if (_profileContext?.employee != null) {
      return _profileContext!.employee!.fullName;
    }
    if (_profileContext?.owner != null) {
      return _profileContext!.owner!.fullName;
    }
    return _userEmail.isNotEmpty ? _userEmail : 'Usuario ShiftIQ';
  }

  String get roleDisplay {
    final roles = _profileContext?.roles ?? [];
    if (roles.contains('ROLE_OWNER') || roles.contains('OWNER')) {
      return 'Propietario / Gerente General (Owner)';
    }
    if (roles.contains('ROLE_EMPLOYEE') || roles.contains('EMPLOYEE')) {
      return 'Mecánico Especialista (B2B Staff)';
    }
    if (roles.contains('ROLE_ADMIN') || roles.contains('ADMIN')) {
      return 'Administrador de Plataforma';
    }
    return 'Personal del Taller';
  }

  String get documentDisplay {
    final emp = _profileContext?.employee;
    if (emp != null && emp.documentNumber.isNotEmpty) {
      return '${emp.documentType}: ${emp.documentNumber}';
    }
    final owner = _profileContext?.owner;
    if (owner != null && owner.documentNumber.isNotEmpty) {
      return '${owner.documentType}: ${owner.documentNumber}';
    }
    return 'No registrado';
  }

  String get phoneDisplay {
    final emp = _profileContext?.employee;
    if (emp != null && emp.phone.isNotEmpty) return emp.phone;
    final owner = _profileContext?.owner;
    if (owner != null && owner.phone.isNotEmpty) return owner.phone;
    return 'No registrado';
  }

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      _userEmail = sessionStorage.username ?? '';
      _activeBranchId = await sessionStorage.getActiveBranchId() ?? '';
      _activeBranchName =
          await sessionStorage.getActiveBranchName() ?? 'Sede Principal Surquillo';

      // 1. Fetch live unified profile context from Render (/api/v1/profiles/me)
      final rawContext = await profileApi.getMyProfileContext();
      final dto = UserProfileContextDto.fromJson(rawContext);
      _profileContext = dto.toDomain();

      // 2. Fetch employee registration details if employee exists
      if (_profileContext?.employee != null) {
        try {
          final registrations = await employeeRegistrationApi
              .getEmployeeRegistrations(employeeId: _profileContext!.employee!.employeeId);
          if (registrations.isNotEmpty) {
            final activeReg = registrations.first;
            final specName = (activeReg['specialityName'] ?? '').toString();
            final spec = (activeReg['speciality'] ?? '').toString();
            _specialtyName = specName.isNotEmpty
                ? specName
                : (spec.isNotEmpty ? spec : 'Mecánica General');
            _salary = (activeReg['salary'] as num?)?.toDouble() ?? 2800.0;
          }
        } catch (_) {
          // Fallback to standard specialty if registration query fails
        }
      }
    } catch (e) {
      _error = 'Error cargando datos del perfil desde Render: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates personal details directly on the Render backend.
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final employee = _profileContext?.employee;
      final owner = _profileContext?.owner;

      if (employee != null) {
        // Send PUT /api/v1/employees/{employeeId} to Render
        await profileApi.updateEmployeeProfile(
          employeeId: employee.employeeId,
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          documentType: employee.documentType,
          documentNumber: employee.documentNumber,
          phone: phone.trim(),
        );
      } else if (owner != null) {
        // Send PUT /api/v1/owners/{ownerId} to Render
        await profileApi.updateOwnerProfile(
          ownerId: owner.id,
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          documentType: owner.documentType,
          documentNumber: owner.documentNumber,
          phone: phone.trim(),
        );
      } else {
        throw Exception('No se encontró un perfil de empleado ni de propietario activo.');
      }

      await init(); // Refresh profile context
      _successMessage = 'Perfil actualizado exitosamente en el servidor Render.';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error actualizando perfil en Render: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Terminates the current session, clearing all tokens and local cache.
  Future<void> logout() async {
    await sessionStorage.clearSession();
  }
}
