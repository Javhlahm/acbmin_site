/// Identificadores de roles que se intercambian con el backend.
///
/// Centralizarlos evita que alta, edición y menú usen nombres diferentes para
/// el mismo permiso.
abstract final class AppRoles {
  static const String admin = 'admin';
  static const String tallerAutos = 'taller_autos';
  static const String resguardosInternos = 'resguardos_internos';
  static const String bajasBienes = 'bajas_bienes';
  static const String entregaEquipo = 'entrega_equipo';
}
