import 'package:acbmin_site/platform/descargar_excel.dart';
import 'package:acbmin_site/PaginaHistorial.dart';
import 'package:acbmin_site/PaginaIngresoItem.dart';
import 'package:acbmin_site/PaginaSalidaItem.dart';
import 'package:acbmin_site/entity/Item.dart';
import 'package:acbmin_site/services/almacen_autos/obtener_items.dart';
import 'package:excel/excel.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:acbmin_site/ui/tabla_datos.dart';
import 'package:acbmin_site/ui/responsive.dart';

late List<Item> datosExportacion;

class Paginainventariotaller extends StatelessWidget {
  const Paginainventariotaller({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 800
        ? PaginaInventarioTallerEscritorio()
        : PaginaInventarioTallerEscritorio();
  }
}

class PaginaInventarioTallerEscritorio extends StatefulWidget {
  const PaginaInventarioTallerEscritorio({super.key});

  @override
  State<PaginaInventarioTallerEscritorio> createState() => _PaginState();
}

class _PaginState extends State<PaginaInventarioTallerEscritorio> {
  late Future<List<Item>> listaItems;
  Color colorHoverEntradasSalidas = Colors.black;
  Color colorHoverHistorial = Colors.black;
  Color colorHoverRegresar = Colors.black;
  Color colorHoverActualizar = Colors.black;
  Color colorHoverExportar = Colors.black;
  String? serieSeleccionada = "";
  var scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    listaItems = obtenerItems();
  }

  @override
  Widget build(BuildContext context) {
    var landscape =
        ScreenUtil().orientation == Orientation.landscape ? true : false;

    return Scaffold(
      key: scaffoldkey,
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(color: Colors.amberAccent),
                child: Center(
                  child: Text(
                    "Movimientos",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                )),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => paginaIngresoItem()));
              },
              title:
                  Text("Ingreso de Material", style: TextStyle(fontSize: 18)),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Paginasalidaitem(
                              serie: serieSeleccionada,
                            )));
              },
              title: Text("Salida de Material", style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 64,
            color: Color(0xfff6c500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  onHover: (value) {
                    setState(() {
                      colorHoverRegresar =
                          value == true ? Colors.red : Colors.black;
                    });
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: colorHoverRegresar,
                    size: 28,
                  ),
                ),
                Expanded(child: Container()),
                Text(
                  context.isMobile
                      ? "INVENTARIO"
                      : "ACBMIN: TALLER DE AUTOS–ALMACÉN",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: context.isMobile ? 18 : 25),
                ),
                Expanded(child: Container()),
                InkWell(
                  onTap: () {
                    setState(() {
                      serieSeleccionada = "";
                      listaItems = obtenerItems();
                    });
                  },
                  onHover: (value) {
                    setState(() {
                      colorHoverActualizar =
                          value == true ? Colors.red : Colors.black;
                    });
                  },
                  child: Icon(
                    Icons.refresh_sharp,
                    color: colorHoverActualizar,
                    size: 28,
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 15.0.w)),
                InkWell(
                    onTap: () {
                      scaffoldkey.currentState!.openEndDrawer();
                    },
                    onHover: (value) {
                      setState(() {
                        colorHoverEntradasSalidas =
                            value == true ? Colors.red : Colors.black;
                      });
                    },
                    child: landscape
                        ? Text(
                            "Ingreso y Salida de Material",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorHoverEntradasSalidas,
                                fontSize: 15),
                          )
                        : Icon(Icons.storage)),
                Padding(padding: EdgeInsets.only(left: 20.0.w)),
                InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Paginahistorial()));
                    },
                    onHover: (value) {
                      setState(() {
                        colorHoverHistorial =
                            value == true ? Colors.red : Colors.black;
                      });
                    },
                    child: landscape
                        ? Text(
                            "Historial",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorHoverHistorial,
                                fontSize: 15),
                          )
                        : Icon(Icons.history)),
                Padding(padding: EdgeInsets.only(left: 20.0.w)),
                InkWell(
                    onTap: () {
                      exportarExcel();
                    },
                    onHover: (value) {
                      setState(() {
                        colorHoverExportar =
                            value == true ? Colors.red : Colors.black;
                      });
                    },
                    child: landscape
                        ? Text(
                            "Exportar",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorHoverExportar,
                                fontSize: 15),
                          )
                        : Icon(Icons.download)),
              ],
            ),
          ),
          FutureBuilder(
              future: listaItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  }
                  datosExportacion = snapshot.data!;
                  return Container(
                    height: MediaQuery.sizeOf(context).height - 64,
                    width: double.infinity,
                    child: TablaDatos(
                        alSeleccionar: (fila) {
                          serieSeleccionada = fila['serie'] as String?;
                        },
                        columnas: [
                          ColumnaTabla(titulo: "Artículo", campo: "nombre"),
                          ColumnaTabla(titulo: "Categoria", campo: "categoria"),
                          ColumnaTabla(titulo: "Marca", campo: "marca"),
                          ColumnaTabla(titulo: "Modelo", campo: "modelo"),
                          ColumnaTabla(titulo: "Serie", campo: "serie"),
                          ColumnaTabla(titulo: "Descripcion", campo: "descripcion"),
                          ColumnaTabla(titulo: "Cantidad", campo: "cantidad", numerica: true),
                          ColumnaTabla(titulo: "Vehículo", campo: "modeloAuto"),
                          ColumnaTabla(titulo: "Último Movimiento", campo: "ultMovimiento"),
                          ColumnaTabla(titulo: "Notas", campo: "notas"),
                          ColumnaTabla(titulo: "Localidad", campo: "localidad"),
                          ColumnaTabla(titulo: "Antiguedad", campo: "aging"),
                        ],
                        filas: snapshot.data!.map((item) {
                          return <String, Object?>{
                            "id_prod": item.idProd,
                            "nombre": item.nombre,
                            "categoria": item.categoria,
                            "marca": item.marca,
                            "modelo": item.modelo,
                            "serie": item.serie,
                            "descripcion": item.descripcion,
                            "cantidad": item.cantidad,
                            "modeloAuto": item.modeloAuto,
                            "ultMovimiento": item.ultMovimiento,
                            "notas": item.notas,
                            "localidad": item.localidad,
                            "aging": item.aging,
                          };
                        }).toList()),
                  );
                }
              }),
        ],
      ),
    );
  }
}

