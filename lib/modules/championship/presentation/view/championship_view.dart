import 'dart:io';
import 'package:championship_manager/modules/championship/domain/entity/enum/sport_type_enum.dart';
import 'package:championship_manager/modules/championship/domain/entity/enum/championship_format_enum.dart';
import 'package:championship_manager/modules/championship/presentation/view/save_championship_view.dart';
import 'package:flutter/material.dart';
import 'package:championship_manager/modules/championship/domain/entity/championship_entity.dart';

class ChampionshipView extends StatefulWidget {
  final ChampionshipEntity championship;

  const ChampionshipView({
    super.key,
    required this.championship,
  });

  @override
  State<ChampionshipView> createState() => _ChampionshipViewState();
}

class _ChampionshipViewState extends State<ChampionshipView>
    with SingleTickerProviderStateMixin {
  late ChampionshipEntity _currentChampionship;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentChampionship = widget.championship;
    _tabController = TabController(
      length: _isKnockout ? 2 : 3,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _editChampionship() async {
    final result = await Navigator.of(context).push<ChampionshipEntity>(
      MaterialPageRoute(
        builder: (_) => SaveChampionshipView(
          championship: _currentChampionship,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentChampionship = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Editar Campeonato',
                onPressed: _editChampionship,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: LayoutBuilder(
                builder: (context, constraints) {
                  // Determina se a AppBar está colapsada (ou próxima disso)
                  final settings = context
                      .dependOnInheritedWidgetOfExactType<
                        FlexibleSpaceBarSettings
                      >();
                  final bool isCollapsed =
                      settings != null &&
                      settings.currentExtent <=
                          settings.minExtent +
                              MediaQuery.of(context).padding.top +
                              10;

                  return Text(
                    _currentChampionship.name,
                    maxLines: isCollapsed ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isCollapsed
                          ? Theme.of(context).colorScheme.onPrimary
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: Center(
                  child: _currentChampionship.imagePath != null
                      ? Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: DecorationImage(
                              image: FileImage(
                                File(_currentChampionship.imagePath!),
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.3),
                        ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSummaryCard(),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: _isKnockout
                    ? const [
                        Tab(
                          text: 'Eliminatórias',
                          icon: Icon(Icons.account_tree),
                        ),
                        Tab(text: 'Equipes', icon: Icon(Icons.groups)),
                      ]
                    : const [
                        Tab(text: 'Tabela', icon: Icon(Icons.table_chart)),
                        Tab(text: 'Rodadas', icon: Icon(Icons.list_alt)),
                        Tab(text: 'Equipes', icon: Icon(Icons.groups)),
                      ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 32),
            sliver: _buildActiveTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent() {
    if (_isKnockout) {
      return switch (_tabController.index) {
        0 => SliverToBoxAdapter(child: _buildKnockoutBrackets()),
        1 => _buildTeamsList(),
        _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
      };
    }

    if (!_isPointsFormat) {
      return SliverToBoxAdapter(
        child: _buildPlaceholder(
          _tabController.index == 0
              ? 'A tabela de classificação aparecerá aqui.'
              : _tabController.index == 1
              ? 'A listagem de rodadas e jogos aparecerá aqui.'
              : 'A lista de equipes participantes aparecerá aqui.',
        ),
      );
    }

    return switch (_tabController.index) {
      0 => SliverToBoxAdapter(child: _buildPointsTable()),
      1 => _buildRoundsList(),
      2 => _buildTeamsList(),
      _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
    };
  }

  Widget _buildKnockoutBrackets() {
    // Simulando um campeonato com 53 equipes (cenário solicitado pelo usuário)
    const int startingTeamsCount = 53;
    final List<_RoundInfo> rounds = _calculateKnockoutRounds(startingTeamsCount);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(rounds.length, (index) {
            final round = rounds[index];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBracketColumn(
                  round.name,
                  round.matchCount,
                  exemptCount: round.exemptCount,
                  isFinal: round.teamsCount == 2,
                ),
                if (round.teamsCount > 2) _buildBracketDivider(),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _getRoundName(int teamsInRound, int totalTeams, int roundIndex) {
    if (teamsInRound == 2) return 'Final';
    if (teamsInRound == 4) return 'Semifinal';
    if (teamsInRound == 8) return 'Quartas de Final';
    if (teamsInRound == 16) return 'Oitavas de Final';

    // Acima de 16, segue a lógica de 1ª Fase, 2ª Fase, etc.
    return '${roundIndex + 1}ª Fase ($teamsInRound)';
  }

  Widget _buildBracketColumn(
    String title,
    int matchCount, {
    int exemptCount = 0,
    bool isFinal = false,
  }) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          if (exemptCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '$exemptCount equipes isentas',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 24),
          ...List.generate(matchCount, (index) {
            return _buildKnockoutMatchCard(isFinal && index == 0);
          }),
          if (isFinal) ...[
            const SizedBox(height: 48),
            Text(
              'Disputa de 3º Lugar',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildKnockoutMatchCard(false, isThirdPlace: true),
          ],
        ],
      ),
    );
  }

  Widget _buildBracketDivider() {
    return const SizedBox(
      width: 40,
      child: Center(
        child: Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
    );
  }

  Widget _buildKnockoutMatchCard(
    bool isGrandFinal, {
    bool isThirdPlace = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGrandFinal
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.withValues(alpha: 0.2),
          width: isGrandFinal ? 2 : 1,
        ),
        boxShadow: isGrandFinal
            ? [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          _buildKnockoutTeamRow('Equipe A', '2', true),
          const Divider(height: 1),
          _buildKnockoutTeamRow('Equipe B', '1', false),
        ],
      ),
    );
  }

  Widget _buildKnockoutTeamRow(String name, String score, bool isWinner) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.shield,
              size: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                color: isWinner ? null : Colors.grey,
              ),
            ),
          ),
          Text(
            score,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isWinner
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  bool get _isKnockout =>
      _currentChampionship.format == ChampionshipFormatEnum.knockout;

  bool get _isPointsFormat =>
      _currentChampionship.format == ChampionshipFormatEnum.pointsSimple ||
      _currentChampionship.format == ChampionshipFormatEnum.points;

  List<_RoundInfo> _calculateKnockoutRounds(int startingTeams) {
    List<_RoundInfo> rounds = [];
    int currentTeams = startingTeams;
    int roundIndex = 0;

    // Se não for potência de 2, a primeira fase é especial (Equipes Isentas)
    if (!_isPowerOfTwo(currentTeams)) {
      final int nextPowerOfTwo = _highestPowerOfTwoLessThan(currentTeams);
      final int matches = currentTeams - nextPowerOfTwo;
      final int exempt = currentTeams - (2 * matches);

      rounds.add(_RoundInfo(
        teamsCount: currentTeams,
        matchCount: matches,
        exemptCount: exempt,
        name: _getRoundName(currentTeams, startingTeams, roundIndex),
      ));

      currentTeams = nextPowerOfTwo;
      roundIndex++;
    }

    // Rodadas subsequentes (Sempre potências de 2)
    while (currentTeams >= 2) {
      rounds.add(_RoundInfo(
        teamsCount: currentTeams,
        matchCount: currentTeams ~/ 2,
        exemptCount: 0,
        name: _getRoundName(currentTeams, startingTeams, roundIndex),
      ));
      currentTeams ~/= 2;
      roundIndex++;
    }

    return rounds;
  }

  bool _isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;

  int _highestPowerOfTwoLessThan(int n) {
    if (n < 1) return 0;
    int p = 1;
    while (p * 2 < n) {
      p *= 2;
    }
    return p;
  }

  bool get _isFootball => [
    SportTypeEnum.soccer,
    SportTypeEnum.soccer7,
    SportTypeEnum.soccerSwiss,
    SportTypeEnum.futsal,
  ].contains(_currentChampionship.sport);

  bool get _isBasketball =>
      _currentChampionship.sport == SportTypeEnum.basketball;

  Widget _buildPointsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.3),
          ),
          columns: [
            const DataColumn(
              label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const DataColumn(
              label: Text(
                'Equipe',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const DataColumn(
              label: Text('P', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const DataColumn(
              label: Text('J', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const DataColumn(
              label: Text('V', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (_isFootball)
              const DataColumn(
                label: Text(
                  'E',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const DataColumn(
              label: Text('D', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (_isFootball)
              const DataColumn(
                label: Text(
                  'SG',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (_isBasketball)
              const DataColumn(
                label: Text(
                  'SC',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
          rows: List.generate(
            5,
            (index) => DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        child: Icon(Icons.shield, size: 12),
                      ),
                      const SizedBox(width: 8),
                      Text('Equipe ${index + 1}'),
                    ],
                  ),
                ),
                DataCell(Text('${(5 - index) * 3}')),
                const DataCell(Text('5')),
                DataCell(Text('${5 - index}')),
                if (_isFootball) const DataCell(Text('0')),
                DataCell(Text('$index')),
                if (_isFootball) DataCell(Text('${(5 - index) * 2}')),
                if (_isBasketball) DataCell(Text('${(5 - index) * 10}')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundsList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, roundIndex) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${roundIndex + 1}ª Rodada',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Text(
                      '15/05/2026',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(2, (matchIndex) {
                  final isFinished = matchIndex == 0;
                  return Card(
                    elevation: 0,
                    color:
                        Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Equipe ${matchIndex + 1}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: isFinished
                                ? BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  )
                                : null,
                            child: Text(
                              isFinished ? '2 × 1' : '×',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 2,
                                color: isFinished ? null : Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Equipe ${matchIndex + 3}',
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            );
          },
          childCount: 3,
        ),
      ),
    );
  }

  Widget _buildTeamsList() {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.shield,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text('Equipe ${index + 1}'),
              subtitle: const Text('Cidade da Equipe'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                // Futura navegação para detalhes da equipe
              },
            );
          },
          childCount: 8,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildInfoItem(
                  Icons.sports_soccer,
                  'Esporte',
                  _currentChampionship.sport.label,
                ),
                _buildInfoItem(
                  Icons.format_list_bulleted,
                  'Formato',
                  _currentChampionship.format.label,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                _buildInfoItem(
                  Icons.calendar_today,
                  'Início',
                  _formatDate(_currentChampionship.startDate),
                ),
                _buildInfoItem(
                  Icons.event_available,
                  'Fim',
                  _formatDate(_currentChampionship.endDate),
                ),
              ],
            ),
            if (_currentChampionship.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Descrição',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _currentChampionship.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _RoundInfo {
  final int teamsCount;
  final int matchCount;
  final int exemptCount;
  final String name;

  _RoundInfo({
    required this.teamsCount,
    required this.matchCount,
    required this.exemptCount,
    required this.name,
  });
}
