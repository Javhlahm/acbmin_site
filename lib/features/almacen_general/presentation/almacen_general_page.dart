import 'dart:typed_data';

import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/features/almacen_general/data/almacen_general_service.dart';
import 'package:acbmin_site/features/almacen_general/domain/almacen_general.dart';
import 'package:acbmin_site/features/almacen_general/presentation/compra_form_page.dart';
import 'package:acbmin_site/features/almacen_general/presentation/salida_form_page.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'package:acbmin_site/platform/file_downloader.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:flutter/material.dart';

/// Pantalla del Almacén General: una pestaña por año (2024, 2025, 2026 y los
/// que se vayan agregando). Cada año tiene su vista de compras y de salidas.
class AlmacenGeneralPage extends StatefulWidget {
  const AlmacenGeneralPage({super.key, this.servicio});

  /// Se puede pasar un servicio falso en pruebas.
  final AlmacenGeneralService? servicio;

  @override
  State<AlmacenGeneralPage> createState() => _AlmacenGeneralPageState();
}

class _AlmacenGeneralPageState extends State<AlmacenGeneralPage> {
  late final AlmacenGeneralService _servicio =
      widget.servicio ?? AlmacenGeneralService();

  List<int> _anios = [];
  int? _anioSeleccionado;
  bool _abrirEnSalidas = false; // al recargar, abre la vista de salidas
  bool _cargando = true;
  String? _error;

  // Cambia cada vez que se recargan los años, para que las vistas se vuelvan a crear.
  int _version = 0;

  @override
  void initState() {
    super.initState();
    _cargarAnios();
  }

  @override
  void dispose() {
    if (widget.servicio == null) _servicio.close();
    super.dispose();
  }

  /// Consulta los años y deja seleccionado [seleccionar], el que ya estaba
  /// o el año actual.
  Future<void> _cargarAnios({int? seleccionar, bool salidas = false}) async {
    setState(() {
      _cargando = true;
      _error = null;
      _abrirEnSalidas = salidas;
    });
    try {
      final anios = await _servicio.obtenerAnios();
      if (!mounted) return;
      final preferido = seleccionar ?? _anioSeleccionado ?? DateTime.now().year;
      setState(() {
        _anios = anios;
        _anioSeleccionado = anios.contains(preferido) ? preferido : anios.last;
        _version++;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = error is ApiException
            ? error.message
            : 'No fue posible consultar el almacén.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando || _error != null || _anios.isEmpty) {
      return Scaffold(
        appBar: _barra(context),
        body: Center(
          child: _cargando
              ? const CircularProgressIndicator()
              : _Error(mensaje: _error ?? '', alReintentar: _cargarAnios),
        ),
      );
    }

    return DefaultTabController(
      key: ValueKey(_version),
      length: _anios.length,
      initialIndex: _anios.indexOf(_anioSeleccionado!),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: _barra(
            context,
            pestanas: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.red,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [for (final anio in _anios) Tab(text: '$anio')],
            ),
          ),
          body: TabBarView(
            children: [
              for (final anio in _anios)
                _VistaAnio(
                  key: ValueKey('$anio-$_version'),
                  anio: anio,
                  servicio: _servicio,
                  verSalidasAlInicio:
                      _abrirEnSalidas && anio == _anioSeleccionado,
                  // Si la compra o el vale quedó en otro año (o en uno nuevo),
                  // se recargan los años y se abre la pestaña de ese año.
                  alCambiarDeAnio: (nuevo, {salidas = false}) =>
                      _cargarAnios(seleccionar: nuevo, salidas: salidas),
                ),
            ],
          ),
        );
      }),
    );
  }

  AppBar _barra(BuildContext context, {PreferredSizeWidget? pestanas}) {
    return AppBar(
      title: Text(
        context.isMobile ? 'Almacén General' : 'ACBMIN: ALMACÉN GENERAL',
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
          tooltip: 'Actualizar',
          onPressed: () {
            // Al recargar se queda en la pestaña del año que se está viendo.
            final pestanas = DefaultTabController.maybeOf(context);
            if (pestanas != null) _anioSeleccionado = _anios[pestanas.index];
            _cargarAnios();
          },
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
      bottom: pestanas,
    );
  }
}

/// Contenido de un año: buscador, compras y salidas.
class _VistaAnio extends StatefulWidget {
  const _VistaAnio({
    super.key,
    required this.anio,
    required this.servicio,
    required this.alCambiarDeAnio,
    this.verSalidasAlInicio = false,
  });