class PaginaInventarioTallerMovil extends StatefulWidget {
  const PaginaInventarioTallerMovil({super.key});

  @override
  State<PaginaInventarioTallerMovil> createState() =>
      _PaginaInventarioTallerMovilState();
}

class _PaginaInventarioTallerMovilState
    extends State<PaginaInventarioTallerMovil> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void exportarExcel() {
  var reporte = Excel.createExcel(); // Crear un nuevo archivo Excel
  Sheet sheet = reporte['reporte de inventario'];
  reporte.delete("Sheet1");

  sheet.appendRow([
    TextCellValue("#"),
    TextCellValue("Nombre"),
    TextCellValue("Categoria"),
    TextCellValue("Marca"),
    TextCellValue("Modelo"),
    TextCellValue("Serie"),
    TextCellValue("Descripción"),
    TextCellValue("Cantidad"),
    TextCellValue("Vehículo"),
    TextCellValue("Último Movimiento"),
    TextCellValue("Localidad"),
    TextCellValue("Aging"),
    TextCellValue("Notas"),
  ]);

  for (var celda in datosExportacion) {
    sheet.appendRow([
      TextCellValue(celda.idProd.toString()),
      TextCellValue(celda.nombre.toString()),
      TextCellValue(celda.categoria.toString()),
      TextCellValue(celda.marca.toString()),
      TextCellValue(celda.modelo.toString()),
      TextCellValue(celda.serie.toString()),
      TextCellValue(celda.descripcion.toString()),
      TextCellValue(celda.cantidad.toString()),
      TextCellValue(celda.modeloAuto.toString()),
      TextCellValue(celda.ultMovimiento.toString()),
      TextCellValue(celda.localidad.toString()),
      TextCellValue(celda.aging.toString()),
      TextCellValue(celda.notas.toString()),
    ]);
  }
  descargarExcel(reporte, "Reporte_almacen_automoviles.xlsx"); // excel.save() no descarga en Wasm
}
