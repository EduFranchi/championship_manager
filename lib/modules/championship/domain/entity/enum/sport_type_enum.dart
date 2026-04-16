enum SportTypeEnum {
  soccer,
  futsal,
  volleyball,
  basketball,
  tennis,
  other
  ;

  String get label => switch (this) {
    SportTypeEnum.soccer => 'Futebol de Campo',
    SportTypeEnum.futsal => 'Futsal',
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
