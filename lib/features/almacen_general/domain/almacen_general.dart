import 'package:intl/intl.dart';

/// Formato de dinero para precios, importes y totales: $1,234.50
final formatoDinero = NumberFormat.currency(locale: 'es_MX', symbol: r'$');

/// Formato de fecha que se muestra en pantalla: 06/11/2026
final formatoFecha = DateFormat('dd/MM/yyyy');

/// Artículo que llegó en una compra del Almacén General.
///
/// [cantidad] es lo comprado y [existencia] lo que queda después de las salidas.
class ArticuloAlmacen {
  const ArticuloAlmacen({
    this.id,
    required this.descripcion,
    this.marca = '',
    required this.cantidad,
    this.precioUnitario,
    int? existencia,
  }) : existencia = existencia ?? cantidad;

  final int? id;
  final String descripcion;
  final String marca; // opcional
  final int cantidad;
  final double? precioUnitario; // opcional
  final int existencia;

  /// Cantidad por precio unitario; null si no tiene precio.
  double? get importe =>
      precioUnitario == null ? null : precioUnitario! * cantidad;

  /// Piezas que ya salieron del almacén.
  int get salidas => cantidad - existencia;

  factory ArticuloAlmacen.fromJson(Map<String, dynamic> json) {
    return ArticuloAlmacen(
      id: _entero(json['id']),
      descripcion: json['descripcion']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      cantidad: _entero(json['cantidad']) ?? 0,
      precioUnitario: _decimal(json['precioUnitario']),
      existencia: _entero(json['existencia']),
    );
  }

  /// Datos que se mandan a la API. El id se manda para que, al editar,
  /// el artículo conserve sus salidas; la existencia la calcula la API.
  Map<String, dynamic> toPayload() => <String, dynamic>{
        if (id != null) 'id': id,
        'descripcion': descripcion,
        'marca': marca,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
      };
}

/// Compra del Almacén General: una factura con su orden de compra y proveedor,
/// y todos los artículos que llegaron con ella.
class CompraAlmacen {
  const CompraAlmacen({
    this.id,
    required this.fechaFactura,
    this.anio,
    required this.numeroFactura,
    required this.ordenCompra,
    required this.proveedor,
    required this.articulos,
  });

  final int? id;
  final DateTime fechaFactura;
  final int? anio; // lo asigna la API a partir de la fecha de factura
  final String numeroFactura;
  final String ordenCompra;
  final String proveedor;
  final List<ArticuloAlmacen> articulos;

  /// Suma de importes; null si ningún artículo tiene precio.
  double? get total {
    final importes = articulos.map((a) => a.importe).whereType<double>();
    return importes.isEmpty ? null : importes.reduce((a, b) => a + b);
  }

  bool get tieneSalidas => articulos.any((a) => a.salidas > 0);

