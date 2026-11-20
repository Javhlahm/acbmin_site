import 'package:flutter/foundation.dart' show mapEquals;
import 'package:material_ui/material_ui.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

/// Una fila de [TablaDatos]: el valor de cada columna, por su campo.
typedef FilaTabla = Map<String, Object?>;

/// Una columna de [TablaDatos].
class ColumnaTabla {
  const ColumnaTabla({
    required this.titulo,
    required this.campo,
    this.ancho = 200,
    this.numerica = false,
    this.alineacion = TextAlign.start,
    this.fija = false,
    this.celda,
  });

  /// Texto del encabezado.
  final String titulo;

  /// Llave del valor dentro de cada fila.
  final String campo;

  /// Ancho inicial en pixeles (el usuario lo puede cambiar arrastrando el borde).
  final double ancho;

  /// Si es verdadero, al ordenar compara como número y no como texto.
  final bool numerica;

  final TextAlign alineacion;

  /// Columna que se queda fija a la izquierda al desplazarse a los lados.
  final bool fija;

  /// Dibujo a la medida de la celda (por ejemplo, el estatus con color).
  /// Si no se da, se muestra el valor como texto.
  final Widget Function(Object? valor, FilaTabla fila)? celda;
}

/// Tabla de solo lectura con el mismo aspecto que tenía PlutoGrid:
/// encabezado y columnas fijas, ordenar al tocar el título, menú ≡ con
/// ordenar y filtrar, ancho de columna ajustable, fila activa en azul claro
/// y doble toque para abrir el detalle.
///
/// Está hecha con TableView (paquete oficial two_dimensional_scrollables), que solo
/// usa la capa básica de widgets, así que no depende de una versión de Material.
class TablaDatos extends StatefulWidget {
  const TablaDatos({
    super.key,
    required this.columnas,
    required this.filas,
    this.alSeleccionar,
    this.alDobleToque,
    this.altoFila = 45,
    this.altoEncabezado = 45,
    this.estiloCelda = const TextStyle(color: Colors.black, fontSize: 14),
    this.estiloEncabezado = const TextStyle(
        color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
  });

  final List<ColumnaTabla> columnas;
  final List<FilaTabla> filas;

  /// Se llama al tocar una fila (al primer toque, sin esperar).
  final void Function(FilaTabla fila)? alSeleccionar;

  /// Se llama al dar doble toque (o doble clic) en una fila.
  final void Function(FilaTabla fila)? alDobleToque;

  final double altoFila;

  /// Alto del encabezado y de la fila de filtros.
  final double altoEncabezado;
  final TextStyle estiloCelda;
  final TextStyle estiloEncabezado;

  @override
  State<TablaDatos> createState() => _TablaDatosState();
}

class _TablaDatosState extends State<TablaDatos> {
  // Mismos colores que PlutoGrid
  static const _colorBorde = Color(0xFFDDE2EB);
  static const _colorBordeTabla = Color(0xFFA1A5AE);
  static const _colorActivo = Color(0xFFDCF5FF);
  static const _colorIcono = Colors.black26;
  static const _anchoMinimo = 80.0;

  final _desplazamientoVertical = ScrollController();
  final _desplazamientoHorizontal = ScrollController();

  /// Columnas en el orden en que se dibujan: primero las fijas.
  late List<ColumnaTabla> _columnas;

  /// Ancho actual de cada columna, por su campo.
  final Map<String, double> _anchos = {};

  String? _campoOrden;
  bool _ascendente = true;
  bool _mostrarFiltros = false;
  final Map<String, String> _filtros = {};

  /// Fila y columna tocadas por última vez.
  FilaTabla? _filaActiva;
  String? _campoActivo;

  @override
  void initState() {
    super.initState();
    _prepararColumnas();
    // Como PlutoGrid: al abrir, la primera celda queda marcada (solo a la vista)
    if (widget.filas.isNotEmpty && _columnas.isNotEmpty) {
      _filaActiva = widget.filas.first;
      _campoActivo = _columnas.first.campo;
    }
  }

  @override
  void didUpdateWidget(TablaDatos anterior) {
    super.didUpdateWidget(anterior);
    _prepararColumnas();
    // Si la fila activa ya no viene en los datos nuevos, se suelta
    if (_filaActiva != null && !widget.filas.any((f) => _esActiva(f))) {
      _filaActiva = null;
    }
  }

