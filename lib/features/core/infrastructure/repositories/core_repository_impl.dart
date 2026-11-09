import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/branch_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/core_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/profile_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/workshop_api.dart';

/// Repository coordinating remote Core APIs, local session storage, and domain events.
class CoreRepositoryImpl implements CoreRepository {
  final WorkshopApi workshopApi;
  final BranchApi branchApi;
  final ProfileApi profileApi;
  final SessionStorage sessionStorage;
  final DomainEventBus eventBus;

  CoreRepositoryImpl({
    required this.workshopApi,
    required this.branchApi,
    required this.profileApi,
    required this.sessionStorage,
    required this.eventBus,
  });

  // --- Workshop Lifecycle ---

  @override
  Future<Workshop> createWorkshop({
    required String ownerId,
    required String businessName,
    required String brandName,
    required String taxId,
    int mileageIntervalConfig = 5000,
  }) async {
    final json = await workshopApi.createWorkshop(
      ownerId: ownerId,
      businessName: businessName,
      brandName: brandName,
      taxId: taxId,
      mileageIntervalConfig: mileageIntervalConfig,
    );
    return WorkshopDto.fromJson(json).toDomain();
  }

  @override
  Future<Workshop> updateWorkshop({
    required String workshopId,
    required String businessName,
    required String brandName,
    required String taxId,
    required int mileageIntervalConfig,
  }) async {
    final json = await workshopApi.updateWorkshop(
      workshopId: workshopId,
      businessName: businessName,
      brandName: brandName,
      taxId: taxId,
      mileageIntervalConfig: mileageIntervalConfig,
    );
    return WorkshopDto.fromJson(json).toDomain();
  }

  @override
  Future<Workshop> getWorkshopById(String workshopId) async {
    final json = await workshopApi.getWorkshopById(workshopId);
    return WorkshopDto.fromJson(json).toDomain();
  }

  @override
  Future<List<Workshop>> getWorkshops({String? ownerId}) async {
    final list = await workshopApi.getWorkshops(ownerId: ownerId);
    return list.map((json) => WorkshopDto.fromJson(json).toDomain()).toList();
  }

  // --- Branch Lifecycle & Active Context ---

  @override
  Future<Branch> createBranch({
    required String workshopId,
    required String code,
    required String name,
    required String address,
    required String phone,
  }) async {
    final json = await branchApi.createBranch(
      workshopId: workshopId,
      code: code,
      name: name,
      address: address,
      phone: phone,
    );
    return BranchDto.fromJson(json).toDomain();
  }

  @override
  Future<Branch> updateBranch({
    required String branchId,
    required String code,
    required String name,
    required String address,
    required String phone,
  }) async {
    final json = await branchApi.updateBranch(
      branchId: branchId,
      code: code,
      name: name,
      address: address,
      phone: phone,
    );
    return BranchDto.fromJson(json).toDomain();
  }

  @override
  Future<Branch> getBranchById(String branchId) async {
    final json = await branchApi.getBranchById(branchId);
    return BranchDto.fromJson(json).toDomain();
  }

  @override
  Future<List<Branch>> getBranchesByWorkshop(String workshopId) async {
    final list = await branchApi.getBranches(workshopId);
    return list.map((json) => BranchDto.fromJson(json).toDomain()).toList();
  }

  @override
  Future<void> setActiveBranch(Branch branch) async {
    await sessionStorage.setActiveBranch(
      branchId: branch.id,
      branchName: branch.name,
    );
    await sessionStorage.setActiveWorkshop(branch.workshopId);

    eventBus.emit(
      ActiveBranchChangedEvent(
        branchId: branch.id,
        branchName: branch.name,
      ),
    );
  }

  @override
  Future<String?> getActiveBranchId() async {
    return sessionStorage.activeBranchId;
  }

  @override
  Future<String?> getActiveBranchName() async {
    return sessionStorage.activeBranchName;
  }

  // --- Workshop Specialties Catalog ---

  @override
  Future<WorkshopSpecialty> createSpecialty({
    required String workshopId,
    required String name,
    required String code,
    String? description,
  }) async {
    final json = await workshopApi.createSpecialty(
      workshopId: workshopId,
      name: name,
      code: code,
      description: description,
    );
    return WorkshopSpecialtyDto.fromJson(json).toDomain();
  }

  @override
  Future<List<WorkshopSpecialty>> getSpecialties({
    required String workshopId,
    bool activeOnly = true,
  }) async {
    final list = await workshopApi.getSpecialties(
      workshopId: workshopId,
      activeOnly: activeOnly,
    );
    return list
        .map((json) => WorkshopSpecialtyDto.fromJson(json).toDomain())
        .toList();
  }

  @override
  Future<WorkshopSpecialty> getSpecialtyById({
    required String workshopId,
    required String specialtyId,
  }) async {
    final json = await workshopApi.getSpecialtyById(
      workshopId: workshopId,
      specialtyId: specialtyId,
    );
    return WorkshopSpecialtyDto.fromJson(json).toDomain();
  }