  factory CompraAlmacen.fromJson(Map<String, dynamic> json) {
    final articulos = json['articulos'];
    return CompraAlmacen(
      id: _entero(json['id']),
      fechaFactura:
          DateTime.tryParse(json['fechaFactura']?.toString() ?? '') ??
              DateTime.now(),
      anio: _entero(json['anio']),
      numeroFactura: json['numeroFactura']?.toString() ?? '',
      ordenCompra: json['ordenCompra']?.toString() ?? '',
      proveedor: json['proveedor']?.toString() ?? '',
      articulos: articulos is List
          ? articulos
              .map((a) =>
                  ArticuloAlmacen.fromJson(Map<String, dynamic>.from(a as Map)))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toPayload() => <String, dynamic>{
        'fechaFactura': _fechaIso(fechaFactura),
        'numeroFactura': numeroFactura,
        'ordenCompra': ordenCompra,
        'proveedor': proveedor,
        'articulos': articulos.map((a) => a.toPayload()).toList(),
      };

  /// Búsqueda por factura, orden de compra, proveedor, descripción o marca.
  bool coincideCon(String busqueda) {
    final texto = busqueda.trim().toLowerCase();
    if (texto.isEmpty) return true;
    return numeroFactura.toLowerCase().contains(texto) ||
        ordenCompra.toLowerCase().contains(texto) ||
        proveedor.toLowerCase().contains(texto) ||
        articulos.any((a) =>
            a.descripcion.toLowerCase().contains(texto) ||
            a.marca.toLowerCase().contains(texto));
  }
}

/// Material que sale en un vale: el artículo, cuántas piezas y los datos de
/// su factura de origen (los llena la API al consultar).
class MaterialSalida {
  const MaterialSalida({
    required this.articuloId,
    this.compraId,
    required this.cantidad,
    this.descripcion = '',
    this.marca = '',
    this.numeroFactura = '',
    this.ordenCompra = '',
    this.proveedor = '',
  });

  final int articuloId;
  final int? compraId;
  final int cantidad;
  final String descripcion;
  final String marca;
  final String numeroFactura;
  final String ordenCompra;
  final String proveedor;

  factory MaterialSalida.fromJson(Map<String, dynamic> json) {
    return MaterialSalida(
      articuloId: _entero(json['articuloId']) ?? 0,
      compraId: _entero(json['compraId']),
      cantidad: _entero(json['cantidad']) ?? 0,
      descripcion: json['descripcion']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      numeroFactura: json['numeroFactura']?.toString() ?? '',
      ordenCompra: json['ordenCompra']?.toString() ?? '',
      proveedor: json['proveedor']?.toString() ?? '',
    );
  }

  // La API solo necesita el artículo y la cantidad; lo demás lo toma de la compra.
  Map<String, dynamic> toPayload() => <String, dynamic>{
        'articuloId': articuloId,
        'cantidad': cantidad,
      };
}

/// Vale de salida del almacén, con folio consecutivo por año (0001/2026).
class ValeSalida {
  const ValeSalida({
    this.id,
    this.anio,
    this.folio,
    required this.fecha,
    required this.recibe,
    this.area = '',
    this.observaciones = '',
    required this.materiales,
  });

  final int? id;
  final int? anio; // lo asigna la API con el año de la fecha
  final int? folio; // lo asigna la API
  final DateTime fecha;
  final String recibe; // persona que recibe el material
  final String area; // opcional
  final String observaciones; // opcional
  final List<MaterialSalida> materiales;

  String get folioTexto =>
      folio == null ? 'Nuevo' : '${folio.toString().padLeft(4, '0')}/$anio';

  /// Facturas de donde sale el material, sin repetir.
  List<String> get facturas => materiales
      .map((m) => m.numeroFactura)
      .where((f) => f.isNotEmpty)
      .toSet()
      .toList();

  /// Resumen del material: "3 × Hojas blancas, 5 × Foco LED".
  String get resumen =>
      materiales.map((m) => '${m.cantidad} × ${m.descripcion}').join(', ');

  factory ValeSalida.fromJson(Map<String, dynamic> json) {
    final articulos = json['articulos'];
    return ValeSalida(
      id: _entero(json['id']),
      anio: _entero(json['anio']),
      folio: _entero(json['folio']),
      fecha: DateTime.tryParse(json['fecha']?.toString() ?? '') ??
          DateTime.now(),
      recibe: json['recibe']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      observaciones: json['observaciones']?.toString() ?? '',
      materiales: articulos is List
          ? articulos
              .map((a) =>
                  MaterialSalida.fromJson(Map<String, dynamic>.from(a as Map)))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toPayload() => <String, dynamic>{
        'fecha': _fechaIso(fecha),
        'recibe': recibe,
        'area': area,
        'observaciones': observaciones,
        'articulos': materiales.map((m) => m.toPayload()).toList(),
      };

  /// Búsqueda por folio, quién recibe, área, material o factura de origen.
  bool coincideCon(String busqueda) {
    final texto = busqueda.trim().toLowerCase();
    if (texto.isEmpty) return true;
    return [
      folioTexto,
      recibe,
      area,
      observaciones,
      for (final m in materiales) ...[
        m.descripcion,
        m.marca,
        m.numeroFactura,
        m.ordenCompra,
        m.proveedor,
      ],
    ].any((valor) => valor.toLowerCase().contains(texto));
  }
}

/// Artículo con existencia, de cualquier compra, con su factura de origen.
/// Es la lista de donde se elige el material de un vale.
class ArticuloDisponible {
  const ArticuloDisponible({
    required this.articuloId,
    required this.descripcion,
    this.marca = '',
    required this.existencia,
    required this.numeroFactura,
    this.ordenCompra = '',
    this.proveedor = '',
    this.anio,
  });

  /// El artículo de una compra que ya está en pantalla.
  factory ArticuloDisponible.desde(
      CompraAlmacen compra, ArticuloAlmacen articulo) {
    return ArticuloDisponible(
      articuloId: articulo.id!,
      descripcion: articulo.descripcion,
      marca: articulo.marca,
      existencia: articulo.existencia,
      numeroFactura: compra.numeroFactura,
      ordenCompra: compra.ordenCompra,
      proveedor: compra.proveedor,
      anio: compra.anio,
    );
  }

  final int articuloId;
  final String descripcion;
  final String marca;
  final int existencia;
  final String numeroFactura;
  final String ordenCompra;
  final String proveedor;
  final int? anio; // año de la compra

  factory ArticuloDisponible.fromJson(Map<String, dynamic> json) {
    return ArticuloDisponible(
      articuloId: _entero(json['articuloId']) ?? 0,
      descripcion: json['descripcion']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      existencia: _entero(json['existencia']) ?? 0,
      numeroFactura: json['numeroFactura']?.toString() ?? '',
      ordenCompra: json['ordenCompra']?.toString() ?? '',
      proveedor: json['proveedor']?.toString() ?? '',
      anio: _entero(json['anio']),
    );
  }

  bool coincideCon(String busqueda) {
    final texto = busqueda.trim().toLowerCase();
    if (texto.isEmpty) return true;
    return [descripcion, marca, numeroFactura, ordenCompra, proveedor]
        .any((valor) => valor.toLowerCase().contains(texto));
  }
}

// Fecha como la espera la API: 2026-11-06
String _fechaIso(DateTime fecha) => DateFormat('yyyy-MM-dd').format(fecha);

int? _entero(Object? valor) {
  if (valor is int) return valor;
  if (valor is num) return valor.toInt();
  return int.tryParse(valor?.toString() ?? '');
}

double? _decimal(Object? valor) {
  if (valor is num) return valor.toDouble();
  return double.tryParse(valor?.toString() ?? '');
}
