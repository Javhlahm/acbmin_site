import 'package:acbmin_site/platform/descargar_excel.dart';
import 'package:acbmin_site/entity/Transaccion.dart';
import 'package:acbmin_site/services/almacen_autos/obtener_transacciones.dart';
import 'package:excel/excel.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:acbmin_site/ui/tabla_datos.dart';
import 'package:acbmin_site/ui/responsive.dart';

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
                  context.isMobile ? "HISTORIAL" : "HISTORIAL DE MOVIMIENTOS",
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
                    size: 28,
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
                                fontSize: 15),
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
                    height: MediaQuery.sizeOf(context).height - 64,
                    width: double.infinity,
                    child: TablaDatos(
                        columnas: [
                          ColumnaTabla(titulo: "Tipo", campo: "tipo"),
                          ColumnaTabla(titulo: "Vale de Almacén", campo: "vale"),
                          ColumnaTabla(titulo: "Requerimiento", campo: "requerimiento"),
                          ColumnaTabla(titulo: "Nombre", campo: "nombre"),
                          ColumnaTabla(titulo: "Descripción", campo: "descripcion"),
                          ColumnaTabla(titulo: "Marca", campo: "marca"),
                          ColumnaTabla(titulo: "Modelo", campo: "modelo"),
                          ColumnaTabla(titulo: "Serie", campo: "serie"),
                          ColumnaTabla(titulo: "Categoria", campo: "categoria"),
                          ColumnaTabla(titulo: "Cantidad", campo: "cantidad", numerica: true),
                          ColumnaTabla(titulo: "Vehículo", campo: "modeloAuto"),
                          ColumnaTabla(titulo: "Placa", campo: "placa"),
                          ColumnaTabla(titulo: "Fecha", campo: "fecha"),
                        ],
                        filas: snapshot.data!.map((trans) {
                          return <String, Object?>{
                            "id_trans": trans.idTrans,
                            "tipo": trans.tipo,
                            "requerimiento": trans.requerimiento,
                            "vale": trans.valeAlmacen,
                            "nombre": trans.nombre,
                            "descripcion": trans.descripcion,
                            "marca": trans.marca,
                            "modelo": trans.modelo,
                            "serie": trans.serie,
                            "categoria": trans.categoria,
                            "cantidad": trans.cantidad,
                            "modeloAuto": trans.modeloAuto,
                            "placa": trans.placa,
                            "fecha": trans.fecha,
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
    TextCellValue("Cantidad"),
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
      TextCellValue(celda.cantidad.toString()),
      TextCellValue(celda.modeloAuto.toString()),
      TextCellValue(celda.placa.toString()),
      TextCellValue(celda.fecha.toString()),
    ]);
  }
  descargarExcel(reporte, "Reporte_almacen_automoviles_Movimientos.xlsx"); // excel.save() no descarga en Wasm
}
