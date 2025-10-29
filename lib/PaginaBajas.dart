// ... (imports) ...
import 'package:acbmin_site/entity/BajaBien.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/PaginaNuevaBaja.dart';
import 'package:acbmin_site/PaginaDetalleBaja.dart';
import 'package:acbmin_site/services/bajas/obtener_bajas.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:collection/collection.dart';

class PaginaBajas extends StatefulWidget {
  const PaginaBajas({super.key});

  @override
  State<PaginaBajas> createState() => _PaginaBajasState();
}

class _PaginaBajasState extends State<PaginaBajas> {
  // ... (Variables _stateManager, _searchController, _nombreUsuarioActual, _futureBajas, listas, _isLoading sin cambios) ...
  PlutoGridStateManager? _stateManager;
  final TextEditingController _searchController = TextEditingController();
  final String? _nombreUsuarioActual = usuarioGlobal?.nombre;

  late Future<List<BajaBien>> _futureBajas;
  List<BajaBien> _allBajas = [];
  List<BajaBien> _filteredBajas = [];
  List<PlutoRow> _rows = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _futureBajas = _cargarDatosIniciales();
    _searchController.addListener(_applyFilter);
  }

  // ... (_cargarDatosIniciales, _actualizarDatos, _applyFilter, _refreshPlutoGrid sin cambios) ...
  Future<List<BajaBien>> _cargarDatosIniciales() async {
    if (!mounted) return [];
    setState(() {
      _isLoading = true;
    });
    try {
      List<BajaBien> bajasDesdeApi = await obtenerBajas();
      if (!mounted) return bajasDesdeApi;
      _allBajas = bajasDesdeApi;
      _filteredBajas = List.from(_allBajas);
      _updatePlutoRows();
      setState(() {
        _isLoading = false;
      });
      return _allBajas;
    } catch (e) {
      if (!mounted) return [];
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al cargar Bajas: ${e.toString()}'),
          backgroundColor: Colors.red));
      return [];
    }
  }

  Future<void> _actualizarDatos() async {
    await _cargarDatosIniciales();
    _searchController.clear();
    if (_searchController.text.isEmpty) {
      _applyFilter();
    }
    _refreshPlutoGrid();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Tabla de Bajas actualizada desde el servidor.'),
          backgroundColor: Colors.blue));
    }
  }

  void _applyFilter() {
    final query = _searchController.text;
    List<BajaBien> tempFiltered;

    if (query.isEmpty) {
      tempFiltered = List.from(_allBajas);
    } else {
      tempFiltered =
          _allBajas.where((baja) => baja.matchesSearch(query)).toList();
    }

    if (!listEquals(_filteredBajas, tempFiltered)) {
      if (!mounted) return;
      setState(() {
        _filteredBajas = tempFiltered;
        _updatePlutoRows();
      });
      _refreshPlutoGrid();
    }
  }

  void _refreshPlutoGrid() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _stateManager != null) {
        _stateManager!.removeAllRows(notify: false);
        _stateManager!.appendRows(_rows);
      }
    });
  }

  // Modificar _exportarAExcel para incluir Observaciones
  void _exportarAExcel() {
    if (_filteredBajas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No hay datos filtrados para exportar.'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Bajas_Bienes'];
      excel.delete('Sheet1');

      // Añadir "Observaciones" al final de los encabezados
      List<CellValue> headers = [
        TextCellValue('Folio'), TextCellValue('Área Baja'),
        TextCellValue('Área o C.T.'),
        TextCellValue('Persona Baja'), TextCellValue('RFC Baja'),
        TextCellValue('No. Inventario'),
        TextCellValue('Descripción'), TextCellValue('Fecha Entrega Activos'),
        TextCellValue('Capturado Por'),
        TextCellValue('Fecha Autorizado'), TextCellValue('Estatus'),
        TextCellValue('Observaciones') // <-- Añadido
      ];
      sheet.appendRow(headers);

      // Añadir el valor de observaciones en los datos
      for (var baja in _filteredBajas) {
        sheet.appendRow([
          TextCellValue(baja.folioFormateado), TextCellValue(baja.areaBaja),
          TextCellValue(baja.areaBaja),
          TextCellValue(baja.personaBaja), TextCellValue(baja.rfcBaja),
          TextCellValue(baja.numeroInventario),
          TextCellValue(baja.descripcion),
          TextCellValue(baja.fechaEntregaActivos?.toString() ?? ''),
          TextCellValue(baja.capturadoPor ?? ''),
          TextCellValue(baja.fechaAutorizado?.toString() ?? ''),
          TextCellValue(baja.estatus ?? 'Pendiente'),
          TextCellValue(baja.observaciones ?? ''), // <-- Añadido
        ]);
      }

      final String fileName =
          "Bajas_Bienes_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx";
      excel.save(fileName: fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Exportando a $fileName...'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print("Error al exportar Bajas a Excel: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al exportar a Excel: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // Modificar _updatePlutoRows para incluir Observaciones
  void _updatePlutoRows() {
    _rows = _filteredBajas.map((baja) {
      return PlutoRow(
        cells: {
          'folio': PlutoCell(value: baja.folioFormateado),
          'area_baja': PlutoCell(value: baja.areaBaja),
          'persona_baja': PlutoCell(value: baja.personaBaja),
          'rfc_baja': PlutoCell(value: baja.rfcBaja),
          'numero_inventario': PlutoCell(value: baja.numeroInventario),
          'descripcion': PlutoCell(value: baja.descripcion),
          'fecha_entrega_activos':
              PlutoCell(value: baja.fechaEntregaActivos?.toString() ?? ''),
          'capturado_por': PlutoCell(value: baja.capturadoPor ?? ''),
          'fecha_autorizado':
              PlutoCell(value: baja.fechaAutorizado?.toString() ?? ''),
          'estatus': PlutoCell(value: baja.estatus ?? 'Pendiente'),
          'observaciones':
              PlutoCell(value: baja.observaciones ?? ''), // <-- Añadido
        },
      );
    }).toList();
  }

  // Modificar _columns para añadir la columna Observaciones
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
        title: 'Área Baja',
        field: 'area_baja',
        type: PlutoColumnType.text(),
        readOnly: true),

    PlutoColumn(
        title: 'Persona Baja',
        field: 'persona_baja',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 250),
    PlutoColumn(
        title: 'RFC Baja',
        field: 'rfc_baja',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 150),
    PlutoColumn(
        title: 'No. Inventario',
        field: 'numero_inventario',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 150),
    PlutoColumn(
        title: 'Descripción',
        field: 'descripcion',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 350),
    PlutoColumn(
        title: 'Fecha Entrega Act.',
        field: 'fecha_entrega_activos',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 150),
    PlutoColumn(
        title: 'Capturado Por',
        field: 'capturado_por',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 180),
    PlutoColumn(
        title: 'Fecha Autorizado',
        field: 'fecha_autorizado',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 180),
    PlutoColumn(
        title: 'Observaciones',
        field: 'observaciones',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 350 // Ancho similar a descripción
        ),
    PlutoColumn(
      // Columna de estatus con renderer (sin cambios)
      title: 'Estatus', field: 'estatus', type: PlutoColumnType.text(),
      width: 120, readOnly: true, textAlign: PlutoColumnTextAlign.center,
      renderer: (rendererContext) {
        /* ... renderer sin cambios ... */
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
    // --- Nueva Columna Observaciones ---

    // ------------------------------------
  ];

  // ... (_navegarANuevaBaja, _navegarADetalleBaja, dispose, build sin cambios estructurales) ...
  void _navegarANuevaBaja() async {
    final nuevaBaja = await Navigator.push<BajaBien>(
      context,
      MaterialPageRoute(builder: (context) => const PaginaNuevaBaja()),
    );
    if (nuevaBaja != null && mounted) {
      await _actualizarDatos();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Éxito'),
            content:
                Text('Baja creada con folio: ${nuevaBaja.folioFormateado}'),
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

  void _navegarADetalleBaja(PlutoRow row) async {
    final String folioFormateado = row.cells['folio']!.value;
    final int folioOriginal;
    try {
      folioOriginal = int.parse(folioFormateado.split('-')[1]);
    } catch (e) {
      print("Error al parsear folio para detalle de baja: $folioFormateado");
      return;
    }

    final BajaBien? bajaSeleccionada =
        _allBajas.firstWhereOrNull((b) => b.folio == folioOriginal);

    if (bajaSeleccionada == null) {
      print("Baja con folio $folioOriginal no encontrada para detalle.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: No se encontró la baja seleccionada.'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    final resultado = await Navigator.push<DetalleBajaResult>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PaginaDetalleBaja(bajaInicial: bajaSeleccionada)),
    );

    if (resultado != null &&
        (resultado.action == DetalleBajaResultAction.updated ||
            resultado.action == DetalleBajaResultAction.deleted) &&
        mounted) {
      await _actualizarDatos();
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
        /* ... AppBar sin cambios ... */
        backgroundColor: Color(0xfff6c500),
        centerTitle: true,
        title: Text(
          "ACBMIN: BAJAS DE BIENES",
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
                  _nombreUsuarioActual,
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
              /* ... Barra de búsqueda y botón Nuevo sin cambios ... */
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          labelText: 'Buscar...',
                          hintText: 'Folio, inventario, área...',
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
                    label: Text('Nueva Baja'),
                    onPressed: _navegarANuevaBaja,
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
            Expanded(
              // ... Lógica de FutureBuilder/Indicador de carga/Tabla sin cambios ...
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _allBajas.isEmpty
                      ? Center(
                          child: Text('No se encontraron bajas registradas.'))
                      : _filteredBajas.isEmpty
                          ? Center(
                              child: Text(
                                  'No hay bajas que coincidan con la búsqueda.'))
                          : PlutoGrid(
                              columns:
                                  _columns, // Usa las columnas actualizadas
                              rows: _rows, // Usa las filas actualizadas
                              onLoaded: (PlutoGridOnLoadedEvent event) {
                                /* ... sin cambios ... */
                                _stateManager = event.stateManager;
                                _stateManager!.setShowColumnFilter(false);
                              },
                              onRowDoubleTap:
                                  (PlutoGridOnRowDoubleTapEvent event) {
                                /* ... sin cambios ... */
                                _navegarADetalleBaja(event.row);
                              },
                              configuration: PlutoGridConfiguration(
                                /* ... sin cambios ... */
                                style: PlutoGridStyleConfig(
                                  enableGridBorderShadow: true,
                                  enableRowColorAnimation: true,
                                  rowHeight: 45.h,
                                  cellTextStyle: TextStyle(fontSize: 14.sp),
                                  columnTextStyle: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold),
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
