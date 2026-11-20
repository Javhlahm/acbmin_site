import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart'; // Para listEquals
import 'package:material_ui/material_ui.dart';
import 'package:acbmin_site/ui/tabla_datos.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:acbmin_site/ui/responsive.dart';

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
  final TextEditingController _searchController = TextEditingController();
  final String? _nombreUsuarioActual = usuarioGlobal?.nombre;

  // Usa Future para cargar los datos iniciales
  late Future<List<Resguardo>> _futureResguardos;
  List<Resguardo> _allResguardos = []; // Almacena los datos una vez cargados
  List<Resguardo> _filteredResguardos = [];
  List<FilaTabla> _rows = [];
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
      _actualizarFilas(); // Actualiza las filas de la tabla
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
        _actualizarFilas(); // Actualiza las filas con los datos filtrados
      });
    }
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

  // _actualizarFilas usa _filteredResguardos
  void _actualizarFilas() {
    _rows = _filteredResguardos.map((resguardo) {
      return <String, Object?>{
          'folio': (resguardo.folioFormateado), // Usa el getter
          'tipo_resguardo': (resguardo.tipoResguardo),
          'numero_inventario': (resguardo.numeroInventario),
          'descripcion': (resguardo.descripcion),
          'area_entrega': (resguardo.areaEntrega),
          'nombre_entrega': (resguardo.nombreEntrega),
          'rfc_entrega': (resguardo.rfcEntrega),
          'area_recibe': (resguardo.areaRecibe),
          'nombre_recibe': (resguardo.nombreRecibe),
          'rfc_recibe': (resguardo.rfcRecibe),
          'observaciones': (resguardo.observaciones ?? ''),
          'capturado_por': (resguardo.capturadoPor ?? ''),
          'fecha_autorizado': (resguardo.fechaAutorizado ?? ''),
          'estatus': (resguardo.estatus ?? 'Pendiente'),
        };
    }).toList();
  }

  // Definición de columnas (sin cambios respecto a la versión anterior)
  final List<ColumnaTabla> _columns = [
    ColumnaTabla(
      titulo: 'Folio',
      campo: 'folio',
      ancho: 110,
      alineacion: TextAlign.center,
      fija: true,
    ),
    ColumnaTabla(
        titulo: 'Tipo',
        campo: 'tipo_resguardo',
        ),
    ColumnaTabla(
        titulo: 'No. Inventario',
        campo: 'numero_inventario',
        ),
    ColumnaTabla(
        titulo: 'Descripción',
        campo: 'descripcion',
        ancho: 350), // Ancho mayor
    ColumnaTabla(
        titulo: 'Área Entrega',
        campo: 'area_entrega',
        ),
    ColumnaTabla(
        titulo: 'Nombre Entrega',
        campo: 'nombre_entrega',
        ),
    ColumnaTabla(
        titulo: 'RFC Entrega',
        campo: 'rfc_entrega',
        ),
    ColumnaTabla(
        titulo: 'Área Recibe',
        campo: 'area_recibe',
        ),
    ColumnaTabla(
        titulo: 'Nombre Recibe',
        campo: 'nombre_recibe',
        ),
    ColumnaTabla(
        titulo: 'RFC Recibe',
        campo: 'rfc_recibe',
        ),
    ColumnaTabla(
        titulo: 'Observaciones',
        campo: 'observaciones',
        ancho: 350), // Ancho mayor
    ColumnaTabla(
        titulo: 'Capturado Por',
        campo: 'capturado_por',
        ),
    ColumnaTabla(
        titulo: 'Fecha Autorizado',
        campo: 'fecha_autorizado',
        ),
    ColumnaTabla(
      titulo: 'Estatus',
      campo: 'estatus',
      ancho: 120,
      alineacion: TextAlign.center,
      celda: (valor, fila) {
        // Renderer para color de fondo según estatus
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
  void _navegarADetalleResguardo(FilaTabla row) async {
    final String folioFormateado = row['folio'] as String;
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
          context.isMobile ? "Resguardos" : "ACBMIN: RESGUARDOS INTERNOS",
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
                  _nombreUsuarioActual!,
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
              padding: const EdgeInsets.only(bottom: 16),
              child: ResponsiveToolbar(
                search: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      labelText: 'Buscar...',
                      hintText: 'Folio, nombre, inventario...',
                      prefixIcon: Icon(Icons.search),
                      border: const OutlineInputBorder()),
                ),
                primaryAction: ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Nuevo Resguardo'),
                  onPressed: _navegarANuevoResguardo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ),
            // Usa FutureBuilder o indicador de carga
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator()) // Muestra carga
                  : _filteredResguardos
                          .isEmpty // Muestra mensaje si no hay datos después de cargar
                      ? Center(child: Text('No se encontraron resguardos.'))
                      : context.isMobile
                          ? ListView.builder(
                              itemCount: _filteredResguardos.length,
                              itemBuilder: (context, index) {
                                final resguardo = _filteredResguardos[index];
                                return MobileRecordCard(
                                  title: resguardo.folioFormateado,
                                  status: resguardo.estatus ?? 'Pendiente',
                                  fields: {
                                    'Tipo': resguardo.tipoResguardo,
                                    'Inventario': resguardo.numeroInventario,
                                    'Descripción': resguardo.descripcion,
                                  },
                                  onTap: () {
                                    final row = _rows.firstWhere((row) =>
                                        row['folio'] ==
                                        resguardo.folioFormateado);
                                    _navegarADetalleResguardo(row);
                                  },
                                );
                              },
                            )
                          : TablaDatos(
                              columnas: _columns,
                              filas: _rows,
                              alDobleToque: (fila) => _navegarADetalleResguardo(fila),
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
} // Fin _PaginaResguardosState
