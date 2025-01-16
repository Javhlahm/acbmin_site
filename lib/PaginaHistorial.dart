import 'package:acbmin_site/entity/Transaccion.dart';
import 'package:acbmin_site/services/almacen_autos/obtener_transacciones.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

late List<Transaccion> datosExportacion;

class Paginahistorial extends StatefulWidget {
  const Paginahistorial({super.key});

  @override
  State<Paginahistorial> createState() => _PaginahistorialState();
}

class _PaginahistorialState extends State<Paginahistorial> {
  late Future<List<Transaccion>> listaTransacciones;
  Color colorHoverEntradasSalidas = Colors.black;
  Color colorHoverHistorial = Colors.black;
  Color colorHoverRegresar = Colors.black;
  Color colorHoverActualizar = Colors.black;
  Color colorHoverExportar = Colors.black;
  String? serieSeleccionada;
  var scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listaTransacciones = obtenerTransacciones();
  }

  @override
  Widget build(BuildContext context) {
    var landscape =
        ScreenUtil().orientation == Orientation.landscape ? true : false;

    return Scaffold(
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
                  "HISTORIAL DE MOVIMIENTOS",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0.dg),
                ),
                Expanded(child: Container()),
                InkWell(
                  onTap: () {
                    setState(() {
                      listaTransacciones = obtenerTransacciones();
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
              future: listaTransacciones,
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
                        columns: [
                          // PlutoColumn(
                          //   title: "#",
                          //   field: "id_trans",
                          //   type: PlutoColumnType.number(),
                          //   readOnly: true,
                          //   enableColumnDrag: false,
                          // ),
                          PlutoColumn(
                            title: "Tipo",
                            field: "tipo",
                            type: PlutoColumnType.text(),
                            readOnly: true,
                            enableColumnDrag: false,
                          ),
                          PlutoColumn(
                              title: "Vale de Almacén",
                              field: "vale",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                              title: "Requerimiento",
                              field: "requerimiento",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                          PlutoColumn(
                            title: "Nombre",
                            field: "nombre",
                            type: PlutoColumnType.text(),
                            readOnly: true,
                            enableColumnDrag: false,
                          ),
                          PlutoColumn(
                              title: "Descripción",
                              field: "descripcion",
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
                              title: "Categoria",
                              field: "categoria",
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
                              title: "Placa",
                              field: "placa",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),

                          PlutoColumn(
                              title: "Fecha",
                              field: "fecha",
                              type: PlutoColumnType.text(),
                              readOnly: true,
                              enableColumnDrag: false),
                        ],
                        rows: snapshot.data!.map((trans) {
                          return PlutoRow(
                            cells: {
                              "id_trans": PlutoCell(value: trans.idTrans),
                              "tipo": PlutoCell(value: trans.tipo),
                              "requerimiento":
                                  PlutoCell(value: trans.requerimiento),
                              "vale": PlutoCell(value: trans.valeAlmacen),
                              "nombre": PlutoCell(value: trans.nombre),
                              "descripcion":
                                  PlutoCell(value: trans.descripcion),
                              "marca": PlutoCell(value: trans.marca),
                              "modelo": PlutoCell(value: trans.modelo),
                              "serie": PlutoCell(value: trans.serie),
                              "categoria": PlutoCell(value: trans.categoria),
                              "cantidad": PlutoCell(value: trans.cantidad),
                              "modeloAuto": PlutoCell(value: trans.modeloAuto),
                              "placa": PlutoCell(value: trans.placa),
                              "fecha": PlutoCell(value: trans.fecha)
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

void exportarExcel() {
  var reporte = Excel.createExcel(); // Crear un nuevo archivo Excel
  Sheet sheet = reporte['reporte de Movimientos'];
  reporte.delete("Sheet1");

  sheet.appendRow([
    TextCellValue("#"),
    TextCellValue("Tipo"),
    TextCellValue("Requerimiento"),
    TextCellValue("Vale de Almacén"),
    TextCellValue("Nombre"),
    TextCellValue("Descripción"),
    TextCellValue("Marca"),
    TextCellValue("Modelo"),
    TextCellValue("Serie"),
    TextCellValue("Categoría"),
    TextCellValue("Vehículo"),
    TextCellValue("Placa"),
    TextCellValue("Fecha")
  ]);

  for (var celda in datosExportacion) {
    sheet.appendRow([
      TextCellValue(celda.idTrans.toString()),
      TextCellValue(celda.tipo.toString()),
      TextCellValue(celda.requerimiento.toString()),
      TextCellValue(celda.valeAlmacen.toString()),
      TextCellValue(celda.nombre.toString()),
      TextCellValue(celda.descripcion.toString()),
      TextCellValue(celda.marca.toString()),
      TextCellValue(celda.modelo.toString()),
      TextCellValue(celda.serie.toString()),
      TextCellValue(celda.categoria.toString()),
      TextCellValue(celda.modeloAuto.toString()),
      TextCellValue(celda.placa.toString()),
      TextCellValue(celda.fecha.toString()),
    ]);
  }
  reporte.save(fileName: "Reporte_almacen_automoviles_Movimientos.xlsx");
}
