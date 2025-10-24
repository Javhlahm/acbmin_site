import 'package:acbmin_site/entity/Resguardo.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/PaginaNuevoResguardo.dart';
import 'package:acbmin_site/PaginaDetalleResguardo.dart'; // <-- IMPORTAR NUEVA PÁGINA
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

class PaginaResguardos extends StatefulWidget {
  const PaginaResguardos({super.key});

  @override
  State<PaginaResguardos> createState() => _PaginaResguardosState();
}

class _PaginaResguardosState extends State<PaginaResguardos> {
  PlutoGridStateManager? _stateManager;
  final TextEditingController _searchController = TextEditingController();
  final String? _nombreUsuarioActual = usuarioGlobal?.nombre;

  late List<Resguardo> _allResguardos;
  List<Resguardo> _filteredResguardos = [];
  List<PlutoRow> _rows = [];

  @override
  void initState() {
    super.initState();
    // Lista inicial de ejemplo
    _allResguardos = [
      Resguardo(
          folio: 100,
          fechaAutorizado: null,
          tipoResguardo: 'Nueva adquisición',
          numeroInventario: 'INV-001',
          descripcion: 'Laptop Dell Latitude 7400',
          areaEntrega: 'N/A',
          nombreEntrega: 'N/A',
          rfcEntrega: 'N/A',
          areaRecibe: 'Recursos Humanos',
          nombreRecibe: 'Ana García',
          rfcRecibe: 'GAAA900202YYY',
          observaciones: 'Equipo nuevo.',
          estatus: 'Pendiente',
          capturadoPor: 'Admin Ejemplo'),
      Resguardo(
          folio: 101,
          fechaAutorizado: '2025-10-22 10:30:00',
          tipoResguardo: 'Traspaso de resguardo',
          numeroInventario: 'INV-002',
          descripcion: 'Monitor LG 24 pulgadas',
          areaEntrega: 'Sistemas',
          nombreEntrega: 'Carlos López',
          rfcEntrega: 'LOLC750303ZZZ',
          areaRecibe: 'Contabilidad',
          nombreRecibe: 'María Rodríguez',
          rfcRecibe: 'ROMM850404AAA',
          observaciones: 'Transferencia interna.',
          estatus: 'Aprobado',
          capturadoPor: 'Otro Usuario'),
      Resguardo(
          folio: 102,
          fechaAutorizado: null,
          tipoResguardo: 'Nueva adquisición',
          numeroInventario: 'INV-003',
          descripcion: 'Silla de Oficina Ergonómica',
          areaEntrega: 'N/A',
          nombreEntrega: 'N/A',
          rfcEntrega: 'N/A',
          areaRecibe: 'Dirección General',
          nombreRecibe: 'Luis Martínez',
          rfcRecibe: 'MALL700505BBB',
          observaciones: 'Asignación a nuevo personal.',
          estatus: 'Pendiente',
          capturadoPor: 'Admin Ejemplo'),
      Resguardo(
          folio: 103,
          fechaAutorizado: null,
          tipoResguardo: 'Traspaso de resguardo',
          numeroInventario: 'INV-001',
          descripcion: 'Laptop Dell Latitude 7400',
          areaEntrega: 'Recursos Humanos',
          nombreEntrega: 'Ana García',
          rfcEntrega: 'GAAA900202YYY',
          areaRecibe: 'Sistemas',
          nombreRecibe: 'Pedro Ramírez',
          rfcRecibe: 'RAMP880606CCC',
          observaciones: 'Cambio de usuario.',
          estatus: 'Rechazado',
          capturadoPor: 'Ana García'),
    ];
    _filteredResguardos = List.from(_allResguardos);
    _searchController.addListener(_filterResguardos);
    _updatePlutoRows();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterResguardos);
    _searchController.dispose();
    super.dispose();
  }

  // Filtra la lista principal basado en el texto de búsqueda
  void _filterResguardos() {
    final query = _searchController.text;
    List<Resguardo> tempFiltered;

    if (query.isEmpty) {
      tempFiltered = List.from(_allResguardos);
    } else {
      tempFiltered = _allResguardos
          .where((resguardo) => resguardo.matchesSearch(query))
          .toList();
    }

    // Solo actualiza si la lista filtrada realmente cambió
    if (!listEquals(_filteredResguardos, tempFiltered)) {
      setState(() {
        _filteredResguardos = tempFiltered;
        _updatePlutoRows(); // Actualiza las filas para PlutoGrid
        // Si el stateManager ya está listo, actualiza las filas en la tabla
        if (mounted && _stateManager != null) {
          _stateManager!.removeAllRows();
          _stateManager!.appendRows(_rows);
        }
      });
    }
  }

  // Función helper para comparar listas (Flutter ya tiene listEquals en foundation)
  // import 'package:flutter/foundation.dart'; // <- Asegúrate de importar esto arriba
  bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      // Comparamos los resguardos usando el == sobreescrito (basado en folio)
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  // Convierte la lista filtrada de Resguardos a filas de PlutoGrid
  void _updatePlutoRows() {
    final folioFormatter = NumberFormat("0000");

    _rows = _filteredResguardos.map((resguardo) {
      return PlutoRow(
        cells: {
          'folio': PlutoCell(
              value:
                  'RICB-${folioFormatter.format(resguardo.folio)}'), // Folio formateado para mostrar
          'tipo_resguardo': PlutoCell(value: resguardo.tipoResguardo),
          'numero_inventario': PlutoCell(value: resguardo.numeroInventario),
          'descripcion': PlutoCell(value: resguardo.descripcion),
          'area_entrega': PlutoCell(value: resguardo.areaEntrega),
          'nombre_entrega': PlutoCell(value: resguardo.nombreEntrega),
          'rfc_entrega': PlutoCell(value: resguardo.rfcEntrega),
          'area_recibe': PlutoCell(value: resguardo.areaRecibe),
          'nombre_recibe': PlutoCell(value: resguardo.nombreRecibe),
          'rfc_recibe': PlutoCell(value: resguardo.rfcRecibe),
          'observaciones': PlutoCell(value: resguardo.observaciones ?? ''),
          'capturado_por': PlutoCell(value: resguardo.capturadoPor ?? ''),
          'fecha_autorizado': PlutoCell(value: resguardo.fechaAutorizado ?? ''),
          'estatus': PlutoCell(value: resguardo.estatus ?? 'Pendiente'),
        },
        // Guardamos el folio original como metadata para poder buscarlo después
        // PlutoGrid no tiene un campo 'userData' directo en la fila,
        // así que lo recuperaremos parseando el folio formateado al hacer doble clic.
      );
    }).toList();
  }

  // Define las columnas para PlutoGrid
  final List<PlutoColumn> _columns = [
    PlutoColumn(
      title: 'Folio',
      field: 'folio',
      type: PlutoColumnType.text(),
      width: 110,
      readOnly: true,
      textAlign: PlutoColumnTextAlign.center,
      frozen: PlutoColumnFrozen.start,
    ),
    PlutoColumn(
        title: 'Tipo',
        field: 'tipo_resguardo',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'No. Inventario',
        field: 'numero_inventario',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Descripción',
        field: 'descripcion',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Área Entrega',
        field: 'area_entrega',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Nombre Entrega',
        field: 'nombre_entrega',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'RFC Entrega',
        field: 'rfc_entrega',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Área Recibe',
        field: 'area_recibe',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Nombre Recibe',
        field: 'nombre_recibe',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'RFC Recibe',
        field: 'rfc_recibe',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Observaciones',
        field: 'observaciones',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 350),
    PlutoColumn(
        title: 'Capturado Por',
        field: 'capturado_por',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Fecha Autorizado',
        field: 'fecha_autorizado',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
      title: 'Estatus', field: 'estatus', type: PlutoColumnType.text(),
      width: 120, // Ancho fijo para estatus
      readOnly: true, textAlign: PlutoColumnTextAlign.center,
      // Renderizador personalizado para colorear la celda
      renderer: (rendererContext) {
        Color backgroundColor;
        final String status = rendererContext.cell.value.toString();
        switch (status.toLowerCase()) {
          case 'aprobado':
            backgroundColor = Colors.green.shade100;
            break;
          case 'pendiente':
            backgroundColor = Colors.yellow.shade100;
            break;
          case 'rechazado':
            backgroundColor = Colors.red.shade100;
            break;
          default:
            backgroundColor = Colors.white;
        }
        // Usar un Container dentro del renderer para el color
        return Container(
          color: backgroundColor,
          child: Center(
            // Centrar el texto dentro del contenedor coloreado
            child: Text(
              status,
              style: TextStyle(
                color: Colors.black87, // Color de texto
                fontSize: 14.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    ),
  ];

  // Navega a la pantalla de nuevo resguardo y maneja el resultado
  void _navegarANuevoResguardo() async {
    // Espera a que PaginaNuevoResguardo devuelva un Resguardo o null
    final nuevoResguardo = await Navigator.push<Resguardo>(
      // Espera un Resguardo directamente
      context,
      MaterialPageRoute(builder: (context) => const PaginaNuevoResguardo()),
    );

    // Si se recibió un nuevo resguardo (no nulo) y el widget sigue montado
    if (nuevoResguardo != null && mounted) {
      setState(() {
        _allResguardos.add(nuevoResguardo); // Añadir a la lista principal
        _filterResguardos(); // Actualizar la lista filtrada y las filas de la tabla
      });

      // Muestra el AlertDialog de confirmación
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Éxito'),
            content: Text(
                'Resguardo creado con folio: ${nuevoResguardo.folioFormateado}'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () =>
                    Navigator.of(context).pop(), // Cierra el diálogo
              ),
            ],
          );
        },
      );
    }
  }

  // Navega a la pantalla de detalle/edición y maneja el resultado
  void _navegarADetalleResguardo(PlutoRow row) async {
    // Extraer el folio original del valor formateado en la celda
    final String folioFormateado = row.cells['folio']!.value; // "RICB-xxxx"
    final int folioOriginal;
    try {
      folioOriginal = int.parse(folioFormateado.split('-')[1]);
    } catch (e) {
      print("Error al parsear folio para detalle: $folioFormateado");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al obtener folio para detalle.'),
          backgroundColor: Colors.red));
      return; // No se puede continuar sin el folio original
    }

    // Encontrar el índice del Resguardo correspondiente en la lista _allResguardos
    final int index =
        _allResguardos.indexWhere((r) => r.folio == folioOriginal);
    if (index == -1) {
      print(
          "Resguardo con folio $folioOriginal no encontrado en _allResguardos para detalle.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: Resguardo no encontrado para detalle.'),
          backgroundColor: Colors.red));
      return; // No encontrado
    }
    final Resguardo resguardoSeleccionado = _allResguardos[index];

    // Navega a la pantalla de detalle, pasando el resguardo encontrado
    final resultado = await Navigator.push<DetalleResguardoResult>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PaginaDetalleResguardo(resguardoInicial: resguardoSeleccionado)),
    );

    // Procesar el resultado al regresar de la pantalla de detalle
    if (resultado != null && mounted) {
      if (resultado.action == DetalleResguardoResultAction.updated &&
          resultado.resguardo != null) {
        // Actualizar el resguardo en la lista principal
        setState(() {
          _allResguardos[index] =
              resultado.resguardo!; // Reemplaza en el índice correcto
          _filterResguardos(); // Refrescar la lista filtrada y la tabla
        });
        // Opcional: Mostrar SnackBar de éxito de actualización aquí si se desea
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resguardo ${resultado.resguardo!.folioFormateado} actualizado.'), backgroundColor: Colors.green));
      } else if (resultado.action == DetalleResguardoResultAction.deleted &&
          resultado.resguardo != null) {
        // Eliminar el resguardo de la lista principal
        setState(() {
          // Asegurarse de que el índice sigue siendo válido (aunque debería serlo)
          if (index < _allResguardos.length &&
              _allResguardos[index].folio == resultado.resguardo!.folio) {
            _allResguardos.removeAt(index);
          } else {
            // Si el índice ya no coincide (raro), buscar y eliminar por folio
            _allResguardos
                .removeWhere((r) => r.folio == resultado.resguardo!.folio);
          }
          _filterResguardos(); // Refrescar la lista filtrada y la tabla
        });
        // Opcional: Mostrar SnackBar de éxito de eliminación aquí si se desea
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resguardo ${resultado.resguardo!.folioFormateado} eliminado.'), backgroundColor: Colors.orange));
      }
      // Si action es 'none', no hacemos nada
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff6c500),
        centerTitle: true,
        // Título actualizado
        title: Text(
          "ACBMIN: RESGUARDOS INTERNOS",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 25.0.dg, // Ajustar tamaño si es necesario
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(), // Botón para regresar
        ),
        actions: [
          // Mostrar nombre de usuario si existe
          if (_nombreUsuarioActual != null)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 15.w),
                child: Text(
                  _nombreUsuarioActual!,
                  style: TextStyle(
                      fontSize: 20.dg,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.black // Asegurar contraste
                      ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w), // Padding general
        child: Column(
          children: [
            // Fila con campo de búsqueda y botón
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  // Campo de búsqueda expandido
                  Expanded(
                    flex: 3, // Ocupa más espacio
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          labelText: 'Buscar...',
                          hintText: 'Folio, nombre, inventario...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h,
                              horizontal: 10.w) // Ajustar padding interno
                          ),
                    ),
                  ),
                  SizedBox(width: 16.w), // Espacio entre búsqueda y botón
                  // Botón Nuevo Resguardo
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Nuevo Resguardo'),
                    onPressed: _navegarANuevoResguardo,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h,
                          horizontal: 20.w), // Padding del botón
                      backgroundColor: Colors.amber, // Color de fondo
                      foregroundColor: Colors.black, // Color del texto/icono
                    ),
                  ),
                ],
              ),
            ),
            // Tabla expandida
            Expanded(
              child: PlutoGrid(
                columns: _columns,
                rows: _rows, // Usar las filas actualizadas
                // Callback cuando la tabla está lista
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  _stateManager = event.stateManager;
                  // Opcional: Ocultar filtros de columna si no se usan
                  _stateManager!.setShowColumnFilter(false);
                },
                // Callback para doble clic en una fila
                onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                  if (event.row != null) {
                    _navegarADetalleResguardo(event.row!);
                  }
                },
                // Configuración general de la tabla
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    enableGridBorderShadow: true, // Sombra alrededor
                    enableRowColorAnimation: true, // Animación al seleccionar
                    rowHeight: 45.h, // Altura de fila ajustada con screenutil
                    cellTextStyle:
                        TextStyle(fontSize: 14.sp), // Tamaño texto celda
                    columnTextStyle: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold), // Tamaño texto encabezado
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
