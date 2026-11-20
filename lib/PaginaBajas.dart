// ... (imports) ...
import 'package:acbmin_site/entity/BajaBien.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/PaginaNuevaBaja.dart';
import 'package:acbmin_site/PaginaDetalleBaja.dart';
import 'package:acbmin_site/services/bajas/obtener_bajas.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:acbmin_site/ui/tabla_datos.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:collection/collection.dart';

class PaginaBajas extends StatefulWidget {
  const PaginaBajas({super.key});

  @override
  State<PaginaBajas> createState() => _PaginaBajasState();
}

class _PaginaBajasState extends State<PaginaBajas> {
  // ... (Variables _searchController, _nombreUsuarioActual, _futureBajas, listas, _isLoading sin cambios) ...
  final TextEditingController _searchController = TextEditingController();
  final String? _nombreUsuarioActual = usuarioGlobal?.nombre;

  late Future<List<BajaBien>> _futureBajas;
  List<BajaBien> _allBajas = [];
  List<BajaBien> _filteredBajas = [];
  List<FilaTabla> _rows = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _futureBajas = _cargarDatosIniciales();
    _searchController.addListener(_applyFilter);
  }

  // ... (_cargarDatosIniciales, _actualizarDatos, _applyFilter sin cambios) ...
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
      _actualizarFilas();
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
        _actualizarFilas();
      });
    }
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

  // Modificar _actualizarFilas para incluir Observaciones
  void _actualizarFilas() {
    _rows = _filteredBajas.map((baja) {
      return <String, Object?>{
          'folio': (baja.folioFormateado),
          'area_baja': (baja.areaBaja),
          'persona_baja': (baja.personaBaja),
          'rfc_baja': (baja.rfcBaja),
          'numero_inventario': (baja.numeroInventario),
          'descripcion': (baja.descripcion),
          'fecha_entrega_activos':
              (baja.fechaEntregaActivos?.toString() ?? ''),
          'capturado_por': (baja.capturadoPor ?? ''),
          'fecha_autorizado':
              (baja.fechaAutorizado?.toString() ?? ''),
          'estatus': (baja.estatus ?? 'Pendiente'),
          'observaciones':
              (baja.observaciones ?? ''), // <-- Añadido
        };
    }).toList();
  }

  // Modificar _columns para añadir la columna Observaciones
  final List<ColumnaTabla> _columns = [
    ColumnaTabla(
      titulo: 'Folio',
      campo: 'folio',
      ancho: 110,
      alineacion: TextAlign.center,
      fija: true,
    ),
    ColumnaTabla(
        titulo: 'Área Baja',
        campo: 'area_baja',
        ),

    ColumnaTabla(
        titulo: 'Persona Baja',
        campo: 'persona_baja',
        ancho: 250),
    ColumnaTabla(
        titulo: 'RFC Baja',
        campo: 'rfc_baja',
        ancho: 150),
    ColumnaTabla(
        titulo: 'No. Inventario',
        campo: 'numero_inventario',
        ancho: 150),
    ColumnaTabla(
        titulo: 'Descripción',
        campo: 'descripcion',
        ancho: 350),
    ColumnaTabla(
        titulo: 'Fecha Entrega Act.',
        campo: 'fecha_entrega_activos',
        ancho: 150),
    ColumnaTabla(
        titulo: 'Capturado Por',
        campo: 'capturado_por',
        ancho: 180),
    ColumnaTabla(
        titulo: 'Fecha Autorizado',
        campo: 'fecha_autorizado',
        ancho: 180),
    ColumnaTabla(
        titulo: 'Observaciones',
        campo: 'observaciones',
        ancho: 350 // Ancho similar a descripción
        ),
    ColumnaTabla(
      // Columna de estatus con renderer (sin cambios)
      titulo: 'Estatus', campo: 'estatus', ancho: 120, alineacion: TextAlign.center,
      celda: (valor, fila) {
        /* ... renderer sin cambios ... */
        Color backgroundColor;
        final String status = valor.toString();
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
                fontSize: 14,
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

  void _navegarADetalleBaja(FilaTabla row) async {
    final String folioFormateado = row['folio'] as String;
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
          context.isMobile ? "Bajas de bienes" : "ACBMIN: BAJAS DE BIENES",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: context.isMobile ? 20 : 25,
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
          const SizedBox(width: 4),
          if (_nombreUsuarioActual != null && context.isDesktop)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Text(
                  _nombreUsuarioActual,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.black),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(context.pagePadding),
        child: Column(
          children: [
            Padding(
              /* ... Barra de búsqueda y botón Nuevo sin cambios ... */
              padding: const EdgeInsets.only(bottom: 16),
              child: ResponsiveToolbar(
                search: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      labelText: 'Buscar...',
                      hintText: 'Folio, inventario, área...',
                      prefixIcon: Icon(Icons.search),
                      border: const OutlineInputBorder()),
                ),
                primaryAction: ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Nueva Baja'),
                  onPressed: _navegarANuevaBaja,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
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
                          : context.isMobile
                              ? ListView.builder(
                                  itemCount: _filteredBajas.length,
                                  itemBuilder: (context, index) {
                                    final baja = _filteredBajas[index];
                                    return MobileRecordCard(
                                      title: baja.folioFormateado,
                                      status: baja.estatus ?? 'Pendiente',
                                      fields: {
                                        'Inventario': baja.numeroInventario,
                                        'Área': baja.areaBaja,
                                        'Descripción': baja.descripcion,
                                      },
                                      onTap: () {
                                        final row = _rows.firstWhere((row) =>
                                            row['folio'] ==
                                            baja.folioFormateado);
                                        _navegarADetalleBaja(row);
                                      },
                                    );
                                  },
                                )
                              : TablaDatos(
                              columnas: _columns,
                              filas: _rows,
                              alDobleToque: (fila) => _navegarADetalleBaja(fila),
                              altoFila: 48,
                              estiloCelda: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              estiloEncabezado: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
