enum ChampionshipFormatEnum {
  pointsSimple,
  points,
  knockout,
  hybridSimple,
  hybrid
  ;

  String get label => switch (this) {
    ChampionshipFormatEnum.pointsSimple => 'Pontos Corridos (Simples)',
    ChampionshipFormatEnum.points => 'Pontos Corridos',
    ChampionshipFormatEnum.knockout => 'Mata-Mata',
    ChampionshipFormatEnum.hybridSimple => 'Grupo (Simples) + Mata-Mata',
    ChampionshipFormatEnum.hybrid => 'Grupo + Mata-Mata',
  };

  String get description => switch (this) {
    ChampionshipFormatEnum.pointsSimple =>
      'Todas as equipes se enfrentam apenas uma vez. Sem jogos de volta.',
    ChampionshipFormatEnum.points =>
      'Todas as equipes se enfrentam em turno e returno (ida e volta).',
    ChampionshipFormatEnum.knockout =>
      'Torneio de eliminação direta: quem perder está fora.',
    ChampionshipFormatEnum.hybridSimple =>
      'Fase de grupos com apenas ida, seguida de fase eliminatória.',
    ChampionshipFormatEnum.hybrid =>
      'Fase de grupos com ida e volta, seguida de fase eliminatória.',
  };
}
