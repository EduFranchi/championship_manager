import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Lista mockada de campeonatos
  final List<Map<String, String>> championships = [
    {
      'name': 'Copa Regional 2026',
      'sport': 'Futebol de Campo',
      'description': 'Torneio amador com as equipes da região metropolitana.',
      'startDate': '15/05/2026',
      'endDate': '20/07/2026',
    },
    {
      'name': 'Liga Futsal Várzea',
      'sport': 'Futsal',
      'description': 'Campeonato longo de pontos corridos interbairros.',
      'startDate': '10/06/2026',
      'endDate': '30/08/2026',
    },
    {
      'name': 'Master de Vôlei',
      'sport': 'Vôlei',
      'description': 'Competição voltada para atletas acima de 40 anos.',
      'startDate': '01/12/2026',
      'endDate': '15/12/2026',
    },
    {
      'name': 'Open de Tênis de Inverno',
      'sport': 'Tênis',
      'description': 'Torneio de simples masculino e feminino na cidade.',
      'startDate': '05/08/2026',
      'endDate': '20/08/2026',
    },
    {
      'name': 'Circuito de Basquete de Rua',
      'sport': 'Basquete',
      'description': 'Times 3x3 competindo pelo título estadual.',
      'startDate': '12/09/2026',
      'endDate': '30/09/2026',
    },
    {
      'name': 'Copa Universitária',
      'sport': 'Futsal',
      'description': 'Maior torneio de futsal entre as universidades.',
      'startDate': '01/10/2026',
      'endDate': '30/11/2026',
    },
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

  @override
  Widget build(BuildContext context) {
    // Aplicando os filtros na lista mockada
    final filteredChampionships = championships.where((champ) {
      final matchesSearch =
          champ['name']?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false;
      final matchesSport =
          _selectedSport == 'Todos' || champ['sport'] == _selectedSport;

      return matchesSearch && matchesSport;
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Campeonatos'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Novo Campeonato',
              onPressed: () {
                // TODO: Navegar para a tela de criação ou abrir um modal
              },
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        championship['name'] ?? '',
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
                                        championship['sport'] ?? '',
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
                                  championship['description'] ?? '',
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
                                      'Início: ${championship['startDate']}',
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
                                      'Fim: ${championship['endDate']}',
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
