import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/features/entregas_equipo/data/entrega_equipo_service.dart';
import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo.dart';
import 'package:acbmin_site/features/entregas_equipo/presentation/entrega_equipo_form_page.dart';
import 'package:acbmin_site/features/entregas_equipo/presentation/entrega_equipo_list_controller.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'package:acbmin_site/platform/file_downloader.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Listado autenticado del módulo Entrega de Equipo.
class EntregaEquipoListPage extends StatefulWidget {
  const EntregaEquipoListPage({super.key, this.repository});

  /// La inyección del repositorio permite probar la pantalla sin una API real.
  final EntregaEquipoRepository? repository;

  @override
  State<EntregaEquipoListPage> createState() => _EntregaEquipoListPageState();
}

class _EntregaEquipoListPageState extends State<EntregaEquipoListPage> {
  final _searchController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final Set<int> _busyFolios = <int>{};

  late final EntregaEquipoRepository _repository;
  late final EntregaEquipoListController _controller;
  late final bool _ownsRepository;

  @override
  void initState() {
    super.initState();
    _ownsRepository = widget.repository == null;
    _repository = widget.repository ?? EntregaEquipoService();
    _controller = EntregaEquipoListController(_repository)..load();
    _searchController.addListener(_applySearch);
  }

  void _applySearch() => _controller.setSearch(_searchController.text);

  Future<void> _openNew() async {
    final created = await Navigator.push<EntregaEquipo>(
      context,
      MaterialPageRoute(
        builder: (_) => EntregaEquipoFormPage(repository: _repository),
      ),
    );
    if (created == null || !mounted) return;

    await _controller.registerCreated(created);
    if (!mounted) return;
    _showMessage(
      'Entrega ${created.folioFormateado} creada correctamente.',
      color: Colors.green,
    );
  }

