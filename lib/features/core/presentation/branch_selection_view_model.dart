import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_user_branches.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/select_active_branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/infrastructure/remote/shared_api.dart';

class BranchSelectionViewModel extends ChangeNotifier {
  final GetUserBranchesUseCase getUserBranchesUseCase;
  final SelectActiveBranchUseCase selectActiveBranchUseCase;
  final SharedApi? sharedApi;

  BranchSelectionViewModel({
    required this.getUserBranchesUseCase,
    required this.selectActiveBranchUseCase,
    this.sharedApi,
  });

  bool isLoading = false;
  String? errorMessage;
  List<Branch> branches = [];
  Branch? selectedBranch;

  Future<void> loadBranches() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      branches = await getUserBranchesUseCase.execute();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }

  /// Uploads a branch cover image to Cloudinary via `/api/v1/media/upload`
  /// and returns its public HTTPS URL.
  Future<String> uploadBranchCoverImage({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final api = sharedApi ?? getIt<SharedApi>();
    final response = await api.uploadMedia(
      fileBytes: fileBytes,
      fileName: fileName,
      folder: 'uploads',
    );
    if (response is Map<String, dynamic> && response['url'] is String) {
      return response['url'] as String;
    }
    throw Exception('Invalid media upload response.');
  }

  Future<bool> createBranch({
    required String workshopId,
    required String code,
    required String name,
    required String address,
    required String phone,
    String? coverImageUrl,
    double? latitude,
    double? longitude,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newBranch = await getUserBranchesUseCase.createBranch(
        workshopId: workshopId,
        code: code,
        name: name,
        address: address,
        phone: phone,
        coverImageUrl: coverImageUrl,
        latitude: latitude,
        longitude: longitude,
      );
      branches = [...branches, newBranch];
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBranch({
    required String branchId,
    required String code,
    required String name,
    required String address,
    required String phone,
    String? coverImageUrl,
    double? latitude,
    double? longitude,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updated = await getUserBranchesUseCase.updateBranch(
        branchId: branchId,
        code: code,
        name: name,
        address: address,
        phone: phone,
        coverImageUrl: coverImageUrl,
        latitude: latitude,
        longitude: longitude,
      );
      branches = branches
          .map((b) => b.id == branchId ? updated : b)
          .toList();
      if (selectedBranch?.id == branchId) {
        selectedBranch = updated;
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> selectBranch(Branch branch) async {
    try {
      await selectActiveBranchUseCase.execute(branch);
      selectedBranch = branch;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
