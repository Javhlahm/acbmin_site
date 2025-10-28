import 'dart:convert'; // Necesario para utf8.decode
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart'; // Para listEquals
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

// Importar la entidad y las páginas relacionadas
import 'entity/Resguardo.dart';
import 'PaginaNuevoResguardo.dart';
import 'PaginaDetalleResguardo.dart';
// Importar el servicio para obtener resguardos
import 'services/resguardos/obtener_resguardos.dart'; // Asegúrate que la ruta sea correcta

class PaginaResguardos extends StatefulWidget {
  const PaginaResguardos({super.key});

  @override
  State<PaginaResguardos> createState() => _PaginaResguardosState();
}

class _PaginaResguardosState extends State<PaginaResguardos> {
  PlutoGridStateManager? _stateManager;
  final TextEditingController _searchController = TextEditingController();
  final String? _nombreUsuarioActual = usuarioGlobal?.nombre;

  // Usa Future para cargar los datos iniciales
  late Future<List<Resguardo>> _futureResguardos;
  List<Resguardo> _allResguardos = []; // Almacena los datos una vez cargados
  List<Resguardo> _filteredResguardos = [];
  List<PlutoRow> _rows = [];
  bool _isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    // Inicia la carga de datos desde la API
    _futureResguardos = _cargarDatosIniciales();
    _searchController.addListener(_applyFilter);
  }

  // Nueva función para cargar datos desde la API
  Future<List<Resguardo>> _cargarDatosIniciales() async {
    if (!mounted) return []; // Evitar setState si el widget no está montado
    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });
    try {
      List<Resguardo> resguardosDesdeApi = await obtenerResguardos();
      if (!mounted)
        return resguardosDesdeApi; // Verificar de nuevo antes de setState
      // Una vez cargados, los guardamos localmente para filtrar/mostrar
      _allResguardos = resguardosDesdeApi;
      _filteredResguardos =
          List.from(_allResguardos); // Copia inicial para filtrado
      _updatePlutoRows(); // Actualiza las filas de la tabla
      setState(() {
        _isLoading = false; // Ocultar indicador de carga
      });
      return _allResguardos; // Devolver los datos cargados
    } catch (e) {
      if (!mounted) return [];
      setState(() {
        _isLoading = false;
      });
      // Mostrar error al usuario
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al cargar resguardos: ${e.toString()}'),
          backgroundColor: Colors.red));
      return []; // Devolver lista vacía en caso de error
    }
  }

  // Modificar _actualizarDatos para volver a llamar a la API
  Future<void> _actualizarDatos() async {
    // Llama a la función que carga desde la API
    await _cargarDatosIniciales();
    // Limpia la búsqueda
    _searchController.clear(); // Esto disparará _applyFilter si tenía texto
    // Si _applyFilter no se disparó (porque estaba vacío), forzamos la actualización visual
    if (_searchController.text.isEmpty) {
      _applyFilter(); // Asegura que se muestren todos los datos
    }
    // Refresca la tabla visualmente (importante después de cargar nuevos datos)
    _refreshPlutoGrid();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Tabla actualizada desde el servidor.'),
          backgroundColor: Colors.blue));
    }
  }

  // _applyFilter ahora opera sobre _allResguardos (que tiene los datos de la API)
  void _applyFilter() {
    final query = _searchController.text;
    List<Resguardo> tempFiltered;

    if (query.isEmpty) {
      tempFiltered = List.from(_allResguardos);
    } else {
      tempFiltered = _allResguardos
          .where((resguardo) => resguardo.matchesSearch(query))
          .toList();
    }

    // Compara si la lista filtrada realmente cambió antes de actualizar estado
    if (!listEquals(_filteredResguardos, tempFiltered)) {
      if (!mounted) return;
      setState(() {
        _filteredResguardos = tempFiltered;
        _updatePlutoRows(); // Actualiza las filas con los datos filtrados
      });
      _refreshPlutoGrid(); // Refresca la tabla visualmente
    }
  }

  // Refresca visualmente el PlutoGrid
  void _refreshPlutoGrid() {
    // Usar addPostFrameCallback para asegurar que el build haya terminado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _stateManager != null) {
        // Limpiar y añadir filas de nuevo es una forma segura de refrescar
        _stateManager!.removeAllRows(notify: false); // No notificar aún
        _stateManager!.appendRows(_rows); // Notifica al final
        // Alternativamente, si solo cambian datos y no la estructura:
        // _stateManager.notifyListeners();
      }
    });
  }

  // _exportarAExcel usa _filteredResguardos
  void _exportarAExcel() {
    if (_filteredResguardos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No hay datos filtrados para exportar.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final folioFormatter = NumberFormat("0000");
      var excel = Excel.createExcel();
      Sheet sheet = excel['Resguardos'];
      excel.delete('Sheet1'); // Eliminar hoja por defecto

      // Encabezados
      List<CellValue> headers = [
        TextCellValue('Folio'),
        TextCellValue('Tipo'),
        TextCellValue('No. Inventario'),
        TextCellValue('Descripción'),
        TextCellValue('Área Entrega'),
        TextCellValue('Nombre Entrega'),
        TextCellValue('RFC Entrega'),
        TextCellValue('Área Recibe'),
        TextCellValue('Nombre Recibe'),
        TextCellValue('RFC Recibe'),
        TextCellValue('Observaciones'),
        TextCellValue('Capturado Por'),
        TextCellValue('Fecha Autorizado'),
        TextCellValue('Estatus')
      ];
      sheet.appendRow(headers);

      // Datos
      for (var resguardo in _filteredResguardos) {
        sheet.appendRow([
          TextCellValue(resguardo.folioFormateado), // Usa el getter formateado
          TextCellValue(resguardo.tipoResguardo),
          TextCellValue(resguardo.numeroInventario),
          TextCellValue(resguardo.descripcion),
          TextCellValue(resguardo.areaEntrega),
          TextCellValue(resguardo.nombreEntrega),
          TextCellValue(resguardo.rfcEntrega),
          TextCellValue(resguardo.areaRecibe),
          TextCellValue(resguardo.nombreRecibe),
          TextCellValue(resguardo.rfcRecibe),
          TextCellValue(resguardo.observaciones ?? ''),
          TextCellValue(resguardo.capturadoPor ?? ''),
          TextCellValue(resguardo.fechaAutorizado ?? ''),
          TextCellValue(resguardo.estatus ?? 'Pendiente'),
        ]);
      }

      final String fileName =
          "Resguardos_Internos_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx";
      excel.save(fileName: fileName); // Guardar el archivo

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Exportando a $fileName...'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print("Error al exportar a Excel: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al exportar a Excel: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // Función auxiliar para comparar listas (necesita import 'package:flutter/foundation.dart')
  // bool listEquals<T>(List<T>? a, List<T>? b) {
  //   if (a == null) return b == null;
  //   if (b == null || a.length != b.length) return false;
  //   if (identical(a, b)) return true;
  //   for (int index = 0; index < a.length; index += 1) {
  //     if (a[index] != b[index]) return false;
  //   }
  //   return true;
  // } // listEquals ya está en foundation.dart

  // _updatePlutoRows usa _filteredResguardos
  void _updatePlutoRows() {
    _rows = _filteredResguardos.map((resguardo) {
      return PlutoRow(
        cells: {
          'folio': PlutoCell(value: resguardo.folioFormateado), // Usa el getter
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
      );
    }).toList();
  }

  // Definición de columnas (sin cambios respecto a la versión anterior)
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
        readOnly: true,
        width: 350), // Ancho mayor
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
        width: 350), // Ancho mayor
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
      title: 'Estatus',
      field: 'estatus',
      type: PlutoColumnType.text(),
      width: 120,
      readOnly: true,
      textAlign: PlutoColumnTextAlign.center,
      renderer: (rendererContext) {
        // Renderer para color de fondo según estatus
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
        return Container(
          color: backgroundColor,
          child: Center(
            child: Text(
              status,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    ),
  ];

  // _navegarANuevoResguardo llama a _actualizarDatos al volver si se creó algo
  void _navegarANuevoResguardo() async {
    final nuevoResguardo = await Navigator.push<Resguardo>(
      // Espera Resguardo (no Resguardo?)
      context,
      MaterialPageRoute(builder: (context) => const PaginaNuevoResguardo()),
    );

    // Si se creó un nuevo resguardo (devuelto desde PaginaNuevoResguardo)
    if (nuevoResguardo != null && mounted) {
      // Actualiza la lista completa desde la API para asegurar consistencia
      await _actualizarDatos();

      // Opcional: Mostrar diálogo de éxito (como ya lo tienes)
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  // _navegarADetalleResguardo llama a _actualizarDatos si hubo cambios (update/delete)
  void _navegarADetalleResguardo(PlutoRow row) async {
    final String folioFormateado = row.cells['folio']!.value;
    final int folioOriginal;
    try {
      folioOriginal = int.parse(folioFormateado.split('-')[1]);
    } catch (e) {
      print("Error al parsear folio para detalle: $folioFormateado");
      return;
    }

// Import collection package at the top if not already done:
    // import 'package:collection/collection.dart';

    // Find the Resguardo object using firstWhereOrNull for better null safety
    final Resguardo? resguardoSeleccionado = _allResguardos.firstWhereOrNull(
      (r) => r.folio == folioOriginal,
    );

    // Check if found before proceeding
    if (resguardoSeleccionado == null) {
      print("Resguardo con folio $folioOriginal no encontrado para detalle.");
      if (mounted) {
        // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: No se encontró el resguardo seleccionado.'),
          backgroundColor: Colors.red,
        ));
      }
      return; // No navegar si no se encontró
    }

    // --- El resto de la función _navegarADetalleResguardo continúa igual ---
    // final resultado = await Navigator.push<DetalleResguardoResult>(...)

    // Navega pasando el objeto completo
    final resultado = await Navigator.push<DetalleResguardoResult>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PaginaDetalleResguardo(resguardoInicial: resguardoSeleccionado)),
    );

    // Si se actualizó o eliminó algo al volver de PaginaDetalleResguardo
    if (resultado != null &&
        (resultado.action == DetalleResguardoResultAction.updated ||
            resultado.action == DetalleResguardoResultAction.deleted) &&
        mounted) {
      await _actualizarDatos(); // Recarga toda la lista desde la API
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff6c500),
        centerTitle: true,
        title: Text(
          "ACBMIN: RESGUARDOS INTERNOS",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 25.0.dg,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            tooltip: 'Actualizar Tabla',
            onPressed: _actualizarDatos,
          ),
          IconButton(
            icon: Icon(Icons.download, color: Colors.black),
            tooltip: 'Exportar a Excel',
            onPressed: _exportarAExcel,
          ),
          SizedBox(width: 10.w),
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
                      color: Colors.black),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
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
                              vertical: 10.h, horizontal: 10.w)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Nuevo Resguardo'),
                    onPressed: _navegarANuevoResguardo,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 20.w),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Usa FutureBuilder o indicador de carga
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator()) // Muestra carga
                  : _filteredResguardos
                          .isEmpty // Muestra mensaje si no hay datos después de cargar
                      ? Center(child: Text('No se encontraron resguardos.'))
                      : PlutoGrid(
                          // Muestra la tabla si hay datos
                          columns: _columns,
                          rows:
                              _rows, // Las filas se actualizan en _updatePlutoRows
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            _stateManager = event.stateManager;
                            _stateManager!.setShowColumnFilter(false);
                          },
                          onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                            if (event.row != null) {
                              _navegarADetalleResguardo(
                                  event.row!); // Llama a la versión modificada
                            }
                          },
                          configuration: PlutoGridConfiguration(
                            style: PlutoGridStyleConfig(
                              enableGridBorderShadow: true,
                              enableRowColorAnimation: true,
                              rowHeight: 45.h,
                              cellTextStyle: TextStyle(fontSize: 14.sp),
                              columnTextStyle: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
} // Fin _PaginaResguardosState
