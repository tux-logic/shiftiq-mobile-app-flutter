import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_profile_role.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class Authenticated extends AuthState {
  final User user;
  final UserProfileRole profileRole;

  const Authenticated({
    required this.user,
    required this.profileRole,
  });

  bool get isCustomer => profileRole.hasCustomerAccess;
  bool get isWorkshopEmployee => profileRole.hasEmployeeAccess;
  bool get isOwner => profileRole.hasOwnerAccess;

  @override
  List<Object?> get props => [user, profileRole];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthFailureState extends AuthState {
  final String message;
  final String? code;

  const AuthFailureState({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}
