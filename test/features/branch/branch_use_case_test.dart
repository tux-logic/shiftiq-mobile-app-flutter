import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/application/get_user_branches_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/application/select_active_branch_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch_repository.dart';

class MockBranchRepository implements BranchRepository {
  Branch? activeBranch;

  @override
  Future<List<Workshop>> getWorkshops() async {
    return const [
      Workshop(
        id: 'ws-001',
        ownerId: 'usr-1234',
        businessName: 'Castro Motors S.A.C.',
        brandName: 'Castro Motors',
        taxId: '20549876123',
      ),
    ];
  }

  @override
  Future<List<Branch>> getBranchesByWorkshop(String workshopId) async {
    return const [
      Branch(
        id: 'br-smp-001',
        workshopId: 'ws-001',
        name: 'Sede San Martín de Porres',
        address: 'Av. Canta Callao 1420',
        district: 'San Martín de Porres',
        active: true,
      ),
      Branch(
        id: 'br-olivos-002',
        workshopId: 'ws-001',
        name: 'Sucursal Los Olivos',
        address: 'Av. Alfredo Mendiola 5800',
        district: 'Los Olivos',
        active: true,
      ),
    ];
  }

  @override
  Future<void> setActiveBranch(Branch branch) async {
    activeBranch = branch;
  }

  @override
  Future<String?> getActiveBranchId() async => activeBranch?.id;

  @override
  Future<String?> getActiveBranchName() async => activeBranch?.name;
}

void main() {
  late MockBranchRepository mockRepository;
  late GetUserBranchesUseCase getBranchesUseCase;
  late SelectActiveBranchUseCase selectBranchUseCase;

  setUp(() {
    mockRepository = MockBranchRepository();
    getBranchesUseCase = GetUserBranchesUseCase(repository: mockRepository);
    selectBranchUseCase = SelectActiveBranchUseCase(repository: mockRepository);
  });

  test('GetUserBranchesUseCase should aggregate all branches across owner workshops', () async {
    final branches = await getBranchesUseCase.execute();

    expect(branches.length, 2);
    expect(branches[0].name, 'Sede San Martín de Porres');
    expect(branches[1].district, 'Los Olivos');
  });

  test(
    'SelectActiveBranchUseCase should store the active branch in repository',
    () async {
      const branch = Branch(
        id: 'br-smp-001',
        workshopId: 'ws-001',
        name: 'Sede San Martín de Porres',
        address: 'Av. Canta Callao 1420',
      );

      await selectBranchUseCase.execute(branch);

      final activeId = await mockRepository.getActiveBranchId();
      expect(activeId, 'br-smp-001');
      expect(mockRepository.activeBranch?.name, 'Sede San Martín de Porres');
    },
  );
}
