import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

// Importar la nueva entidad y las nuevas páginas
import 'entity/BajaBien.dart';
import 'PaginaNuevaBaja.dart';
import 'PaginaDetalleBaja.dart';

class PaginaBajas extends StatefulWidget {
  const PaginaBajas({super.key});

  @override
  State<PaginaBajas> createState() => _PaginaBajasState();
}

class _PaginaBajasState extends State<PaginaBajas> {
  PlutoGridStateManager? _stateManager;
  final TextEditingController _searchController = TextEditingController();
  final String? _nombreUsuarioActual = usuarioGlobal?.nombre;

  late List<BajaBien> _allBajas; // Cambiado a BajaBien
  List<BajaBien> _filteredBajas = []; // Cambiado a BajaBien
  List<PlutoRow> _rows = [];

  @override
  void initState() {
    super.initState();
    // Lista inicial de ejemplo para Bajas
    _allBajas = [
      BajaBien(
          folio: 101,
          areaBaja: 'Sistemas',
          claveCentroTrabajo: 'CCT-001',
          personaBaja: 'Juan Pérez',
          rfcBaja: 'PEPJ800101XXX',
          descripcion: 'Monitor Dell 22 pulgadas Obsoleto',
          numeroInventario: 'INV-1234',
          fechaEntregaActivos: '2025-10-25',
          estatus: 'Pendiente',
          capturadoPor: 'Admin Ejemplo'),
      BajaBien(
          folio: 102,
          fechaAutorizado: '2025-10-20 11:00:00',
          areaBaja: 'Recursos Humanos',
          claveCentroTrabajo: 'CCT-002',
          personaBaja: 'Maria Lopez',
          rfcBaja: 'LOPM850202YYY',
          descripcion: 'Laptop HP Dañada (sin reparación)',
          numeroInventario: 'INV-5678',
          fechaEntregaActivos: '2025-10-21',
          estatus: 'Aprobado',
          capturadoPor: 'Otro Usuario'),
      BajaBien(
          folio: 103,
          areaBaja: 'Contabilidad',
          claveCentroTrabajo: 'CCT-003',
          personaBaja: 'Carlos Garcia',
          rfcBaja: 'GACC750303ZZZ',
          descripcion: 'Impresora Epson L3110 (Fin de vida útil)',
          numeroInventario: 'INV-9101',
          fechaEntregaActivos: null, // Aún no entregado
          estatus: 'Pendiente',
          capturadoPor: 'Admin Ejemplo'),
    ];
    _filteredBajas = List.from(_allBajas);
    _searchController.addListener(_applyFilter);
    _updatePlutoRows();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  // _applyFilter adaptado para BajaBien
  void _applyFilter() {
    final query = _searchController.text;
    List<BajaBien> tempFiltered;

    if (query.isEmpty) {
      tempFiltered = List.from(_allBajas);
    } else {
      tempFiltered =
          _allBajas.where((baja) => baja.matchesSearch(query)).toList();
    }

    // Comparación simple, puedes hacerla más robusta si necesitas
    if (!listEquals(_filteredBajas, tempFiltered)) {
      setState(() {
        _filteredBajas = tempFiltered;
        _updatePlutoRows();
      });
      _refreshPlutoGrid();
    } else if (query.isEmpty && _filteredBajas.length != _allBajas.length) {
      // Caso especial para cuando se borra la búsqueda
      setState(() {
        _filteredBajas = List.from(_allBajas);
        _updatePlutoRows();
      });
      _refreshPlutoGrid();
    }
  }

  void _refreshPlutoGrid() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _stateManager != null) {
        _stateManager!.removeAllRows();
        _stateManager!.appendRows(_rows);
        // _stateManager.notifyListeners(); // Alternativa si lo anterior no funciona
      }
    });
  }

  // Función para simular la recarga de datos (igual, pero opera sobre _allBajas)
  void _actualizarDatos() {
    setState(() {
      // Aquí podrías recargar datos de una fuente externa si fuera necesario
      _allBajas = List.from(_allBajas); // Simula recarga
      _searchController.clear(); // Limpia búsqueda
      _filteredBajas = List.from(_allBajas);
      _updatePlutoRows();
    });
    _refreshPlutoGrid(); // Refresca visualmente la tabla
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tabla de Bajas actualizada.'),
        backgroundColor: Colors.blue));
  }

  // _exportarAExcel adaptado para BajaBien
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
      final folioFormatter = NumberFormat("0000");
      var excel = Excel.createExcel();
      Sheet sheet = excel['Bajas_Bienes']; // Nombre de la hoja
      excel.delete('Sheet1');

      // Encabezados adaptados
      List<CellValue> headers = [
        TextCellValue('Folio'),
        TextCellValue('Área Baja'),
        TextCellValue('Clave CT'),
        TextCellValue('Persona Baja'),
        TextCellValue('RFC Baja'),
        TextCellValue('No. Inventario'),
        TextCellValue('Descripción'),
        TextCellValue('Fecha Entrega Activos'),
        TextCellValue('Capturado Por'),
        TextCellValue('Fecha Autorizado'),
        TextCellValue('Estatus')
      ];
      sheet.appendRow(headers);

      // Datos adaptados
      for (var baja in _filteredBajas) {
        sheet.appendRow([
          TextCellValue(
              'BICB-${folioFormatter.format(baja.folio)}'), // Folio formateado
          TextCellValue(baja.areaBaja),
          TextCellValue(baja.claveCentroTrabajo),
          TextCellValue(baja.personaBaja),
          TextCellValue(baja.rfcBaja),
          TextCellValue(baja.numeroInventario),
          TextCellValue(baja.descripcion),
          TextCellValue(baja.fechaEntregaActivos ?? ''),
          TextCellValue(baja.capturadoPor ?? ''),
          TextCellValue(baja.fechaAutorizado ?? ''),
          TextCellValue(baja.estatus ?? 'Pendiente'),
        ]);
      }

      final String fileName =
          "Bajas_Bienes_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx";
      excel.save(fileName: fileName); // Guardar el archivo

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Exportando a $fileName...'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      print("Error al exportar Bajas a Excel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al exportar a Excel: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  // Función auxiliar para comparar listas (igual que antes)
  bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  // _updatePlutoRows adaptado para BajaBien
  void _updatePlutoRows() {
    final folioFormatter = NumberFormat("0000");
    _rows = _filteredBajas.map((baja) {
      return PlutoRow(
        cells: {
          'folio': PlutoCell(
              value:
                  'BICB-${folioFormatter.format(baja.folio)}'), // Usar getter
          'area_baja': PlutoCell(value: baja.areaBaja),
          'clave_ct': PlutoCell(value: baja.claveCentroTrabajo),
          'persona_baja': PlutoCell(value: baja.personaBaja),
          'rfc_baja': PlutoCell(value: baja.rfcBaja),
          'numero_inventario': PlutoCell(value: baja.numeroInventario),
          'descripcion': PlutoCell(value: baja.descripcion),
          'fecha_entrega_activos':
              PlutoCell(value: baja.fechaEntregaActivos ?? ''),
          'capturado_por': PlutoCell(value: baja.capturadoPor ?? ''),
          'fecha_autorizado': PlutoCell(value: baja.fechaAutorizado ?? ''),
          'estatus': PlutoCell(value: baja.estatus ?? 'Pendiente'),
        },
      );
    }).toList();
  }

  // Definición de columnas adaptada para BajaBien
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
        title: 'Clave CT',
        field: 'clave_ct',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Persona Baja',
        field: 'persona_baja',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'RFC Baja',
        field: 'rfc_baja',
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
        width: 350), // Ancho mayor para descripción
    PlutoColumn(
        title: 'Fecha Entrega Activos',
        field: 'fecha_entrega_activos',
        type: PlutoColumnType.text(), // O tipo fecha si prefieres
        readOnly: true),
    PlutoColumn(
        title: 'Capturado Por',
        field: 'capturado_por',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Fecha Autorizado',
        field: 'fecha_autorizado',
        type: PlutoColumnType.text(), // O tipo fecha
        readOnly: true),
    PlutoColumn(
      // Columna de estatus (igual que en Resguardos)
      title: 'Estatus',
      field: 'estatus',
      type: PlutoColumnType.text(),
      width: 120,
      readOnly: true,
      textAlign: PlutoColumnTextAlign.center,
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

  // _navegarANuevaBaja adaptado
  void _navegarANuevaBaja() async {
    final nuevaBaja = await Navigator.push<BajaBien>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const PaginaNuevaBaja()), // Navega a la nueva página
    );

    if (nuevaBaja != null && mounted) {
      bool changed = false;
      setState(() {
        _allBajas.add(nuevaBaja);
        changed = true;
        // Refrescar lista filtrada
        if (_searchController.text.isNotEmpty) {
          _filteredBajas = _allBajas
              .where((baja) => baja.matchesSearch(_searchController.text))
              .toList();
        } else {
          _filteredBajas = List.from(_allBajas);
        }
        _updatePlutoRows();
      });
      if (changed) {
        _refreshPlutoGrid();
      }
      showDialog(
        // Mostrar confirmación
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

  // _navegarADetalleBaja adaptado
  void _navegarADetalleBaja(PlutoRow row) async {
    final String folioFormateado = row.cells['folio']!.value;
    final int folioOriginal;
    try {
      // Extraer el número del folio formateado 'BICB-XXXX'
      folioOriginal = int.parse(folioFormateado.split('-')[1]);
    } catch (e) {
      print("Error al parsear folio para detalle de baja: $folioFormateado");
      return; // Salir si el formato no es el esperado
    }
    // Buscar en la lista completa por el folio numérico
    final int indexAll = _allBajas.indexWhere((b) => b.folio == folioOriginal);
    if (indexAll == -1) {
      print("Baja con folio $folioOriginal no encontrada para detalle.");
      return; // Salir si no se encuentra
    }
    final BajaBien bajaSeleccionada = _allBajas[indexAll];

    // Navegar a la página de detalle de baja
    final resultado = await Navigator.push<DetalleBajaResult>(
      // Espera DetalleBajaResult
      context,
      MaterialPageRoute(
          builder: (context) =>
              PaginaDetalleBaja(bajaInicial: bajaSeleccionada)),
    );

    // Procesar el resultado al volver
    if (resultado != null && mounted) {
      bool changed = false;
      setState(() {
        if (resultado.action == DetalleBajaResultAction.updated &&
            resultado.baja != null) {
          // Actualizar la baja en la lista completa
          final int currentIndex =
              _allBajas.indexWhere((b) => b.folio == resultado.baja!.folio);
          if (currentIndex != -1) {
            _allBajas[currentIndex] = resultado.baja!;
            changed = true;
          }
        } else if (resultado.action == DetalleBajaResultAction.deleted &&
            resultado.baja != null) {
          // Eliminar la baja de la lista completa
          int initialLength = _allBajas.length;
          _allBajas.removeWhere((b) => b.folio == resultado.baja!.folio);
          if (_allBajas.length < initialLength) changed = true;
        }
        // Si hubo cambios, actualizar la lista filtrada y las filas de PlutoGrid
        if (changed) {
          if (_searchController.text.isNotEmpty) {
            _filteredBajas = _allBajas
                .where((baja) => baja.matchesSearch(_searchController.text))
                .toList();
          } else {
            _filteredBajas = List.from(_allBajas);
          }
          _updatePlutoRows();
        }
      });
      // Refrescar visualmente si hubo cambios
      if (changed) {
        _refreshPlutoGrid();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff6c500),
        centerTitle: true,
        title: Text(
          "ACBMIN: BAJAS DE BIENES", // Título cambiado
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
            onPressed: _exportarAExcel, // Llama a la función adaptada
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
                    flex: 3, // Ocupa más espacio
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          labelText: 'Buscar...',
                          hintText:
                              'Folio, inventario, área...', // Hint adaptado
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
                    label: Text('Nueva Baja'), // Texto del botón cambiado
                    onPressed: _navegarANuevaBaja, // Navega a la nueva página
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 20.w),
                      backgroundColor: Colors.amber, // O el color que prefieras
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PlutoGrid(
                columns: _columns, // Columnas adaptadas
                rows: _rows, // Filas generadas desde _updatePlutoRows
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  _stateManager = event.stateManager;
                  _stateManager!.setShowColumnFilter(
                      false); // Ocultar filtros si no los usas
                },
                onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                  if (event.row != null) {
                    _navegarADetalleBaja(
                        event.row!); // Navega al detalle de baja
                  }
                },
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    enableGridBorderShadow: true,
                    enableRowColorAnimation: true,
                    rowHeight: 45.h, // Altura de fila
                    cellTextStyle:
                        TextStyle(fontSize: 14.sp), // Estilo texto celda
                    columnTextStyle: TextStyle(
                        // Estilo texto cabecera
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  // localeText: PlutoGridLocaleText.spanish(), // Considera añadir localización
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
