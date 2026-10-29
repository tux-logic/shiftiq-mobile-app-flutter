class GoogleLoginRequestDto {
  final String idToken;

  const GoogleLoginRequestDto({
    required this.idToken,
  });

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
      };
}
