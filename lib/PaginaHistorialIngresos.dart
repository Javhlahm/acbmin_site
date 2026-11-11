import 'package:acbmin_site/services/historial/historial_ingresos.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Solo admin: quién entra al sitio, cuándo, desde dónde y cuándo sale.
class PaginaHistorialIngresos extends StatefulWidget {
  const PaginaHistorialIngresos({super.key});

  @override
  State<PaginaHistorialIngresos> createState() =>
      _PaginaHistorialIngresosState();
}

class _PaginaHistorialIngresosState extends State<PaginaHistorialIngresos> {
  // Periodos que se pueden consultar (días hacia atrás, hoy incluido)
  static const Map<int, String> _periodos = {
    1: 'Hoy',
    7: 'Últimos 7 días',
    30: 'Últimos 30 días',
    90: 'Últimos 90 días',
    365: 'Último año',
  };

  final _buscar = TextEditingController();
  final _fechaHora = DateFormat('dd/MM/yyyy HH:mm');
  final _hora = DateFormat('HH:mm');
  int _dias = 7;
  bool _soloFallidos = false;
  late Future<List<IngresoUsuario>> _historial;

  @override
  void initState() {
    super.initState();
    _cargar();
    _buscar.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _buscar.dispose();
    super.dispose();
  }

  void _cargar() => _historial = obtenerHistorialIngresos(_dias);

  /// Salida: hora de "Cerrar sesión", o el último uso si solo cerró el navegador.
  String _salida(IngresoUsuario i) {
    if (!i.exitoso) return '-';
    if (i.fechaSalida != null) return _formato(i.fechaEntrada, i.fechaSalida!);
    if (i.ultimoUso == null) return 'Sin cierre';
    return 'Sin cierre · último uso ${_formato(i.fechaEntrada, i.ultimoUso!)}';
  }

  /// Solo la hora si fue el mismo día que entró; si no, fecha y hora.
  String _formato(DateTime entrada, DateTime momento) {
    final mismoDia = entrada.year == momento.year &&
        entrada.month == momento.month &&
        entrada.day == momento.day;
    return mismoDia ? _hora.format(momento) : _fechaHora.format(momento);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.isMobile ? 'Ingresos' : 'ACBMIN: HISTORIAL DE INGRESOS',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: context.isMobile ? 20 : 28),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(_cargar),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(context.pagePadding),
        child: Column(
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: context.isMobile ? double.infinity : 380,
                  child: TextField(
                    controller: _buscar,
                    decoration: const InputDecoration(
                      labelText: 'Buscar',
                      hintText: 'Nombre, correo o IP',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                DropdownButton<int>(
                  value: _dias,
                  items: [
                    for (final p in _periodos.entries)
                      DropdownMenuItem(value: p.key, child: Text(p.value)),
                  ],
                  onChanged: (valor) {
                    if (valor == null) return;
                    setState(() {
                      _dias = valor;
                      _cargar();
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Solo intentos fallidos'),
                  selected: _soloFallidos,
                  onSelected: (valor) => setState(() => _soloFallidos = valor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<IngresoUsuario>>(
                future: _historial,
                builder: (context, estado) {
                  if (estado.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (estado.hasError) {
                    return Center(
                        child: Text(estado.error
                            .toString()
                            .replaceFirst('Exception: ', '')));
                  }
                  final filas = estado.data!
                      .where((i) => !_soloFallidos || !i.exitoso)
                      .where((i) => i.coincide(_buscar.text))
                      .toList();
                  if (filas.isEmpty) {
                    return const Center(
                        child: Text('No hay ingresos en este periodo.'));
                  }
                  return context.isMobile
                      ? _lista(filas)
                      : _tabla(filas);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultado(IngresoUsuario i) {
    final color = i.exitoso ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(i.exitoso ? 'Ingreso' : 'Intento fallido',
          style: TextStyle(color: color.shade700, fontSize: 12)),
    );
  }

  Widget _tabla(List<IngresoUsuario> filas) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, limites) => Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: limites.maxWidth < 1040 ? 1040 : limites.maxWidth,
              child: SingleChildScrollView(
                child: DataTable(
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 64,
                  columns: const [
                    DataColumn(label: Text('Entrada')),
                    DataColumn(label: Text('Usuario')),
                    DataColumn(label: Text('Resultado')),
                    DataColumn(label: Text('Salida')),
                    DataColumn(label: Text('IP')),
                    DataColumn(label: Text('Navegador')),
                  ],
                  rows: [
                    for (final i in filas)
                      DataRow(cells: [
                        DataCell(Text(_fechaHora.format(i.fechaEntrada))),
                        DataCell(Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(i.nombre ?? '(correo no registrado)',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(i.email,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                          ],
                        )),
                        DataCell(_resultado(i)),
                        DataCell(Text(_salida(i))),
                        DataCell(Text(i.ip ?? '-')),
                        DataCell(Text(i.navegadorCorto)),
                      ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lista(List<IngresoUsuario> filas) {
    return ListView.builder(
      itemCount: filas.length,
      itemBuilder: (context, n) {
        final i = filas[n];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(i.nombre ?? i.email,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  _resultado(i),
                ]),
                const SizedBox(height: 6),
                Text(i.email, style: const TextStyle(color: Colors.black54)),
                Text('Entrada: ${_fechaHora.format(i.fechaEntrada)}'),
                if (i.exitoso) Text('Salida: ${_salida(i)}'),
                Text('IP: ${i.ip ?? '-'} · ${i.navegadorCorto}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
