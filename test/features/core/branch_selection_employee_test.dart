import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_view_model.dart';

class _FakeSessionStorage extends SessionStorage {
  final List<String> _roles;

  _FakeSessionStorage(this._roles);

  @override
  List<String> get roles => _roles;
}

class _FakeBranchSelectionViewModel extends ChangeNotifier
    implements BranchSelectionViewModel {
  @override
  final List<Branch> branches;

  @override
  Branch? selectedBranch;

  _FakeBranchSelectionViewModel(this.branches);

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> loadBranches() async {}

  @override
  Future<bool> selectBranch(Branch branch) async {
    selectedBranch = branch;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final getIt = GetIt.instance;

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('auto-selects single branch for employee scope on init',
      (tester) async {
    getIt.registerSingleton<SessionStorage>(
      _FakeSessionStorage(const ['ROLE_EMPLOYEE']),
    );
    const branch = Branch(
      id: 'b-1',
      workshopId: 'ws-1',
      code: 'LIM-01',
      name: 'Sede Surco',
      address: 'Av. Primavera 123',
    );
    final vm = _FakeBranchSelectionViewModel(const [branch]);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BranchSelectionPage(
          viewModel: vm,
          mainPageBuilder: (_) =>
              const Scaffold(key: Key('auto_entered_main')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(vm.selectedBranch?.id, 'b-1');
    expect(find.byKey(const Key('auto_entered_main')), findsOneWidget);
  });

  testWidgets('does not auto-select single branch for ownerAdmin scope',
      (tester) async {
    getIt.registerSingleton<SessionStorage>(
      _FakeSessionStorage(const ['ROLE_OWNER']),
    );
    const branch = Branch(
      id: 'b-1',
      workshopId: 'ws-1',
      code: 'LIM-01',
      name: 'Sede Surco',
      address: 'Av. Primavera 123',
    );
    final vm = _FakeBranchSelectionViewModel(const [branch]);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BranchSelectionPage(viewModel: vm),
      ),
    );
    await tester.pump();

    expect(vm.selectedBranch, isNull);
  });
}
