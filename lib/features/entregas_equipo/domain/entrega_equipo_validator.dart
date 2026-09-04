import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo.dart';

/// Reglas de validación compartidas por el formulario y las pruebas.
abstract final class EntregaEquipoValidator {
  static String? requiredText(
    String? value, {
    required String label,
    required int maxLength,
  }) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return '$label es obligatorio.';
    if (normalized.length > maxLength) {
      return '$label admite máximo $maxLength caracteres.';
    }
    return null;
  }

  static String? positiveQuantity(String? value) {
    final quantity = int.tryParse(value?.trim() ?? '');
    if (quantity == null || quantity < 1) {
      return 'La cantidad debe ser un entero mayor que cero.';
    }
    return null;
  }

  /// Valida también los datos que no son editables, como `capturadoPor`, antes
  /// de enviar el documento al backend.
  static List<String> validate(EntregaEquipo entrega) {
    final errors = <String>[];

    void validateText(String value, String label, int maxLength) {
      final error = requiredText(
        value,
        label: label,
        maxLength: maxLength,
      );
      if (error != null) errors.add(error);
    }

    validateText(entrega.nombreUsuario, 'Nombre del usuario', 200);
    validateText(entrega.cargo, 'Cargo', 150);
    validateText(entrega.telefonoExtension, 'Teléfono / extensión', 100);
    validateText(entrega.direccionArea, 'Dirección de área', 250);
    validateText(entrega.direccionGeneral, 'Dirección general', 250);
    validateText(entrega.subsecretaria, 'Subsecretaría', 250);
    validateText(entrega.elaboradoPor, 'Elaborado por', 200);
    validateText(entrega.capturadoPor, 'Capturado por', 200);
    validateText(entrega.observaciones, 'Observaciones', 1500);

    if (entrega.equipos.isEmpty) {
      errors.add('Debe existir al menos un equipo entregado.');
      return errors;
    }

    for (var index = 0; index < entrega.equipos.length; index++) {
      final equipo = entrega.equipos[index];
      final prefix = 'Equipo ${index + 1}';
      if (equipo.cantidad < 1) {
        errors.add('$prefix: la cantidad debe ser mayor que cero.');
      }
      validateText(equipo.descripcion, '$prefix - descripción', 500);
      validateText(equipo.marca, '$prefix - marca', 150);
      validateText(equipo.modelo, '$prefix - modelo', 150);
      validateText(equipo.serie, '$prefix - serie', 150);
      validateText(equipo.pesa, '$prefix - PESA', 100);
    }
    return errors;
  }
}
