import 'package:intl/intl.dart';

class BajaBien {
  final int folio;
  String? fechaAutorizado; // Fecha en que se aprueba/rechaza
  String areaBaja;
  String personaBaja;
  String rfcBaja;
  String descripcion;
  String numeroInventario;
  String? fechaEntregaActivos; // Fecha entrega a Activos Fijos
  String? estatus; // Pendiente, Aprobado, Rechazado
  String? capturadoPor; // Nombre de usuario que lo creó o modificó
  String? observaciones; // Observaciones adicionales

  BajaBien({
    required this.folio,
    this.fechaAutorizado,
    required this.areaBaja,
    required this.personaBaja,
    required this.rfcBaja,
    required this.descripcion,
    required this.numeroInventario,
    this.fechaEntregaActivos,
    this.estatus = 'Pendiente', // Valor por defecto
    this.capturadoPor,
    this.observaciones,
  });

  // Getter para el folio formateado (ej. BICB-0101)
  String get folioFormateado {
    final formatter = NumberFormat("0000");
    // Puedes ajustar el prefijo si lo necesitas
    return 'BICB-${formatter.format(folio)}';
  }

  // Método para buscar coincidencias (incluye folio formateado)
  bool matchesSearch(String query) {
    final queryLower = query.toLowerCase();
    final formatter = NumberFormat("0000");
    // Usar el prefijo definido en folioFormateado
    final folioStr = 'BICB-${formatter.format(folio)}'.toLowerCase();

    return folioStr.contains(queryLower) ||
        areaBaja.toLowerCase().contains(queryLower) ||
        personaBaja.toLowerCase().contains(queryLower) ||
        rfcBaja.toLowerCase().contains(queryLower) ||
        descripcion.toLowerCase().contains(queryLower) ||
        numeroInventario.toLowerCase().contains(queryLower) ||
        (fechaEntregaActivos?.toLowerCase().contains(queryLower) ?? false) ||
        (estatus?.toLowerCase().contains(queryLower) ?? false) ||
        (capturadoPor?.toLowerCase().contains(queryLower) ?? false) ||
        (fechaAutorizado?.toLowerCase().contains(queryLower) ?? false) ||
        (observaciones?.toLowerCase().contains(queryLower) ?? false);
  }

  // Método copyWith adaptado para BajaBien
  BajaBien copyWith({
    int? folio,
    String? fechaAutorizado,
    String? areaBaja,
    String? claveCentroTrabajo,
    String? personaBaja,
    String? rfcBaja,
    String? descripcion,
    String? numeroInventario,
    String? fechaEntregaActivos,
    String? estatus,
    String? capturadoPor,
    String? observaciones,
    // Flags para limpiar campos nullable
    bool clearFechaAutorizado = false,
    bool clearFechaEntregaActivos = false,
    bool clearEstatus = false,
    bool clearCapturadoPor = false,
    bool clearObservaciones = false,
  }) {
    return BajaBien(
      folio: folio ?? this.folio,
      fechaAutorizado: clearFechaAutorizado
          ? null
          : (fechaAutorizado ?? this.fechaAutorizado),
      areaBaja: areaBaja ?? this.areaBaja,
      personaBaja: personaBaja ?? this.personaBaja,
      rfcBaja: rfcBaja ?? this.rfcBaja,
      descripcion: descripcion ?? this.descripcion,
      numeroInventario: numeroInventario ?? this.numeroInventario,
      fechaEntregaActivos: clearFechaEntregaActivos
          ? null
          : (fechaEntregaActivos ?? this.fechaEntregaActivos),
      estatus: clearEstatus ? null : (estatus ?? this.estatus),
      capturadoPor:
          clearCapturadoPor ? null : (capturadoPor ?? this.capturadoPor),
      observaciones: observaciones ?? this.observaciones,
    );
  }

  // Overrides para == y hashCode (importante para comparar objetos)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BajaBien &&
          runtimeType == other.runtimeType &&
          folio == other.folio; // Comparamos principalmente por folio

  @override
  int get hashCode => folio.hashCode; // Usar el folio para el hash

  // Métodos toJson y fromJson (si planeas interactuar con un API)
  // Adaptar nombres de campos según tu API si es necesario

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['folio'] = folio; // O como se llame en tu API
    data['fechaAutorizado'] = fechaAutorizado;
    data['areaBaja'] = areaBaja;
    data['personaBaja'] = personaBaja;
    data['rfcBaja'] = rfcBaja;
    data['descripcion'] = descripcion;
    data['numeroInventario'] = numeroInventario;
    data['fechaEntregaActivos'] = fechaEntregaActivos;
    data['estatus'] = estatus;
    data['capturadoPor'] = capturadoPor;
    data['observaciones'] = observaciones;
    return data;
  }

  factory BajaBien.fromJson(Map<String, dynamic> json) {
    return BajaBien(
      folio: json['folio'] ?? 0, // Asegura un valor por defecto
      fechaAutorizado: json['fechaAutorizado'],
      areaBaja: json['areaBaja'] ?? '',
      personaBaja: json['personaBaja'] ?? '',
      rfcBaja: json['rfcBaja'] ?? '',
      descripcion: json['descripcion'] ?? '',
      numeroInventario: json['numeroInventario'] ?? '',
      fechaEntregaActivos: json['fechaEntregaActivos'],
      estatus: json['estatus'] ?? 'Pendiente',
      capturadoPor: json['capturadoPor'],
      observaciones: json['observaciones'],
    );
  }
}