  Future<void> _openEdit(EntregaEquipo entrega) async {
    final folio = entrega.folio;
    if (folio == null) return;

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EntregaEquipoFormPage(
          folio: folio,
          repository: _repository,
        ),
      ),
    );
    if (updated == true && mounted) await _controller.load();
  }

  /// Muestra todos los equipos con una interacción compatible con mouse y tacto.
  Future<void> _showEquipmentDetails(EntregaEquipo entrega) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => _EquiposDetailDialog(entrega: entrega),
    );
  }

  Future<void> _downloadPdf(EntregaEquipo entrega) async {
    final folio = entrega.folio;
    if (folio == null || _busyFolios.contains(folio)) return;

    setState(() => _busyFolios.add(folio));
    try {
      final pdf = await _repository.downloadPdf(folio);
      await downloadFile(pdf.bytes, pdf.fileName);
      if (!mounted) return;
      _showMessage('La descarga del PDF ha comenzado.', color: Colors.green);
    } catch (error) {
      if (!mounted) return;
      _showMessage(_messageFor(error), color: Colors.red);
    } finally {
      if (mounted) setState(() => _busyFolios.remove(folio));
    }
  }

  Future<void> _confirmDelete(EntregaEquipo entrega) async {
    final folio = entrega.folio;
    if (folio == null || _busyFolios.contains(folio)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar entrega'),
        content: Text(
          '¿Deseas eliminar definitivamente la entrega '
          '${entrega.folioFormateado}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busyFolios.add(folio));
    try {
      await _controller.deleteByFolio(folio);
      if (!mounted) return;
      _showMessage('Entrega eliminada correctamente.', color: Colors.green);
    } catch (error) {
      if (!mounted) return;
      _showMessage(_messageFor(error), color: Colors.red);
    } finally {
      if (mounted) setState(() => _busyFolios.remove(folio));
    }
  }

  String _messageFor(Object error) => error is ApiException
      ? error.message
      : 'No fue posible completar la operación.';

  void _showMessage(String message, {required Color color}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_applySearch)
      ..dispose();
    _controller.dispose();
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
          context.isMobile ? 'Entrega de Equipo' : 'ACBMIN: ENTREGA DE EQUIPO',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: context.isMobile ? 19 : 24,
          ),
        ),
        leading: IconButton(
          tooltip: 'Volver al menú',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar listado',
            onPressed: _controller.load,
            icon: const Icon(Icons.refresh),
          ),
          if (!context.isMobile && usuarioGlobal?.nombre != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  usuarioGlobal!.nombre!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(context.pagePadding),
        child: Column(
          children: [
            ResponsiveToolbar(
              search: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar entregas',
                  hintText: 'Folio, nombre, serie, PESA o descripción',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              primaryAction: ElevatedButton.icon(
                onPressed: _openNew,
                icon: const Icon(Icons.add),
                label: const Text('Nueva entrega'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => _buildListState(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListState() {
    return switch (_controller.status) {
      EntregaEquipoListStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      EntregaEquipoListStatus.empty => _EmptyState(onCreate: _openNew),
      EntregaEquipoListStatus.error => _ErrorState(
          message: _controller.errorMessage,
          onRetry: _controller.load,
        ),
      EntregaEquipoListStatus.success => _buildSuccess(),
    };
  }

  Widget _buildSuccess() {
    final items = _controller.visibleItems;
    if (items.isEmpty) {
      return const Center(
        child: Text('No hay entregas que coincidan con la búsqueda.'),
      );
    }
    return context.isMobile
        ? ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => _EntregaMobileCard(
              entrega: items[index],
              dateFormat: _dateFormat,
              busy: items[index].folio != null &&
                  _busyFolios.contains(items[index].folio),
              onEdit: () => _openEdit(items[index]),
              onViewEquipment: () => _showEquipmentDetails(items[index]),
              onPdf: () => _downloadPdf(items[index]),
              onDelete: () => _confirmDelete(items[index]),
            ),
          )
        : _buildDesktopTable(items);
  }

  Widget _buildDesktopTable(List<EntregaEquipo> items) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) => Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth < 1040 ? 1040 : constraints.maxWidth,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Folio')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Usuario receptor')),
                    DataColumn(label: Text('Cargo')),
                    DataColumn(label: Text('Equipos')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: items.map(_buildDataRow).toList(growable: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(EntregaEquipo entrega) {
    final busy = entrega.folio != null && _busyFolios.contains(entrega.folio);

    return DataRow(
      cells: [
        DataCell(Text(entrega.folioFormateado)),
        DataCell(Text(_dateFormat.format(entrega.fechaEntrega))),
        DataCell(
          SizedBox(
            width: 190,
            child: Text(entrega.nombreUsuario, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(
          SizedBox(
            width: 150,
            child: Text(entrega.cargo, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(
          // La tabla muestra la cantidad y permite abrir el detalle completo.
          _EquipmentDetailsButton(
            count: entrega.equipos.length,
            onPressed: () => _showEquipmentDetails(entrega),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Ver o editar',
                onPressed: busy ? null : () => _openEdit(entrega),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Descargar PDF',
                onPressed: busy ? null : () => _downloadPdf(entrega),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.teal),
              ),
              IconButton(
                tooltip: 'Eliminar',
                onPressed: busy ? null : () => _confirmDelete(entrega),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EntregaMobileCard extends StatelessWidget {
  const _EntregaMobileCard({
    required this.entrega,
    required this.dateFormat,
    required this.busy,
    required this.onEdit,
    required this.onViewEquipment,
    required this.onPdf,
    required this.onDelete,
  });

  final EntregaEquipo entrega;
  final DateFormat dateFormat;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onViewEquipment;
  final VoidCallback onPdf;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Folio ${entrega.folioFormateado}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text('Fecha: ${dateFormat.format(entrega.fechaEntrega)}'),
            Text('Usuario: ${entrega.nombreUsuario}'),
            Text('Cargo: ${entrega.cargo}'),
            // El mismo botón funciona con clic, teclado o toque en móvil.
            _EquipmentDetailsButton(
              count: entrega.equipos.length,
              onPressed: onViewEquipment,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: busy ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Ver / editar'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : onPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón reutilizable que evita depender exclusivamente del hover del mouse.
class _EquipmentDetailsButton extends StatelessWidget {
  const _EquipmentDetailsButton({
    required this.count,
    required this.onPressed,
  });

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = count == 0
        ? 'Sin equipos'
        : count == 1
            ? '1 equipo'
            : '$count equipos';
    return Tooltip(
      message: 'Ver todos los equipos entregados',
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.devices_other_outlined, size: 20),
        label: Text(label),
      ),
    );
  }
}

/// Ventana desplazable que presenta el detalle completo en cualquier pantalla.
class _EquiposDetailDialog extends StatelessWidget {
  const _EquiposDetailDialog({required this.entrega});

  final EntregaEquipo entrega;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final contentWidth = screenSize.width < 600
        ? screenSize.width - 80
        : 680.0;
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenSize.width < 600 ? 16 : 40,
        vertical: 24,
      ),
      constraints: BoxConstraints(
        minWidth: screenSize.width >= 800 ? 680 : 280,
        maxWidth: 760,
        maxHeight: screenSize.height * .9,
      ),
      title: Text('Equipos de la entrega ${entrega.folioFormateado}'),
      // Un tamaño explícito evita cálculos intrínsecos incompatibles con ListView.
      content: SizedBox(
        width: contentWidth,
        height: screenSize.height * .55,
        child: entrega.equipos.isEmpty
            ? const Center(child: Text('Esta entrega no contiene equipos.'))
            : ListView.separated(
                itemCount: entrega.equipos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _EquipoDetailCard(
                  index: index,
                  equipo: entrega.equipos[index],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

/// Resume un equipo sin ocultar información y permite que los datos se ajusten.
class _EquipoDetailCard extends StatelessWidget {
  const _EquipoDetailCard({required this.index, required this.equipo});

  final int index;
  final EquipoEntregado equipo;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.amber.withValues(alpha: .08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Equipo ${index + 1}: ${equipo.descripcion}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            // Los chips saltan de línea automáticamente en pantallas estrechas.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _EquipmentAttribute('Cantidad', equipo.cantidad.toString()),
                _EquipmentAttribute('Marca', equipo.marca),
                _EquipmentAttribute('Modelo', equipo.modelo),
                _EquipmentAttribute('Serie', equipo.serie),
                _EquipmentAttribute('PESA', equipo.pesa),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentAttribute extends StatelessWidget {
  const _EquipmentAttribute(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text('$label: $value'),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 58, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Aún no existen entregas de equipo.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Crear primera entrega'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 58, color: Colors.red),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
