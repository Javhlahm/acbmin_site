import 'package:acbmin_site/features/almacen_general/data/almacen_general_service.dart';
import 'package:acbmin_site/features/almacen_general/domain/almacen_general.dart';
import 'package:acbmin_site/network/api_exception.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formulario para crear o editar una compra del Almacén General.
///
/// Si [compra] es null se crea una nueva; si no, se editan sus datos.
/// Al guardar regresa la compra guardada con Navigator.pop.
class CompraFormPage extends StatefulWidget {
  const CompraFormPage({super.key, required this.servicio, this.compra});

  final AlmacenGeneralService servicio;
  final CompraAlmacen? compra;

  @override
  State<CompraFormPage> createState() => _CompraFormPageState();
}

class _CompraFormPageState extends State<CompraFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _facturaController = TextEditingController();
  final _ordenController = TextEditingController();
  final _proveedorController = TextEditingController();
  final List<_ArticuloControllers> _articulos = [];

  DateTime _fechaFactura = DateTime.now(); // la fecha de hoy por defecto
  bool _guardando = false;

  bool get _editando => widget.compra != null;

  @override
  void initState() {
    super.initState();
    final compra = widget.compra;
    if (compra != null) {
      _fechaFactura = compra.fechaFactura;
      _facturaController.text = compra.numeroFactura;
      _ordenController.text = compra.ordenCompra;
      _proveedorController.text = compra.proveedor;
      for (final articulo in compra.articulos) {
        _articulos.add(_ArticuloControllers.desde(articulo));
      }
    }
    if (_articulos.isEmpty) _articulos.add(_ArticuloControllers());
    _fechaController.text = formatoFecha.format(_fechaFactura);
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _facturaController.dispose();
    _ordenController.dispose();
    _proveedorController.dispose();
    for (final articulo in _articulos) {
      articulo.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaFactura,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Fecha de factura',
    );
    if (elegida == null || !mounted) return;
    setState(() {
      _fechaFactura = elegida;
      _fechaController.text = formatoFecha.format(elegida);
    });
  }

  void _agregarArticulo() => setState(() => _articulos.add(_ArticuloControllers()));

  void _quitarArticulo(int indice) {
    final articulo = _articulos[indice];
    // Un artículo que ya tuvo salidas no se puede quitar de la compra.
    if (articulo.salidas > 0) {
      _mensaje('No se puede quitar: ya salieron ${articulo.salidas} piezas.',
          Colors.red);
      return;
    }
    if (_articulos.length == 1) {
      _mensaje('La compra debe tener al menos un artículo.', Colors.red);
      return;
    }
    setState(() => _articulos.removeAt(indice).dispose());
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final compra = CompraAlmacen(
      id: widget.compra?.id,
      fechaFactura: _fechaFactura,
      numeroFactura: _facturaController.text.trim(),
      ordenCompra: _ordenController.text.trim(),
      proveedor: _proveedorController.text.trim(),
      articulos: _articulos.map((a) => a.aModelo()).toList(),
    );

    setState(() => _guardando = true);
    try {
      final guardada = _editando
          ? await widget.servicio.actualizarCompra(compra.id!, compra)
          : await widget.servicio.crearCompra(compra);
      if (mounted) Navigator.pop(context, guardada);
    } catch (error) {
      if (!mounted) return;
      _mensaje(
          error is ApiException ? error.message : 'No se pudo guardar la compra.',
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

  // Total que se va calculando mientras se captura.
  double? get _total {
    final importes = _articulos.map((a) => a.importe).whereType<double>();
    return importes.isEmpty ? null : importes.reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editando
              ? 'Editar compra: factura ${widget.compra!.numeroFactura}'
              : 'Nueva compra',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: context.isMobile ? 19 : 24,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ResponsiveFormCard(
          maxWidth: 1100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _titulo('Datos de la compra'),
              _datosDeLaCompra(),
              const SizedBox(height: 24),
              _titulo('Artículos'),
              for (var i = 0; i < _articulos.length; i++) _tarjetaArticulo(i),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _guardando ? null : _agregarArticulo,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar artículo'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Total: ${_total == null ? 'sin precios' : formatoDinero.format(_total)}',
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
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
                        : const Icon(Icons.save),
                    label: Text(_guardando ? 'Guardando…' : 'Guardar compra'),
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

  Widget _datosDeLaCompra() {
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
              readOnly: true,
              onTap: _elegirFecha,
              decoration: const InputDecoration(
                labelText: 'Fecha de factura',
                prefixIcon: Icon(Icons.calendar_month),
                helperText: 'El año de la fecha decide en qué vista aparece',
              ),
            ),
          ),
          SizedBox(
            width: ancho,
            child: _campoObligatorio('Número de factura', _facturaController, 100),
          ),
          SizedBox(
            width: ancho,
            child: _campoObligatorio('Orden de compra', _ordenController, 100),
          ),
          SizedBox(
            width: ancho,
            child: _campoObligatorio('Proveedor', _proveedorController, 250),
          ),
        ],
      );
    });
  }

  Widget _tarjetaArticulo(int indice) {
    final articulo = _articulos[indice];
    final campos = <Widget>[
      _campoCantidad(articulo),
      _campoObligatorio('Descripción', articulo.descripcion, 500),
      TextFormField(
        controller: articulo.marca,
        maxLength: 150,
        decoration: const InputDecoration(
            labelText: 'Marca (opcional)', counterText: ''),
      ),
      _campoPrecio(articulo),
    ];

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
                    'Artículo ${indice + 1}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (articulo.importe != null)
                  Text('Importe: ${formatoDinero.format(articulo.importe)}'),
                IconButton(
                  tooltip: 'Quitar artículo',
                  onPressed: _guardando ? null : () => _quitarArticulo(indice),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            if (articulo.salidas > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Ya salieron ${articulo.salidas} piezas de este artículo.',
                  style: TextStyle(color: Colors.orange.shade900),
                ),
              ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, constraints) {
                // Pantalla ancha: todo en un renglón. Angosta: en cuadrícula.
                if (constraints.maxWidth >= 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 110, child: campos[0]),
                      const SizedBox(width: 10),
                      Expanded(flex: 3, child: campos[1]),
                      const SizedBox(width: 10),
                      Expanded(child: campos[2]),
                      const SizedBox(width: 10),
                      SizedBox(width: 230, child: campos[3]),
                    ],
                  );
                }
                final ancho = constraints.maxWidth >= 520
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final campo in campos) SizedBox(width: ancho, child: campo)
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoObligatorio(
      String etiqueta, TextEditingController controller, int maximo) {
    return TextFormField(
      controller: controller,
      maxLength: maximo,
      decoration: InputDecoration(labelText: etiqueta, counterText: ''),
      validator: (valor) =>
          (valor ?? '').trim().isEmpty ? 'Campo requerido' : null,
    );
  }

  Widget _campoCantidad(_ArticuloControllers articulo) {
    return TextFormField(
      controller: articulo.cantidad,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(labelText: 'Cantidad'),
      onChanged: (_) => setState(() {}), // recalcula importe y total
      validator: (valor) {
        final cantidad = int.tryParse(valor ?? '');
        if (cantidad == null || cantidad < 1) return 'Mayor a 0';
        if (cantidad < articulo.salidas) return 'Mínimo ${articulo.salidas}';
        return null;
      },
    );
  }

  Widget _campoPrecio(_ArticuloControllers articulo) {
    return TextFormField(
      controller: articulo.precio,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Precio unitario (opcional)',
        prefixText: r'$ ',
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}

/// Controladores de texto de un artículo del formulario.
class _ArticuloControllers {
  _ArticuloControllers({this.id, this.salidas = 0});

  factory _ArticuloControllers.desde(ArticuloAlmacen articulo) {
    final controles =
        _ArticuloControllers(id: articulo.id, salidas: articulo.salidas);
    controles.cantidad.text = articulo.cantidad.toString();
    controles.descripcion.text = articulo.descripcion;
    controles.marca.text = articulo.marca;
    if (articulo.precioUnitario != null) {
      controles.precio.text = articulo.precioUnitario!.toStringAsFixed(2);
    }
    return controles;
  }

  final int? id; // null en artículos nuevos
  final int salidas; // piezas que ya salieron (solo al editar)
  final cantidad = TextEditingController(text: '1');
  final descripcion = TextEditingController();
  final marca = TextEditingController();
  final precio = TextEditingController();

  double? get importe {
    final c = int.tryParse(cantidad.text);
    final p = double.tryParse(precio.text);
    return c == null || p == null ? null : c * p;
  }

  ArticuloAlmacen aModelo() => ArticuloAlmacen(
        id: id,
        cantidad: int.parse(cantidad.text),
        descripcion: descripcion.text.trim(),
        marca: marca.text.trim(),
        precioUnitario: double.tryParse(precio.text),
      );

  void dispose() {
    cantidad.dispose();
    descripcion.dispose();
    marca.dispose();
    precio.dispose();
  }
}