  /// Las páginas pueden volver a armar las filas en cada dibujo, así que se
  /// compara por contenido y no por ser el mismo objeto.
  bool _esActiva(FilaTabla fila) =>
      _filaActiva != null && mapEquals(fila, _filaActiva);

  void _prepararColumnas() {
    _columnas = [
      ...widget.columnas.where((c) => c.fija),
      ...widget.columnas.where((c) => !c.fija),
    ];
    for (final c in _columnas) {
      _anchos.putIfAbsent(c.campo, () => c.ancho);
    }
  }

  @override
  void dispose() {
    _desplazamientoVertical.dispose();
    _desplazamientoHorizontal.dispose();
    super.dispose();
  }

  /// Filas que se ven: las que pasan los filtros, en el orden elegido.
  List<FilaTabla> get _filasVisibles {
    var filas = widget.filas.where((fila) {
      for (final filtro in _filtros.entries) {
        final buscado = filtro.value.trim().toLowerCase();
        if (buscado.isEmpty) continue;
        final valor = (fila[filtro.key] ?? '').toString().toLowerCase();
        if (!valor.contains(buscado)) return false;
      }
      return true;
    }).toList();
    final campo = _campoOrden;
    if (campo != null) {
      final numerica = _columnas.firstWhere((c) => c.campo == campo).numerica;
      filas.sort((a, b) {
        final r = _comparar(a[campo], b[campo], numerica);
        return _ascendente ? r : -r;
      });
    }
    return filas;
  }

  /// Compara dos valores; los vacíos siempre van al final.
  static int _comparar(Object? a, Object? b, bool numerica) {
    final textoA = (a ?? '').toString();
    final textoB = (b ?? '').toString();
    if (textoA.isEmpty || textoB.isEmpty) {
      return textoA.isEmpty ? (textoB.isEmpty ? 0 : 1) : -1;
    }
    if (numerica) {
      final numA = num.tryParse(textoA);
      final numB = num.tryParse(textoB);
      if (numA != null && numB != null) return numA.compareTo(numB);
    }
    return textoA.toLowerCase().compareTo(textoB.toLowerCase());
  }

  /// Al tocar el título: ascendente, luego descendente, luego sin orden.
  void _alternarOrden(String campo) {
    setState(() {
      if (_campoOrden != campo) {
        _campoOrden = campo;
        _ascendente = true;
      } else if (_ascendente) {
        _ascendente = false;
      } else {
        _campoOrden = null;
      }
    });
  }

