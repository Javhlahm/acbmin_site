import 'package:intl/intl.dart';

class Resguardo {
  final int folio;
  String? fechaAutorizado; // Fecha en que se aprueba/rechaza
  String tipoResguardo; // 'Traspaso de resguardo' o 'Nueva adquisición'
  String numeroInventario;
  String descripcion;
  String areaEntrega; // N/A si es nueva adquisición
  String nombreEntrega; // N/A si es nueva adquisición
  String rfcEntrega; // N/A si es nueva adquisición
  String areaRecibe;
  String nombreRecibe;
  String rfcRecibe;
  String? observaciones;
  String? estatus; // Pendiente, Aprobado, Rechazado
  String?
      capturadoPor; // Nombre de usuario que lo creó o modificó por última vez

  Resguardo({
    required this.folio,
    this.fechaAutorizado,
    required this.tipoResguardo,
    required this.numeroInventario,
    required this.descripcion,
    required this.areaEntrega,
    required this.nombreEntrega,
    required this.rfcEntrega,
    required this.areaRecibe,
    required this.nombreRecibe,
    required this.rfcRecibe,
    this.observaciones,
    this.estatus = 'Pendiente', // Valor por defecto
    this.capturadoPor,
  });

  // Getter para el folio formateado
  String get folioFormateado {
    final formatter = NumberFormat("0000");
    return 'RICB-${formatter.format(folio)}';
  }

  // Método para buscar coincidencias (incluye folio formateado)
  bool matchesSearch(String query) {
    final queryLower = query.toLowerCase();
    final formatter = NumberFormat("0000");
    final folioStr = 'RICB-${formatter.format(folio)}'.toLowerCase();

    return folioStr.contains(queryLower) ||
        tipoResguardo.toLowerCase().contains(queryLower) ||
        numeroInventario.toLowerCase().contains(queryLower) ||
        descripcion.toLowerCase().contains(queryLower) ||
        areaEntrega.toLowerCase().contains(queryLower) ||
        nombreEntrega.toLowerCase().contains(queryLower) ||
        rfcEntrega.toLowerCase().contains(queryLower) ||
        areaRecibe.toLowerCase().contains(queryLower) ||
        nombreRecibe.toLowerCase().contains(queryLower) ||
        rfcRecibe.toLowerCase().contains(queryLower) ||
        (observaciones?.toLowerCase().contains(queryLower) ?? false) ||
        (estatus?.toLowerCase().contains(queryLower) ?? false) ||
        (capturadoPor?.toLowerCase().contains(queryLower) ?? false) ||
        (fechaAutorizado?.toLowerCase().contains(queryLower) ?? false);
  }

  // Método copyWith CORREGIDO
  Resguardo copyWith({
    int? folio,
    String? fechaAutorizado, // Acepta String? directamente
    String? tipoResguardo,
    String? numeroInventario,
    String? descripcion,
    String? areaEntrega,
    String? nombreEntrega,
    String? rfcEntrega,
    String? areaRecibe,
    String? nombreRecibe,
    String? rfcRecibe,
    String? observaciones, // Acepta String? directamente
    String? estatus, // Acepta String? directamente
    String? capturadoPor, // Acepta String? directamente
    // Flags para indicar si se quiere limpiar un campo nullable
    bool clearFechaAutorizado = false,
    bool clearObservaciones = false,
    bool clearEstatus = false,
    bool clearCapturadoPor = false,
  }) {
    return Resguardo(
      folio: folio ?? this.folio,
      // Lógica para actualizar o limpiar campos nullable
      fechaAutorizado: clearFechaAutorizado
          ? null
          : (fechaAutorizado ?? this.fechaAutorizado),
      tipoResguardo: tipoResguardo ?? this.tipoResguardo,
      numeroInventario: numeroInventario ?? this.numeroInventario,
      descripcion: descripcion ?? this.descripcion,
      areaEntrega: areaEntrega ?? this.areaEntrega,
      nombreEntrega: nombreEntrega ?? this.nombreEntrega,
      rfcEntrega: rfcEntrega ?? this.rfcEntrega,
      areaRecibe: areaRecibe ?? this.areaRecibe,
      nombreRecibe: nombreRecibe ?? this.nombreRecibe,
      rfcRecibe: rfcRecibe ?? this.rfcRecibe,
      observaciones:
          clearObservaciones ? null : (observaciones ?? this.observaciones),
      estatus: clearEstatus ? null : (estatus ?? this.estatus),
      capturadoPor:
          clearCapturadoPor ? null : (capturadoPor ?? this.capturadoPor),
    );
  }

  // --- Métodos fromJson y toJson ---

  // Convierte un objeto JSON (Map) a una instancia de Resguardo
  factory Resguardo.fromJson(Map<String, dynamic> json) {
    return Resguardo(
      // Asegúrate que los nombres coincidan con los de tu API Java
      folio: json['folio'] ?? 0, // Proporciona un valor por defecto si es nulo
      fechaAutorizado: json['fechaAutorizado'], // Puede ser nulo
      tipoResguardo: json['tipoResguardo'] ?? '',
      numeroInventario: json['numeroInventario'] ?? '',
      descripcion: json['descripcion'] ?? '',
      areaEntrega: json['areaEntrega'] ?? 'N/A', // O '' según prefieras
      nombreEntrega: json['nombreEntrega'] ?? 'N/A',
      rfcEntrega: json['rfcEntrega'] ?? 'N/A',
      areaRecibe: json['areaRecibe'] ?? '',
      nombreRecibe: json['nombreRecibe'] ?? '',
      rfcRecibe: json['rfcRecibe'] ?? '',
      observaciones: json['observaciones'], // Puede ser nulo
      estatus: json['estatus'] ?? 'Pendiente', // Valor por defecto si es nulo
      capturadoPor: json['capturadoPor'], // Puede ser nulo
    );
  }

  // Convierte una instancia de Resguardo a un objeto JSON (Map)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // No incluimos el folio al enviar si la API lo genera automáticamente al crear
    // Si necesitas enviarlo para actualizar, asegúrate que el endpoint lo maneje
    // data['folio'] = this.folio; // Descomentar si necesitas enviar el folio

    data['fechaAutorizado'] = this.fechaAutorizado;
    data['tipoResguardo'] = this.tipoResguardo;
    data['numeroInventario'] = this.numeroInventario;
    data['descripcion'] = this.descripcion;
    data['areaEntrega'] = this.areaEntrega;
    data['nombreEntrega'] = this.nombreEntrega;
    data['rfcEntrega'] = this.rfcEntrega;
    data['areaRecibe'] = this.areaRecibe;
    data['nombreRecibe'] = this.nombreRecibe;
    data['rfcRecibe'] = this.rfcRecibe;
    data['observaciones'] = this.observaciones;
    data['estatus'] = this.estatus;
    data['capturadoPor'] = this.capturadoPor;
    return data;
  }

  // Overrides para == y hashCode (importante para comparar objetos)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Resguardo &&
          runtimeType == other.runtimeType &&
          folio == other.folio; // Comparamos principalmente por folio

  @override
  int get hashCode => folio.hashCode; // Usar el folio para el hash
}
