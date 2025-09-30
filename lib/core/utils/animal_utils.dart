import 'package:kurban_frontend/data/models/app_config.dart';


class AnimalTypes {
  final String name;
  final int maxShares;

  AnimalTypes({
    required this.name,
    required this.maxShares,
  });
}

class AnimalUtils {

  static final List<AnimalTypes> supportedAnimalTypes = [
    AnimalTypes(name: 'Cow', maxShares: 7),
    AnimalTypes(name: 'Goat', maxShares: 1),
    AnimalTypes(name: 'Sheep', maxShares: 1),
    AnimalTypes(name: 'Camel', maxShares: 7),
    AnimalTypes(name: 'Chicken', maxShares: 1),
  ];

  static List<String> get supportedAnimalTypeNames {
    return supportedAnimalTypes.map((animalType) => animalType.name).toList();
  }

  static AnimalTypes? getAnimalTypeByName(String name) {
    return supportedAnimalTypes.firstWhere(
      (animalType) => animalType.name.toLowerCase() == name.toLowerCase(),
      orElse: () => throw ArgumentError('Animal type "$name" is not supported.'),
    );
  }

  static int getMaxSharesForAnimal(String name) {
    final animalType = getAnimalTypeByName(name);
    if (animalType != null) {
      return animalType.maxShares;
    }
    throw ArgumentError('Animal type "$name" is not supported.');
  }

  static double getAnimalDefaultCost(String name) {
    // Get default costs for each animal type fron app config
    AppConfig config = const AppConfig();
    return config.getAnimalTypeByName[name.toLowerCase()] ?? 0.0;
  }
}
