import 'package:championship_manager/modules/championship/domain/entity/enum/sport_type_enum.dart';
import 'package:championship_manager/modules/championship/domain/entity/enum/championship_format_enum.dart';

class ChampionshipEntity {
  final String name;
  final SportTypeEnum sport;
  final ChampionshipFormatEnum format;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  const ChampionshipEntity({
    required this.name,
    required this.sport,
    required this.format,
    required this.description,
    required this.startDate,
    required this.endDate,
  });
}
