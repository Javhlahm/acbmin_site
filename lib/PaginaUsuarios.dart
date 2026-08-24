import 'package:acbmin_site/PaginaEditarUsuario.dart';
import 'package:acbmin_site/PaginaNuevoUsuario.dart';
import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/services/usuarios/ObtenerUsuarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:acbmin_site/ui/responsive.dart';

late List<Usuario> datosExportacion;
late Future<List<Usuario>> listaUsuarios;
String? UsuarioSeleccionado = "";

class Paginausuarios extends StatefulWidget {
  @override
  State<Paginausuarios> createState() => _PaginausuariosState();
}

class _PaginausuariosState extends State<Paginausuarios> {
  // --- INICIO DE CÓDIGO MODIFICADO ---
  @override
  void initState() {
    super.initState();
    // Se llama a la API aquí en lugar de en el 'build'
    listaUsuarios = obtenerUsuarios();
  }
  // --- FIN DE CÓDIGO MODIFICADO ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.isMobile ? "Usuarios" : "ACBMIN: USUARIOS",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: context.isMobile ? 20 : 28),
        ),
        backgroundColor: Color(0xfff6c500),
        actions: [
          IconButton(
              tooltip: 'Actualizar usuarios',
              onPressed: () {
                // Se refresca la lista llamando a setState
                setState(() {
                  listaUsuarios = obtenerUsuarios();
                });
              },
              icon: Icon(
                Icons.refresh,
                size: 30.0,
                color: Colors.black,
              )),
          !context.isMobile
              ? InkWell(
                  child: Text(
                    "Nuevo Usuario",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Paginanuevousuario()));
                  },
                )
              : IconButton(
                  tooltip: 'Nuevo usuario',
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
          const SizedBox(width: 4),
          !context.isMobile
              ? InkWell(
                  child: Text(
                    "Editar Usuario",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18),
                  ),
                  onTap: () {
                    if (UsuarioSeleccionado!.isEmpty ||
                        UsuarioSeleccionado == null) {
                      return;
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Paginaeditarusuario(
                                  usuarioSeleccionado: UsuarioSeleccionado!,
                                )));
                  },
                )
              : IconButton(
                  tooltip: 'Editar usuario seleccionado',
                  onPressed: () {
                    if (UsuarioSeleccionado!.isEmpty ||
                        UsuarioSeleccionado == null) {
                      return;
                    }
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
          if (context.isDesktop) ...[
            const SizedBox(width: 12),
            Text(
              usuarioGlobal!.nombre!,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(width: 20),
          ],
        ],
      ),
      body: FutureBuilder(
          future: listaUsuarios, // Ahora usa la variable de estado
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
              return SizedBox.expand(
                child: PlutoGrid(
                    mode: PlutoGridMode.selectWithOneTap,
                    configuration: PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                          enableGridBorderShadow: true,
                          enableRowColorAnimation: true),
                    ),
                    onSelected: (event) {
                      setState(() {
                        UsuarioSeleccionado = event.row!.cells['email']?.value;
                      });
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
                          width: context.isMobile ? 150 : .25.sw,
                          enableColumnDrag: false),

                      PlutoColumn(
                          title: "Correo",
                          field: "email",
                          type: PlutoColumnType.text(),
                          readOnly: true,
                          width: context.isMobile ? 200 : .25.sw,
                          enableColumnDrag: false),

                      PlutoColumn(
                          title: "Roles",
                          field: "roles",
                          type: PlutoColumnType.text(),
                          readOnly: true,
                          width: context.isMobile ? 190 : .25.sw,
                          enableColumnDrag: false),
                      PlutoColumn(
                          title: "Estatus",
                          field: "status",
                          type: PlutoColumnType.text(),
                          readOnly: true,
                          width: context.isMobile ? 120 : .25.sw,
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
