class UserModel {
  final String uid;
  final String email;
  final String role;
  final String adresse;
  final String numsalarier;
  final String dateNaissance;
  final String teleportable;
  final String? commercialId; // Ajoutez ce champ optionnel

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.adresse,
    required this.numsalarier,
    required this.dateNaissance,
    required this.teleportable,
    this.commercialId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'adresse': adresse,
      'numsalarier': numsalarier,
      'dateNaissance': dateNaissance,
      'teleportable': teleportable,
      if (commercialId != null) 'commercialId': commercialId,
    };
  }
}
