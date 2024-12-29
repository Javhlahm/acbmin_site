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
  num tamanoLogout = 1;
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
              onTap: () {},
              title: Text("Salida"),
            )
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(7.0),
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
                      tamanoLogout = value == true ? 1.15 : 1;
                    });
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.height *
                        0.07 *
                        tamanoLogout,
                  ),
                ),
                Expanded(child: Container()),
                InkWell(
                    onTap: () {
                      scaffoldkey.currentState!.openEndDrawer();
                    },
                    onHover: (value) {
                      setState(() {
                        tamanoLogout = value == true ? 1.15 : 1;
                      });
                    },
                    child: Icon(
                      Icons.menu,
                      size: MediaQuery.of(context).size.height *
                          0.07 *
                          tamanoLogout,
                    ))
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
                        configuration: PlutoGridConfiguration(
                          style: PlutoGridStyleConfig(
                              enableGridBorderShadow: true,
                              enableRowColorAnimation: true),
                        ),
                        columns: [
                          PlutoColumn(
                              title: "#",
                              field: "id_prod",
                              type: PlutoColumnType.number(),
                              readOnly: true,
                              enableColumnDrag: false),
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