  final int anio;
  final AlmacenGeneralService servicio;
  final void Function(int anio, {bool salidas}) alCambiarDeAnio;
  final bool verSalidasAlInicio;

  @override
  State<_VistaAnio> createState() => _VistaAnioState();
}

class _VistaAnioState extends State<_VistaAnio>
    with AutomaticKeepAliveClientMixin {
  final _busquedaController = TextEditingController();

  List<CompraAlmacen> _compras = [];
  List<ValeSalida> _vales = [];
  bool _cargando = true;
  String? _error;
  late bool _verSalidas = widget.verSalidasAlInicio; // false = compras, true = salidas
  bool _ocupado = false; // mientras se borra o se descarga algo

  AlmacenGeneralService get _servicio => widget.servicio;

  // La vista no se vuelve a cargar cada vez que se cambia de pestaña.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _busquedaController.addListener(() => setState(() {}));
    _cargar();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final compras = await _servicio.obtenerCompras(widget.anio);
      final vales = await _servicio.obtenerVales(widget.anio);
      if (!mounted) return;
      setState(() {
        _compras = compras;
        _vales = vales;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = _textoDeError(error);
      });
    }
  }

  // ---------- Acciones de compras ----------

  Future<void> _abrirFormulario([CompraAlmacen? compra]) async {
    final guardada = await Navigator.push<CompraAlmacen>(
      context,
      MaterialPageRoute(
        builder: (_) => CompraFormPage(servicio: _servicio, compra: compra),
      ),
    );
    if (guardada == null || !mounted) return;

    _mensaje(
      compra == null
          ? 'Compra de la factura ${guardada.numeroFactura} guardada en ${guardada.anio}.'
          : 'Compra de la factura ${guardada.numeroFactura} actualizada.',
      Colors.green,
    );
    if (guardada.anio != null && guardada.anio != widget.anio) {
      widget.alCambiarDeAnio(guardada.anio!);
    } else {
      _cargar();
    }
  }

  Future<void> _eliminarCompra(CompraAlmacen compra) async {
    final confirmado = await _confirmar(
      'Eliminar compra',
      '¿Eliminar la compra de la factura ${compra.numeroFactura} '
          '(${compra.proveedor}) con sus ${compra.articulos.length} artículos?',
    );
    if (!confirmado) return;
    await _ejecutar(() => _servicio.eliminarCompra(compra.id!),
        'Compra eliminada.');
  }

  Future<void> _descargarPdf(
      Future<(Uint8List, String)> Function() generar) async {
    setState(() => _ocupado = true);
    try {
      final (bytes, nombre) = await generar();
      await downloadFile(bytes, nombre);
      if (mounted) _mensaje('La descarga del PDF ha comenzado.', Colors.green);
    } catch (error) {
      if (mounted) _mensaje(_textoDeError(error), Colors.red);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  /// Muestra los artículos de la compra. Si se elige "Dar salida",
  /// se abre el vale de salida con ese artículo.
  Future<void> _verArticulos(CompraAlmacen compra) async {
    final articulo = await showDialog<ArticuloAlmacen>(
      context: context,
      builder: (_) => _ArticulosDialog(compra: compra),
    );
    if (articulo == null || !mounted) return;
    await _nuevaSalida(ArticuloDisponible.desde(compra, articulo));
  }

  // ---------- Acciones de vales de salida ----------

  Future<void> _nuevaSalida([ArticuloDisponible? articulo]) async {
    final vale = await Navigator.push<ValeSalida>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SalidaFormPage(servicio: _servicio, articuloInicial: articulo),
      ),
    );
    if (vale == null || !mounted) return;

    // Aviso con el folio y un atajo para descargar el vale.
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Vale de salida ${vale.folioTexto} registrado.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'DESCARGAR PDF',
          textColor: Colors.white,
          onPressed: () => _servicio
              .descargarPdfVale(vale)
              .then((archivo) => downloadFile(archivo.$1, archivo.$2))
              .catchError((_) => messenger.showSnackBar(const SnackBar(
                    content: Text('No se pudo descargar el PDF.'),
                    backgroundColor: Colors.red,
                  ))),
        ),
      ));
    if (vale.anio != null && vale.anio != widget.anio) {
      widget.alCambiarDeAnio(vale.anio!, salidas: true);
    } else {
      setState(() => _verSalidas = true);
      _cargar();
    }
  }

  Future<void> _eliminarVale(ValeSalida vale) async {
    final confirmado = await _confirmar(
      'Eliminar vale de salida',
      '¿Eliminar el vale ${vale.folioTexto}? '
          'Su material regresa a la existencia.',
    );
    if (!confirmado) return;
    await _ejecutar(() => _servicio.eliminarVale(vale.id!),
        'Vale ${vale.folioTexto} eliminado; la existencia se actualizó.');
  }

  Future<void> _verVale(ValeSalida vale) async {
    final descargar = await showDialog<bool>(
      context: context,
      builder: (_) => _ValeDialog(vale: vale),
    );
    if (descargar == true && mounted) {
      _descargarPdf(() => _servicio.descargarPdfVale(vale));
    }
  }

  // ---------- Ayudas ----------

  /// Corre una acción que cambia datos, avisa el resultado y recarga.
  Future<void> _ejecutar(Future<void> Function() accion, String exito) async {
    setState(() => _ocupado = true);
    try {
      await accion();
      if (!mounted) return;
      _mensaje(exito, Colors.green);
      await _cargar();
    } catch (error) {
      if (mounted) _mensaje(_textoDeError(error), Colors.red);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<bool> _confirmar(String titulo, String texto) async {
    final respuesta = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
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
    return respuesta == true && mounted;
  }

  String _textoDeError(Object error) => error is ApiException
      ? error.message
      : 'No fue posible completar la operación.';

  void _mensaje(String texto, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto), backgroundColor: color));
  }

  // ---------- Pantalla ----------

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.all(context.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveToolbar(
            search: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: 'Buscar en ${widget.anio}',
                hintText: _verSalidas
                    ? 'Folio, quién recibe, área, material o factura'
                    : 'Factura, orden de compra, proveedor, descripción o marca',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            primaryAction: ElevatedButton.icon(
              onPressed: _cargando
                  ? null
                  : () => _verSalidas ? _nuevaSalida() : _abrirFormulario(),
              icon: const Icon(Icons.add),
              label: Text(_verSalidas ? 'Nueva salida' : 'Nueva compra'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.receipt_long),
                    label: Text('Compras (${_compras.length})'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.outbox),
                    label: Text('Salidas (${_vales.length})'),
                  ),
                ],
                selected: {_verSalidas},
                onSelectionChanged: (valor) =>
                    setState(() => _verSalidas = valor.first),
              ),
              if (!_verSalidas && _totalDelAnio != null)
                Text(
                  'Total comprado en ${widget.anio}: '
                  '${formatoDinero.format(_totalDelAnio)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: _contenido()),
        ],
      ),
    );
  }

  double? get _totalDelAnio {
    final totales = _compras.map((c) => c.total).whereType<double>();
    return totales.isEmpty ? null : totales.reduce((a, b) => a + b);
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _Error(mensaje: _error!, alReintentar: _cargar);
    return _verSalidas ? _listaSalidas() : _listaCompras();
  }

  // ---------- Vista de compras ----------

  Widget _listaCompras() {
    if (_compras.isEmpty) {
      return _Vacio(
        texto: 'Aún no hay compras registradas en ${widget.anio}.',
        boton: 'Registrar compra',
        alPresionar: () => _abrirFormulario(),
      );
    }
    final compras =
        _compras.where((c) => c.coincideCon(_busquedaController.text)).toList();
    if (compras.isEmpty) {
      return const Center(child: Text('No hay compras que coincidan con la búsqueda.'));
    }

    if (context.isMobile) {
      return ListView(
        children: [for (final compra in compras) _tarjetaCompra(compra)],
      );
    }
    return _Tabla(
      anchoMinimo: 1100,
      columnas: const [
        'Fecha factura', 'Factura', 'Orden de compra', 'Proveedor',
        'Artículos', 'Total', 'Acciones',
      ],
      filas: [
        for (final compra in compras)
          DataRow(cells: [
            DataCell(Text(formatoFecha.format(compra.fechaFactura))),
            DataCell(Text(compra.numeroFactura)),
            DataCell(Text(compra.ordenCompra)),
            DataCell(SizedBox(
              width: 220,
              child: Text(compra.proveedor, overflow: TextOverflow.ellipsis),
            )),
            DataCell(_botonArticulos(compra)),
            DataCell(Text(_dinero(compra.total))),
            DataCell(_accionesCompra(compra)),
          ]),
      ],
    );
  }

  Widget _tarjetaCompra(CompraAlmacen compra) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Factura ${compra.numeroFactura}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Fecha: ${formatoFecha.format(compra.fechaFactura)}'),
            Text('Orden de compra: ${compra.ordenCompra}'),
            Text('Proveedor: ${compra.proveedor}'),
            Text('Total: ${_dinero(compra.total)}'),
            _botonArticulos(compra),
            _accionesCompra(compra),
          ],
        ),
      ),
    );
  }

  Widget _botonArticulos(CompraAlmacen compra) {
    final n = compra.articulos.length;
    return TextButton.icon(
      onPressed: () => _verArticulos(compra),
      icon: const Icon(Icons.inventory_2_outlined, size: 20),
      label: Text(n == 1 ? '1 artículo' : '$n artículos'),
    );
  }

  Widget _accionesCompra(CompraAlmacen compra) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Ver o editar',
          onPressed: _ocupado ? null : () => _abrirFormulario(compra),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Descargar PDF',
          onPressed: _ocupado
              ? null
              : () => _descargarPdf(() => _servicio.descargarPdf(compra)),
          icon: const Icon(Icons.picture_as_pdf, color: Colors.teal),
        ),
        IconButton(
          tooltip: 'Eliminar',
          onPressed: _ocupado ? null : () => _eliminarCompra(compra),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
        ),
      ],
    );
  }

  // ---------- Vista de salidas ----------

  Widget _listaSalidas() {
    if (_vales.isEmpty) {
      return _Vacio(
        texto: 'No hay vales de salida en ${widget.anio}.',
        boton: 'Registrar salida',
        alPresionar: () => _nuevaSalida(),
      );
    }
    final vales =
        _vales.where((v) => v.coincideCon(_busquedaController.text)).toList();
    if (vales.isEmpty) {
      return const Center(child: Text('No hay salidas que coincidan con la búsqueda.'));
    }

    if (context.isMobile) {
      return ListView(
        children: [for (final vale in vales) _tarjetaVale(vale)],
      );
    }
    return _Tabla(
      anchoMinimo: 1100,
      columnas: const [
        'Folio', 'Fecha', 'Recibe', 'Área', 'Material', 'Factura de origen',
        'Acciones',
      ],
      filas: [
        for (final vale in vales)
          DataRow(cells: [
            DataCell(Text(vale.folioTexto,
                style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(formatoFecha.format(vale.fecha))),
            DataCell(SizedBox(
              width: 160,
              child: Text(vale.recibe, overflow: TextOverflow.ellipsis),
            )),
            DataCell(SizedBox(
              width: 150,
              child: Text(vale.area, overflow: TextOverflow.ellipsis),
            )),
            DataCell(SizedBox(
              width: 240,
              child: Text(vale.resumen, overflow: TextOverflow.ellipsis),
            )),
            DataCell(SizedBox(
              width: 130,
              child: Text(vale.facturas.join(', '),
                  overflow: TextOverflow.ellipsis),
            )),
            DataCell(_accionesVale(vale)),
          ]),
      ],
    );
  }

  Widget _tarjetaVale(ValeSalida vale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vale ${vale.folioTexto}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Fecha: ${formatoFecha.format(vale.fecha)}'),
            Text('Recibe: ${vale.recibe}'),
            if (vale.area.isNotEmpty) Text('Área: ${vale.area}'),
            Text('Material: ${vale.resumen}'),
            Text('Factura de origen: ${vale.facturas.join(', ')}'),
            _accionesVale(vale),
          ],
        ),
      ),
    );
  }

  Widget _accionesVale(ValeSalida vale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Ver material',
          onPressed: _ocupado ? null : () => _verVale(vale),
          icon: const Icon(Icons.visibility_outlined),
        ),
        IconButton(
          tooltip: 'Descargar vale en PDF',
          onPressed: _ocupado
              ? null
              : () => _descargarPdf(() => _servicio.descargarPdfVale(vale)),
          icon: const Icon(Icons.picture_as_pdf, color: Colors.teal),
        ),
        IconButton(
          tooltip: 'Eliminar',
          onPressed: _ocupado ? null : () => _eliminarVale(vale),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
        ),
      ],
    );
  }

  String _dinero(double? valor) =>
      valor == null ? 'Sin precio' : formatoDinero.format(valor);
}

