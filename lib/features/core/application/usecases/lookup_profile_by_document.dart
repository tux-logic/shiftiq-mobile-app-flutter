import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Use case searching user profiles by document number (DNI/RUC) across core domains.
class LookupProfileByDocumentUseCase {
  final CoreRepository repository;

  LookupProfileByDocumentUseCase({required this.repository});

  Future<UserProfileContext?> execute(String documentNumber) {
    return repository.lookupProfileByDocument(documentNumber);
  }
}
