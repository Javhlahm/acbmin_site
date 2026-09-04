import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/features/entregas_equipo/data/entrega_equipo_service.dart';
import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo.dart';
import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo_validator.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formulario único para crear o editar una Entrega de Equipo.
///
/// Cuando [folio] es nulo realiza POST; cuando existe carga el registro con GET
/// y guarda el arreglo completo de equipos mediante PUT.
class EntregaEquipoFormPage extends StatefulWidget {
  const EntregaEquipoFormPage({
    super.key,
    this.folio,
    this.repository,
  });

  final int? folio;
  final EntregaEquipoRepository? repository;

  @override
  State<EntregaEquipoFormPage> createState() => _EntregaEquipoFormPageState();
}

class _EntregaEquipoFormPageState extends State<EntregaEquipoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  // Cada controlador representa un campo editable de la cabecera del documento.
  final _fechaEntregaController = TextEditingController();
  final _nombreUsuarioController = TextEditingController();
  final _cargoController = TextEditingController();
  final _telefonoExtensionController = TextEditingController();
  final _direccionAreaController = TextEditingController();
  final _direccionGeneralController = TextEditingController();
  final _subsecretariaController = TextEditingController();
  final _elaboradoPorController = TextEditingController();
  final _capturadoPorController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _folioController = TextEditingController();
  final _fechaCreacionController = TextEditingController();

  final List<_EquipoControllers> _equipos = <_EquipoControllers>[];
  late final EntregaEquipoRepository _repository;
  late final bool _ownsRepository;

  DateTime _fechaEntrega = DateTime.now();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _loadError;

  bool get _isEditing => widget.folio != null;

  @override
  void initState() {
    super.initState();
    _ownsRepository = widget.repository == null;
    _repository = widget.repository ?? EntregaEquipoService();

    // El correo proviene exclusivamente de la sesión y nunca es editable.
    _capturadoPorController.text = usuarioGlobal?.email?.trim() ?? '';
    _fechaEntregaController.text = _dateFormat.format(_fechaEntrega);
    _addEquipo(notify: false);

    if (_isEditing) _loadEntrega();
  }

  Future<void> _loadEntrega() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final entrega = await _repository.fetchByFolio(widget.folio!);
      if (!mounted) return;
      _fillForm(entrega);
      setState(() => _isLoading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = _messageFor(error);
      });
    }
  }

  /// Copia los datos recibidos del backend a los controles visuales de edición.
  void _fillForm(EntregaEquipo entrega) {
    _fechaEntrega = entrega.fechaEntrega;
    _fechaEntregaController.text = _dateFormat.format(entrega.fechaEntrega);
    _nombreUsuarioController.text = entrega.nombreUsuario;
    _cargoController.text = entrega.cargo;
    _telefonoExtensionController.text = entrega.telefonoExtension;
    _direccionAreaController.text = entrega.direccionArea;
    _direccionGeneralController.text = entrega.direccionGeneral;
    _subsecretariaController.text = entrega.subsecretaria;
    _elaboradoPorController.text = entrega.elaboradoPor;
    // En edición también se registra al usuario de la sesión actual. Solo se
    // conserva el valor del servidor como respaldo si la sesión no trae correo.
    final sessionEmail = usuarioGlobal?.email?.trim() ?? '';
    _capturadoPorController.text =
        sessionEmail.isNotEmpty ? sessionEmail : entrega.capturadoPor;
    _observacionesController.text = entrega.observaciones;
    _folioController.text = entrega.folioFormateado;
    _fechaCreacionController.text = entrega.fechaCreacion == null
        ? ''
        : _dateFormat.format(entrega.fechaCreacion!);

    for (final controllers in _equipos) {
      controllers.dispose();
    }
    _equipos
      ..clear()
      ..addAll(entrega.equipos.map(_EquipoControllers.fromModel));
    if (_equipos.isEmpty) _addEquipo(notify: false);
  }

  void _addEquipo({bool notify = true}) {
    _equipos.add(_EquipoControllers.empty());
    if (notify) setState(() {});
  }

  void _removeEquipo(int index) {
    if (_equipos.length == 1) {
      _showMessage(
        'Debe conservar al menos un equipo. Agrega otro antes de eliminarlo.',
        color: Colors.orange,
      );
      return;
    }
    final removed = _equipos.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _fechaEntrega = selected;
      _fechaEntregaController.text = _dateFormat.format(selected);
    });
  }

  EntregaEquipo _buildEntrega() {
    return EntregaEquipo(
      folio: widget.folio,
      fechaEntrega: _fechaEntrega,
      nombreUsuario: _nombreUsuarioController.text.trim(),
      cargo: _cargoController.text.trim(),
      telefonoExtension: _telefonoExtensionController.text.trim(),
      direccionArea: _direccionAreaController.text.trim(),
      direccionGeneral: _direccionGeneralController.text.trim(),
      subsecretaria: _subsecretariaController.text.trim(),
      elaboradoPor: _elaboradoPorController.text.trim(),
      capturadoPor: _capturadoPorController.text.trim(),
      observaciones: _observacionesController.text.trim(),
      fechaCreacion: _fechaCreacionController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_fechaCreacionController.text.trim()),
      equipos: _equipos.map((controllers) => controllers.toModel()).toList(),
    );
  }

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) return;

    final entrega = _buildEntrega();
    final validationErrors = EntregaEquipoValidator.validate(entrega);
    if (validationErrors.isNotEmpty) {
      _showMessage(validationErrors.first, color: Colors.red);
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        await _repository.update(widget.folio!, entrega);
        if (!mounted) return;
        _showMessage('Entrega actualizada correctamente.', color: Colors.green);
        Navigator.pop(context, true);
      } else {
        final created = await _repository.create(entrega);
        if (!mounted) return;
        Navigator.pop(context, created);
      }
    } catch (error) {
      if (!mounted) return;
      // El formulario permanece intacto para que el usuario pueda corregir o reintentar.
      _showMessage(_messageFor(error), color: Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _messageFor(Object error) => error is ApiException
      ? error.message
      : 'Ocurrió un error inesperado. Intenta nuevamente.';

  void _showMessage(String message, {required Color color}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _fechaEntregaController,
      _nombreUsuarioController,
      _cargoController,
      _telefonoExtensionController,
      _direccionAreaController,
      _direccionGeneralController,
      _subsecretariaController,
      _elaboradoPorController,
      _capturadoPorController,
      _observacionesController,
      _folioController,
      _fechaCreacionController,
    ]) {
      controller.dispose();
    }
    for (final controllers in _equipos) {
      controllers.dispose();
    }
    if (_ownsRepository && _repository is EntregaEquipoService) {
      _repository.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Entrega de Equipo' : 'Nueva Entrega de Equipo',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: context.isMobile ? 19 : 24,
          ),
        ),
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return _FormLoadError(message: _loadError!, onRetry: _loadEntrega);
    }

    return ResponsiveFormCard(
      maxWidth: 1400,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing) ...[
              const _SectionTitle('Datos asignados por el servidor'),
              _buildReadOnlyFields(),
              const Divider(height: 36),
            ],
            const _SectionTitle('1. Datos de la entrega'),
            _buildDeliveryFields(),
            const Divider(height: 40),
            Row(
              children: [
                const Expanded(child: _SectionTitle('2. Equipos entregados')),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _addEquipo,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar equipo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < _equipos.length; index++)
              _buildEquipoCard(index),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isEditing ? 'Guardar cambios' : 'Crear entrega'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
                OutlinedButton(
                  onPressed:
                      _isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Solo se muestran metadatos útiles; el estatus no es editable ni visible.
        final width = _fieldWidth(constraints.maxWidth, columns: 2);
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _sizedField(
                width, _textField('Folio', _folioController, enabled: false)),
            _sizedField(
              width,
              _textField(
                'Fecha de creación',
                _fechaCreacionController,
                enabled: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeliveryFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _fieldWidth(constraints.maxWidth, columns: 2);
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _sizedField(
              width,
              TextFormField(
                controller: _fechaEntregaController,
                readOnly: true,
                onTap: _isSaving ? null : _selectDate,
                decoration: const InputDecoration(
                  labelText: 'Fecha de entrega',
                  suffixIcon: Icon(Icons.calendar_month),
                ),
              ),
            ),
            _sizedField(
              width,
              _requiredField(
                  'Nombre del usuario', _nombreUsuarioController, 200),
            ),
            _sizedField(width, _requiredField('Cargo', _cargoController, 150)),
            _sizedField(
              width,
              _requiredField(
                'Teléfono / extensión',
                _telefonoExtensionController,
                100,
                hint: 'Puede capturar N/A',
              ),
            ),
            _sizedField(
              width,
              _requiredField(
                  'Dirección de área', _direccionAreaController, 250),
            ),
            _sizedField(
              width,
              _requiredField(
                'Dirección general',
                _direccionGeneralController,
                250,
              ),
            ),
            _sizedField(
              width,
              _requiredField('Subsecretaría', _subsecretariaController, 250),
            ),
            _sizedField(
              width,
              _requiredField('Elaborado por', _elaboradoPorController, 200),
            ),
            _sizedField(
              width,
              _textField(
                'Capturado por',
                _capturadoPorController,
                enabled: false,
              ),
            ),
            SizedBox(
              width: constraints.maxWidth,
              child: _requiredField(
                'Observaciones',
                _observacionesController,
                1500,
                maxLines: 4,
                hint: 'Puede capturar “Sin observaciones”',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEquipoCard(int index) {
    final controllers = _equipos[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.amber.withValues(alpha: .08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Equipo ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Eliminar equipo',
                  onPressed: _isSaving ? null : () => _removeEquipo(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth >= 1050
                  ? _buildDesktopEquipmentRow(controllers)
                  : _buildCompactEquipmentGrid(
                      controllers, constraints.maxWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopEquipmentRow(_EquipoControllers controllers) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 105, child: _quantityField(controllers.cantidad)),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: _requiredField('Descripción', controllers.descripcion, 500),
        ),
        const SizedBox(width: 10),
        Expanded(child: _requiredField('Marca', controllers.marca, 150)),
        const SizedBox(width: 10),
        Expanded(child: _requiredField('Modelo', controllers.modelo, 150)),
        const SizedBox(width: 10),
        Expanded(child: _requiredField('Serie', controllers.serie, 150)),
        const SizedBox(width: 10),
        Expanded(child: _requiredField('PESA', controllers.pesa, 100)),
      ],
    );
  }

  Widget _buildCompactEquipmentGrid(
    _EquipoControllers controllers,
    double maxWidth,
  ) {
    final width = maxWidth >= 620 ? (maxWidth - 12) / 2 : maxWidth;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _sizedField(width, _quantityField(controllers.cantidad)),
        _sizedField(
          width,
          _requiredField('Descripción', controllers.descripcion, 500),
        ),
        _sizedField(width, _requiredField('Marca', controllers.marca, 150)),
        _sizedField(width, _requiredField('Modelo', controllers.modelo, 150)),
        _sizedField(
          width,
          _requiredField('Serie', controllers.serie, 150, hint: 'Acepta N/A'),
        ),
        _sizedField(
          width,
          _requiredField('PESA', controllers.pesa, 100, hint: 'Acepta N/A'),
        ),
      ],
    );
  }

  Widget _quantityField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(labelText: 'Cantidad'),
      validator: EntregaEquipoValidator.positiveQuantity,
    );
  }

  Widget _requiredField(
    String label,
    TextEditingController controller,
    int maxLength, {
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
      ),
      validator: (value) => EntregaEquipoValidator.requiredText(
        value,
        label: label,
        maxLength: maxLength,
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(labelText: label),
    );
  }

  double _fieldWidth(double maxWidth, {required int columns}) {
    if (context.isMobile || maxWidth < 720) return maxWidth;
    return (maxWidth - (columns - 1) * 16) / columns;
  }

  Widget _sizedField(double width, Widget child) =>
      SizedBox(width: width, child: child);
}

/// Agrupa y libera los controladores que pertenecen a un renglón dinámico.
class _EquipoControllers {
  _EquipoControllers({
    required this.cantidad,
    required this.descripcion,
    required this.marca,
    required this.modelo,
    required this.serie,
    required this.pesa,
  });

  factory _EquipoControllers.empty() => _EquipoControllers(
        cantidad: TextEditingController(text: '1'),
        descripcion: TextEditingController(),
        marca: TextEditingController(),
        modelo: TextEditingController(),
        serie: TextEditingController(),
        pesa: TextEditingController(),
      );

  factory _EquipoControllers.fromModel(EquipoEntregado equipo) =>
      _EquipoControllers(
        cantidad: TextEditingController(text: equipo.cantidad.toString()),
        descripcion: TextEditingController(text: equipo.descripcion),
        marca: TextEditingController(text: equipo.marca),
        modelo: TextEditingController(text: equipo.modelo),
        serie: TextEditingController(text: equipo.serie),
        pesa: TextEditingController(text: equipo.pesa),
      );

  final TextEditingController cantidad;
  final TextEditingController descripcion;
  final TextEditingController marca;
  final TextEditingController modelo;
  final TextEditingController serie;
  final TextEditingController pesa;

  EquipoEntregado toModel() => EquipoEntregado(
        cantidad: int.tryParse(cantidad.text.trim()) ?? 0,
        descripcion: descripcion.text.trim(),
        marca: marca.text.trim(),
        modelo: modelo.text.trim(),
        serie: serie.text.trim(),
        pesa: pesa.text.trim(),
      );

  void dispose() {
    cantidad.dispose();
    descripcion.dispose();
    marca.dispose();
    modelo.dispose();
    serie.dispose();
    pesa.dispose();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
      ),
    );
  }
}

class _FormLoadError extends StatelessWidget {
  const _FormLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
