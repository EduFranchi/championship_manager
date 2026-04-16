enum SportTypeEnum {
  soccer,
  soccer7,
  soccerSwiss,
  futsal,
  futmesa,
  footVolley,
  volleyball,
  basketball,
  tennis,
  other
  ;

  String get label => switch (this) {
    SportTypeEnum.soccer => 'Futebol de Campo',
    SportTypeEnum.soccer7 => 'Futebol 7',
    SportTypeEnum.soccerSwiss => 'Futebol Suíço',
    SportTypeEnum.futsal => 'Futsal',
    SportTypeEnum.futmesa => 'Futmesa',
    SportTypeEnum.footVolley => 'Futevôlei',
    SportTypeEnum.volleyball => 'Vôlei',
    SportTypeEnum.basketball => 'Basquete',
    SportTypeEnum.tennis => 'Tênis',
    SportTypeEnum.other => 'Outro',
  };

  static SportTypeEnum fromLabel(String label) {
    return SportTypeEnum.values.firstWhere(
      (e) => e.label == label,
      orElse: () => SportTypeEnum.other,
    );
  }
}