  @override
  Future<WorkshopSpecialty> updateSpecialty({
    required String workshopId,
    required String specialtyId,
    required String name,
    String? description,
  }) async {
    final json = await workshopApi.updateSpecialty(
      workshopId: workshopId,
      specialtyId: specialtyId,
      name: name,
      description: description,
    );
    return WorkshopSpecialtyDto.fromJson(json).toDomain();
  }

  @override
  Future<void> deactivateSpecialty({
    required String workshopId,
    required String specialtyId,
  }) async {
    await workshopApi.deactivateSpecialty(
      workshopId: workshopId,
      specialtyId: specialtyId,
    );
  }

  @override
  Future<List<SpecialtyRevisionHistory>> getSpecialtyHistory({
    required String workshopId,
    required String specialtyId,
  }) async {
    final list = await workshopApi.getSpecialtyHistory(
      workshopId: workshopId,
      specialtyId: specialtyId,
    );
    return list
        .map((json) => SpecialtyRevisionHistoryDto.fromJson(json).toDomain())
        .toList();
  }

  // --- Branch Subscriptions ---

  @override
  Future<BranchSubscription> assignBranchSubscription({
    required String branchId,
    required String planId,
    required String billingCycle,
    required String cardNumber,
    required String cardHolderName,
    required String expirationDate,
    required String cvv,
  }) async {
    final json = await branchApi.assignSubscription(
      branchId: branchId,
      planId: planId,
      billingCycle: billingCycle,
      cardNumber: cardNumber,
      cardHolderName: cardHolderName,
      expirationDate: expirationDate,
      cvv: cvv,
    );
    return BranchSubscriptionDto.fromJson(json).toDomain();
  }

  @override
  Future<void> cancelBranchSubscription(String branchId) async {
    await branchApi.cancelSubscription(branchId);
  }

  // --- Unified Profile Context ---

  @override
  Future<UserProfileContext> getMyProfileContext() async {
    final json = await profileApi.getMyProfileContext();
    return UserProfileContextDto.fromJson(json).toDomain();
  }

  @override
  Future<List<String>> getProfileRoles(String userId) async {
    return profileApi.getProfileRoles(userId);
  }

  @override
  Future<UserProfileContext?> lookupProfileByDocument(
    String documentNumber,
  ) async {
    final json = await profileApi.lookupProfileByDocument(documentNumber);
    if (json != null) {
      return UserProfileContextDto.fromJson(json).toDomain();
    }
    return null;
  }

  // --- Profile Lifecycle Operations ---

  @override
  Future<Map<String, dynamic>> getOwnerById(String ownerId) {
    return profileApi.getOwnerById(ownerId);
  }

  @override
  Future<Map<String, dynamic>> updateOwnerProfile({
    required String ownerId,
    required String firstName,
    required String lastName,
    required String documentType,
    required String documentNumber,
    required String phone,
  }) {
    return profileApi.updateOwnerProfile(
      ownerId: ownerId,
      firstName: firstName,
      lastName: lastName,
      documentType: documentType,
      documentNumber: documentNumber,
      phone: phone,
    );
  }

  @override
  Future<void> deleteOwnerProfile(String ownerId) {
    return profileApi.deleteOwnerProfile(ownerId);
  }

  @override
  Future<Map<String, dynamic>> getEmployeeById(String employeeId) {
    return profileApi.getEmployeeById(employeeId);
  }

  @override
  Future<List<Map<String, dynamic>>> getEmployeesByDocumentNumber(
    String documentNumber,
  ) {
    return profileApi.getEmployeesByDocumentNumber(documentNumber);
  }

  @override
  Future<Map<String, dynamic>> updateEmployeeProfile({
    required String employeeId,
    required String firstName,
    required String lastName,
    required String documentType,
    required String documentNumber,
    required String phone,
  }) {
    return profileApi.updateEmployeeProfile(
      employeeId: employeeId,
      firstName: firstName,
      lastName: lastName,
      documentType: documentType,
      documentNumber: documentNumber,
      phone: phone,
    );
  }

  @override
  Future<void> deleteEmployeeProfile(String employeeId) {
    return profileApi.deleteEmployeeProfile(employeeId);
  }

  @override
  Future<Map<String, dynamic>> getCustomerById(String customerId) {
    return profileApi.getCustomerById(customerId);
  }

  @override
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String customerId,
    required String documentType,
    required String documentNumber,
    required String phone,
    String? firstName,
    String? lastName,
    String? businessName,
  }) {
    return profileApi.updateCustomerProfile(
      customerId: customerId,
      documentType: documentType,
      documentNumber: documentNumber,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      businessName: businessName,
    );
  }

  @override
  Future<void> deleteCustomerProfile(String customerId) {
    return profileApi.deleteCustomerProfile(customerId);
  }
}

/// Backward compatibility alias.
typedef BranchRepositoryImpl = CoreRepositoryImpl;
