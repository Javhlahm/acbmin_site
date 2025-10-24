import 'package:acbmin_site/entity/Resguardo.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/PaginaNuevoResguardo.dart';
import 'package:acbmin_site/PaginaDetalleResguardo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart'; // Importar paquete excel
// NO importamos dart:html ni dart:convert aquí

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
    // Lista inicial de ejemplo (igual que antes)
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
    _searchController.addListener(_applyFilter);
    _updatePlutoRows();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

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

    if (!listEquals(_filteredResguardos, tempFiltered)) {
      setState(() {
        _filteredResguardos = tempFiltered;
        _updatePlutoRows();
      });
      _refreshPlutoGrid();
    } else if (query.isEmpty &&
        _filteredResguardos.length != _allResguardos.length) {
      setState(() {
        _filteredResguardos = List.from(_allResguardos);
        _updatePlutoRows();
      });
      _refreshPlutoGrid();
    }
  }

  // Refresca visualmente el PlutoGrid
  void _refreshPlutoGrid() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _stateManager != null) {
        _stateManager!.removeAllRows();
        _stateManager!.appendRows(_rows);
      }
    });
  }

  // Función para simular la recarga de datos
  void _actualizarDatos() {
    setState(() {
      _allResguardos = List.from(_allResguardos);
      _searchController.clear();
      _filteredResguardos = List.from(_allResguardos);
      _updatePlutoRows();
    });
    _refreshPlutoGrid();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tabla actualizada.'), backgroundColor: Colors.blue));
  }

  // *** FUNCIÓN EXPORTAR CORREGIDA ***
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
          TextCellValue('RICB-${folioFormatter.format(resguardo.folio)}'),
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

      // Guardar usando el método del paquete excel
      final String fileName =
          "Resguardos_Internos_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx";
      // El método save() intentará iniciar la descarga en web o guardar en otras plataformas
      // (puede requerir permisos o configuración adicional fuera de web)
      excel.save(fileName: fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Exportando a $fileName...'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      print("Error al exportar a Excel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al exportar a Excel: $e'),
            backgroundColor: Colors.red),
      );
    }
  }
  // *** FIN FUNCIÓN EXPORTAR CORREGIDA ***

  bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  void _updatePlutoRows() {
    final folioFormatter = NumberFormat("0000");
    _rows = _filteredResguardos.map((resguardo) {
      return PlutoRow(
        cells: {
          'folio': PlutoCell(
              value: 'RICB-${folioFormatter.format(resguardo.folio)}'),
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

  void _navegarANuevoResguardo() async {
    final nuevoResguardo = await Navigator.push<Resguardo>(
      context,
      MaterialPageRoute(builder: (context) => const PaginaNuevoResguardo()),
    );

    if (nuevoResguardo != null && mounted) {
      bool changed = false;
      setState(() {
        _allResguardos.add(nuevoResguardo);
        changed = true;
        if (_searchController.text.isNotEmpty) {
          _filteredResguardos = _allResguardos
              .where((resguardo) =>
                  resguardo.matchesSearch(_searchController.text))
              .toList();
        } else {
          _filteredResguardos = List.from(_allResguardos);
        }
        _updatePlutoRows();
      });
      if (changed) {
        _refreshPlutoGrid();
      }
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

  void _navegarADetalleResguardo(PlutoRow row) async {
    final String folioFormateado = row.cells['folio']!.value;
    final int folioOriginal;
    try {
      folioOriginal = int.parse(folioFormateado.split('-')[1]);
    } catch (e) {
      print("Error al parsear folio para detalle: $folioFormateado");
      return;
    }
    final int indexAll =
        _allResguardos.indexWhere((r) => r.folio == folioOriginal);
    if (indexAll == -1) {
      print("Resguardo con folio $folioOriginal no encontrado para detalle.");
      return;
    }
    final Resguardo resguardoSeleccionado = _allResguardos[indexAll];

    final resultado = await Navigator.push<DetalleResguardoResult>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PaginaDetalleResguardo(resguardoInicial: resguardoSeleccionado)),
    );

    if (resultado != null && mounted) {
      bool changed = false;
      setState(() {
        if (resultado.action == DetalleResguardoResultAction.updated &&
            resultado.resguardo != null) {
          final int currentIndex = _allResguardos
              .indexWhere((r) => r.folio == resultado.resguardo!.folio);
          if (currentIndex != -1) {
            _allResguardos[currentIndex] = resultado.resguardo!;
            changed = true;
          }
        } else if (resultado.action == DetalleResguardoResultAction.deleted &&
            resultado.resguardo != null) {
          int initialLength = _allResguardos.length;
          _allResguardos
              .removeWhere((r) => r.folio == resultado.resguardo!.folio);
          if (_allResguardos.length < initialLength) changed = true;
        }
        if (changed) {
          if (_searchController.text.isNotEmpty) {
            _filteredResguardos = _allResguardos
                .where((resguardo) =>
                    resguardo.matchesSearch(_searchController.text))
                .toList();
          } else {
            _filteredResguardos = List.from(_allResguardos);
          }
          _updatePlutoRows();
        }
      });
      if (changed) {
        _refreshPlutoGrid();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // El build queda exactamente igual que en la versión anterior
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
            Expanded(
              child: PlutoGrid(
                columns: _columns,
                rows: _rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  _stateManager = event.stateManager;
                  _stateManager!.setShowColumnFilter(false);
                },
                onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                  if (event.row != null) {
                    _navegarADetalleResguardo(event.row!);
                  }
                },
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    enableGridBorderShadow: true,
                    enableRowColorAnimation: true,
                    rowHeight: 45.h,
                    cellTextStyle: TextStyle(fontSize: 14.sp),
                    columnTextStyle:
                        TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
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
