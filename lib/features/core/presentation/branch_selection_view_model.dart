import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_user_branches.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/select_active_branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';

class BranchSelectionViewModel extends ChangeNotifier {
  final GetUserBranchesUseCase getUserBranchesUseCase;
  final SelectActiveBranchUseCase selectActiveBranchUseCase;

  BranchSelectionViewModel({
    required this.getUserBranchesUseCase,
    required this.selectActiveBranchUseCase,
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
