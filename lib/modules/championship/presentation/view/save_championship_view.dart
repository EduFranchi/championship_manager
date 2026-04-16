import 'package:flutter/material.dart';
import 'package:championship_manager/modules/championship/domain/entity/championship_entity.dart';
import 'package:championship_manager/modules/championship/domain/entity/enum/sport_type_enum.dart';

class SaveChampionshipView extends StatefulWidget {
  final ChampionshipEntity? championship;

  const SaveChampionshipView({super.key, this.championship});

  @override
  State<SaveChampionshipView> createState() => _SaveChampionshipViewState();
}

class _SaveChampionshipViewState extends State<SaveChampionshipView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  SportTypeEnum? _selectedSport;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isEditing => widget.championship != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.championship?.name);
    _descriptionController = TextEditingController(
      text: widget.championship?.description,
    );
    _selectedSport = widget.championship?.sport;
    _startDate = widget.championship?.startDate;
    _endDate = widget.championship?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _showSportPicker() {
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
                'Selecionar Esporte',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: SportTypeEnum.values
                    .map(
                      (sport) => ListTile(
                        title: Text(sport.label),
                        trailing: _selectedSport == sport
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          setState(() => _selectedSport = sport);
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um esporte.')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe as datas de início e fim.')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A data de fim não pode ser anterior à de início.'),
        ),
      );
      return;
    }

    final entity = ChampionshipEntity(
      name: _nameController.text.trim(),
      sport: _selectedSport!,
      description: _descriptionController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
    );

    Navigator.of(context).pop(entity);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Campeonato' : 'Novo Campeonato'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nome
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do campeonato',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do campeonato.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Descrição
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a descrição do campeonato.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Esporte
                InkWell(
                  onTap: _showSportPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Esporte',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _selectedSport?.label ?? 'Selecione um esporte',
                      style: TextStyle(
                        color: _selectedSport == null
                            ? Theme.of(context).hintColor
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Data de início
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _startDate != null
                        ? 'Início: ${_formatDate(_startDate!)}'
                        : 'Data de início',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  onTap: () => _pickDate(isStart: true),
                ),
                const SizedBox(height: 16),

                // Data de fim
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: const Icon(Icons.event_available),
                  title: Text(
                    _endDate != null
                        ? 'Fim: ${_formatDate(_endDate!)}'
                        : 'Data de fim',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  onTap: () => _pickDate(isStart: false),
                ),
                const SizedBox(height: 32),

                // Botão salvar
                FilledButton(
                  onPressed: _submit,
                  child: Text(
                    _isEditing ? 'Salvar alterações' : 'Criar campeonato',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
