import 'package:acbmin_site/services/historial/historial_ingresos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lee un ingreso como lo manda la API', () {
    final ingreso = IngresoUsuario.fromJson({
      'id': 3,
      'email': 'persona@ejemplo.mx',
      'nombre': 'Persona Ejemplo',
      'exitoso': true,
      'ip': '201.0.0.7',
      'navegador':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36',
      'fechaEntrada': '2026-11-11T09:15:00',
      'fechaSalida': null,
      'ultimoUso': '2026-11-11T13:42:10',
    });

    expect(ingreso.exitoso, isTrue);
    expect(ingreso.fechaEntrada, DateTime(2026, 11, 11, 9, 15));
    expect(ingreso.fechaSalida, isNull);
    expect(ingreso.ultimoUso, DateTime(2026, 11, 11, 13, 42, 10));
    expect(ingreso.navegadorCorto, 'Chrome en Windows');
  });

  test('busca por nombre, correo e IP', () {
    final ingreso = IngresoUsuario.fromJson({
      'email': 'persona@ejemplo.mx',
      'nombre': 'Persona Ejemplo',
      'exitoso': false,
      'ip': '201.0.0.7',
      'fechaEntrada': '2026-11-11T09:15:00',
    });

    expect(ingreso.coincide('persona ej'), isTrue);
    expect(ingreso.coincide('EJEMPLO.MX'), isTrue);
    expect(ingreso.coincide('201.0'), isTrue);
    expect(ingreso.coincide('otra'), isFalse);
  });

  test('reconoce los navegadores comunes', () {
    String corto(String ua) => IngresoUsuario.fromJson({
          'email': 'x',
          'exitoso': true,
          'navegador': ua,
          'fechaEntrada': '2026-11-11T09:15:00',
        }).navegadorCorto;

    expect(corto('Mozilla/5.0 (Linux; Android 14) Chrome/130.0 Mobile Safari/537.36'),
        'Chrome en Android');
    expect(corto('Mozilla/5.0 (iPhone; CPU iPhone OS 17_0) Version/17.0 Mobile Safari/604.1'),
        'Safari en iPhone/iPad');
    expect(corto('Mozilla/5.0 (Windows NT 10.0) Chrome/130.0 Safari/537.36 Edg/130.0'),
        'Edge en Windows');
    expect(corto(''), '-');
  });
}
