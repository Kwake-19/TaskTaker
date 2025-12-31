class ICTUMatriculeValidator {
  static String extractAdmissionYear(String matricule) {
    final regex = RegExp(r'^ICTU(\d{4})\d{4}$');

    if (!regex.hasMatch(matricule)) {
      throw Exception("Invalid ICT University matricule.");
    }

    return regex.firstMatch(matricule)!.group(1)!;
  }
}
