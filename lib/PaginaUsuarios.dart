import 'package:acbmin_site/PaginaEditarUsuario.dart';
import 'package:acbmin_site/PaginaNuevoUsuario.dart';
import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/services/usuarios/ObtenerUsuarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

late List<Usuario> datosExportacion;
late Future<List<Usuario>> listaUsuarios;
String? UsuarioSeleccionado = "";

class Paginausuarios extends StatefulWidget {
  @override
  State<Paginausuarios> createState() => _PaginausuariosState();
}

class _PaginausuariosState extends State<Paginausuarios> {
  PaginaUsuarios() {}

  @override
  Widget build(BuildContext context) {
    listaUsuarios = obtenerUsuarios();
    var landscape =
        ScreenUtil().orientation == Orientation.landscape ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ACBMIN-USUARIOS",
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 35.0.dg),
        ),
        backgroundColor: Color(0xfff6c500),
        actions: [
          IconButton(
              padding: EdgeInsets.only(right: 20.0.dg),
              onPressed: () {
                setState(() {
                  listaUsuarios = obtenerUsuarios();
                });
              },
              icon: Icon(
                Icons.refresh,
                size: 30.0,
                color: Colors.black,
              )),
          landscape
              ? InkWell(
                  child: Text(
                    "Nuevo Usuario",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20.0.dg),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Paginanuevousuario()));
                  },
                )
              : IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Paginanuevousuario()));
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.black,
                  )),
          Padding(padding: EdgeInsets.symmetric(horizontal: 10.dg)),
          landscape
              ? InkWell(
                  child: Text(
                    "Editar Usuario",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20.0.dg),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Paginaeditarusuario(
                                  usuarioSeleccionado: UsuarioSeleccionado!,
                                )));
                  },
                )
              : IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Paginaeditarusuario(
                                  usuarioSeleccionado: UsuarioSeleccionado!,
                                )));
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.black,
                  )),
          Padding(padding: EdgeInsets.symmetric(horizontal: 10.dg)),
        ],
      ),
      body: FutureBuilder(
          future: listaUsuarios,
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
                width: 1.sw,
                child: PlutoGrid(
                    mode: PlutoGridMode.selectWithOneTap,
                    configuration: PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                          enableGridBorderShadow: true,
                          enableRowColorAnimation: true),
                    ),
                    onSelected: (event) {
                      UsuarioSeleccionado = event.row!.cells['email']?.value;
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
                          title: "Nombre",
                          field: "nombre",
                          type: PlutoColumnType.text(),
                          readOnly: true,
                          width: .25.sw,
                          enableColumnDrag: false),

                      PlutoColumn(
                          title: "Correo",
                          field: "email",
                          type: PlutoColumnType.text(),
                          readOnly: true,
                          width: .25.sw,
                          enableColumnDrag: false),

                      PlutoColumn(
                          title: "Roles",
                          field: "roles",
                          type: PlutoColumnType.text(),
                          readOnly: true,
                          width: .25.sw,
                          enableColumnDrag: false),
                      PlutoColumn(
                          title: "Estatus",
                          field: "status",
                          type: PlutoColumnType.text(),
                          readOnly: true,
                          width: .25.sw,
                          enableColumnDrag: false),
                    ],
                    rows: snapshot.data!.map((usuario) {
                      return PlutoRow(
                        cells: {
                          "nombre": PlutoCell(value: usuario.nombre),
                          "email": PlutoCell(value: usuario.email),
                          "roles": PlutoCell(value: usuario.roles),
                          "status": PlutoCell(value: usuario.status),
                        },
                      );
                    }).toList()),
              );
            }
          }),
    );
  }
}