/// Ventana con los artículos de una compra, su existencia e importe.
/// Regresa el artículo al que se le quiere dar salida.
class _ArticulosDialog extends StatelessWidget {
  const _ArticulosDialog({required this.compra});

  final CompraAlmacen compra;

  @override
  Widget build(BuildContext context) {
    final pantalla = MediaQuery.sizeOf(context);
    return AlertDialog(
      title: Text('Artículos de la factura ${compra.numeroFactura}'),
      content: SizedBox(
        width: pantalla.width < 600 ? pantalla.width - 80 : 720,
        height: pantalla.height * .6,
        child: ListView.separated(
          itemCount: compra.articulos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final articulo = compra.articulos[i];
            return Card(
              margin: EdgeInsets.zero,
              color: Colors.amber.withValues(alpha: .08),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      articulo.descripcion,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Dato('Comprado', '${articulo.cantidad}'),
                        _Dato('Existencia', '${articulo.existencia}',
                            resaltar: articulo.existencia == 0),
                        if (articulo.marca.isNotEmpty)
                          _Dato('Marca', articulo.marca),
                        if (articulo.precioUnitario != null)
                          _Dato('P. unitario',
                              formatoDinero.format(articulo.precioUnitario)),
                        if (articulo.importe != null)
                          _Dato('Importe', formatoDinero.format(articulo.importe)),
                        ElevatedButton.icon(
                          onPressed: articulo.existencia > 0
                              ? () => Navigator.pop(context, articulo)
                              : null,
                          icon: const Icon(Icons.outbox),
                          label: const Text('Dar salida'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
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
      actions: [
        if (compra.total != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text('Total: ${formatoDinero.format(compra.total)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

/// Detalle de un vale de salida: datos y material con su factura de origen.
/// Regresa true si se pidió descargar el PDF.
class _ValeDialog extends StatelessWidget {
  const _ValeDialog({required this.vale});

  final ValeSalida vale;

  @override
  Widget build(BuildContext context) {
    final pantalla = MediaQuery.sizeOf(context);
    return AlertDialog(
      title: Text('Vale de salida ${vale.folioTexto}'),
      content: SizedBox(
        width: pantalla.width < 600 ? pantalla.width - 80 : 720,
        height: pantalla.height * .6,
        child: ListView(
          children: [
            Text('Fecha: ${formatoFecha.format(vale.fecha)}'),
            Text('Recibe: ${vale.recibe}'),
            if (vale.area.isNotEmpty) Text('Área o destino: ${vale.area}'),
            if (vale.observaciones.isNotEmpty)
              Text('Observaciones: ${vale.observaciones}'),
            const SizedBox(height: 12),
            for (final material in vale.materiales)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: Colors.amber.withValues(alpha: .08),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${material.cantidad} × ${material.descripcion}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (material.marca.isNotEmpty)
                            _Dato('Marca', material.marca),
                          _Dato('Factura', material.numeroFactura),
                          _Dato('Orden de compra', material.ordenCompra),
                          _Dato('Proveedor', material.proveedor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.picture_as_pdf, color: Colors.teal),
          label: const Text('Descargar PDF'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor, {this.resaltar = false});

  final String etiqueta;
  final String valor;
  final bool resaltar; // en rojo, por ejemplo cuando ya no hay existencia

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: resaltar ? Colors.red.shade50 : null,
      label: Text('$etiqueta: $valor'),
    );
  }
}

/// Tabla con desplazamiento horizontal y vertical para pantallas anchas.
class _Tabla extends StatelessWidget {
  const _Tabla({
    required this.columnas,
    required this.filas,
    required this.anchoMinimo,
  });

  final List<String> columnas;
  final List<DataRow> filas;
  final double anchoMinimo;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) => Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // Ocupa al menos el ancho disponible, pero puede crecer si el
            // contenido no cabe; entonces se desplaza hacia los lados.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth < anchoMinimo
                    ? anchoMinimo
                    : constraints.maxWidth,
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    for (final columna in columnas)
                      DataColumn(label: Text(columna)),
                  ],
                  rows: filas,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({
    required this.texto,
    required this.boton,
    required this.alPresionar,
  });

  final String texto;
  final String boton;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 58, color: Colors.grey),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: alPresionar,
            icon: const Icon(Icons.add),
            label: Text(boton),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.mensaje, required this.alReintentar});

  final String mensaje;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 58, color: Colors.red),
          const SizedBox(height: 12),
          Text(mensaje, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: alReintentar,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
