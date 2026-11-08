import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/application/get_user_branches_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/application/select_active_branch_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch.dart';

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
