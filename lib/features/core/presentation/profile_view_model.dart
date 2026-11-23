import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/core_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/profile_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/application/usecases/manage_media_uploads.dart';

/// ViewModel managing profile viewing, editing, and session termination
/// strictly consuming live endpoints from the deployed Render backend.
class ProfileViewModel extends ChangeNotifier {
  final ProfileApi profileApi;
  final EmployeeRegistrationApi employeeRegistrationApi;
  final SessionStorage sessionStorage;
  final ManageMediaUploads? manageMediaUploads;

  ProfileViewModel({
    required this.profileApi,
    required this.employeeRegistrationApi,
    required this.sessionStorage,
    this.manageMediaUploads,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isUploadingImage = false;
  bool get isUploadingImage => _isUploadingImage;

  String? _error;
  String? get error => _error;

  String? _successMessage;
  String? get successMessage => _successMessage;

  UserProfileContext? _profileContext;
  UserProfileContext? get profileContext => _profileContext;

  String? get profileImageUrl => _profileContext?.resolvedProfileImageUrl;

  String _userEmail = '';
  String get userEmail => _userEmail;

  String _activeBranchName = '-';
  String get activeBranchName => _activeBranchName;

  String _activeBranchId = '';
  String get activeBranchId => _activeBranchId;

  String _specialtyName = '-';
  String get specialtyName => _specialtyName;

  double _salary = 0.0;
  double get salary => _salary;

  bool get isOwner {
    final roles = _profileContext?.roles ?? sessionStorage.roles;
    return _profileContext?.owner != null ||
        roles.contains('ROLE_OWNER') ||
        roles.contains('OWNER');
  }

  bool get isOwnerAdmin {
    final roles = _profileContext?.roles ?? sessionStorage.roles;
    return _profileContext?.owner != null ||
        RoleRouter.resolveScope(roles) == MobileRoleScope.ownerAdmin;
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
    if (_profileContext?.customer != null) {
      return _profileContext!.customer!.displayName;
    }
    return _userEmail.isNotEmpty ? _userEmail : 'Usuario ShiftIQ';
  }

  String get roleDisplay {
    final contextRoles = _profileContext?.roles ?? const <String>[];
    final roles = contextRoles.isNotEmpty ? contextRoles : sessionStorage.roles;
    if (roles.contains('ROLE_OWNER') || roles.contains('OWNER')) {
      return 'Propietario / Gerente General (Owner)';
    }
    if (roles.contains('ROLE_ADMIN') || roles.contains('ADMIN')) {
      return 'Administrador de Plataforma';
    }
    if (roles.contains('ROLE_EMPLOYEE') || roles.contains('EMPLOYEE')) {
      return 'Mecánico Especialista (B2B Staff)';
    }
    if (roles.contains('ROLE_CUSTOMER') ||
        roles.contains('CUSTOMER') ||
        roles.contains('ROLE_USER')) {
      return 'Cliente ShiftIQ';
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
    final customer = _profileContext?.customer;
    if (customer != null && customer.documentNumber.isNotEmpty) {
      return '${customer.documentType}: ${customer.documentNumber}';
    }
    return 'No registrado';
  }

  String get phoneDisplay {
    final emp = _profileContext?.employee;
    if (emp != null && emp.phone.isNotEmpty) return emp.phone;
    final owner = _profileContext?.owner;
    if (owner != null && owner.phone.isNotEmpty) return owner.phone;
    final customer = _profileContext?.customer;
    if (customer != null && customer.phone.isNotEmpty) return customer.phone;
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
      _activeBranchName = await sessionStorage.getActiveBranchName() ?? '-';

      // 1. Fetch live unified profile context (/api/v1/profiles/me)
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
                : (spec.isNotEmpty ? spec : '-');
            _salary = (activeReg['salary'] as num?)?.toDouble() ?? 0.0;
          }
        } catch (_) {
          // Keep default '-' if registration query fails
        }
      }
    } catch (e) {
      _error = 'Error loading profile: $e';
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
      final customer = _profileContext?.customer;

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
      } else if (customer != null) {
        // Send PUT /api/v1/customers/{customerId} to Render
        await profileApi.updateCustomerProfile(
          customerId: customer.customerId,
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          businessName: customer.businessName,
          documentType: customer.documentType,
          documentNumber: customer.documentNumber,
          phone: phone.trim(),
        );
      } else {
        throw Exception('No active profile found for this account.');
      }

      await init(); // Refresh profile context
      _successMessage = 'Profile updated successfully.';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error updating profile: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Uploads an image to Cloudinary and persists `profileImageUrl` via
  /// `PUT /api/v1/profiles/me/image` across all caller Core profiles.
  Future<bool> uploadAndSetProfileImage({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final uploader = manageMediaUploads;
    if (uploader == null) {
      _error = 'Media upload service is not available.';
      notifyListeners();
      return false;
    }

    _isUploadingImage = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final uploadResult = await uploader.uploadAvatarPhoto(
        fileBytes: fileBytes,
        fileName: fileName,
      );
      final updatedRaw = await profileApi.updateMyProfileImage(
        uploadResult.url,
      );
      _profileContext = UserProfileContextDto.fromJson(updatedRaw).toDomain();
      _successMessage = 'Profile photo updated.';
      return true;
    } catch (e) {
      _error = 'Error updating profile photo: $e';
      return false;
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  /// Terminates the current session, clearing all tokens and local cache.
  Future<void> logout() async {
    await sessionStorage.clearSession();
  }
}
