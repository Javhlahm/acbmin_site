import 'dart:convert';

import 'package:acbmin_site/entity/Item.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:http/http.dart' as http;

class Paginainventariotaller extends StatelessWidget {
  const Paginainventariotaller({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 800
        ? PaginaInventarioTallerEscritorio()
        : PaginaInventarioTallerMovil();
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
  String? serieSeleccionada;
  var scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listaItems = obtenerItems();
  }

  @override
  Widget build(BuildContext context) {
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
                    "Transacciones",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
            ListTile(
              onTap: () {},
              title: Text("Ingreso"),
            ),
            ListTile(
              onTap: () {
                dialogoConfirmacionSalida(context, serieSeleccionada);
              },
              title: Text("Salida"),
            )
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(15.0, 7.0, 25.0, 7.0),
            height: MediaQuery.of(context).size.height * 0.10,
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
                    size: 30.0,
                  ),
                ),
                Expanded(child: Container()),
                Text(
                  "ACBMIN: TALLER DE AUTOS--ALMACÉN",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0),
                ),
                Expanded(child: Container()),
                InkWell(
                  onTap: () {
                    setState(() {
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
                    size: 30.0,
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 15.0)),
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
                    child: Text(
                      "Ingreso y Salida de Material",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorHoverEntradasSalidas),
                    )),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                InkWell(
                    onTap: () {},
                    onHover: (value) {
                      setState(() {
                        colorHoverHistorial =
                            value == true ? Colors.red : Colors.black;
                      });
                    },
                    child: Text(
                      "Historial",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorHoverHistorial),
                    )),
                Padding(padding: EdgeInsets.only(left: 20.0)),
                InkWell(
                    onTap: () {},
                    onHover: (value) {
                      setState(() {
                        colorHoverExportar =
                            value == true ? Colors.red : Colors.black;
                      });
                    },
                    child: Text(
                      "Exportar",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorHoverExportar),
                    )),
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
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
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
                          PlutoColumn(
                            title: "#",
                            field: "id_prod",
                            type: PlutoColumnType.number(),
                            readOnly: true,
                            enableColumnDrag: false,
                          ),
                          PlutoColumn(
                              title: "Producto",
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
                              "notas": PlutoCell(value: item.notas)
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

Future<List<Item>> obtenerItems() async {
  var url = Uri.parse("http://89.117.149.126/api/tallerautomotriz/almacen");
//  var url = Uri.parse("http://localhost:8050/tallerautomotriz/almacen");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Item.fromJson(json)).toList();
  } else {
    throw Exception('Error al obtener productos: ${response.statusCode}');
  }
}

dialogoConfirmacionSalida(context, [serie]) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
              "Serie",
              textAlign: TextAlign.center,
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            content: Container(
              height: 200,
              child: Center(
                child: Column(
                  children: [
                    Form(
                        child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(hintText: "Serie"),
                          initialValue: serie,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        ElevatedButton(
                            onPressed: () {}, child: Text("Continuar"))
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ));
}
