import 'package:acbmin_site/PaginaHistorial.dart';
import 'package:acbmin_site/PaginaIngresoItem.dart';
import 'package:acbmin_site/PaginaSalidaItem.dart';
import 'package:acbmin_site/entity/Item.dart';
import 'package:acbmin_site/services/almacen_autos/obtener_items.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 30.0.dg),
                  ),
                )),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => paginaIngresoItem()));
              },
              title: Text("Ingreso de Material",
                  style: TextStyle(fontSize: 25.0.dg)),
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
              title: Text("Salida de Material",
                  style: TextStyle(fontSize: 25.0.dg)),
            )
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(15.0, 7.0, 25.0, 7.0).w,
            height: 0.10.sh,
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
                    size: landscape ? 0.07.sh : 0.03.sh,
                  ),
                ),
                Expanded(child: Container()),
                Text(
                  "ACBMIN: TALLER DE AUTOS--ALMACÉN",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0.dg),
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
                    size: landscape ? 0.07.sh : 0.03.sh,
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
                                fontSize: 15.0.dg),
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
                                fontSize: 15.0.dg),
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
                                fontSize: 15.0.dg),
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
                    height: 0.9.sh,
                    width: double.infinity,
                    child: PlutoGrid(
                        mode: PlutoGridMode.selectWithOneTap,
                        configuration: PlutoGridConfiguration(
                          style: PlutoGridStyleConfig(
                              enableGridBorderShadow: true,
                              enableRowColorAnimation: true),
                        ),
                        onSelected: (event) {
                          serieSeleccionada = event.row!.cells['serie']?.value;
                        },
                        columns: [
                          // PlutoColumn(
                          //   title: "#",
                          //   field: "id_prod",
                          //   type: PlutoColumnType.number(),
                          //   readOnly: true,
                          //   enableColumnDrag: false,
                          // ),
                          PlutoColumn(
                              title: "Artículo",
                              field: "nombre",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Categoria",
                              field: "categoria",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Marca",
                              field: "marca",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Modelo",
                              field: "modelo",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Serie",
                              field: "serie",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Descripcion",
                              field: "descripcion",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Cantidad",
                              field: "cantidad",
                              type: PlutoColumnType.number(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Vehículo",
                              field: "modeloAuto",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Último Movimiento",
                              field: "ultMovimiento",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Notas",
                              field: "notas",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Localidad",
                              field: "localidad",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Antiguedad",
                              field: "aging",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                        ],
                        rows: snapshot.data!.map((item) {
                          return PlutoRow(
                            cells: {
                              "id_prod": PlutoCell(value: item.idProd),
                              "nombre": PlutoCell(value: item.nombre),
                              "categoria": PlutoCell(value: item.categoria),
                              "marca": PlutoCell(value: item.marca),
                              "modelo": PlutoCell(value: item.modelo),
                              "serie": PlutoCell(value: item.serie),
                              "descripcion": PlutoCell(value: item.descripcion),
                              "cantidad": PlutoCell(value: item.cantidad),
                              "modeloAuto": PlutoCell(value: item.modeloAuto),
                              "ultMovimiento":
                                  PlutoCell(value: item.ultMovimiento),
                              "notas": PlutoCell(value: item.notas),
                              "localidad": PlutoCell(value: item.localidad),
                              "aging": PlutoCell(value: item.aging)
                            },
                          );
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
  reporte.save(fileName: "Reporte_almacen_automoviles.xlsx");
}
