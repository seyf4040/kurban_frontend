class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Persons
  static const String persons = '$baseUrl/persons';
  static String personById(int id) => '$persons/$id';
  static const String personsWithContact = '$persons/with-contact';
  static const String personsWithoutContact = '$persons/without-contact';
  static String personsByIntermediary(int id) => '$persons/intermediary/$id';
  
  // Sacrifices
  static const String sacrifices = '$baseUrl/sacrifices';
  static String sacrificeById(int id) => '$sacrifices/$id';
  static String sacrificesByStatus(String status) => '$sacrifices/status/$status';
  static String sacrificesByAnimalType(String animalType) => '$sacrifices/animal-type/$animalType';
  static String completeSacrifice(int id) => '$sacrifices/$id/complete';
  static String cancelSacrifice(int id) => '$sacrifices/$id/cancel';
  
  // Participations
  static const String participations = '$baseUrl/participations';
  static String participationById(int id) => '$participations/$id';
  static String participationsBySacrifice(int sacrificeId) => '$participations/sacrifice/$sacrificeId';
  static String markParticipationPaid(int id) => '$participations/$id/mark-paid';
  
  // Config
  static const String config = '$baseUrl/config';
}