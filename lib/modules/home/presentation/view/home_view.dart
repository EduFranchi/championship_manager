import 'package:flutter/material.dart';
import 'package:championship_manager/modules/championship/domain/entity/championship_entity.dart';
import 'package:championship_manager/modules/championship/domain/entity/enum/sport_type_enum.dart';
import 'package:championship_manager/modules/championship/presentation/view/save_championship_view.dart';

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
      description: 'Torneio amador com as equipes da região metropolitana.',
      startDate: DateTime(2026, 5, 15),
      endDate: DateTime(2026, 7, 20),
    ),
    ChampionshipEntity(
      name: 'Liga Futsal Várzea',
      sport: SportTypeEnum.futsal,
      description: 'Campeonato longo de pontos corridos interbairros.',
      startDate: DateTime(2026, 6, 10),
      endDate: DateTime(2026, 8, 30),
    ),
    ChampionshipEntity(
      name: 'Master de Vôlei',
      sport: SportTypeEnum.volleyball,
      description: 'Competição voltada para atletas acima de 40 anos.',
      startDate: DateTime(2026, 12, 1),
      endDate: DateTime(2026, 12, 15),
    ),
    ChampionshipEntity(
      name: 'Open de Tênis de Inverno',
      sport: SportTypeEnum.tennis,
      description: 'Torneio de simples masculino e feminino na cidade.',
      startDate: DateTime(2026, 8, 5),
      endDate: DateTime(2026, 8, 20),
    ),
    ChampionshipEntity(
      name: 'Circuito de Basquete de Rua',
      sport: SportTypeEnum.basketball,
      description: 'Times 3x3 competindo pelo título estadual.',
      startDate: DateTime(2026, 9, 12),
      endDate: DateTime(2026, 9, 30),
    ),
    ChampionshipEntity(
      name: 'Copa Universitária',
      sport: SportTypeEnum.futsal,
      description: 'Maior torneio de futsal entre as universidades.',
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 11, 30),
    ),
  ];

  // Variáveis de estado para os filtros
  String _searchQuery = '';
  String _selectedSport = 'Todos';

  // Opções de filtro de esporte
  final List<String> _sportsOptions = [
    'Todos',
    'Futebol de Campo',
    'Futsal',
    'Vôlei',
    'Basquete',
    'Tênis',
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
          title: const Text('Gerenciador de Campeonatos'),
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

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cabeçalho do Card (Título e Esporte)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        championship.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(
                                        championship.sport.label,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.blue.withValues(
                                        alpha: 0.1,
                                      ),
                                      side: BorderSide.none,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Descrição
                                Text(
                                  championship.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),

                                // Datas (Início e Fim)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.blueGrey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Início: ${_formatDate(championship.startDate)}',
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.event_available,
                                      size: 16,
                                      color: Colors.blueGrey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fim: ${_formatDate(championship.endDate)}',
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
