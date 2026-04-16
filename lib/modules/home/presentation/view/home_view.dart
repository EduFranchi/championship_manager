import 'dart:io';
import 'package:flutter/material.dart';
import 'package:championship_manager/modules/championship/domain/entity/championship_entity.dart';
import 'package:championship_manager/modules/championship/domain/entity/enum/sport_type_enum.dart';
import 'package:championship_manager/modules/championship/domain/entity/enum/championship_format_enum.dart';
import 'package:championship_manager/modules/championship/presentation/view/save_championship_view.dart';
import 'package:championship_manager/modules/championship/presentation/view/championship_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Lista de campeonatos
  final List<ChampionshipEntity> championships = [
    ChampionshipEntity(
      name: 'Copa Regional 2026',
      sport: SportTypeEnum.soccer,
      format: ChampionshipFormatEnum.knockout,
      description: 'Torneio amador com as equipes da região metropolitana.',
      startDate: DateTime(2026, 5, 15),
      endDate: DateTime(2026, 7, 20),
    ),
    ChampionshipEntity(
      name: 'Liga Futsal Várzea',
      sport: SportTypeEnum.futsal,
      format: ChampionshipFormatEnum.pointsSimple,
      description: 'Campeonato longo de pontos corridos interbairros.',
      startDate: DateTime(2026, 6, 10),
      endDate: DateTime(2026, 8, 30),
    ),
    ChampionshipEntity(
      name: 'Master de Vôlei',
      sport: SportTypeEnum.volleyball,
      format: ChampionshipFormatEnum.hybridSimple,
      description: 'Competição voltada para atletas acima de 40 anos.',
      startDate: DateTime(2026, 12, 1),
      endDate: DateTime(2026, 12, 15),
    ),
    ChampionshipEntity(
      name: 'Open de Tênis de Inverno',
      sport: SportTypeEnum.tennis,
      format: ChampionshipFormatEnum.knockout,
      description: 'Torneio de simples masculino e feminino na cidade.',
      startDate: DateTime(2026, 8, 5),
      endDate: DateTime(2026, 8, 20),
    ),
    ChampionshipEntity(
      name: 'Circuito de Basquete de Rua',
      sport: SportTypeEnum.basketball,
      format: ChampionshipFormatEnum.hybrid,
      description: 'Equipes 3x3 competindo pelo título estadual.',
      startDate: DateTime(2026, 9, 12),
      endDate: DateTime(2026, 9, 30),
    ),
    ChampionshipEntity(
      name: 'Copa Universitária',
      sport: SportTypeEnum.futmesa,
      format: ChampionshipFormatEnum.points,
      description: 'Maior torneio de futsal entre as universidades.',
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 11, 30),
    ),
  ];

  // Variáveis de estado para os filtros
  String _searchQuery = '';
  String _selectedSport = 'Todos';

  // Opções de filtro de esporte geradas dinamicamente do enum
  List<String> get _sportsOptions => [
    'Todos',
    ...SportTypeEnum.values.map((s) => s.label),
  ];

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Opções',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Adicionar campeonato'),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await Navigator.of(context)
                    .push<ChampionshipEntity>(
                      MaterialPageRoute(
                        builder: (_) => const SaveChampionshipView(),
                      ),
                    );

                if (result != null) {
                  setState(() {
                    championships.add(result);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Aplicando os filtros na lista
    final filteredChampionships = championships.where((champ) {
      final matchesSearch = champ.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesSport =
          _selectedSport == 'Todos' || champ.sport.label == _selectedSport;

      return matchesSearch && matchesSport;
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Gerenciador de Campeonatos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
              onPressed: () => _openMenu(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Área dos Filtros
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filtro por Nome (Texto)
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Pesquisar campeonato',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Filtro por Esporte (ChoiceChips)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _sportsOptions.map((sport) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(sport),
                            selected: _selectedSport == sport,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedSport = sport;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de Campeonatos (Resultado dos Filtros)
            Expanded(
              child: filteredChampionships.isEmpty
                  ? const Center(
                      child: Text('Nenhum campeonato encontrado.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filteredChampionships.length,
                      itemBuilder: (context, index) {
                        final championship = filteredChampionships[index];

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChampionshipView(
                                  championship: championship,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Imagem/Thumbnail do Campeonato
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      image: championship.imagePath != null
                                          ? DecorationImage(
                                              image: FileImage(
                                                File(championship.imagePath!),
                                              ),
                                              fit: BoxFit.contain,
                                            )
                                          : null,
                                    ),
                                    child: championship.imagePath == null
                                        ? Icon(
                                            Icons.emoji_events,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.5),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),

                                  // Detalhes do Campeonato
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Cabeçalho do Card (Título e Logo)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                championship.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Chip(
                                              label: Text(
                                                championship.sport.label,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              backgroundColor: Colors.blue
                                                  .withValues(alpha: 0.1),
                                              side: BorderSide.none,
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        // Descrição
                                        Text(
                                          championship.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 4),

                                        // Formato
                                        Text(
                                          'Formato: ${championship.format.label}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 10,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${_formatDate(championship.startDate)} - ${_formatDate(championship.endDate)}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
