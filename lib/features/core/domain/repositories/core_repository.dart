import 'package:shiftiq_mobile_app_flutter/features/core/domain/models/aggregates/branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/models/aggregates/specialty.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/models/aggregates/subscription.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/models/aggregates/workshop.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/models/entities/user_profile_context.dart';

/// Contract interface for Automotive Core Domain:
/// Workshops, Branches, Specialties, Subscriptions, and Profiles.
abstract class CoreRepository {
  // --- Workshop Lifecycle ---
  Future<Workshop> createWorkshop({
    required String ownerId,
    required String businessName,
    required String brandName,
    required String taxId,
    int mileageIntervalConfig = 5000,
  });

  Future<Workshop> updateWorkshop({
    required String workshopId,
    required String businessName,
    required String brandName,
    required String taxId,
    required int mileageIntervalConfig,
  });

  Future<Workshop> getWorkshopById(String workshopId);

  Future<List<Workshop>> getWorkshops({String? ownerId});

  // --- Branch Lifecycle & Active Context ---
  Future<Branch> createBranch({
    required String workshopId,
    required String code,
    required String name,
    required String address,
    required String phone,
  });

  Future<Branch> updateBranch({
    required String branchId,
    required String code,
    required String name,
    required String address,
    required String phone,
  });

  Future<Branch> getBranchById(String branchId);

  Future<List<Branch>> getBranchesByWorkshop(String workshopId);

  Future<void> setActiveBranch(Branch branch);

  Future<String?> getActiveBranchId();

  Future<String?> getActiveBranchName();

  // --- Workshop Specialties Catalog ---
  Future<WorkshopSpecialty> createSpecialty({
    required String workshopId,
    required String name,
    required String code,
    String? description,
  });

  Future<List<WorkshopSpecialty>> getSpecialties({
    required String workshopId,
    bool activeOnly = true,
  });

  Future<WorkshopSpecialty> getSpecialtyById({
    required String workshopId,
    required String specialtyId,
  });

  Future<WorkshopSpecialty> updateSpecialty({
    required String workshopId,
    required String specialtyId,
    required String name,
    String? description,
  });

  Future<void> deactivateSpecialty({
    required String workshopId,
    required String specialtyId,
  });

  Future<List<SpecialtyRevisionHistory>> getSpecialtyHistory({
    required String workshopId,
    required String specialtyId,
  });

  // --- Branch Subscriptions ---
  Future<BranchSubscription> assignBranchSubscription({
    required String branchId,
    required String planId,
    required String billingCycle,
    required String cardNumber,
    required String cardHolderName,
    required String expirationDate,
    required String cvv,
  });

  Future<void> cancelBranchSubscription(String branchId);

  // --- Unified Profile Context ---
  Future<UserProfileContext> getMyProfileContext();

  Future<List<String>> getProfileRoles(String userId);

  Future<UserProfileContext?> lookupProfileByDocument(String documentNumber);

  // --- Profile Lifecycle Operations ---
  Future<Map<String, dynamic>> getOwnerById(String ownerId);

  Future<Map<String, dynamic>> updateOwnerProfile({
    required String ownerId,
    required String firstName,
    required String lastName,
    required String documentType,
    required String documentNumber,
    required String phone,
  });

  Future<void> deleteOwnerProfile(String ownerId);

  Future<Map<String, dynamic>> getEmployeeById(String employeeId);

  Future<List<Map<String, dynamic>>> getEmployeesByDocumentNumber(
    String documentNumber,
  );

  Future<Map<String, dynamic>> updateEmployeeProfile({
    required String employeeId,
    required String firstName,
    required String lastName,
    required String documentType,
    required String documentNumber,
    required String phone,
  });

  Future<void> deleteEmployeeProfile(String employeeId);

  Future<Map<String, dynamic>> getCustomerById(String customerId);

  Future<Map<String, dynamic>> updateCustomerProfile({
    required String customerId,
    required String documentType,
    required String documentNumber,
    required String phone,
    String? firstName,
    String? lastName,
    String? businessName,
  });

  Future<void> deleteCustomerProfile(String customerId);
}

/// Backward compatibility alias.
typedef BranchRepository = CoreRepository;
