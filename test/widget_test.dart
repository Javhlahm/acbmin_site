import 'package:acbmin_site/PaginaMENU.dart';
import 'package:acbmin_site/PaginaNuevoUsuario.dart';
import 'package:acbmin_site/PaginaPrincipal.dart';
import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/security/app_roles.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    usuarioGlobal = Usuario(
      nombre: 'Usuario de prueba',
      roles: const [
        AppRoles.admin,
        AppRoles.tallerAutos,
        AppRoles.resguardosInternos,
        AppRoles.bajasBienes,
        AppRoles.entregaEquipo,
      ],
    );
  });

  tearDown(() => usuarioGlobal = null);

  testWidgets('oculta Entrega de Equipo cuando falta su rol', (tester) async {
    // Tener acceso administrativo no concede implícitamente este módulo: el
    // permiso entrega_equipo debe venir expresamente en la sesión.
    usuarioGlobal = Usuario(
      nombre: 'Administrador sin entregas',
      roles: const [AppRoles.admin],
    );

    await tester.pumpWidget(const MaterialApp(home: Paginamenu()));
    await tester.pumpAndSettle();

    expect(find.text('Control de Acceso'), findsOneWidget);
    expect(find.text('Entrega de Equipo'), findsNothing);
  });

  testWidgets('permite seleccionar Entrega de Equipo al crear un usuario',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Paginanuevousuario()),
    );

    final roleTile = find.widgetWithText(CheckboxListTile, 'Entrega de Equipo');
    expect(roleTile, findsOneWidget);
    expect(tester.widget<CheckboxListTile>(roleTile).value, isFalse);

    // El último rol queda debajo del pliegue en la ventana de prueba; se
    // desplaza el formulario igual que lo haría el usuario antes de tocarlo.
    await tester.ensureVisible(roleTile);
    await tester.pumpAndSettle();
    await tester.tap(roleTile);
    await tester.pump();

    expect(tester.widget<CheckboxListTile>(roleTile).value, isTrue);
  });

  testWidgets('el menú muestra todas las opciones en la matriz responsive',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const sizes = [
      Size(360, 800),
      Size(390, 844),
      Size(844, 390),
      Size(768, 1024),
      Size(1024, 768),
      Size(1366, 768),
    ];
    for (final size in sizes) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MaterialApp(home: Paginamenu()));
      await tester.pumpAndSettle();

      expect(find.text('Almacén Taller Vehículos'), findsOneWidget);
      expect(find.text('Resguardos Bienes'), findsOneWidget);
      expect(find.text('Entrega de Equipo'), findsOneWidget);
      expect(find.text('Bajas de Bienes'), findsOneWidget);
      expect(find.text('Control de Acceso'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Viewport: $size');
    }
  });

  testWidgets('la barra de acciones se apila únicamente en móvil',
      (tester) async {
    Future<void> render(Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveToolbar(
              search: SizedBox(key: Key('search'), height: 48),
              primaryAction: SizedBox(key: Key('action'), height: 48),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await render(const Size(390, 844));
    expect(tester.getTopLeft(find.byKey(const Key('action'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const Key('search'))).dy));

    await render(const Size(1024, 768));
    expect(tester.getTopLeft(find.byKey(const Key('action'))).dy,
        tester.getTopLeft(find.byKey(const Key('search'))).dy);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el título de la landing permanece visible sin desbordarse',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const sizes = [
      Size(390, 844),
      Size(844, 390),
      Size(1366, 768),
      Size(1907, 702),
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MaterialApp(home: Paginaprincipal()));
      await tester.pumpAndSettle();

      expect(find.text('ACBMIN'), findsOneWidget);
      expect(find.text('Área de Control de Bienes'), findsOneWidget);
      expect(find.text('Muebles e Inmuebles'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Viewport: $size');
    }
  });
}
