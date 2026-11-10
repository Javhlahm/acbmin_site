import 'package:acbmin_site/features/almacen_general/data/almacen_general_service.dart';
import 'package:acbmin_site/features/almacen_general/domain/almacen_general.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formulario para registrar un vale de salida con uno o varios materiales.
///
/// El material se elige de los artículos con existencia de cualquier compra;
/// cada uno queda ligado a su factura de origen. Si [articuloInicial] no es
/// null, el vale empieza con ese material. Al guardar regresa el vale con su
/// folio con Navigator.pop.
class SalidaFormPage extends StatefulWidget {
  const SalidaFormPage({
    super.key,
    required this.servicio,
    this.articuloInicial,
  });

  final AlmacenGeneralService servicio;
  final ArticuloDisponible? articuloInicial;

  @override
  State<SalidaFormPage> createState() => _SalidaFormPageState();
}

class _SalidaFormPageState extends State<SalidaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _recibeController = TextEditingController();
  final _areaController = TextEditingController();
  final _observacionesController = TextEditingController();
  final List<_Material> _materiales = [];

  List<ArticuloDisponible> _disponibles = [];
  // La salida siempre lleva la fecha de hoy; no se puede cambiar (la API también la pone).
  final DateTime _fecha = DateTime.now();
  bool _cargando = true;
  String? _error;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _fechaController.text = formatoFecha.format(_fecha);
    _cargarDisponibles();
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _recibeController.dispose();
    _areaController.dispose();
    _observacionesController.dispose();
    for (final material in _materiales) {
      material.dispose();
    }
    super.dispose();
  }

  Future<void> _cargarDisponibles() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final disponibles = await widget.servicio.obtenerArticulosDisponibles();
      if (!mounted) return;
      setState(() {
        _disponibles = disponibles;
        _cargando = false;
        // El artículo con el que se abrió el formulario, con su existencia al día.
        final inicial = widget.articuloInicial;
        if (inicial != null && _materiales.isEmpty) {
          final actual = disponibles
              .where((a) => a.articuloId == inicial.articuloId)
              .firstOrNull;
          if (actual != null) _materiales.add(_Material(actual));
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = error is ApiException
            ? error.message
            : 'No fue posible consultar los artículos disponibles.';
      });
    }
  }

  Future<void> _agregarMaterial() async {
    // No se ofrece lo que ya está en el vale.
    final elegidos = _materiales.map((m) => m.articulo.articuloId).toSet();
    final opciones = _disponibles
        .where((a) => !elegidos.contains(a.articuloId))
        .toList();
    if (opciones.isEmpty) {
      _mensaje('No hay más artículos con existencia.', Colors.orange);
      return;
    }
    final articulo = await showDialog<ArticuloDisponible>(
      context: context,
      builder: (_) => _ElegirArticuloDialog(opciones: opciones),
    );
    if (articulo == null || !mounted) return;
    setState(() => _materiales.add(_Material(articulo)));
  }

  void _quitarMaterial(int indice) {
    setState(() => _materiales.removeAt(indice).dispose());
  }

  Future<void> _guardar() async {
    if (_materiales.isEmpty) {
      _mensaje('Agrega al menos un material al vale.', Colors.red);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final vale = ValeSalida(
      fecha: _fecha,
      recibe: _recibeController.text.trim(),
      area: _areaController.text.trim(),
      observaciones: _observacionesController.text.trim(),
      materiales: [
        for (final material in _materiales)
          MaterialSalida(
            articuloId: material.articulo.articuloId,
            cantidad: int.parse(material.cantidad.text),
          ),
      ],
    );

    setState(() => _guardando = true);
    try {
      final guardado = await widget.servicio.registrarVale(vale);
      if (mounted) Navigator.pop(context, guardado);
    } catch (error) {
      if (!mounted) return;
      _mensaje(
          error is ApiException
              ? error.message
              : 'No se pudo registrar el vale de salida.',
          Colors.red);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mensaje(String texto, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nueva salida',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: context.isMobile ? 19 : 24,
          ),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _cargarDisponibles,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _formulario(),
    );
  }

  Widget _formulario() {
    return Form(
      key: _formKey,
      child: ResponsiveFormCard(
        maxWidth: 1100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _titulo('Datos del vale'),
            _datosDelVale(),
            const SizedBox(height: 24),
            _titulo('Material'),
            if (_materiales.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Agrega el material que sale del almacén.'),
              ),
            for (var i = 0; i < _materiales.length; i++) _tarjetaMaterial(i),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _guardando ? null : _agregarMaterial,
                icon: const Icon(Icons.add),
                label: const Text('Agregar material'),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 12,
              children: [
                TextButton(
                  onPressed: _guardando ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.outbox),
                  label: Text(_guardando ? 'Guardando…' : 'Registrar salida'),
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
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          texto,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      );

  Widget _datosDelVale() {
    return LayoutBuilder(builder: (context, constraints) {
      // Dos columnas en pantalla ancha, una en celular.
      final ancho = constraints.maxWidth >= 620
          ? (constraints.maxWidth - 12) / 2
          : constraints.maxWidth;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: ancho,
            child: TextFormField(
              controller: _fechaController,
              enabled: false, // solo se muestra, no se puede elegir
              decoration: const InputDecoration(
                labelText: 'Fecha de salida',
                prefixIcon: Icon(Icons.calendar_month),
                helperText: 'Se registra con la fecha de hoy',
              ),
            ),
          ),
          SizedBox(
            width: ancho,
            child: TextFormField(
              controller: _recibeController,
              maxLength: 200,
              decoration:
                  const InputDecoration(labelText: 'Recibe', counterText: ''),
              validator: (valor) =>
                  (valor ?? '').trim().isEmpty ? 'Campo requerido' : null,
            ),
          ),
          SizedBox(
            width: ancho,
            child: TextFormField(
              controller: _areaController,
              maxLength: 250,
              decoration: const InputDecoration(
                  labelText: 'Área o destino (opcional)', counterText: ''),
            ),
          ),
          SizedBox(
            width: ancho,
            child: TextFormField(
              controller: _observacionesController,
              maxLength: 1000,
              decoration: const InputDecoration(
                  labelText: 'Observaciones (opcional)', counterText: ''),
            ),
          ),
        ],
      );
    });
  }

  Widget _tarjetaMaterial(int indice) {
    final material = _materiales[indice];
    final articulo = material.articulo;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.amber.withValues(alpha: .08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: TextFormField(
                controller: material.cantidad,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Cantidad'),
                validator: (valor) {
                  final cantidad = int.tryParse(valor ?? '');
                  if (cantidad == null || cantidad < 1) return 'Mayor a 0';
                  if (cantidad > articulo.existencia) {
                    return 'Hay ${articulo.existencia}';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: _DatosArticulo(articulo)),
            IconButton(
              tooltip: 'Quitar material',
              onPressed: _guardando ? null : () => _quitarMaterial(indice),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

/// Descripción del artículo, su existencia y su factura de origen.
class _DatosArticulo extends StatelessWidget {
  const _DatosArticulo(this.articulo);

  final ArticuloDisponible articulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          articulo.marca.isEmpty
              ? articulo.descripcion
              : '${articulo.descripcion} (${articulo.marca})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('En existencia: ${articulo.existencia}'),
        Text(
          'Factura ${articulo.numeroFactura} · OC ${articulo.ordenCompra} · '
          '${articulo.proveedor}${articulo.anio == null ? '' : ' (${articulo.anio})'}',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

/// Ventana para buscar y elegir un artículo con existencia.
class _ElegirArticuloDialog extends StatefulWidget {
  const _ElegirArticuloDialog({required this.opciones});

  final List<ArticuloDisponible> opciones;

  @override
  State<_ElegirArticuloDialog> createState() => _ElegirArticuloDialogState();
}

class _ElegirArticuloDialogState extends State<_ElegirArticuloDialog> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final pantalla = MediaQuery.sizeOf(context);
    final opciones =
        widget.opciones.where((a) => a.coincideCon(_busqueda)).toList();
    return AlertDialog(
      title: const Text('Elegir material'),
      content: SizedBox(
        width: pantalla.width < 600 ? pantalla.width - 80 : 720,
        height: pantalla.height * .6,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: (texto) => setState(() => _busqueda = texto),
              decoration: const InputDecoration(
                labelText: 'Buscar',
                hintText: 'Descripción, marca, factura, orden de compra o proveedor',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: opciones.isEmpty
                  ? const Center(child: Text('Ningún artículo coincide.'))
                  : ListView.separated(
                      itemCount: opciones.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) => ListTile(
                        title: _DatosArticulo(opciones[i]),
                        onTap: () => Navigator.pop(context, opciones[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

/// Material del vale: el artículo elegido y el campo de cantidad.
class _Material {
  _Material(this.articulo);

  final ArticuloDisponible articulo;
  final cantidad = TextEditingController(text: '1');

  void dispose() => cantidad.dispose();
}
