import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo.dart';
import 'package:acbmin_site/features/entregas_equipo/domain/entrega_equipo_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntregaEquipo JSON', () {
    test('deserializa todos los campos de la respuesta', () {
      final entrega = EntregaEquipo.fromJson(_responseJson());

      expect(entrega.folio, 27);
      expect(entrega.folioFormateado, '0027');
      expect(entrega.fechaEntrega, DateTime(2026, 8, 24));
      expect(entrega.estatus, 'Pendiente');
      expect(entrega.fechaCreacion, DateTime.parse('2026-08-24T12:30:00'));
      expect(entrega.equipos, hasLength(1));
      expect(entrega.equipos.single.id, 91);
      expect(entrega.equipos.single.serie, 'PF-4A92XZ');
    });

    test('POST y PUT omiten campos de solo lectura e IDs', () {
      final payload = EntregaEquipo.fromJson(_responseJson()).toPayload();

      // Esta lista protege el contrato exacto aceptado por el backend.
      expect(payload.keys, <String>{
        'fechaEntrega',
        'nombreUsuario',
        'cargo',
        'telefonoExtension',
        'direccionArea',
        'direccionGeneral',
        'subsecretaria',
        'elaboradoPor',
        'capturadoPor',
        'observaciones',
        'equipos',
      });
      expect(payload, isNot(contains('folio')));
      expect(payload, isNot(contains('estatus')));
      expect(payload, isNot(contains('fechaCreacion')));
      expect(payload, isNot(contains('tipoUnidad')));

      final equipoPayload = (payload['equipos'] as List).single as Map;
      expect(equipoPayload, isNot(contains('id')));
      expect(equipoPayload, isNot(contains('tipoUnidad')));
      expect(equipoPayload['cantidad'], 1);
    });

    test('la búsqueda incluye folio, nombre, serie, PESA y descripción', () {
      final entrega = EntregaEquipo.fromJson(_responseJson());

      expect(entrega.matchesSearch('0027'), isTrue);
      expect(entrega.matchesSearch('maría'), isTrue);
      expect(entrega.matchesSearch('pf-4a92xz'), isTrue);
      expect(entrega.matchesSearch('pesa-0001842'), isTrue);
      expect(entrega.matchesSearch('portátil'), isTrue);
      expect(entrega.matchesSearch('sin coincidencia'), isFalse);
    });
  });

  group('EntregaEquipoValidator', () {
    test('acepta una entrega completa con cantidad positiva', () {
      final entrega = EntregaEquipo.fromJson(_responseJson());
      expect(EntregaEquipoValidator.validate(entrega), isEmpty);
    });

    test('rechaza nombre vacío, cantidad cero y campos visibles incompletos',
        () {
      final invalid = EntregaEquipo(
        fechaEntrega: DateTime(2026, 8, 24),
        nombreUsuario: '',
        cargo: '',
        telefonoExtension: '',
        direccionArea: '',
        direccionGeneral: '',
        subsecretaria: '',
        elaboradoPor: '',
        capturadoPor: '',
        observaciones: '',
        equipos: const [
          EquipoEntregado(
            cantidad: 0,
            descripcion: '',
            marca: '',
            modelo: '',
            serie: '',
            pesa: '',
          ),
        ],
      );

      final errors = EntregaEquipoValidator.validate(invalid);
      expect(errors, contains('Nombre del usuario es obligatorio.'));
      expect(
          errors, contains('Equipo 1: la cantidad debe ser mayor que cero.'));
      expect(errors, contains('Equipo 1 - descripción es obligatorio.'));
      expect(errors, contains('Equipo 1 - serie es obligatorio.'));
      expect(errors, contains('Equipo 1 - PESA es obligatorio.'));
    });

    test('exige al menos un equipo', () {
      final json = _responseJson()..['equipos'] = <Object>[];
      final errors = EntregaEquipoValidator.validate(
        EntregaEquipo.fromJson(json),
      );
      expect(errors, contains('Debe existir al menos un equipo entregado.'));
    });
  });
}

/// Respuesta representativa con campos de solo lectura asignados por Java.
Map<String, dynamic> _responseJson() => <String, dynamic>{
      'folio': 27,
      'fechaEntrega': '2026-08-24',
      'nombreUsuario': 'María Fernanda Torres Gómez',
      'cargo': 'Jefa de Departamento',
      'telefonoExtension': '33 3030 7500 ext. 4512',
      'direccionArea': 'Área de Control de Bienes Muebles e Inmuebles',
      'direccionGeneral': 'Dirección General de Recursos Materiales',
      'subsecretaria': 'Subsecretaría de Administración',
      'elaboradoPor': 'Carlos Eduardo Ramírez Soto',
      'capturadoPor': 'usuario@dominio.mx',
      'observaciones': 'Equipo entregado con todos sus accesorios.',
      'estatus': 'Pendiente',
      'fechaCreacion': '2026-08-24T12:30:00',
      'equipos': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 91,
          'cantidad': 1,
          'descripcion': 'Computadora portátil',
          'marca': 'Lenovo',
          'modelo': 'ThinkPad E14',
          'serie': 'PF-4A92XZ',
          'pesa': 'PESA-0001842',
        },
      ],
    };