  void _elegirDelMenu(String campo, String opcion) {
    setState(() {
      switch (opcion) {
        case 'asc':
          _campoOrden = campo;
          _ascendente = true;
        case 'desc':
          _campoOrden = campo;
          _ascendente = false;
        case 'sin_orden':
          _campoOrden = null;
        case 'filtrar':
          _mostrarFiltros = true;
        case 'quitar_filtros':
          _mostrarFiltros = false;
          _filtros.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filas = _filasVisibles;
    final filasFijas = _mostrarFiltros ? 2 : 1;
    final columnasFijas = _columnas.where((c) => c.fija).length;

    // El borde se pinta encima para que la tabla no lo tape
    return Container(
      color: Colors.white,
      foregroundDecoration:
          BoxDecoration(border: Border.all(color: _colorBordeTabla)),
      child: Scrollbar(
        controller: _desplazamientoVertical,
        thumbVisibility: true,
        notificationPredicate: (n) => n.metrics.axis == Axis.vertical,
        child: Scrollbar(
          controller: _desplazamientoHorizontal,
          thumbVisibility: true,
          notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
          child: TableView.builder(
            verticalDetails:
                ScrollableDetails.vertical(controller: _desplazamientoVertical),
            horizontalDetails: ScrollableDetails.horizontal(
                controller: _desplazamientoHorizontal),
            pinnedRowCount: filasFijas,
            pinnedColumnCount: columnasFijas,
            rowCount: filasFijas + filas.length,
            columnCount: _columnas.length,
            columnBuilder: (i) => TableSpan(
              extent: FixedTableSpanExtent(_anchos[_columnas[i].campo]!),
              foregroundDecoration: TableSpanDecoration(
                border: TableSpanBorder(
                  trailing: BorderSide(
                      // La última columna fija lleva una línea más marcada
                      color: i == columnasFijas - 1
                          ? _colorBordeTabla
                          : _colorBorde),
                ),
              ),
            ),
            rowBuilder: (i) {
              final esDato = i >= filasFijas;
              final activa = esDato && _esActiva(filas[i - filasFijas]);
              return TableSpan(
                extent: FixedTableSpanExtent(
                    esDato ? widget.altoFila : widget.altoEncabezado),
                backgroundDecoration: TableSpanDecoration(
                    color: activa ? _colorActivo : Colors.white),
                foregroundDecoration: TableSpanDecoration(
                  border: TableSpanBorder(
                      trailing: BorderSide(
                          color: i == filasFijas - 1
                              ? _colorBordeTabla
                              : _colorBorde)),
                ),
              );
            },
            cellBuilder: (context, vicinity) {
              final columna = _columnas[vicinity.column];
              if (vicinity.row == 0) {
                return TableViewCell(child: _encabezado(columna));
              }
              if (vicinity.row < filasFijas) {
                return TableViewCell(child: _campoFiltro(columna));
              }
              return TableViewCell(
                  child: _celda(columna, filas[vicinity.row - filasFijas]));
            },
          ),
        ),
      ),
    );
  }

  Widget _encabezado(ColumnaTabla columna) {
    final ordenada = _campoOrden == columna.campo;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _alternarOrden(columna.campo),
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      columna.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: widget.estiloEncabezado,
                    ),
                  ),
                  if (ordenada)
                    Icon(
                      _ascendente ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color: Colors.black54,
                    ),
                ],
              ),
            ),
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Opciones de la columna',
          color: Colors.white,
          icon: const Icon(Icons.dehaze, size: 18, color: _colorIcono),
          padding: EdgeInsets.zero,
          onSelected: (opcion) => _elegirDelMenu(columna.campo, opcion),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'asc', child: Text('Ordenar ascendente')),
            const PopupMenuItem(
                value: 'desc', child: Text('Ordenar descendente')),
            if (_campoOrden != null)
              const PopupMenuItem(value: 'sin_orden', child: Text('Quitar orden')),
            const PopupMenuDivider(),
            if (!_mostrarFiltros)
              const PopupMenuItem(value: 'filtrar', child: Text('Filtrar')),
            if (_mostrarFiltros)
              const PopupMenuItem(
                  value: 'quitar_filtros', child: Text('Quitar filtros')),
          ],
        ),
        // Agarradera para cambiar el ancho arrastrando el borde derecho
        MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) => setState(() {
              final nuevo = _anchos[columna.campo]! + d.delta.dx;
              _anchos[columna.campo] = nuevo < _anchoMinimo ? _anchoMinimo : nuevo;
            }),
            child: const SizedBox(width: 6, height: double.infinity),
          ),
        ),
      ],
    );
  }

  Widget _campoFiltro(ColumnaTabla columna) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: TextFormField(
        initialValue: _filtros[columna.campo],
        style: widget.estiloCelda,
        decoration: const InputDecoration(
          isDense: true,
          hintText: 'Filtrar',
          prefixIcon: Icon(Icons.search, size: 16),
          prefixIconConstraints: BoxConstraints(minWidth: 26),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        ),
        onChanged: (texto) => setState(() => _filtros[columna.campo] = texto),
      ),
    );
  }

  Widget _celda(ColumnaTabla columna, FilaTabla fila) {
    final valor = fila[columna.campo];
    final activa = _esActiva(fila) && _campoActivo == columna.campo;
    Widget contenido = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: switch (columna.alineacion) {
        TextAlign.center => Alignment.center,
        TextAlign.right || TextAlign.end => Alignment.centerRight,
        _ => Alignment.centerLeft,
      },
      // La celda tocada lleva borde azul, como en PlutoGrid
      decoration: activa
          ? BoxDecoration(border: Border.all(color: Colors.lightBlue))
          : null,
      child: columna.celda != null
          ? columna.celda!(valor, fila)
          : Text(
              valor?.toString() ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: columna.alineacion,
              style: widget.estiloCelda,
            ),
    );
    if (widget.alDobleToque != null) {
      contenido = GestureDetector(
        onDoubleTap: () => widget.alDobleToque!(fila),
        child: contenido,
      );
    }
    // Listener marca la fila al instante (no espera a saber si habrá doble toque)
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        setState(() {
          _filaActiva = fila;
          _campoActivo = columna.campo;
        });
        widget.alSeleccionar?.call(fila);
      },
      child: contenido,
    );
  }
}
