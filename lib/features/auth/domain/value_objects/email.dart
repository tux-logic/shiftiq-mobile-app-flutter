import 'package:equatable/equatable.dart';

class Email extends Equatable {
  final String value;
  final bool isValid;

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  const Email._(this.value, this.isValid);

  factory Email(String input) {
    final trimmed = input.trim();
    final valid = _emailRegex.hasMatch(trimmed) && trimmed.isNotEmpty;
    return Email._(trimmed, valid);
  }

  String? get errorMessage {
    if (value.isEmpty) return 'El correo electrónico no puede estar vacío';
    if (!isValid) return 'Ingresa un correo electrónico válido';
    return null;
  }

  @override
  List<Object?> get props => [value, isValid];
}
