import 'package:equatable/equatable.dart';

class Password extends Equatable {
  final String value;
  final bool isValid;

  const Password._(this.value, this.isValid);

  factory Password(String input) {
    // Requires minimum 6 characters for user friendly client-side check
    final valid = input.length >= 6;
    return Password._(input, valid);
  }

  String? get errorMessage {
    if (value.isEmpty) return 'La contraseña no puede estar vacía';
    if (!isValid) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  @override
  List<Object?> get props => [value, isValid];
}
